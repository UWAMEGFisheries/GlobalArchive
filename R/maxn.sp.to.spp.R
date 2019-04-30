##  ----
#' maxn.sp.to.spp function
#'
#' Change all sp1 sp2 sp3 to spp \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#' maxn.sp.to.spp()
#'
#' @export
maxn.sp.to.spp<-function(dat,sp.list,return.changes=FALSE){
  dat.spp<-dat%>%
    dplyr::mutate(species=ifelse(species%in%sp.list,"spp",as.character(species)))%>% # Change all of the sp in the sp.list into spp
    dplyr::mutate(species=ifelse(grepl("sp | sp|spp",species),"spp",as.character(species)))%>%
    dplyr::group_by(campaignid,sample,family,genus,species)%>% # 
    dplyr::slice(which.max(maxn))%>% # Take only the spp with the maximum MaxN
    #mutate(Scientific = paste(genus, species, sep = ' '))%>% # Remake the Scientific
    dplyr::ungroup()
  
  if(return.changes==TRUE){maxn.taxa.replaced.by.spp<<-dplyr::anti_join(dat,dat.spp,by=c("campaignid","sample","genus","species"))%>%
    dplyr::distinct(campaignid,sample,family,genus,species)
  } 
  
  return(dat.spp)
}

