##  ----
#' Read txt function
#'
#' Function that reads in txt files and creates a column for filepath to get CampaignID from \code{\link{GlobalArchive}}
#'
#' @param flnm file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export
read_files_txt <- function(flnm) {
  read_tsv(flnm,col_types = cols(.default = "c"))%>% 
    dplyr::mutate(campaign.naming=str_replace_all(flnm,paste(download.dir,"/",sep=""),""))%>%
    tidyr::separate(campaign.naming,into=c("project","campaignid"),sep="/", extra = "drop", fill = "right")%>%
    clean_names%>%
    plyr::rename(., replace = c(opcode="sample"),warn_missing = TRUE)
}