########################################################################################################################################################
#' @ Function name: bundle_split
#' @ Purpose: Splits completed, cleaned extraction sheet into bundle-specific subset files ready to be uploaded to the research database
#' @ Input datasets: csv-format result from previous data-cleaning scripts
#' @ Input arguments: bundle_ids, variables containing conditional info to split, values forming splitting conditions
#' @ Outputs: a list with two elements: 
#'    1. bundle_<bundle_id>.csv = subsetted csv file(s); 
#'    2. success_text = description of bundle-file(s) saved, with row count(s)
#' @ Author: Steph Zimsen
#' @ Date Submitted: 2021-12-15
#' @ Notes: Function is a downstream component in workflow to prep extracted data for upload: clean and validate extracted data found in IHME-standard templated xlsm format, and subset into csv files which are ready to upload to IHME's epi-database.
#' Files of extracted data often contain info to be assigned to more than one epi-db bundle (such as all-ages and age-specific rows), whereas data can only be uploaded to one bundle (either all-ages or age-specific).
#' So the extraction file must be split into bundles, following logical rules which correspond to a bundle definition.
########################################################################################################################################################
## Load packages
pacman::p_load(data.table, dplyr, stringr, readr)

# TODO delete custom inputs here -- if they work in `save_report` script!
# ## Bundle-splitting arguments
# # USER enter bundle IDs, bundle names, & subsetting criteria
# bundle_args <- data.table(
#   bundle_id = c("6362", "6359", "6365", "6638"),
#   bundle_name = c("leprosy_cases", "leprosy_cases_grade_2", 
#                   "leprosy_cure_rate", "leprosy_age_split"),
#   splitting_criteria = c('!is.na(nid)', 
#                       'severity == "G2DN"', 
#                       'measure == "remission"',
#                       'as.numeric(age_start) > 2 | as.numeric(age_end) < 80')
# )
# # (selecting all rows is operationalized by selecting rows with non-null NIDs)
## end of user-entered parameters

## Bundle-splitting function
split_bundles <- function(dt, bundle_id, splitting_criteria) {
  for(s in splitting_criteria){
    dt <- dt[eval(parse(text = s))]
  }
  return(dt)
}


## Apply the `split_bundles` function to all rows of the args table
split_list <- mapply(split_bundles, MoreArgs=list(dt =dt), bundle_id = bundle_args$bundle_id, splitting_criteria = bundle_args$splitting_criteria)


## Parse, separate, label, and report on the output of `split_list` function
# Initialize outputs
success_text <- list()  # if inside for-loop, only latest message retained

for (i in 1:nrow(bundle_args)){
  dt <- as.data.table(split_list[1:60,i])
  # Assign filtered dataset to new dt named for its bundle_id
  assign(paste0("bundle_", bundle_args[i,bundle_id]), dt)
  # Write success message
  success_text[[i]] <- paste("You have", nrow(dt), "observations in", bundle_args[i, bundle_name], "bundle as bundle_id =", bundle_args[i,bundle_id]) 
  print(success_text[i])

  # return(list(data = dt))  # return statement breaks the loop! 

  # Save bundle-specific ubsets
  # TODO`write_csv` statement works! but ...
  #    commenting it out bc no point saving it during testing
  
  # write_csv(dt, file.path(source_dir, 
  #                         paste0("bundle_", bundle_args[i,bundle_id],".csv")))
} 


# The other functions use `return` to collect output -- 
#   data and text --
# but all relevant info here is available outside the for-loop,
# and I can't get the multiple results to not overwrite themselves 
#   inside the for-loop! 
# To set up this script to feed the `save_report` script,
# try this:
output_list <- list(data = objects(pattern = "bundle_6"),
                    success_text = success_text)


#####
## TODO either verify that above `list` outside the for-loop will do,
##    or fix the inside-the-loop problems (message text; return statement)
## 
## TODO maybe -- move "save" step to `save_report.R` script?
##    since data are assigned to named objects
##
## DONE
## Make script more consistent with rest of team's functions:
##   [✔] move "custom" input data to `save_report` script; 
##   [✔] write & implement "success" messages;
##   [?]  MAYBE DONE? output results (data & messages) to `save_report` script
##
## [✔] Add success message
## [✔] Add a line to save files 

# end
