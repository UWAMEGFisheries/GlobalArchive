# Some url patterns for querying
URL_DOMAIN <- "https://globalarchive.org"
# URL_DOMAIN <- "http://localhost:5000"
API_ENDPOINT_CAMPAIGN_LIST <- "/api/campaign"
API_ENDPOINT_CAMPAIGN_DETAIL <- "/api/campaign-full/%s"
API_ENDPOINT_CAMPAIGN_FILE <- "/api/campaign_file_file/%s"


###############################################################################
# General GA API HTTP methods
###############################################################################

ga.get <- function(api_endpoint, api_token, page=1, q="") {
  # Performs HTTP GET request to GlobalArchive API
  #
  # Args:
  #   api_endpoint:
  #   api_token:
  #   page [optional, default=1]:
  #   q [optional, default=NULL]:
  #
  # Return:
  #   A dataframe containing the json response from the API
  api_endpoint = paste0(api_endpoint, "?page=", page)
  if (q != "") {api_endpoint <- paste0(api_endpoint,"&q=",q)}
  ga.print("\n*** HTTP GET REQUEST: %s\n", api_endpoint)
  r <- GET(URL_DOMAIN, path=api_endpoint, add_headers("auth-token" = api_token), accept_json())
  stop_for_status(r)  # raise error and stop if unsuccessful response
  data = fromJSON(content(r, "text", encoding="UTF-8"))
  return (data)
}

ga.get.object_list <- function(api_endpoint, api_token, f=NULL, q="") {
  # Performs paginated multiple HTTP GET requests on api endpoint and processes
  # each object with optional processing function
  #
  # Args:
  #   api_endpoint:
  #   api_token:
  #   f [optional, default=NULL]: function pointer to process each object. If NULL, do nothing
  #   q [optional, default=NULL]: json query string for GA API
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

ga.download.file <- function(api_token, api_endpoint, path, query=NULL) {
  r = GET(URL_DOMAIN, path=api_endpoint, add_headers("auth-token" = api_token), query=query, write_disk(path, overwrite=TRUE))
  stop_for_status(r)  # raise error and stop if unsuccessful response
}


###############################################################################
# CUSTOM API ENDPOINT METHODS
###############################################################################

ga.get.campaign.list <- function(api_token, f, q="") {
  return(ga.get.object_list(API_ENDPOINT_CAMPAIGN_LIST, API_USER_TOKEN, f=f, q=q))
}

ga.get.campaign <- function(api_token, campaign_id) {
  return(ga.get(sprintf(API_ENDPOINT_CAMPAIGN_DETAIL, campaign_id), API_USER_TOKEN))
}

ga.download.campaign_files <- function(api_token, campaign_files, save_path, match=NULL, exclude=NULL) {
  start_time <- Sys.time()
  ga.print(paste0("Downloading files | matching: '",match,"' | excluding: '", exclude,"'"))
  nfiles = 0
  # get filtered list
  if(!is.null(exclude)) {
    campaign_files <- campaign_files[-grep(exclude, campaign_files$name), ]
  }
  if(!is.null(match)) {
    campaign_files <- campaign_files[grep(match, campaign_files$name), ]
  }

  # download files to directory
  if (length(campaign_files)) {
    nfiles = nrow(campaign_files)
    for (i in 1:nfiles){
      id <- campaign_files[i,"id"]
      save_file_path <- file.path(save_path, campaign_files[i,"name"])
      cat(sprintf("  Saving: '%s'...", save_file_path))
      ga.download.campaign_file(api_token, id, save_file_path)
      campaign_files[i,"file_path"] = save_file_path
      writeLines("...Done")
    }
  }
  ga.print("Downloaded %i files in %.2f s", nfiles, difftime(Sys.time(),start_time,units="secs"))
  return (campaign_files)
}

ga.download.campaign_file <- function(api_token, id, save_file_path){
  file_endpoint <- sprintf(API_ENDPOINT_CAMPAIGN_FILE, id)
  ga.download.file(api_token, file_endpoint, save_file_path)
}

ga.download.campaign_record <- function(api_token, campaign_details, save_path) {
  file_path <- file.path(save_path, ".record.json")
  # write record to json file
  cat("  Saving campaign record...")
  write(toJSON(campaign_details, pretty=TRUE), file_path)
  writeLines("...Done")
}

ga.download.campaign_info <- function(api_token, campaign_info, save_path) {
  # campaign_name <- campaign_details$name
  campaign_info <- campaign_info
  file_path <- file.path(save_path, ".info.csv")
  cat("  Saving campaign info...")
  df_info <- data.frame()
  if (length(campaign_info)) {
    for (i in 1:nrow(campaign_info)) {
      df <- data.frame(field=campaign_info[i,"property"]["name"], value=campaign_info[i,"value"], is_filter=campaign_info[i,"property"]["is_filter"])
      df_info <- rbind(df_info,df)
    }
  }
  write.csv(df_info, file_path)
  writeLines("...Done")
}


ga.print.campaign_details <- function(campaign_details) {
  campaign_description <- campaign_details["description"]
  campaign_info <- campaign_details$info
  campaign_files <- campaign_details$files
  campaign_platform <- campaign_details$platform
  campaign_project <- campaign_details$project
  campaign_workgroups <- campaign_details$workgroups

  ga.print("Campaign: %s (ID=%s)", campaign_details$name, campaign_details$id)
  ga.print("Description: %s", campaign_description)
  ga.print("Method: %s", campaign_platform["name"])
  ga.print("Deployment count: %i", campaign_details$deployment_count)
  ga.print("Project: %s (ID=%s)", campaign_project["name"], campaign_project["id"])

  writeLines(sprintf("Shared in %i Collaboration(s):", nrow(campaign_workgroups)))
  # Print Campaign Info fields
  if (length(campaign_workgroups)) {
    for (i in 1:nrow(campaign_workgroups)) {
      writeLines(sprintf("  %s (ID=%s)", campaign_workgroups[i,"name"], campaign_workgroups[i,"id"]))
    }
  }

  ga.print("Found info fields:")
  # Print Campaign Info fields
  if (length(campaign_info)) {
    for (i in 1:nrow(campaign_info)) {
      ga.print("  %s: %s", campaign_info[i,"property"]["name"], campaign_info[i,"value"])
    }
  }

  ga.print("Found files:")
  # Print names and IDs of available files
  if (length(campaign_files)) {
    for (i in 1:nrow(campaign_files)){
      ga.print("  %s (ID=%s)", campaign_files[i,"name"], campaign_files[i,"id"])
    }
  }
}

ga.print <- function(format, ...) {
  writeLines(sprintf(format, ...))
}






