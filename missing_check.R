########################################################################################################################################################
#' @ Function name: missing_check
#' @ Purpose: Screen for potential missingness
#' @ Inputs: dt = data table you are screening; vars_check = character vector of column names to check for missingness
#' @ Outputs: A list with three elements: 
#' dt = the data table you started with; error_rows = all rows flagged with errors; error_text = all error text that was printed
#' @ Author: Rose Bender
#' @ Date Submitted: 2021-12-14
#' @ Notes: 
########################################################################################################################################################
## Load packages
pacman::p_load(data.table)

## Set up inputs
dt <- as.data.table(read.xlsx(paste0("/ihme/homes/rbender1/leprosy_extracted_Wkly-Epi-Rcrd_GBD2019.xlsx")))

## Sample vars to check
vars_check <- c("age_start", "age_end", "sex")

## Helper function
whats_missing <- function(x){
  is.na(x) | is.null(x) | x == ""
}

## Main function
missing_check <- function(dt, vars_check){
  # Initialize outputs
  error_rows <- list()
  error_text <- list()
  # For each column of interest, identify rows that do not meet criteria
  for(v in vars_check){
    dt[, missing_check := 0]
    dt[whats_missing(get(v)), missing_check := 1]
    # Print and save your error statements
    if(any(dt$missing_check == 1)){
      error_text[[v]] <- paste("You have", nrow(dt[missing_check == 1]), "observations with missing values of", v, "in these rows:", paste(which(dt$missing_check == 1), collapse = ", "))
      print(error_text[[v]])
    } 
    # Save your error rows
    error_rows[[v]] <- copy(dt[missing_check == 1])
  }
  dt$missing_check <- NULL
  return(list(data = dt,
              error_rows = error_rows, 
              error_text = error_text))
}

# END
                  