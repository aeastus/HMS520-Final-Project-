########################################################################################################################################################
#' @ Function name: write_outputs
#' @ Purpose: Write out the result of all your data checks
#' @ Inputs: list = list of the results of all your checks, output_dir = directory to save, name = vector of names of checks performed
#' @ Outputs: No function outputs to note. Saves .xlsx files of rows with errors and .txt file of error reports
#' @ Author: Rose Bender
#' @ Date Submitted: 2021-12-14
#' @ Notes: 
########################################################################################################################################################

## Function to save the outputs of your check
write_outputs <- function(list, output_dir, name){
  all_rows_with_errors <- rbindlist(list[["error_rows"]])
  all_rows_with_errors <- all_rows_with_errors[!duplicated(all_rows_with_errors)]
  if(nrow(all_rows_with_errors > 0)) write.xlsx(all_rows_with_errors, paste0(output_dir, name, ".xlsx"))
  error_text <- list[["error_text"]]
  cat(paste(error_text), sep = "\n")
  write.table(error_text, paste0(output_dir, name, ".txt"))
}
