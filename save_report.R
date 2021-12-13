#' @Function name: save_report
#' @ Inputs: validation_check, duplicate_check, missing_check, outlier_check
#' @ Outputs: Output 1 = Output 1 (observations that do not meet criteria), Output 2 = Output 2(new dt that has all rows with errors) Output 3 = output_list[["error_text"]] 
#' 
#' @ Notes: : Final check across all functions for errors/missing data and other problems in the data set. 
########################################################################################################################################################

#Validation final check
test_dt <- validation_check(dt, validation_criteria)
all_rows_with_errors <-  rbindlist(test_dt[["error_rows"]])
test_dt[["error_text"]]

#duplicate final check 
dt <- as.data.table(read.xlsx(paste0("/Users/allieeastus/Downloads/Copy of leprosy_extracted_Wkly-Epi-Rcrd_GBD2019 (3).xlsx")))
test2_dt <- duplicate_check(dt, byvars)
all_rows_with_errors <-  rbindlist(test2_dt[["error_rows"]])
test2_dt[["error_text"]]

#missing final check 
test3_dt <- missing_check(dt, vars_check)
all_rows_with_errors <-  rbindlist(test3_dt[["error_rows"]])
test3_dt[["error_text"]]

#outlier final check 
test4_dt <- outlier_checkk(dt, byvars, release_id, n = 3, flag_zeros = TRUE)
all_rows_with_errors <-  rbindlist(test4_dt[["error_rows"]])
test4_dt[["error_text"]]


