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
dat.spp<-left_join(dat,synonyms,by=c("family","genus","species"))%>%
    mutate(genus=ifelse(!is.na(genus_correct),genus_correct,genus))%>%
    mutate(species=ifelse(!is.na(species_correct),species_correct,species))%>%
    mutate(family=ifelse(!is.na(family_correct),family_correct,family))%>%
    select(-c(family_correct,genus_correct,species_correct))
 
if(return.changes==TRUE){taxa.replaced.by.synonym<<-left_join(dat,synonyms,by=c("family","genus","species"))%>% 
  filter(!is.na(genus_correct))%>%
  select(campaignid,family,genus,species,family_correct,genus_correct,species_correct)%>%
  distinct()
} 

if(save.report==TRUE){setwd(error.dir)
  write.csv(taxa.replaced.by.synonym,paste(study,deparse(substitute(dat)),"taxa.replaced.by.synonym.csv",sep = "."))
} 

return(dat.spp)
}