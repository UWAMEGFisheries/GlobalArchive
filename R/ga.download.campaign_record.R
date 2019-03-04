##  ----
#' ga.download.campaign_record function
#'
#' Function that dowloads particular campaign record from  \code{\link{GlobalArchive}}
#'
#' @param api_token api_token
#' 
#' @param campaign_details campaign_details
#' 
#' @param save_file_path save_file_path
#'
#' @return prints output
#'
#' @examples
#' ga.download.campaign_record()
#'
#' @export
ga.download.campaign_record <- function(api_token, campaign_details, save_path) {
  file_path <- file.path(save_path, ".record.json")
  # write record to json file
  cat("  Saving campaign record...")
  write(toJSON(campaign_details, pretty=TRUE), file_path)
  writeLines("...Done")
}