########################################################################################################################################################
#' @ Function name: save_report
#' @ Purpose: Parent script
#'  Run check functions for errors/missing data and other problems in the data set; split dataset into specific bundle subsets.
#'  Create output folder with reports showing what was done.
#' @ Inputs: two CSVs with script configuration. see .README for more information
#' check_args: csv with fields that define how to apply checks 
#' split_args: csv with fields that define how to split the data into bundles or subsets
#' @ Outputs: a folder in the specified output directory with .xlsx and .txt files showing results of data checks
#' @ Notes:
########################################################################################################################################################
## Define code directory
source_dir <- '~/00_repos/HMS520-Final-Project-/'

## Source functions
functions <- c("duplicate_check.R", "missing_check.R", "validate_check.R", "outlier_check.R", "bundle_split.R", "write_outputs.R")
invisible(sapply(paste0(source_dir, functions), source))

## Load packages
pacman::p_load(data.table, openxlsx, readr, knitr, rmarkdown)

## Read custom input config
check_args <- readRDS(paste0(source_dir, "config.RDS"))

## Load data
dt <- as.data.table(read.xlsx(check_args$data_path, startRow = 2)) # drop description row
dt_headers <- as.data.table(read.xlsx(check_args$data_path, rows = 1, colNames = FALSE)) # read header names
names(dt) <- as.character(dt_headers)
ages <- as.data.table(read.xlsx(check_args$ages_path))

## END INPUTS

## Run all checks
list_of_outputs <- list()
list_of_outputs[["missing_list"]] <- missing_check(dt, check_args$vars_check)
list_of_outputs[["duplicate_list"]] <- duplicate_check(dt, check_args$byvars)
list_of_outputs[["outlier_list"]] <- outlier_check(dt, check_args$byvars, ages)
list_of_outputs[["validation_list"]] <- validation_check(dt, check_args$validation_criteria)

## Write out the results of the checks
invisible(mapply(write_outputs, list_of_outputs, names(list_of_outputs), MoreArgs = list(output_dir = check_args$output_dir)))
print(paste("Outputs are saved to", check_args$output_dir))

## Split the bundle 
bundle_split_list <- bundle_split(dt = dt, bundle_args = check_args$bundle_args, output_dir = check_args$output_dir)

## END
