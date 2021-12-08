dt <- data.table(var_1 = c("", NA, "c", "c"))

whats_missing <- function(x){
  is.na(x) | is.null(x) | x == ""
}

missing_check <- function(dt, vars_check){
  dt[, missing_check := lapply(.SD, whats_missing), .SDcols = vars_check]
  if(any(dt$missing_check)){
    stop(paste("You have missing values. Check these rows:", paste(which(dt$missing_check == TRUE), collapse = ", ")))
  } else {
    print("Missingness screening complete, no missingness found!")
  }
  dt$missing_check <- NULL
  return(dt)
}
                  