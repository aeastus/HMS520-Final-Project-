#' @Function name: save_report
#' @ Inputs: validation_check, duplicate_check, missing_check, outlier_check
#' @ Outputs: Output 1 = Output 1 (observations that do not meet criteria), Output 2 = Output 2(new dt that has all rows with errors) Output 3 = output_list[["error_text"]] 
#' 
#' @ Notes: : Final check across all functions for errors/missing data and other problems in the data set. 
########################################################################################################################################################
## Load packages
pacman::p_load(data.table, openxlsx, knitir)

#Validation final check
test_dt <- validation_check(dt, validation_criteria)
all_rows_with_errors <-  rbindlist(test_dt[["error_rows"]])
all_rows_with_errors <- all_rows_with_errors[!duplicated(all_rows_with_errors)]
test_dt[["error_text"]]

#duplicate final check 
test2_dt <- duplicate_check(dt, byvars)
all_rows_with_errors <-  rbindlist(test2_dt[["error_rows"]])
all_rows_with_errors <- all_rows_with_errors[!duplicated(all_rows_with_errors)]
test2_dt[["error_text"]]

#missing final check 
test3_dt <- missing_check(dt, vars_check)
all_rows_with_errors <-  rbindlist(test3_dt[["error_rows"]])
all_rows_with_errors <- all_rows_with_errors[!duplicated(all_rows_with_errors)]
test3_dt[["error_text"]]

#outlier final check 
test4_dt <- outlier_checkk(dt, byvars, release_id, n = 3, flag_zeros = TRUE)
all_rows_with_errors <-  rbindlist(test4_dt[["error_rows"]])
all_rows_with_errors <- all_rows_with_errors[!duplicated(all_rows_with_errors)]
test4_dt[["error_text"]]

#Write a report with the final check into PDF (also Rmarkdown option below)
rmarkdown::render("save_report.R", "pdf_document")

#Report --> Rmarkdown
rmarkdown::render("save_report.R", "rmarkdown")



