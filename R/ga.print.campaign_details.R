##  ----
#' ga.print.campaign_details function
#'
#' Function that prints particular campaign info from  \code{\link{GlobalArchive}}
#'
#' @param campaign_details campaign_details
#'
#' @return prints output
#'
#' @examples
#' ga.print.campaign_details()
#'
#' @export
ga.print.campaign_details <- function(campaign_details) {
  campaign_description <- campaign_details["description"]
  campaign_info <- campaign_details$info
  campaign_files <- campaign_details$files
  campaign_platform <- campaign_details$platform
  campaign_project <- campaign_details$project
  campaign_workgroups <- campaign_details$workgroups
  
  ga.print("Campaign: %s (ID=%s)", campaign_details$name, campaign_details$id)
  ga.print("Description: %s", campaign_description)
  ga.print("Method: %s", campaign_platform["name"])
  ga.print("Deployment count: %i", campaign_details$deployment_count)
  ga.print("Project: %s (ID=%s)", campaign_project["name"], campaign_project["id"])
  
  writeLines(sprintf("Shared in %i Collaboration(s):", nrow(campaign_workgroups)))
  # Print Campaign Info fields
  if (length(campaign_workgroups)) {
    for (i in 1:nrow(campaign_workgroups)) {
      writeLines(sprintf("  %s (ID=%s)", campaign_workgroups[i,"name"], campaign_workgroups[i,"id"]))
    }
  }
  
  ga.print("Found info fields:")
  # Print Campaign Info fields
  if (length(campaign_info)) {
    for (i in 1:nrow(campaign_info)) {
      ga.print("  %s: %s", campaign_info[i,"property"]["name"], campaign_info[i,"value"])
    }
  }
  
  ga.print("Found files:")
  # Print names and IDs of available files
  if (length(campaign_files)) {
    for (i in 1:nrow(campaign_files)){
      ga.print("  %s (ID=%s)", campaign_files[i,"name"], campaign_files[i,"id"])
    }
  }
}
