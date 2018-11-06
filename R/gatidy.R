

###############################################################################
# General GA API methods
###############################################################################

if (!exists("API_USER_TOKEN")) {
  args = commandArgs(trailingOnly=TRUE)
  if (length(args)==0) {stop("Not API_USER_TOKEN found. Either set it in the code or pass it as an argument to the script!")}
  else {API_USER_TOKEN <- args[1]}   # get it from command line argument
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
    separate(campaignnames,into=c("Folder","Synthesis","Project","CampaignID","File"),sep="/")%>%
    select(-c(Folder,Synthesis,File))%>%
    clean_names
}
## Function that reads in txt files and creates a column for filepath to get CampaignID ----
read_files_txt <- function(flnm) {
  read_tsv(flnm,col_types = cols(.default = "c"))%>% 
    mutate(campaignnames = flnm)%>%
    separate(campaignnames,into=c("Folder","Synthesis","Project","CampaignID","File"),sep="/")%>%
    select(-c(Folder,Synthesis,File))%>%
    clean_names
}