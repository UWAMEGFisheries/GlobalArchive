##  ----
#' check.api function
#'
#' Function that checks connection to \code{\link{GlobalArchive}}
#'
#' @param API_USER_TOKEN needs user token to connect to \code{\link{GlobalArchive}}
#'
#' @return None
#'
#' @examples
#' check.api()
#'
#' @export
check.api<-function(API_USER_TOKEN){
  if (!exists("API_USER_TOKEN")) {
    args = commandArgs(trailingOnly=TRUE)
    if (length(args)==0) {stop("Not API_USER_TOKEN found. Either set it in the code or pass it as an argument to the script!")}
    else {API_USER_TOKEN <- args[1]}   # get it from command line argument
  }
}


