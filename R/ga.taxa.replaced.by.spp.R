##  ----
#' taxa.replaced.by.spp function
#'
#' List all taxa replaced by all sp1 sp2 sp3 to spp \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export
ga.taxa.replaced.by.spp<-function(dat){
  dat<-dat%>%
    dplyr::filter(species%in%sp.list)%>%
    dplyr::distinct(campaignid,family,genus,species)%>%
    dplyr::select(campaignid,family,genus,species)
}



