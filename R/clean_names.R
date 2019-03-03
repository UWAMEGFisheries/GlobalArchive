#' Clean names function
#'
#' Creates lower case names with no special characters in \code{\link{GlobalArchive}}
#'
#' @param dat data to be renamed
#'
#' @return None
#'
#' @examples
#' clean_names()
#'
#' @export
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
