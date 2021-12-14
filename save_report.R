#' @ Function name: save_report
#' @ Purpose: master script - save output report based on other checks
#' @ Inputs: dt = data table of data of interest, ages = data table of ages for outliering
#' @ Outputs: RMarkdown file
#' @ Notes: : Run check functions for errors/missing data and other problems in the data set. 
########################################################################################################################################################
## Load packages
pacman::p_load(data.table, openxlsx, knitr, rmarkdown)

## Source functions
source_dir <- '~/00_repos/HMS520-Final-Project-/'
source(paste0(source_dir, '/duplicate_check.R'))
source(paste0(source_dir, '/missing_check.R'))
source(paste0(source_dir, '/validate_cause_function.R'))
source(paste0(source_dir, '/outlier_check.R'))

## Read my inputs
input_dir <- '~/'
dt <- as.data.table(read.xlsx(paste0(input_dir, "leprosy_extracted_Wkly-Epi-Rcrd_GBD2019.xlsx")))
dt <- dt[!nid %like% "Found in GHDx"]
ages <- as.data.table(read.xlsx(paste0(input_dir, "gbd_2020_ages.xlsx")))

## Custom inputs
# For validate_check
validation_criteria <- list('age_start >= 0',
                            'pathogen_load %in% c("MB", "PB") | is.na(pathogen_load)',
                            'severity %in% c("G2DN", "G<2D") | is.na(severity)')
# For duplicate_check 
byvars <- c("location_id", "sex", "year_start", "year_end", "nid", "case_name", "measure", "group", "specificity", "age_start", "age_end")
# For missing_check
vars_check <- c("age_start", "age_end", "sex")

## Run all checks
list_of_outputs <- list()
list_of_outputs[["missing_list"]] <- missing_check(dt, vars_check)
list_of_outputs[["duplicate_list"]] <- duplicate_check(dt, byvars)
list_of_outputs[["validation_list"]] <- validation_check(dt, validation_criteria)
list_of_outputs[["outlier_list"]] <- outlier_check(dt, byvars, ages)

## Validation final check
print_outputs <- function(list){
  all_rows_with_errors <-  rbindlist(list[["error_rows"]])
  all_rows_with_errors <- all_rows_with_errors[!duplicated(all_rows_with_errors)]
  print(all_rows_with_errors)
  error_text <- list[["error_text"]]
  cat(paste(error_text), sep = "\n")
  return(list)
}

lapply(list_of_outputs, print_outputs)


#Write a report with the final check into PDF (also Rmarkdown option below)
rmarkdown::render(input = paste0(source_dir, "save_report.R"), output_format = "pdf_document", output_dir = input_dir)

#Report --> Rmarkdown
rmarkdown::render("save_report.R", "rmarkdown")



