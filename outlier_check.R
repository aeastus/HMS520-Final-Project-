########################################################################################################################################################
#' @ Function name: outlier_check
#' @ Purpose: Screen for potential outliers - extreme values - flag for further screening/potential reextraction
#' @ Inputs: var_1 = Variable 1, var_2 = Variable 2, var_3 = Variable 3
#' @ Outputs: output_1 = Output 1
#' @ Author: Rose Bender
#' @ Date Submitted: 2021-10-21
#' @ Notes: This function screens based on MAD of age-standardized points
########################################################################################################################################################
rm(list=ls())

## Load packages
pacman::p_load(data.table, openxlsx, parallel, pbapply)

## Set up inputs
byvars <- c("location_id", "sex", "year_start", "year_end", "nid", "case_name", "measure", "group", "specificity") # variables used to identify data-series
dt <- as.data.table(read.xlsx(paste0("/ihme/homes/rbender1/leprosy_extracted_Wkly-Epi-Rcrd_GBD2019.xlsx")))
release_id <- 9 
n <- 3 # set the number of deviations to outlier at
flag_zeros <- TRUE

## HELPER FUNCTION
# find the correct age group(s)
find_closest <- function(number, vector){
  index <- which.min(abs(number-vector))
  closest <- vector[index]
  return(closest)
}

outlier_check <- function(dt, byvars, release_id, n = 3, flag_zeros = TRUE){
  ## Cleanup
  cols_numeric <- c("nid", "location_id", "year_start", "year_end", "age_start", "age_end", "age_demographer", "mean", "lower", "upper", "cases", "sample_size")
  dt[,(cols_numeric) := lapply(.SD, as.numeric), .SDcols = cols_numeric]
  
  ## Delete rows with empty means
  dt[is.na(mean) & !is.na(cases), mean := cases/sample_size]
  dt <- dt[!is.na(mean)]
  
  ## Get age weights
  ages <- get_age_metadata(age_group_set_id=19, release_id = release_id) #double check what this age group id coresponds too #changed this for GBD 2020
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
    stop("Your groups are not uniquely defined. Rerun duplicate_check, and check your byvars.")
  }
  dt[, new_weight := age_group_weight_value/sum, by = byvars] #divide each age-group's standard weight by the sum of all the weights in their locaiton-age-sex-nid group

  ## Age standardizing per location-year by sex
  ## Add a column titled "as_mean" with the age-standardized mean for the location-year-sex-nid
  dt[, as_mean := mean * new_weight] # initially just the weighted mean for that AGE-location-year-sex-nid
  dt[, as_mean := sum(as_mean), by = byvars] # sum across ages within the location-year-sex-nid group, you now have age-standardized mean for that series
  
  if(flag_zeros) dt[as_mean == 0, `:=` (flag_outlier = 1, flag_note = "mean 0")] 
  
  ## Log-transform to pick up low outliers 
  dt[as_mean != 0, as_mean := log(as_mean)]
  
  ## Calculate median absolute deviation
  dt[as_mean == 0, as_mean := NA] # don't count zeros in median calculations
  by_mad <- c("sex") # Could add super-region later
  dt[, mad := mad(as_mean, na.rm = T), by=by_mad]
  dt[, median := median(as_mean, na.rm = T), by=by_mad]
  
  ## Set number of MAD and mark here
  dt[as_mean>((n*mad)+median), `:=` (flag_outlier = 1, flag_note = paste("higher than", n, "MAD above median"))]
  dt[as_mean<(median-(n*mad)), `:=` (flag_outlier = 1, flag_note = paste("lower than", n, "MAD below median"))]
  dt[, c("sum", "new_weight", "as_mean", "median", "mad", "age_group_weight_value") := NULL]
  
  ## Print results
  print(paste(nrow(dt[flag_note %like% "MAD" & flag_outlier == 1]), "points were flagged as potential outliers with", n, "MAD"))
  if (flag_zeros) print(paste(nrow(dt[!flag_note %like% "MAD" & flag_outlier == 1]), "points were flagged as potential outliers with zeroes"))
  percent_outliered <- round((nrow(dt[flag_outlier == 1]) / nrow(dt))*100, digits = 1)
  print(paste("Flagged", percent_outliered, "% of data"))
  flagged_nids <- unique(dt[flag_outlier == 1]$nid)
  flagged_locs <- unique(dt[flag_outlier == 1]$ihme_loc_id)
  if(length(flagged_nids) == 0 & length(flagged_locs) == 0) {
    print("No NIDs or locations to check!")
  } else {
    print(paste("NIDs to check:", paste(flagged_nids, collapse = ", ")))
    print(paste("Locations to check:", paste(flagged_locs, collapse = ", ")))
  }
  return(dt)
}

## end
