########################################################################################################################################################
#' @ Script name: config.R
#' @ Purpose: Script that saves a .RDS file of all custom inputs 
#' @ Inputs: all custom inputs
#' @ Outputs: .RDS file
#' @ Notes:
########################################################################################################################################################
## Define code directory
source_dir <- '~/00_repos/HMS520-Final-Project-/'
config_dir <- '~/00_repos/HMS520-Final-Project-/'

## Define data input directory and filepaths
data_path <- "~/leprosy_extracted_Wkly-Epi-Rcrd_GBD2019.xlsx"
ages_path <- "~/gbd_2020_ages.xlsx"

## Set output directory
output_root <- '~/HMS_tmp/'
output_dir <- paste0(output_root, Sys.Date(), "/")
dir.create(output_dir)

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

saveRDS(list(source_dir = source_dir,
             output_dir = output_dir,
             data_path = data_path, 
             ages_path = ages_path,
             vars_check = vars_check,
             byvars = byvars,
             validation_criteria = validation_criteria,
             n = n,
             flag_zeros = flag_zeros,
             bundle_args = bundle_args),
        paste0(config_dir, "/config.RDS"))

## END USER-DEFINED INPUTS