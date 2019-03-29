##  ----
#' change.synonyms function
#'
#' Change all synonyms \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#' change.synonyms()
#'
#' @export
change.synonyms<-function(dat,return.changes=FALSE){
dat.spp<-left_join(dat,synonyms,by=c("family","genus","species"))%>%
    mutate(genus=ifelse(!is.na(genus_correct),genus_correct,genus))%>%
    mutate(species=ifelse(!is.na(species_correct),species_correct,species))%>%
    mutate(family=ifelse(!is.na(family_correct),family_correct,family))%>%
    select(-c(family_correct,genus_correct,species_correct))
 
if(return.changes==TRUE){taxa.replaced.by.synonym<<-anti_join(dat,dat.spp,by=c("campaignid","sample","genus","species"))%>%
  distinct(campaignid,sample,family,genus,species)
} 

return(dat.spp)
}