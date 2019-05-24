##  ----
#' Read EventMeasure txt function
#'
#' Function that reads in txt files and creates a column for filename to get CampaignID from EventMeasure database tables
#'
#' @param flnm file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export
ga.read.files_em.txt <- function(flnm) {
  read_tsv(flnm,col_types = cols(.default = "c"))%>%
    dplyr::mutate(campaign.naming=str_replace_all(flnm,paste(download.dir,"/",sep=""),""))%>%
    tidyr::separate(campaign.naming,into=c("campaignid"),sep="/", extra = "drop", fill = "right")%>%
    ga.clean.names%>%
    mutate(campaignid=str_replace_all(.$campaignid,c("_Points.txt"="","_3DPoints.txt"="","_Lengths.txt"="")))%>%
    plyr::rename(., replace = c(opcode="sample"),warn_missing = FALSE)
}