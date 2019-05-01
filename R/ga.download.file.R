##  ----
#' ga.download.file function
#'
#' Function that performs paginated multiple HTTP GET requests on api endpoint and processes each object with optional processing function from  \code{\link{GlobalArchive}}
#'
#' @param api_endpoint api_endpoint
#' 
#' @param api_token api_token
#'
#' @param path to where results will be saved

#'
#' @return A dataframe containing the json response from the API
#'
#' @examples
#'
#' @export
ga.download.file <- function(api_token, api_endpoint, path, query=NULL) {
  r = GET(URL_DOMAIN, path=api_endpoint, add_headers("auth-token" = api_token), query=query, write_disk(path, overwrite=TRUE))
  stop_for_status(r)  # raise error and stop if unsuccessful response
}
