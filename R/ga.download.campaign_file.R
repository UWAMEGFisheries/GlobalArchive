##  ----
#' ga.download.campaign_file function
#'
#' Function that dowloads particular campaign from  \code{\link{GlobalArchive}}
#'
#' @param api_token api_token
#' 
#' @param id id
#' 
#' @param save_file_path save_file_path
#' 
#'
#' @return prints output
#'
#' @examples
#'
#' @export
ga.download.campaign_file <- function(api_token, id, save_file_path){
  file_endpoint <- sprintf(API_ENDPOINT_CAMPAIGN_FILE, id)
  ga.download.file(api_token, file_endpoint, save_file_path)
}