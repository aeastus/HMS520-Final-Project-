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
#' @ Notes: Function is a downstream component in workflow to prep extracted data for upload: 
#' clean and validate extracted data found in IHME-standard templated xlsm format, and subset into csv files which are ready to upload to IHME's epi-database.
#' Files of extracted data often contain info to be assigned to more than one epi-db bundle (such as all-ages and age-specific rows), 
#' whereas data can only be uploaded to one bundle (either all-ages or age-specific).
#' So the extraction file must be split into bundles, following logical rules which correspond to a bundle definition.
########################################################################################################################################################
## Load packages
pacman::p_load(data.table, dplyr, stringr, readr)

## Bundle-splitting child function
split_child <- function(dt, splitting_criteria) {
  for(s in splitting_criteria){
    dt <- dt[eval(parse(text = s))]
  }
  return(dt)
}

## Bundle splitting parent function 
bundle_split <- function(dt, bundle_args, output_dir){
  # Apply the child funciton over each bundle you want to split
  split_list <- mapply(split_child, MoreArgs=list(dt = dt), splitting_criteria = bundle_args$splitting_criteria)
  # Initialize outputs
  error_text <- list()
  dt_list <- list()
  # Create output directory
  output_dir <- paste0(output_dir, "/split_bundles/")
  dir.create(output_dir, showWarnings = FALSE)
  for (i in 1:nrow(bundle_args)){
    # Separate out each data table from the matrix output
    dt_tmp <- as.data.table(split_list[1:60,i])
    dt_list[[paste0("bundle_", bundle_args[i,bundle_id])]] <- dt_tmp
    # Write success message (still called error_text for use later)
    write_csv(dt, file.path(output_dir, paste0("bundle_", bundle_args[i,bundle_id],".csv")))
    error_text[[i]] <- paste("You have", nrow(dt_tmp), "observations in", bundle_args[i, bundle_name], "bundle as bundle_id =", bundle_args[i,bundle_id],
                             "Results saved to", output_dir)
    print(error_text[[i]])
  } 
  return(list(data = dt_list, error_text = error_text))
}

