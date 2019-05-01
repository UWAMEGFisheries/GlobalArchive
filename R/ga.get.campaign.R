##  ----
#' ga.get.campaign function
#'
#' Function that gets campaign from  \code{\link{GlobalArchive}}
#'
#' @param api_token api_token
#' 
#'
#' @return null
#'
#' @examples
#'
#' @export
ga.get.campaign <- function(api_token, campaign_id) {
  return(ga.get(sprintf(API_ENDPOINT_CAMPAIGN_DETAIL, campaign_id), API_USER_TOKEN))
}
