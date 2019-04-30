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
change.synonyms<-function(dat,return.changes=FALSE,save.report=FALSE){
dat.spp<-dplyr::left_join(dat,synonyms,by=c("family","genus","species"))%>%
  dplyr::mutate(genus=ifelse(!is.na(genus_correct),genus_correct,genus))%>%
  dplyr::mutate(species=ifelse(!is.na(species_correct),species_correct,species))%>%
  dplyr::mutate(family=ifelse(!is.na(family_correct),family_correct,family))%>%
  dplyr::select(-c(family_correct,genus_correct,species_correct))
 
if(return.changes==TRUE){taxa.replaced.by.synonym<<-dplyr::left_join(dat,synonyms,by=c("family","genus","species"))%>% 
  dplyr::filter(!is.na(genus_correct))%>%
  dplyr::select(campaignid,sample,family,genus,species,family_correct,genus_correct,species_correct)%>%
  dplyr::distinct()
} 

if(save.report==TRUE){taxa.replaced.by.synonym<<-dplyr::left_join(dat,synonyms,by=c("family","genus","species"))%>% 
  dplyr::filter(!is.na(genus_correct))%>%
  dplyr::select(campaignid,sample,family,genus,species,family_correct,genus_correct,species_correct)%>%
  dplyr::distinct()
  setwd(error.dir)
  write.csv(taxa.replaced.by.synonym,paste(study,deparse(substitute(dat)),"taxa.replaced.by.synonym.csv",sep = "_"),row.names = FALSE)
} 

return(dat.spp)
}