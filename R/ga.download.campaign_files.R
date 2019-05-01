##  ----
#' ga.download.campaign_files function
#'
#' Function that downloads campaign_files from  \code{\link{GlobalArchive}}
#'
#' @param api_token api_token
#' 
#' @param campaign_files campaign_files
#' 
#' @param save_path api_token
#'
#' @return prints output
#'
#' @examples
#'
#' @export

ga.download.campaign_files <- function(api_token, campaign_files, save_path, match=NULL, exclude=NULL) {
  start_time <- Sys.time()
  ga.print(paste0("Downloading files | matching: '",match,"' | excluding: '", exclude,"'"))
  nfiles = 0
  # get filtered list
  if(!is.null(exclude)) {
    campaign_files <- campaign_files[-grep(exclude, campaign_files$name), ]
  }
  if(!is.null(match)) {
    campaign_files <- campaign_files[grep(match, campaign_files$name), ]
  }
  
  # download files to directory
  if (length(campaign_files)) {
    nfiles = nrow(campaign_files)
    for (i in 1:nfiles){
      id <- campaign_files[i,"id"]
      save_file_path <- file.path(save_path, campaign_files[i,"name"])
      cat(sprintf("  Saving: '%s'...", save_file_path))
      ga.download.campaign_file(api_token, id, save_file_path)
      campaign_files[i,"file_path"] = save_file_path
      writeLines("...Done")
    }
  }
  ga.print("Downloaded %i files in %.2f s", nfiles, difftime(Sys.time(),start_time,units="secs"))
  return (campaign_files)
}