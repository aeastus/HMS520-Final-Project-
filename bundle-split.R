########################################################################################################################################################
#' @ Function name: bundle_split
#' @ Purpose: Splits completed, cleaned extraction sheet into bundle-specific subset files ready to be uploaded to the research database
#' @ Input datasets: csv-format result from previous data-cleaning scripts
#' TODO @ Input arguments: var_1 = Variable 1, var_2 = Variable 2, var_3 = Variable 3
#'TODO @ Outputs: TODO output_1 = Output 1
#' @ Author: Steph Zimsen
#' @ Date Submitted: 2021-12-17
#' @ Notes: Function is a downstream component in workflow to prep extracted data for upload: clean and validate extracted data found in IHME-standard templated xlsm format, and subset into csv files which are ready to upload to IHME's epi-database.
#' Files of extracted data often contain info to be assigned to more than one epi-db bundle (such as all-ages and age-specific rows), whereas data can only be uploaded to one bundle (either all-ages or age-specific).
#' So the extraction file must be split into bundles, following logical rules which correspond to a bundle definition.
########################################################################################################################################################
rm(list=ls())

## Load required libraries (base-R only)
### USER enter needed packages into list below
packages <- c("tidyverse", "readxl")
# TODO cut tidyverse to minimum-- what else does the script need?
# need dplyr, strngr, readr &| readxl, ...

### Load if installed; if not, install & then load
sapply(packages, function(x) {
        require(x, character.only = TRUE) || {
            install.packages(x, dependencies = TRUE);
            library(x, character.only = TRUE)
            }
        }
)

## User-entered arguments

# USER enter the filepath for the input dataset and the filename
# TODO: set up path & name as output of a previous controller script
inputdir       <- "FILEPATH"
input_filename <- "leprosy_extracted_Wkly-Epi-Rcrd_GBD2019.xlsx"

# USER enter the target folder to store the saved, upload-ready bundle-specific datasets -- it should contain sub-folders named as just the bundle_id number
outdir <- file.path("FILEPATH/leprosy")  # default for pilot dataset


## Bundle info

## USER enter needed bundle_ids
bundle_ids <- c("6362", "6638", "6359", "6365")  # don't rly need these here!

## Subsetting by numeric ranges
## Need column names and allowed numerical ranges to subset bundles by quantitative fields

    # for one-at-a-time testing:
## bundle_id `6638` - bundle_name `"leprosy_age_split"`

# # USER enter name of numerical variable containing lower range limit
# low_var <- "age_start"    # NOPE
                            # that doesn't get treated as a variable name later
# # USER enter name of numerical variable containing upper range limit
# upp_var <- data_in$age_end    # NOPE that gets the whole variable column
#
    # syntax is off to alias a column name and have it work as a variable
    # TODO fix syntax!!!
    # OTOH maybe don't need to vectorize this bc only age-splitting takes numerical criertia, for this example
    # (and only other use case I know of is its counterpart, an all-ages bundle)

# USER enter minimum value for lower range limit
var_min <-  2
# USER enter maximum value for upper range limit
var_max <- 79
# these work!

## Subsetting by text categories
# Need column names and allowed text lists to subset bundles by non-numeric fields

## for bundle_id `6359` - bundle_name `"leprosy_cases_wer_grade_2"`

# # USER enter name of categorical variable
# category_var <- "severity"  # NOPE same syntax problem as above
    # TODO solve syntax problem here

# USER enter needed level(s) of categorical variable
var_levels <- "G2DN"

#########################################

## Get input data
# if not importing csv from upstream pipeline scripts,
#   add a way to drop row 2 if taking in raw dataset instead of cleaned data
data_in <- read_excel(file.path(inputdir, input_filename)) %>%
      filter(str_detect(nid, "^Found", negate = TRUE))  # which also drops NAs

# # if importing cleaned csv from upstream pipeline scripts
# data_in <- read_csv(file.path(inputdir, input_filename))


## Arguments constructed from user input
## Bundle-splitting logic

# Full dataset bundle
# Keep all rows (drop blank rows - use rows without NID)
bundle_6362 <- data_in %>% filter(!(is.na(nid)))

# Age-specific bundle
# Keep rows with incomplete age ranges, starting >2y old or ending <79y old
bundle_6638 <- data_in %>%  filter(as.numeric(age_start) > var_min |
                                   as.numeric(age_end) < var_max)
    # TODO get these hard-coded variable names higher up in the user-entry paramaterization area of the script

# High-severity bundle
# Keep rows with grade-2 disability only
bundle_6359 <- data_in %>% filter(severity == var_levels)

# # Cure-rate bundle
# # Keep rows with remission info only
# bundle_6365 <- data_in %>% filter(category_var == var_levels)
    # TODO solve the same syntax problem here with the alias "category_var"

## Bundle-splitting function
    # TODO vectorized function
    # for vectorizing categorical limits:
# names = c(bundle_id, bundle name, category_var, var_levels)
# 6362, "leprosy_cases", measure, !is.na
# 6359, "leprosy_cases_grade_2", "severity", "G2DN"
# 6365, "leprosy_cure_rate", "measure", "remission"
#
    # Write a function to vectorize over rows and subset per the one-at-a-time pattern
#
    # & backing up a step -- for vectorizing numerical limits:
# names = c(bundle_id, bundle name, low_var, upp_var, var_min, var_max)
# 6638, "leprosy_age_split", "age_start", "age_end", 2, 79
    # but solve syntax of aliasing variable names

## save bundle-specific child files
    # use `save_csv()` for better defaults

################
## NOTES
  ## For extensibility -- A vectorized function would be better, executing the filtering logic for each bundle as it gets to it.
  ## Parameters would be better as a table, then:
    #  bundle_id     human-readable_name     category_var     var_levels
    #  6362,leprosy_cases_wer_extraction, measure, !is.na
    #  6362, leprosy_cases_wer_extraction, severity, G2DN
    #  6365,leprosy_proportions_wer_cure_rate, measure, remission

