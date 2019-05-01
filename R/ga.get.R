##  ----
#' ga.get function
#'
#' Function that Performs HTTP GET request to  \code{\link{GlobalArchive}}
#'
#' @param api_endpoint api_endpoint
#' 
#' @param api_token api_token
#'
#' @param page page optional, default=1
#' 
#' @param q optional, default=NULL
#'
#' @return A dataframe containing the json response from the API
#'
#' @examples
#'
#' @export
ga.get <- function(api_endpoint, api_token, page=1, q="") {

  api_endpoint = paste0(api_endpoint, "?page=", page)
  if (q != "") {api_endpoint <- paste0(api_endpoint,"&q=",q)}
  ga.print("\n*** HTTP GET REQUEST: %s\n", api_endpoint)
  r <- GET(URL_DOMAIN, path=api_endpoint, add_headers("auth-token" = api_token), accept_json())
  stop_for_status(r)  # raise error and stop if unsuccessful response
  data = fromJSON(content(r, "text", encoding="UTF-8"))
  return (data)
}


