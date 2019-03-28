#' List files in GA
#'
#' Expand files
#'
#' @param dat 
#'
#' @return None
#'
#' @examples
#' expand.files()
#'
#' @export
expand.files<-function(files) {
  as.data.frame(files)%>%
    mutate(campaign=row.names(.))%>%
    filter(lines>1)%>% # filter out all empty text files
    select(campaign)%>%
    as_vector(.)
}