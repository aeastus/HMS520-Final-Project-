# HMS520-Final-Project-
## Authors: Rose Bender, Allie Eastus, Steph Zimsen
## Autumn quarter 2021

## Summary
HMS 520 final project public repository. This repository includes presentation information, all of the component scripts, and the description of our project. 

## About
The goal of this final project is to create a set of functions to clean validate finished extraction datasets from "by hand" scientific literature systematic review extractions. It performs these key functions:
1) Check for missingness in user-defined columns
2) Check for duplicates, using user-defined expected groupings of unique observations
3) Apply user-specified custom validations
4) Check for potential outlier candidates using Mean Absolute Deviation
5) Split dataset into multiple bundles based on user-specified criteria
6) Writes out a folder with diagnostic .xlsx and .txt files describing the checks that were applied.

The only two scripts you will need to touch are:
1) config.R
2) save_report.R
The rest are child scripts called by save_report.R

## First step: Setting up your config
** config.R is the script that does this. config.R generates config.RDS, which is the config file of a list of all your inputs that is fed into the parent script. Modify the arguments in config.R to fit your use case. Arguments:
* source_dir <- string; directory where your repository is located and from which you source your functions
* config_dir <- string; directory where you save config.RDS
* data_path <- string; full path to where you have your data, must be .xlsx
* ages_path <- string; full path to where you have your GBD age data table (for age-standardizing outliering), must be .xlsx
* output_root <- string; directory where you save your output diagnostic files. creates output_dir, a date-versioned folder in output_root
* vars_check <- character vector; vector of variable names that you want to check for missingness in missing_check
* byvars <- character vector; vector of variable names which define what you expect to be a unique group in duplicate_check and also used in outlier_check
* validation_criteria <- character list; list of criteria used for custom validation in validation_check
* n <- integer; number of deviations to flag for potential outliering, default is 3
* flag_zeros <- boolean; whether to flag zeros for potential outliering (generally T for common causes, F for rare causes)
* bundle_args <- data.table; has three columns where each row corresponds to a bundle that you are splitting out of the parent dataset into its own .csv in bundle_split. 

## Second step: Running the parent script
** save_report.R: This is the parent file. It reads from config.RDS and outputs a set of diagnostic files to your output directory. It runs the child scripts

## The child scripts
The child scripts are launched from save_report.R in this order:
1) missing_check
2) duplicate_check
3) outlier_check
4) validation_check
5) write_outputs
6) bundle_split
Their functions correspond to the numbered descriptions in the "about" section. 
Additional information on inputs and outputs for each function is available in the function headers.
