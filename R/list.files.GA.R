##  ----
#' list.files.GA function
#'
#' Function that lists campaign objects from \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#' list.files.GA()
#'
#' @export
list.files.GA<-function(pattern) {
  list.files(path=download.dir, 
             recursive=T,
             pattern=pattern,
             full.names=T)
}