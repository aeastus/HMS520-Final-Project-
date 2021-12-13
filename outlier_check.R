########################################################################################################################################################
#' @ Function name: outlier_check
#' @ Purpose: Screen for potential outliers - extreme values - flag for further screening/potential reextraction
#' @ Inputs: dt = data table you are screening; byvars = character vector, set of variables that you expect will define unique observations, i.e. the variables to group by,
#' n = integer, the number of deviations to flag for outliering at; flag_zeros = boolean defining whether to flag zeros as potential outliers
#' @ Outputs:  A list with five elements: 
#' dt = the data table you started with; error_rows = list of all rows flagged with errors; error_text = list of all error text that was printed;
#' flagged_nids = vector of NIDs flagged with potential outliers; flagged_locations = vector of locations flagged with potential outliers
#' @ Author: Rose Bender
#' @ Date Submitted: 2021-12-14
#' @ Notes: This function screens based on MAD of age-standardized points
########################################################################################################################################################
## Load packages
pacman::p_load(data.table, openxlsx, parallel, pbapply)

## Set up inputs
dt <- as.data.table(read.xlsx(paste0("/ihme/homes/rbender1/leprosy_extracted_Wkly-Epi-Rcrd_GBD2019.xlsx")))
ages <- as.data.table(read.xlsx("/ihme/homes/rbender1/gbd_2020_ages.xlsx"))
byvars <- c("location_id", "sex", "year_start", "year_end", "nid", "case_name", "measure", "group", "specificity")
n <- 3 
flag_zeros <- TRUE

## Helper Function
find_closest <- function(number, vector){
  index <- which.min(abs(number-vector))
  closest <- vector[index]
  return(closest)
}

## Main Function
outlier_check <- function(dt, byvars, ages, n = 3, flag_zeros = TRUE){
  # Initialize outputs
  error_rows <- list()
  error_text <- list()
  
  # Cleanup
  cols_numeric <- c("nid", "location_id", "year_start", "year_end", "age_start", "age_end", "age_demographer", "mean", "lower", "upper", "cases", "sample_size")
  dt[,(cols_numeric) := lapply(.SD, as.numeric), .SDcols = cols_numeric]
  
  # Delete rows with empty means
  dt[is.na(mean) & !is.na(cases), mean := cases/sample_size]
  dt <- dt[!is.na(mean)]
  
  # Get age weights bases on your age data table
  setnames(ages, old = c("age_group_years_start", "age_group_years_end"), new = c("age_start", "age_end"))
  ages[age_start >= 1 , age_end := age_end - 1]
  
  # Round to the closest GBD age start and end 
  dt[, age_start := sapply(age_start, find_closest, vector = unique(ages$age_start))]
  dt[, age_end := sapply(age_end, find_closest, vector = unique(ages$age_end))]
  
  # Sum the age weights across all age groups in the row
  print("Calculating age weights for each row")
  age_weights <- pblapply(1:nrow(dt), function(i){
    # Pull age groups that are row i, and sum age_group_weight_value across age groups.
    summed_row_weight <- sum(ages[age_start >= dt[i, age_start] & age_start < dt[i, age_end]]$age_group_weight_value)
    return(summed_row_weight)
  }, cl = 40)
  dt[, age_group_weight_value := unlist(age_weights)]

  # Create new age-weights for each data source
  byvars <- byvars[!byvars %in% c("age_start", "age_end")]
  dt[, sum := sum(age_group_weight_value), by = byvars] #sum of standard age-weights for all the ages we are using, by location-age-sex-nid, sum will be same for all age-groups and possibly less than one
  if(any(dt$sum > 1)){
    print("Your groups are not uniquely defined. Rerun duplicate_check, and check your byvars. Results from this function will NOT be reliable.")
  }
  dt[, new_weight := age_group_weight_value/sum, by = byvars] #divide each age-group's standard weight by the sum of all the weights in their locaiton-age-sex-nid group

  # Age standardizing per location-year by sex
  # Add a column titled "as_mean" with the age-standardized mean for the location-year-sex-nid
  dt[, as_mean := mean * new_weight] # initially just the weighted mean for that AGE-location-year-sex-nid
  dt[, as_mean := sum(as_mean), by = byvars] # sum across ages within the location-year-sex-nid group, you now have age-standardized mean for that series
  
  if(flag_zeros) dt[as_mean == 0, `:=` (flag_outlier = 1, flag_note = "mean 0")] 
  
  # Log-transform to pick up low outliers 
  dt[as_mean != 0, as_mean := log(as_mean)]
  
  # Calculate median absolute deviation
  dt[as_mean == 0, as_mean := NA] # don't count zeros in median calculations
  by_mad <- c("sex") # Could add super-region later
  dt[, mad := mad(as_mean, na.rm = T), by=by_mad]
  dt[, median := median(as_mean, na.rm = T), by=by_mad]
  
  # Set number of MAD and mark here
  dt[as_mean>((n*mad)+median), `:=` (flag_outlier = 1, flag_note = paste("higher than", n, "MAD above median"))]
  dt[as_mean<(median-(n*mad)), `:=` (flag_outlier = 1, flag_note = paste("lower than", n, "MAD below median"))]
  dt[, c("sum", "new_weight", "as_mean", "median", "mad", "age_group_weight_value") := NULL]
  
  # Write up and save result messages
  error_text[["total"]] <- paste(nrow(dt[flag_note %like% "MAD" & flag_outlier == 1]), "points were flagged as potential outliers with", n, "MAD")
  if (flag_zeros) error_text[["zeroes"]] <- paste(nrow(dt[!flag_note %like% "MAD" & flag_outlier == 1]), "points were flagged as potential outliers with zeroes")
  percent_outliered <- round((nrow(dt[flag_outlier == 1]) / nrow(dt))*100, digits = 1)
  error_text[["percent"]] <- paste("Flagged", percent_outliered, "% of data")
  flagged_nids <- unique(dt[flag_outlier == 1]$nid)
  flagged_locs <- unique(dt[flag_outlier == 1]$ihme_loc_id)
  if(length(flagged_nids) == 0 & length(flagged_locs) == 0) {
    error_text[["nid_location"]] <-"No NIDs or locations to check!"
  } else {
    error_text[["nid_location"]] <- paste("NIDs to check:", paste(flagged_nids, collapse = ", "), "Locations to check:", paste(flagged_locs, collapse = ", "), sep = "\n")
  }
  error_rows[["rows"]] <- copy(dt[flag_outlier == 1])
  
  # Print result messages
  cat(paste(error_text), sep = "\n")
  dt$flag_outlier <- NULL
  return(list(data = dt,
              error_rows = error_rows, 
              error_text = error_text,
              flagged_nids = flagged_nids,
              flagged_locs = flagged_locs))
}

## end
