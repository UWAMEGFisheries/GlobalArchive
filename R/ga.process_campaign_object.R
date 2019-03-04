##  ----
#' process_campaign_object function
#'
#' Function that returns campaign objects from \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#' process_campaign_object()
#'
#' @export
process_campaign_object <- function(object) {
  # Perform another request to the API to get more detailed campaign info
  campaign <- ga.get.campaign(API_USER_TOKEN, object["id"])
  #print(toJSON(campaign, pretty=TRUE))  # show all avialable info
  # Print campaign_info to console
  ga.print.campaign_details(campaign)  # prints details about campaign
  # Download/save campaign files and data
  campaign_path <- file.path(DATA_DIR, campaign$project["name"], campaign$name) # create campaign path
  dir.create(campaign_path, showWarnings = FALSE, recursive=TRUE)             # create campaign dir
  campaign_files = ga.download.campaign_files(API_USER_TOKEN, campaign$files, campaign_path, match=MATCH_FILES)   # download all campaign files
  ga.download.campaign_info(API_USER_TOKEN, campaign$info, campaign_path)     # generate csv file for info
  ga.download.campaign_record(API_USER_TOKEN, campaign, campaign_path)        # generate json file containing campaign record information
}

