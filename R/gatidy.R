

# ###############################################################################
# # General GA API methods
# ###############################################################################

# Tim altered this - need to check it works or is needed?
check.api<-function(API_USER_TOKEN){
  if (!exists("API_USER_TOKEN")) {
    args = commandArgs(trailingOnly=TRUE)
    if (length(args)==0) {stop("Not API_USER_TOKEN found. Either set it in the code or pass it as an argument to the script!")}
    else {API_USER_TOKEN <- args[1]}   # get it from command line argument
  }
}


### Return campaign objects ----
process_campaign_object <- function(object) {
  # Perform another request to the API to get more detailed campaign info
  campaign <- ga.get.campaign(API_USER_TOKEN, object["id"])
  #print(toJSON(campaign, pretty=TRUE))  # show all avialable info
  # Print campaign_info to console
  ga.print.campaign_details(campaign)  # prints details about campaign
  # Download/save campaign files and data
  campaign_path <- file.path(DATA_DIR, campaign$project["name"], campaign$name) # create campaign path
  dir.create(campaign_path, showWarnings = FALSE, recursive=TRUE)             # create campaign dir
  campaign_files = ga.download.campaign_files(API_USER_TOKEN, campaign$files, campaign_path, match=MATCH_FILES)   # download all campaign files
  ga.download.campaign_info(API_USER_TOKEN, campaign$info, campaign_path)     # generate csv file for info
  ga.download.campaign_record(API_USER_TOKEN, campaign, campaign_path)        # generate json file containing campaign record information
}


###############################################################################
# General GA tidydata methods
###############################################################################

# Clean names function ----
clean_names <- function(dat){
  old_names <- names(dat)
  new_names <- old_names %>%
    gsub("%", "percent", .) %>%
    make.names(.) %>%
    gsub("[.]+", ".", .) %>%
    tolower(.) %>%
    gsub("_$", "", .)
  setNames(dat, new_names)
}

## Function that reads in csv files and creates a column for filepath to get CampaignID ----
read_files_csv <- function(flnm) {
  read_csv(flnm,col_types = cols(.default = "c"))%>% 
    mutate(campaignnames = flnm)%>%
    separate(campaignnames,into=c("Folder","Collaborations","Project","CampaignID","File"),sep="/")%>%
    select(-c(Folder,Collaborations,File))%>%
    str_replace(.,c(".txt", ".csv"), "")%>%
    clean_names
}
## Function that reads in txt files and creates a column for filepath to get CampaignID ----
read_files_txt <- function(flnm) {
  read_tsv(flnm,col_types = cols(.default = "c"))%>% 
    mutate(campaignnames = flnm)%>%
    separate(campaignnames,into=c("Folder","Collaborations","Project","CampaignID","File"),sep="/")%>%
    select(-c(Folder,Collaborations,File))%>%
    str_replace(.,c(".txt", ".csv"), "")%>%
    clean_names
}


# Function to capitalise species names ----
capitalise=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

# SPP Function-----
maxn.sp.to.spp<-function(dat,
                         sp.list,
                         return.changes=FALSE){
  dat.spp<-dat%>%
    mutate(species=ifelse(species%in%sp.list,"spp",as.character(species)))%>% # Change all of the sp in the sp.list into spp
    mutate(species=ifelse(grepl("sp | sp|spp",species),"spp",as.character(species)))%>%
    group_by(id,family,genus,species)%>% # 
    slice(which.max(maxn))%>% # Take only the spp with the maximum MaxN
    #mutate(Scientific = paste(genus, species, sep = ' '))%>% # Remake the Scientific
    ungroup()
  
  if(return.changes==TRUE){taxa.replaced.by.spp<<-anti_join(dat,dat.spp,by=c("id","genus","species"))%>%
    distinct(id,family,genus,species)%>%
    select(id,family,genus,species)
  } 
  
  return(dat.spp)
}


