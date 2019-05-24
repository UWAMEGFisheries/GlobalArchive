##  ----
#' ga.query.pattern function
#'
#' Query by pattern name \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export
ga.query.pattern<-function(pattern){
  q='{"filters":[{"name":"name","op":"like","val":"%pattern%"}]}'  
  q<-str_replace_all(q,"pattern",pattern)
}