########################################################################################################################################################
#' @ Function name: bundle_split
#' @ Purpose: Splits completed, cleaned extraction sheet into bundle-specific subset files ready to be uploaded to the research database
#' @ Input datasets: csv-format result from previous data-cleaning scripts
#' @ Input arguments: bundle_ids, bundle names, variables containing conditional info to split, values forming splitting conditions
#' @ Outputs: bundle-specific subset file(s)
#' @ Author: Steph Zimsen
#' @ Date Submitted: 2021-12-17
#' @ Notes: Function is a downstream component in workflow to prep extracted data for upload: clean and validate extracted data found in IHME-standard templated xlsm format, and subset into csv files which are ready to upload to IHME's epi-database.
#' Files of extracted data often contain info to be assigned to more than one epi-db bundle (such as all-ages and age-specific rows), whereas data can only be uploaded to one bundle (either all-ages or age-specific).
#' So the extraction file must be split into bundles, following logical rules which correspond to a bundle definition.
########################################################################################################################################################
rm(list=ls())

## Load required libraries (base-R only)
### USER enter needed packages into list below
packages <- c("dplyr", "stringr", "readr", "readxl")
# TODO cut tidyverse to minimum-- what else does the script need?
# need "dplyr", "strngr", "readr" &| "readxl", ...

### Load if installed; if not, install & then load
sapply(packages, function(x) {
  require(x, character.only = TRUE) || {
    install.packages(x, dependencies = TRUE);
    library(x, character.only = TRUE)
  }
}
)

## User-entered arguments

## Filepaths
# USER enter the filepath for the input dataset and the filename
# TODO: set up path & name as output of a previous controller script
inputdir       <- "FILEPATH"
input_filename <- "leprosy_extracted_Wkly-Epi-Rcrd_GBD2019.xlsx"

# USER enter the target folder to store the saved, upload-ready bundle-specific datasets -- it should contain sub-folders named as just the bundle_id number
outdir <- file.path("FILEPATH/leprosy")  # default for pilot dataset

## Bundle-splitting arguments
# Default: the superset bundle of all raw data
# (condition where NID is not blank just removes blank rows)
# (and avoids having to make a flexible function that doesn't need conditions)
bundle_args <- list(
  bundle_id = 6326,
  bundle_name = "leprosy_cases",
  category_vars = c(measure),  # TODO solve syntax error - measure not in envt
  var_levels = !is.na(nid)     # TODO "nid" would not be in envt either then
)

# Towards a vectorized function:
# bundle_name for human readability: promote error prevention & easy correction
# USER enter bundle IDs for machine & human
# & USER enter parameters fwom which to make subsetting rules
bundle_args <- data.frame(
  bundle_id = c("6362", "6359", "6365"),
  bundle_name = c("leprosy_cases", "leprosy_cases_grade_2", 
                  "leprosy_cure_rate"),
  category_vars = c(measure, severity, measure),
  var_levels = c(!is.na(nid), "G2DN", "remission")
)
# problem: this is not easy to enter correctly
# possible implementation: yet another child script, asking for user input to generate the bundle info and the subsetting parameters
# next problem: age_split needs 2 input fields & 2 logical-test values

## end of user-entered parameters


## Bundle-splitting function
# * vectorize over argument d;
# * subset, per the one-at-a-time pattern(s) that work;
# * save with bundle_id in filename and in bundle subdir of cause subfolder

split_bundles <- function(dataset, args) {
  paste0("bundle_", bundle_id) <- dataset %>% 
    filter(category_vars == var_levels)
  # add step to save each, named with bundle_id, 
  # stowed in bundle-specific folder `paste0(outdir, bundle_id)`
}

## Get input data
# if not importing csv from upstream pipeline scripts,
#   add a way to drop row 2 if taking in raw dataset instead of cleaned data
data_in <- read_excel(file.path(inputdir, input_filename)) %>%
  filter(str_detect(nid, "^Found", negate = TRUE))  # which also drops NAs
# TODO maybe -- solve problem: all coltypes guessed as chr due to text in row 2

# # if importing cleaned csv from upstream pipeline scripts
# data_in <- read_csv(file.path(inputdir, input_filename))
# TODO remove "readxl" from package list if reading csv from previous steps


## Split input data into bundles & save to upload-ready location
split_bundles(data_in, bundle_args)


# TODO improvements below
###########
# testing: one-at-a-time steps
# THESE WORK
# 
# Full dataset bundle
# Keep all rows (drop blank rows - operationalize as rows without NID)
bundle_6362 <- data_in %>% filter(!(is.na(nid)))

# Age-specific bundle
# Keep rows with incomplete age ranges, starting >2y old or ending <79y old
bundle_6638 <- data_in %>%  filter(as.numeric(age_start) > var_min |
                                     as.numeric(age_end) < var_max)
# TODO get these hard-coded variable names higher up in the user-entry paramaterization area of the script

# High-severity bundle
# Keep rows with grade-2 disability only
var_levels <- "G2DN"
bundle_6359 <- data_in %>% filter(severity == var_levels)

# # Cure-rate bundle
# # Keep rows with remission info only
bundle_6365 <- data_in %>% filter(measure == "remission")
# TODO solve the same syntax problem here with the alias "category_var"


#####
# TODO Bundle-splitting function
# add capability of taking in 2 filtering arguments 
## Age-split bundle function
#bundle_arg_df <- data.frame(
#   bundle_id = c("6362", "6359", "6365", "6638"),
#   bundle_name = c("leprosy_cases", "leprosy_cases_grade_2", 
#                 "leprosy_cure_rate", "leprosy_age_split"),
#   category_vars = c(measure, severity, measure, c(age_start, age_end)),
#   var_levels = c(!is.na(nid), "G2DN", "remission", c(2, 79))
# )

# if length of bundle_arg_df$category_vars[i] == 2
# then split category_vars 
#     into category_vars[i[1]] == low_var & category_vars[i[2]] == upp_var
# 
# & split var_levels into
#     var_levels[i[1]] == var_min & var_levels[i[2]] == var_max
# then use one-at-a-time example below

## Subsetting by numeric ranges
## Need column names and allowed numerical ranges to subset bundles by quantitative fields
## bundle_id `6638` - bundle_name `"leprosy_age_split"`
# # USER enter name of numerical variable containing lower range limit
# low_var <- "age_start"    # NOPE - not treated as a variable name later
# # USER enter name of numerical variable containing upper range limit
# upp_var <- data_in$age_end    # NOPE that gets the whole variable column
#
# syntax is off to alias a column name and have it work as a variable
# TODO fix syntax!!!
# OTOH maybe don't need to vectorize this bc only age-splitting takes numerical criertia, for this example
# (and only other use case I know of is its counterpart, an all-ages bundle)

# # USER enter minimum value for lower range limit
# var_min <-  2
# # USER enter maximum value for upper range limit
# var_max <- 79
# # these work!
