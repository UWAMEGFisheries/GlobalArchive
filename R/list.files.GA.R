#' List files in GA
#'
#' Read in files that match the pattern in your downloads dir
#'
#' @param dat data to be renamed
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