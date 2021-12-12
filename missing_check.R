########################################################################################################################################################
#' @ Function name: missing_check
#' @ Purpose: Screen for potential missingness
#' @ Inputs: var_1 = Variable 1, var_2 = Variable 2, var_3 = Variable 3
#' @ Outputs: output_1 = Output 1
#' @ Author: Rose Bender
#' @ Date Submitted: 2021-10-21
#' @ Notes: 
########################################################################################################################################################
## Load packages
pacman::p_load(data.table)

dt <- data.table(var_1 = c("", NA, "c", "c"))

whats_missing <- function(x){
  is.na(x) | is.null(x) | x == ""
}

missing_check <- function(dt, vars_check){
  dt[, missing_check := lapply(.SD, whats_missing), .SDcols = vars_check]
  if(any(dt$missing_check)){
    stop(paste("You have missing values. Check these rows:", paste(which(dt$missing_check == TRUE), collapse = ", ")))
  } else {
    print("Missingness screening complete, no missingness found!")
  }
  dt$missing_check <- NULL
  return(dt)
}
                  