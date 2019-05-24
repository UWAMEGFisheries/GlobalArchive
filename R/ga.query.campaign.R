##  ----
#' ga.query.campaign function
#'
#' Query by campaign name \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export
ga.query.campaign<-function(campaign){
  q='{"filters":[{"name":"name","op":"eq","val":"Insert campaignID"}]}'
  q<-str_replace_all(q,"Insert campaignID",campaign)
}