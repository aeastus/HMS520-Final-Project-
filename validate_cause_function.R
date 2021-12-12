########################################################################################################################################################
#' @ Function name: validate_cause_data_function
#' @ Inputs: input_arg_names = list("unique_group", "severity", "pathogen_load",)
#' input_arg_criteria = list(is.numerical(x, threshold = NA))
#' @ Outputs: TRUE/FALSE
########################################################################################################################################################
## Load packages
pacman::p_load(data.table, openxlsx, validate)

## Set up inputs
dt <- as.data.table(read.xlsx(paste0("/ihme/homes/rbender1/leprosy_extracted_Wkly-Epi-Rcrd_GBD2019.xlsx")))

# Sample validation criteria
validation_criteria <- list('age_start >= 0',
                            'pathogen_load %in% c("MB", "PB") | is.na(pathogen_load)',
                            'severity %in% c("G2DN", "G<2D") | is.na(severity)')

validation_check <- function(dt, validation_criteria) {
  for(v in validation_criteria){
    dt[, meet_criteria := 0]
    dt[eval(parse(text = v)), meet_criteria := 1]
    if(any(dt$meet_criteria == 0)){
      print(paste("You have", nrow(dt[meet_criteria == 0]), "observations that do not meet", v, "in these rows:", paste(which(dt$meet_criteria == 0), collapse = ", ")))
    } 
  }
  return(dt)
}
