##  ----
#' length.sp.to.spp function
#'
#' Change all sp1 sp2 sp3 to spp \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#' length.sp.to.spp()
#'
#' @export
length.sp.to.spp<-function(dat,sp.list){
  
  length.number<-dat%>%
    group_by(campaignid,sample,family,genus,species)%>%
    summarise(total=sum(number))%>%
    ungroup()%>%
    mutate(new.species=ifelse(species%in%sp.list,"spp",as.character(species)))
  
  length.max<-length.number%>%
    group_by(campaignid,sample,family,genus,new.species)%>%
    slice(which.max(total))%>%
    left_join(.,length.number) # only select the ones with the highest total
  
  dat<-semi_join(dat,length.max, by = c("campaignid", "sample", "family", "genus", "species")) # only selects ones that had the highest
  
  dat<-dat%>%
    dplyr::mutate(species=ifelse(species%in%sp.list,"spp",as.character(species)))
}







