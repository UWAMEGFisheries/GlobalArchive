##  ----
#' ga.get.campaign.list function
#'
#' Function that gets campaign list from  \code{\link{GlobalArchive}}
#'
#' @param api_token api_token
#' 
#'
#' @return prints list of campaigns
#'
#' @examples
#'
#' @export
ga.get.campaign.list <- function(api_token, f, q="") {
  return(ga.get.object_list(API_ENDPOINT_CAMPAIGN_LIST, API_USER_TOKEN, f=f, q=q))
}
