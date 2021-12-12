########################################################################################################################################################
#' @Function name: validate_cause_data_function
#' @ Inputs: input_arg_names = list("unique_group", "severity", "pathogen_load",)
#' input_arg_criteria = list(is.numerical(x, threshold = NA))
#' @ Outputs: TRUE/FALSE
########################################################################################################################################################

install.packages("validate")
Copy_of_leprosy_extracted_Wkly_Epi_Rcrd_GBD2019_3_

#This sets up the criteria to validate the cause-specific columns (as specified in the inputs)
validation_criteria <- validate(unique_group >= 0
                                 , severity >= (G2DN < G2)
                                 , pathogen_load >= 0)
out <- confront(Copy_of_leprosy_extracted_Wkly_Epi_Rcrd_GBD2019_3_, validation_criteria)
summary(out)

byvars <- c("unique_group", "severity", "pathogen_load")
dt <- Copy_of_leprosy_extracted_Wkly_Epi_Rcrd_GBD2019_3_

validation_check <- function(dt, byvars) {
  dt[, num_rows := .N, by = byvars] 
  if(any(dt$num_rows > 0)){
    stop(paste("Review the cause-specific data for accuracy:", paste(which(dt$num_rows > 1), collapse = ", ")))
  } else {
    print("Cause-specfic validation confirmed!")
  }
  dt$num_rows <- NULL
  return(dt)
}

#if further extraction is desired for validation results continue - this will create df of just the validation criteria results
df_out <- as.data.frame(out)

