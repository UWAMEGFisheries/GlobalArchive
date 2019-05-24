##  ----
#' Read EventMeasure csv function
#'
#' Function that reads in csv files and creates a column for the file name to get CampaignID from EventMeasure database tables
#'
#' @param flnm file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export
ga.read.files_em.csv <- function(flnm) {
  read_csv(flnm,col_types = cols(.default = "c"))%>%
    dplyr::mutate(campaign.naming=str_replace_all(flnm,paste(download.dir,"/",sep=""),""))%>%
    tidyr::separate(campaign.naming,into=c("campaignid"),sep="/", extra = "drop", fill = "right")%>%
    ga.clean.names%>%
    mutate(campaignid=str_replace_all(.$campaignid,c("_Metadata.csv"="")))%>%
    plyr::rename(., replace = c(opcode="sample"),warn_missing = FALSE)
}