##  ----
#' query.workgroup function
#'
#' Query by workgroup name \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export
query.workgroup<-function(workgroup){
  q='{"filters":[{"name":"workgroups","op":"any","val":{"name":"name","op":"eq","val":"Insert workgroup"}}]}'
  q<-str_replace_all(q,"Insert workgroup",workgroup)
}