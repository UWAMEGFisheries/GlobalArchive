##  ----
#' ga.get.object_list function
#'
#' Function that performs paginated multiple HTTP GET requests on api endpoint and processes each object with optional processing function from  \code{\link{GlobalArchive}}
#'
#' @param api_endpoint api_endpoint
#' 
#' @param api_token api_token
#'
#' @param f f optional, default=NULL, function pointer to process each object. If NULL, do nothing
#' 
#' @param q optional, default=NULL: json query string for GA API
#'
#' @return A dataframe containing the json response from the API
#'
#' @examples
#'
#' @export
ga.get.object_list <- function(api_endpoint, api_token, f=NULL, q="") {
  
  start_time <- Sys.time()  # start timer (just for info purposes)
  page <- 0
  total_pages <- NULL
  num_results <- 0
  num_objects <- 0
  while (is.null(total_pages) || page < total_pages) {
    page <- page+1
    object_list <- ga.get(api_endpoint, api_token, page=page, q=q)
    total_pages <- object_list$total_pages
    num_results <- object_list$num_results
    page <- object_list$page
    if (!length(object_list$objects)) {
      return(0)
    }
    if (!is.null(f)){  # && length(object_list$objects)) {
      for (i in 1:nrow(object_list$objects)){
        obj <- object_list$objects[i,]
        num_objects <- num_objects+1
        ga.print("\n* Processing object: %i/%s...", num_objects, num_results)
        f(obj)
      }
    }
  }
  ga.print("\nDONE! Processed %i results in %.2f seconds...", num_results, difftime(Sys.time(),start_time,units="secs")) # print summary
  return (num_objects)
}


