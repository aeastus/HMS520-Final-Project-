########################################################################################################################################################
#' @Function name: validate_cause_data_function
#' @ Inputs: input_arg_names = list("name_1", "name_2")
#' input_arg_criteria = list(is.categorical(x, threshold = NA))
#' @ Outputs: TRUE/FALSE
#' 
#' @Function: df <- tibble(var_1 = c("missing", "N/A", "c", "c", "null"))
#'                  missing_data <- c("missing", "N/A", "null")
#'                  df %>% filter(var_1 %in% missing_data)
#'                  df %>% mutate(flag = if_else(var_1 %in% missing_data, "missing", "not missing"))
#'@ Inputs: values that may appear in cells that would be considered missing (NULL, N/A , any IHME specific indicator?)
#'@ Notes: Lines 9-11 can be used to flag missing data Are any blanks that should not be? **Uses tidyverse

########################################################################################################################################################

#' @Function name: save_report
#' @ Inputs: extraction data >%> filter_all(is.na())
#' @ Outputs:Cells that are NA (missing)
#' 
#' if extraction data >%> filter_all(is.na()) {
#'  return nrow(x) }
#' @ Notes: : what errors were found in which rows (does it make sense to subset the data?). Append iterative change-logs until there are no more errors; & save report once 
########################################################################################################################################################
