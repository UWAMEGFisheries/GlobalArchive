##  ----
#' Capitalise function
#'
#' Function to capitalise species names from \code{\link{GlobalArchive}}
#'
#' @param x column to be manipulated
#'
#' @return None
#'
#' @examples
#' capitalise("tEst dATa")
#'
#' @export
capitalise=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))
