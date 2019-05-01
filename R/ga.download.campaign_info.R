##  ----
#' ga.download.campaign_info function
#'
#' Function that downloads particular campaign info from  \code{\link{GlobalArchive}}
#'
#' @param api_token api_token
#' 
#' @param campaign_info campaign_info
#' 
#' @param save_path save_path
#'
#' @return prints output
#'
#' @examples
#'
#' @export
ga.download.campaign_info <- function(api_token, campaign_info, save_path) {
  # campaign_name <- campaign_details$name
  campaign_info <- campaign_info
  file_path <- file.path(save_path, ".info.csv")
  cat("  Saving campaign info...")
  df_info <- data.frame()
  if (length(campaign_info)) {
    for (i in 1:nrow(campaign_info)) {
      df <- data.frame(field=campaign_info[i,"property"]["name"], value=campaign_info[i,"value"], is_filter=campaign_info[i,"property"]["is_filter"])
      df_info <- rbind(df_info,df)
    }
  }
  write.csv(df_info, file_path)
  writeLines("...Done")
}