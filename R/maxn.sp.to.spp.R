##  ----
#' Sp to spp function
#'
#' Function that corrects sp to spp based on a species list from \code{\link{GlobalArchive}}
#'
#' @param dat file to be manipulated
#' 
#' @param sp.list list of species to compare with
#'
#' @return None
#'
#' @examples
#' maxn.sp.to.spp()
#'
#' @export
maxn.sp.to.spp<-function(dat,
                         sp.list,
                         return.changes=FALSE){
  dat.spp<-dat%>%
    mutate(species=ifelse(species%in%sp.list,"spp",as.character(species)))%>% # Change all of the sp in the sp.list into spp
    mutate(species=ifelse(grepl("sp | sp|spp",species),"spp",as.character(species)))%>%
    group_by(id,family,genus,species)%>% # 
    slice(which.max(maxn))%>% # Take only the spp with the maximum MaxN
    #mutate(Scientific = paste(genus, species, sep = ' '))%>% # Remake the Scientific
    ungroup()
  
  if(return.changes==TRUE){taxa.replaced.by.spp<<-anti_join(dat,dat.spp,by=c("id","genus","species"))%>%
    distinct(id,family,genus,species)%>%
    select(id,family,genus,species)
  } 
  
  return(dat.spp)
}

