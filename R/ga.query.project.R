##  ----
#' ga.query.project function
#'
#' Query by project name \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export
ga.query.project<-function(project){
  q='{"filters":[{"name":"project","op":"has","val":{"name":"name","op":"eq","val":"Insert project"}}]}'
  q<-str_replace_all(q,"Insert project",project)
}