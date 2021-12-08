########################################################################################################################################################
#' @ Function name: duplicate_check
#' @ Purpose: Screen for potential duplicates
#' @ Inputs: var_1 = Variable 1, var_2 = Variable 2, var_3 = Variable 3
#' @ Outputs: output_1 = Output 1
#' @ Author: Rose Bender
#' @ Date Submitted: 2021-10-21
#' @ Notes: 
########################################################################################################################################################
rm(list=ls())

## Source shared functions
invisible(sapply(list.files("/share/cc_resources/libraries/current/r/", full.names = T), source))

## Load packages
pacman::p_load(data.table, openxlsx, parallel, pbapply)

## Set up inputs
byvars <- c("location_id", "sex", "year_start", "year_end", "nid", "case_name", "measure", "group", "specificity", "age_start", "age_end") # variables used to identify data-series
dt <- as.data.table(read.xlsx(paste0("/ihme/homes/rbender1/leprosy_extracted_Wkly-Epi-Rcrd_GBD2019.xlsx")))

duplicate_check <- function(dt, byvars){
  dt[, num_rows := .N, by = byvars] #sum of standard age-weights for all the ages we are using, by location-age-sex-nid, sum will be same for all age-groups and possibly less than one
  if(any(dt$num_rows > 1)){
    stop(paste("Your groups are not uniquely defined by the variables you have chosen. Confirm your byvars. Then, check for duplicates in these rows:", paste(which(dt$num_rows > 1), collapse = ", ")))
  } else {
    print("Duplicate screening complete, no duplicates found!")
  }
  dt$num_rows <- NULL
  return(dt)
}

## end
