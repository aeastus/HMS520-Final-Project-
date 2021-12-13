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
## Load packages
pacman::p_load(dplyr, stringr, readr)

## Bundle-splitting arguments
# Default: the superset bundle of all raw data
bundle_args <- list(
  bundle_id = 6326,
  bundle_name = "leprosy_cases",
  splitting_criteria = '!is.na(nid)'
)

# Towards a vectorized function:
# bundle_name for human readability: promote error prevention & easy correction
# USER enter bundle IDs for machine & human
# & USER enter parameters fwom which to make subsetting rules
bundle_args <- data.table(
  bundle_id = c("6362", "6359", "6365"),
  bundle_name = c("leprosy_cases", "leprosy_cases_grade_2", 
                  "leprosy_cure_rate"),
  splitting_criteria = c('!is.na(nid)', 'severity == "G2DN"', 'measure == "remission"')
)
## end of user-entered parameters

## Bundle-splitting function

split_bundles <- function(dt, bundle_id, splitting_criteria) {
  for(s in splitting_criteria){
    dt <- dt[eval(parse(text = s))]
  }
  return(dt)
}

split_list <- mapply(split_bundles, MoreArgs=list(dt =dt), bundle_id = bundle_args$bundle_id, splitting_criteria = bundle_args$splitting_criteria)

for (i in 1:nrow(bundle_args)){
  dt <- as.data.table(split_list[1:60,i])
  assign(paste0("bundle_", bundle_args[i,bundle_id]), dt)
}

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

## TODO
## Add error/success message
## Add a line to save files 