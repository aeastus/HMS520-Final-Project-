########################################################################################################################################################
#' @ Function name: save_report
#' @ Purpose: master script - save output report based on other checks
#' @ Inputs: dt = data table of data of interest, ages = data table of ages for outliering
#' @ Outputs: RMarkdown file
#' @ Notes: Run check functions for errors/missing data and other problems in the data set; split dataset into specific bundle subsets.
########################################################################################################################################################
## Load packages
pacman::p_load(data.table, openxlsx, readr, knitr, rmarkdown)

## Source functions
source_dir <- '~/00_repos/HMS520-Final-Project-/'
functions <- c("duplicate_check.R", "missing_check.R", "validate_check.R", "outlier_check.R", "bundle_split.R", "write_outputs.R")
invisible(sapply(paste0(source_dir, functions), source))

## Set output directory
output_root <- '~/HMS_tmp/'
output_dir <- paste0(output_root, Sys.Date(), "/")
dir.create(output_dir)

## Read my inputs
input_dir <- '~/'
dt <- as.data.table(read.xlsx(paste0(input_dir, "leprosy_extracted_Wkly-Epi-Rcrd_GBD2019.xlsx")))
dt <- dt[!nid %like% "Found in GHDx"]
ages <- as.data.table(read.xlsx(paste0(input_dir, "gbd_2020_ages.xlsx")))

## Custom inputs
# For missing_check
vars_check <- c("age_start", "age_end", "sex")
# For duplicate_check 
byvars <- c("location_id", "sex", "year_start", "year_end", "nid", "case_name", "measure", "group", "specificity", "age_start", "age_end")
# For validate_check
validation_criteria <- list('age_start >= 0',
                            'pathogen_load %in% c("MB", "PB") | is.na(pathogen_load)',
                            'severity %in% c("G2DN", "G<2D") | is.na(severity)')
# For outlier_check
n <- 3 
flag_zeros <- TRUE
# For splitting bundles
bundle_args <- data.table(
  bundle_id = c("6362", "6359", "6365", "6638"),
  bundle_name = c("leprosy_cases", "leprosy_cases_grade_2", 
                  "leprosy_cure_rate", "leprosy_age_split"),
  splitting_criteria = c('!is.na(nid)', 
                         'severity == "G2DN"', 
                         'measure == "remission"',
                         'as.numeric(age_start) > 2 | as.numeric(age_end) < 80')
)

## END USER-DEFINED INPUTS

## Run all checks
list_of_outputs <- list()
list_of_outputs[["missing_list"]] <- missing_check(dt, vars_check)
list_of_outputs[["duplicate_list"]] <- duplicate_check(dt, byvars)
list_of_outputs[["validation_list"]] <- validation_check(dt, validation_criteria)

## Write out the results of the checks
invisible(mapply(write_outputs, list_of_outputs, names(list_of_outputs), MoreArgs = list(output_dir = output_dir)))
print(paste("Outputs are saved to", output_dir))

## Split the bundle 
bundle_split_list <- bundle_split(dt, bundle_args, output_dir)

## END
