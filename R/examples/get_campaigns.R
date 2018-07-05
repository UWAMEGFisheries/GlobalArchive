#!/usr/bin/env Rscript

#install.packages("httr")
library(httr)
#install.packages("jsonlite")
library(jsonlite)
source("galib.R")

args = commandArgs(trailingOnly=TRUE)

################################################################################
# Setup your query
# Set you GA API USER TOKEN for this query. If you do not set in the script, it
# expects to receive it from the command line argument
################################################################################
# API_USER_TOKEN <- "eea9068a...7fb4bcbd595"  # hard code it here or pass it as an argument
if (!exists("API_USER_TOKEN")) {
  if (length(args)==0) {stop("You need to pass in your API USER TOKEN!")}
  else {API_USER_TOKEN <- args[1]}
}


# Configure this to be the location for which you want to download all
# campaign and project data for this query
DATA_DIR <- "my_data"

################################################################################
# The following is an example of a user defined function that is passed into the
# API function to operate on the returned campaign objects. You can customise
# this to do whatever you want on each campaign that matches you search and will
# operate on each individually. If you want to work on all campaigns that match
# a search you can maintain data in data frames with shared scope.
################################################################################
process_campaign_object <- function(object) {
  #print(toJSON(object, pretty=TRUE))  # show available info from object list

  # Perform another request to the API to get more detailed campaign info
  campaign <- ga.get.campaign(API_USER_TOKEN, object["id"])
  #print(toJSON(campaign, pretty=TRUE))  # show all avialable info

  # Print campaign_info to console
  ga.print.campaign_details(campaign)  # prints details about campaign

  # Download/save campaign files and data
  campaign_path <- file.path(DATA_DIR, campaign$project["name"], campaign$name) # create campaign path: DATA_DIR/<project>/<campaign>
  dir.create(campaign_path, showWarnings = FALSE, recursive=TRUE)             # create campaign dir (if doesn't already exist)
  ga.download.campaign_files(API_USER_TOKEN, campaign$files, campaign_path)   # download all campaign files
  ga.download.campaign_info(API_USER_TOKEN, campaign$info, campaign_path)     # generate csv file containing all campaign info properties
  ga.download.campaign_record(API_USER_TOKEN, campaign, campaign_path)        # generate json file containing campaign record information
}

################################################################################
# Customise the API search criteria for your query (JSON)
# The examples below show some possible search queries. Many more types of
# queries are available. Note, only the last one will be used since it
# overwrites the previous ones, so comment out the ones you're not using
################################################################################
# EXAMPLE 1: search for all campaigns matching pattern ( % = wildcard)
q='{"filters":[{"name":"name","op":"like","val":"%_Capes.sanctuaries_stereoBRUVs"}]}'
# EXAMPLE 2: search for specific campaign by name
q='{"filters":[{"name":"name","op":"eq","val":"2011-09_Barrow.PDS_stereoBRUVs"}]}'
# EXAMPLE 3: search for all campaigns by user's email
q='{"filters":[{"name":"user","op":"has","val":{"name":"email","op":"eq","val":"euan.harvey@curtin.edu.au"}}]}'
# EXAMPLE 4: search for all campaigns from Project (note + for spaces)
q='{"filters":[{"name":"project","op":"has","val":{"name":"name","op":"eq","val":"Deep+Water+FRDC"}}]}'
# EXAMPLE 5: search for all campaigns from Collaboration (note + for spaces)
q='{"filters":[{"name":"workgroups","op":"any","val":{"name":"name","op":"eq","val":"NSW+MER+BRUVS"}}]}'
# EXAMPLE 6: get all campaigns that my user account has access to
q=""

#TODO: build a function to help construct common queries



################################################################################
# Run the query and process the resultant campaigns
################################################################################
# start timer (just for info purposes)
start_time <- Sys.time()

# This is where all the magic happens. It makes the API request to retrieve the
# campaigns matching the query "q" and then processes each one through the
# passed in function pointer "process_campaign_object"
nobjects <- ga.get.campaign.list(API_USER_TOKEN, process_campaign_object, q=q)

# print summary
writeLines(sprintf("\n\nDone processing %i campaigns in %.2f seconds...", nobjects, difftime(Sys.time(),start_time,units="secs"))) # print summary

# TODO: once files are downloaded you can run queries, or alternatively you
# could modify the 'process_campaign_object' function to process data on the fly
