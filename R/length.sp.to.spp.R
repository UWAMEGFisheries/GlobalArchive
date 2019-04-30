##  ----
#' lengths.sp.to.spp function
#'
#' Change all sp1 sp2 sp3 to spp and only keep the one with the most length measurements \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#' lengths.sp.to.spp()
#'
#' @export
lengths.sp.to.spp<-function(dat,sp.list,return.changes=FALSE){
  length.number<-dat%>%
    dplyr::group_by(campaignid,sample,family,genus,species)%>%
    dplyr::summarise(total=sum(number))%>%
    ungroup()%>%
    dplyr::mutate(new.species=ifelse(species%in%sp.list,"spp",as.character(species)))
  length.max<-length.number%>%
    dplyr::group_by(campaignid,sample,family,genus,new.species)%>%
    slice(which.max(total))%>%
    dplyr::left_join(.,length.number) # only select the ones with the highest total
  dat.spp<-semi_join(dat,length.max, by = c("campaignid", "sample", "family", "genus", "species")) # only selects ones that had the highest
  dat.spp<-dat.spp%>%
    dplyr::mutate(species=ifelse(species%in%sp.list,"spp",as.character(species)))
  if(return.changes==TRUE){length.taxa.replaced.by.spp<<-anti_join(dat,dat.spp,by=c("campaignid","sample","genus","species"))%>%
    dplyr::distinct(campaignid,sample,family,genus,species)
  } 
  return(dat.spp)
}



