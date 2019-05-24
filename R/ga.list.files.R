##  ----
#' ga.list.files function
#'
#' Function that lists campaign objects from \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export
ga.list.files<-function(pattern) {
  list.files(path=download.dir, 
             recursive=T,
             pattern=pattern,
             full.names=T)
}