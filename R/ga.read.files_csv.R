##  ----
#' Read csv function
#'
#' Function that reads in csv files and creates a column for filepath to get CampaignID from \code{\link{GlobalArchive}}
#'
#' @param flnm file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export

ga.read.files_csv <- function(flnm) {
  read_csv(flnm,col_types = cols(.default = "c"))%>%
    dplyr::mutate(campaign.naming=str_replace_all(flnm,paste(download.dir,"/",sep=""),""))%>%
    tidyr::separate(campaign.naming,into=c("project","campaignid"),sep="/", extra = "drop", fill = "right")%>%
    ga.clean.names%>%
    plyr::rename(., replace = c(opcode="sample"),warn_missing = FALSE)
}