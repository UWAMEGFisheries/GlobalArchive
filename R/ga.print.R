##  ----
#' ga.print function
#'
#' Function that prints objects from  \code{\link{GlobalArchive}}
#'
#' @param format format
#' 
#'
#' @return prints output
#'
#' @examples
#'
#' @export
ga.print <- function(format, ...) {
  writeLines(sprintf(format, ...))
}
