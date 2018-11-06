###############################################################################
# General GA tidydata methods
###############################################################################

# Clean names function ----
#TJL - this could be loaded from a repo as function above?
clean_names <- function(dat){
  old_names <- names(dat)
  new_names <- old_names %>%
    gsub("%", "percent", .) %>%
    make.names(.) %>%
    gsub("[.]+", ".", .) %>%
    tolower(.) %>%
    gsub("_$", "", .)
  setNames(dat, new_names)
}
