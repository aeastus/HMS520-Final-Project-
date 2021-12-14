########################################################################################################################################################
#' @ Function name: validate_check
#' @ Purpose: Validate custom tests in your data
#' @ Inputs: dt = data table you are screening; validation_criteria = character vector of logical tests to apply to your variables
#' Example: validation_criteria <- list('age_start >= 0','pathogen_load %in% c("MB", "PB") | is.na(pathogen_load)')
#' @ Outputs: A list with three elements: 
#' dt = the data table you started with; error_rows = list of all rows flagged with errors; error_text = list of all error text that was printed
#' @ Author: Rose Bender & Allie Eastus
#' @ Date Submitted: 2021-12-14
#' @ Notes: 
########################################################################################################################################################
## Load packages
pacman::p_load(data.table, openxlsx)

validation_check <- function(dt, validation_criteria) {
  # Initialize outputs
  error_rows <- list()
  error_text <- list()
  # For each listed validation criteria, identify rows that do not meet criteria and send them to error_rows
  for(v in validation_criteria){
    dt[, meet_criteria := 0]
    dt[eval(parse(text = v)), meet_criteria := 1]
    # Print and save your error statements
    if(any(dt$meet_criteria == 0)){
      error_text[[v]] <- paste("You have", nrow(dt[meet_criteria == 0]), "observations that do not meet", v, "in these rows:", paste(which(dt$meet_criteria == 0), collapse = ", "))
      print(error_text[[v]])
    } 
    # Save your error rows
    error_rows[[v]] <- copy(dt[meet_criteria == 0])
  }
  dt$meet_criteria <- NULL
  return(list(data = dt,
              error_rows = error_rows, 
              error_text = error_text))
}

# END
