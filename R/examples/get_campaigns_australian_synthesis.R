## Clear memory ----
rm(list=ls())#!/usr/bin/env Rscript

#install.packages("httr")
library(httr)
#install.packages("jsonlite")
library(jsonlite)
source("R/galib.R")
library(dplyr) # added by Brooke
library(purrr) # added by Brooke
library(tidyr) # added by Brooke
library(readr) # added by Brooke
library(stringr) # added by Brooke
library(plyr)
library(googlesheets)
library(fuzzyjoin)

## Brooke's Functions ----

# Clean names function ----
clean_names <- function(dat){
  # Takes a data.frame, returns the same data frame with cleaned names
  old_names <- names(dat)
  new_names <- old_names %>%
    gsub("%", "percent", .) %>%
    make.names(.) %>%
    gsub("[.]+", ".", .) %>%
    tolower(.) %>%
    gsub("_$", "", .)
  setNames(dat, new_names)
}

## Create a new function that reads in csv files and creates a column for filepath to get CampaignID ----
read_files_csv <- function(flnm) {
  read_csv(flnm,col_types = cols(.default = "c"))%>% 
    mutate(campaignnames = flnm)%>%
    separate(campaignnames,into=c("Folder","Synthesis","Project","CampaignID","File"),sep="/")%>%
    select(-c(Folder,Synthesis))%>%
    clean_names
}
## Create a new function that reads in txt files and creates a column for filepath to get CampaignID ----
read_files_txt <- function(flnm) {
  read_tsv(flnm,col_types = cols(.default = "c"))%>% 
    mutate(campaignnames = flnm)%>%
    separate(campaignnames,into=c("Folder","Synthesis","Project","CampaignID","File"),sep="/")%>%
    select(-c(Folder,Synthesis))%>%
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

## Life history sheet -----
# life-history-sheet ---
master<-gs_title("Australia.life.history")%>%gs_read_csv(ws = "australia.life.history")%>%clean_names()%>%
  filter(grepl('Australia', global.region))

master.expanded<-master%>%
  mutate(marine.region = strsplit(as.character(marine.region), split = "/"))%>%
  unnest(marine.region)

### Life-history families----
families<-master%>%
  distinct(family, genus)%>%
  dplyr::rename(family.new=family)
# Bring in Campaign Specific Marine Regions -----
regions <- gs_title("Marine_Regions")%>%
  gs_read_csv(ws = "Campaigns")%>%clean_names()%>%
  dplyr::select(-c(comment))%>%
  mutate(marine.park=str_replace_all(marine.park,"[^[:alnum:]]", ".")) # Replace non-alphanumeric

unique(regions$marine.park)

regions<-regions%>%select(campaignid,marine.region,state,custodian,marine.park)

# Bring in synonyms and remove lists ----
syn.rem<-gs_title("Synonyms_Australia")
synonyms<-syn.rem%>%gs_read_csv(ws = "Synonyms_Australia")%>%distinct()%>%clean_names()%>%select(-comment)
remove<-syn.rem%>%gs_read_csv(ws = "To remove")%>%distinct()%>%clean_names()%>%select(-comment)

# Googlesheet reports ----
report.sheet <- gs_title("Au.reporting.errors")
wrong.region.report<-report.sheet%>%gs_read_csv(ws = "Au.wrong.region.list")
# Bring in Campaign Specific Marine Regions -----
regions <- gs_title("Marine_Regions")%>%
  gs_read_csv(ws = "Campaigns")%>%clean_names()%>%
  dplyr::select(-c(comment))%>%
  mutate(marine.park=str_replace_all(marine.park,"[^[:alnum:]]", "."))%>%# Replace non-alphanumeric
  dplyr::rename(file=campaignid)

regions<-regions%>%select(campaignid,marine.region,state,custodian,marine.park)

################################################################################
# Setup your query
################################################################################
# Set you GA API USER TOKEN for this query. If you do not set in the script, it
# expects to receive it from the command line argument
API_USER_TOKEN <- "ef231f61b4ef204d39f47f58cccadf71af250a365e314e83dbcb3b08"  # hard code it here or pass it as an argument
if (!exists("API_USER_TOKEN")) {
  args = commandArgs(trailingOnly=TRUE)
  if (length(args)==0) {stop("Not API_USER_TOKEN found. Either set it in the code or pass it as an argument to the script!")}
  else {API_USER_TOKEN <- args[1]}   # get it from command line argument
}

# Configure this to be the location for which you want to download all
# campaign and project data for this query
DATA_DIR <- "Data/AustralianSynthesis"

# Configure search pattern for downloading all files
# Example: only download .csv and .txt files
MATCH_FILES <- ".csv$|.txt$"
# Example: only download files with "_Metadata."" in the filename
# MATCH_FILES <- "_Metadata."
# Example: download all files
# MATCH_FILES <- NULL

# Customise the API search criteria for your query (JSON)
# The examples below show some possible search queries. Many more types of
# queries are available. Note, only the last one will be used since it
# overwrites the previous ones, so comment out the ones you're not using
#TODO: build a function to help construct common queries
# EXAMPLE 1: search for all campaigns matching pattern ( % = wildcard)
# q='{"filters":[{"name":"name","op":"like","val":"%_PointAddis_stereoBRUVs"}]}'
# EXAMPLE 2: search for specific campaign by name
# q='{"filters":[{"name":"name","op":"eq","val":"2011-09_Barrow.PDS_stereoBRUVs"}]}'
# EXAMPLE 3: search for all campaigns by user's email
# q='{"filters":[{"name":"user","op":"has","val":{"name":"email","op":"eq","val":"euan.harvey@curtin.edu.au"}}]}'
# EXAMPLE 4: search for all campaigns from Project (note + for spaces)
# q='{"filters":[{"name":"project","op":"has","val":{"name":"name","op":"eq","val":"Port+Stephens-Great+Lakes+Marine+Park+MER+Program"}}]}'

# EXAMPLE 5: search for all campaigns from Collaboration (note + for spaces)
q='{"filters":[{"name":"workgroups","op":"any","val":{"name":"name","op":"eq","val":"Australia+Synthesis"}}]}'
# EXAMPLE 6: search for all campaigns from Collaboration with wildcard search (%=wildcarg, ilike=case insensitive)
# q='{"filters":[{"name":"workgroups","op":"any","val":{"name":"name","op":"ilike","val":"nsw%bruvs"}}]}'
# EXAMPLE 7: get all campaigns that my user account has access to
# q=""

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
  campaign_files = ga.download.campaign_files(API_USER_TOKEN, campaign$files, campaign_path, match=MATCH_FILES)   # download all campaign files
  ga.download.campaign_info(API_USER_TOKEN, campaign$info, campaign_path)     # generate csv file containing all campaign info properties
  ga.download.campaign_record(API_USER_TOKEN, campaign, campaign_path)        # generate json file containing campaign record information
  #print(campaign_files)  # prints output of campaign files including saved location
}

################################################################################
# Run the query and process the resultant campaigns
################################################################################
# This is where all the magic happens. It makes the API request to retrieve the
# campaigns matching the query "q" and then processes each one using the
# function pointer "process_campaign_object"
nresults <- ga.get.campaign.list(API_USER_TOKEN, process_campaign_object, q=q)

# TODO: once files are downloaded you can run queries, or alternatively you
# could modify the 'process_campaign_object' function to process data on the fly

## Beginning of Brooke's work ----
## Bring in metadata files using new function ----
metadata <-
  list.files(path="Data",
             recursive=T,
             pattern="Metadata.csv",
             full.names=T) %>% 
  map_df(~read_files_csv(.))%>%
  select(-c(successful))%>%
  mutate(file=str_replace_all(file,"_Metadata.csv",""))%>%
  glimpse()

## Metadata checks ----
# read in manual metadata to check if matches
man.met<-read_csv("C:/Users/00097191/Google Drive/MEG/Analysis_GlobalArchive_Australia/Tidy data_Australia/Au.Maxn.Metadata.2018-08-20.csv",col_types = cols(.default = "c"))%>%
  dplyr::rename(file=campaignid)%>%glimpse()

maxn.metadata<-metadata%>%
  filter(successful.count=="Yes")%>%
  mutate(file=str_replace_all(file,"_Metadata.csv",""))

# Samples that are missing from 
missing.from.download<-maxn.metadata%>%
  select(file,sample)%>%
  anti_join(man.met,.) # At the moment is three campaigns that aren't uploaded (432) But i've moved these into manual folder

missing.from.manual<-maxn.metadata%>%
  select(file,sample)%>%
  anti_join(.,man.met) # Should be none

rm(missing.from.download, missing.from.manual,maxn.metadata,man.met) # remove these from data 

## Bring in files to create maxn file -----
## EventMeasure points ----
points <-
  list.files(path="Data",
             recursive=T,
             pattern="_Points.txt",
             full.names=T) %>% 
  map_df(~read_files_txt(.))%>%
  dplyr::rename(sample=opcode)%>%
  mutate(file=str_replace_all(file,"_Points.txt",""))%>%
  dplyr::select(campaignid,sample,family,genus,species,number,frame)%>%
  glimpse()

unique(points$campaignid) # 83 

## Generic count ----
count <-
  list.files(path="Data",
             recursive=T,
             pattern="_Count.csv",
             full.names=T) %>% 
  map_df(~read_files_csv(.))%>%
  mutate(file=str_replace_all(file,"_Count.csv",""))%>%glimpse()%>%
  select(-c(file,project))

unique(count$campaignid) # 120 (correct number) 154872 correct rows

# Query maxn from EM data tables and add in generic count- at first Period time----
maxn.raw<-points%>%
  group_by(campaignid,sample,frame,family,genus,species)%>%
  dplyr::mutate(number=as.numeric(number))%>%
  dplyr::summarise(maxn=sum(number))%>%
  group_by(campaignid,sample,family,genus,species)%>%
  dplyr::slice(which.max(maxn))%>%
  ungroup()%>%
  filter(!is.na(maxn))%>%
  filter(!maxn==0)%>%
  glimpse()

names(maxn.raw)
names(count)
unique(maxn.raw$campaignid) # 83 (correct) should be 118181 rows (1 more)

# Add in the generic count data----
maxn<-maxn.raw%>%
  select(-frame)%>%
  plyr::rbind.fill(count)%>%
  inner_join(metadata,by=c("campaignid","sample"))%>%
  replace_na(list(maxn=0))%>%
  dplyr::filter(successful.count=="Yes")%>%
  dplyr::mutate(id=paste(file,sample,sep="."))%>%
  dplyr::mutate(genus = ifelse(genus%in%c("Genus","genus","NA","NANA","sp","Sp","spp","unknown","fish","Unidentified","unidentified","Sp1"),"Unknown", genus))%>%
  tidyr::replace_na(list(family = "Unknown",genus = "Unknown", species = "spp"))%>% # Removes all NA's taxa (should be none though)
  dplyr::filter(!(family=="Unknown"&genus=="Unknown"))%>% 
  dplyr::mutate(genus = capitalise(genus))%>%
  dplyr::mutate(family = capitalise(family))%>%
  dplyr::mutate(species = tolower(species))%>%
  dplyr::mutate(maxn=ifelse(maxn%in%c(0,NA),count,maxn))%>%
  dplyr::mutate(maxn=as.numeric(maxn))%>%
  dplyr::mutate(genus=ifelse(family==genus,"Unknown",genus))%>%
  dplyr::mutate(species=ifelse(toupper(family)==toupper(species),"spp",species))%>%
  select(-c(count))%>%
  filter(maxn>0)%>% 
  glimpse()


length(unique(maxn$campaignid)) # 203 
length(unique(maxn$id)) # 19287 in api, 19287 in manual

250924-251061 #(137 different)

man.maxn<-read_csv("C:/Users/00097191/Google Drive/MEG/Analysis_GlobalArchive_Australia/Tidy data_Australia/maxn.test.csv")

# In new data but not in manual data
test1<-maxn%>%
  select(c(id,family,genus,species))%>%
  #select(id)%>%
  anti_join(.,man.maxn)%>%
  distinct()

test<-maxn%>%
  #select(c(id,family,genus,species))%>%
  select(id)%>%
  anti_join(.,man.maxn)%>%
  distinct()

rm(test,test1)

## Begin Checks ----
# Change sp, sp2, etc. to spp, and find overall maxn of the spp ----
sp.list<-c(paste0("sp",1:20),paste0("sp ",1:20),paste0("sp.",1:20),paste0("sp. ",1:20),"sp","sp.","spp","species","unknown","NA",NA,"-","jsp1","sp_capenat","sp_jurien","sp_kimberley","juv","white line black edge of c-fin","yellow_dorsal_patch","yellow-naped","pale_sp","like_pike_eel","black_sp","black_white_dorsal_stripe","dark_sp","sp_black","sp_whitetailed","stripey - banded","blotched_elongate_sp","indeterminate","spsmallgreen","j_sp1","unidentified")

maxn<-maxn.sp.to.spp(maxn,sp.list,return.changes = T)

### Add families if missing ----
maxn<-left_join(maxn,families,by="genus")%>%
  mutate(family=ifelse(!(genus=="Unknown"|is.na(family.new)),family.new,family))%>% # don't want to change if unknown genus or if genus isn't in sheet e.g. Pagrus
  select(-family.new) # this replaces families with life-history families

# maxn Checks----
# species name changes ----
maxn<-left_join(maxn,synonyms,by=c("family","genus","species"))%>%
  mutate(genus=ifelse(!is.na(genus_correct),genus_correct,genus))%>%
  mutate(species=ifelse(!is.na(species_correct),species_correct,species))%>%
  mutate(family=ifelse(!is.na(family_correct),family_correct,family))%>%
  select(-c(family_correct,genus_correct,species_correct))

# species to remove ----
maxn<-anti_join(maxn,remove,by=c("genus","species"))

# Change names as directed by custodians ----
campaign.specific.fixes<-wrong.region.report%>%
  dplyr::select(campaignid,family,genus,species,decision,change.to.family,change.to.genus,change.to.species)%>%
  dplyr::rename(file=campaignid)%>%
  distinct()

campaign.rename<-campaign.specific.fixes%>%
  filter(decision=="rename")%>%
  filter(!is.na(change.to.family))%>%
  distinct()

campaign.remove<-campaign.specific.fixes%>%
  filter(decision=="remove")%>%distinct()

names(maxn)

## First remove species ----
maxn<-anti_join(maxn,campaign.remove,by = c("family", "genus", "species", "file")) # changed to file from campaignid

## Then change species names ----
maxn<-left_join(maxn,campaign.specific.fixes,by=c("file","family","genus","species"))%>%
  mutate(family=ifelse(!is.na(change.to.family),change.to.family,family))%>%
  mutate(genus=ifelse(!is.na(change.to.genus),change.to.genus,genus))%>%
  mutate(species=ifelse(!is.na(change.to.species),change.to.species,species))%>%
  select(-c(change.to.family,change.to.genus,change.to.species,decision))

###### Check for taxa not match ------
# Check the taxa that don't exist in the life history at all ----
wrong.species.maxn <- master%>%
  select("family","genus","species")%>%
  anti_join(maxn,.,by=c("family","genus","species"))%>%
  distinct(file,family,genus,species)%>%
  filter(!species=="spp")%>%
  select(file,family,genus,species) # this should be zero

test<-anti_join(wrong.species.maxn,remove, by = c("genus", "species"))


wrong.family.maxn <- master%>%
  select("family")%>%
  anti_join(maxn,.,by=c("family"))%>%
  distinct(campaignid,family,genus,species)%>%
  #filter(!species=="spp")%>%
  select(campaignid,family,genus,species) # this can have some due to not having any species of that family (all should be spp)

# Check the taxa that don't match regions ----
wrong.region<-maxn%>%
  left_join(regions)%>%
  distinct(file,family,genus,species,marine.region,maxn)%>%  # make it distinct or takes 4ever
  regex_anti_join(.,master.expanded,by=c("family","genus","species","marine.region"))%>%
  group_by(file,family,genus,species)%>%
  dplyr::summarise(total.abundance=sum(maxn))%>%
  ungroup()%>%
  arrange(file,desc(total.abundance))%>%
  filter(!species=="spp")#%>% # this does take quite a while to run
  #left_join(.,select(regions,c(campaignid,custodian)),by="campaignid")%>%
  #select(custodian,campaignid,everything())

# maxn Factors---
keep.cols <- c("campaignid","sample","latitude","longitude","date","location","status","site","depth","observer","file","id")

maxn.factors<-maxn%>%
  select(one_of(keep.cols))%>%
  distinct()%>%
  glimpse()

unique(maxn.factors$campaignid) # 203
length(unique(maxn.factors$id)) # 19 287
names(maxn)

# Make complete.maxn: fill in 0, make Total and species Richness and join in factors----
complete.maxn<-maxn%>%
  group_by(campaignid,sample,family,genus,species)%>%
  dplyr::summarise(maxn=max(maxn))%>%
  ungroup()%>%
  mutate(id=paste(campaignid,sample,sep="."))%>%
  glimpse()

unique(complete.maxn$campaignid) # 203
length(unique(complete.maxn$id)) # 19244

length(unique(maxn$id)) # 19287

test<-anti_join(metadata,maxn,by="campaignid") # none
unique(test$campaignid)

test<-anti_join(maxn,complete.maxn,by=c("id","family","genus","species","maxn"))



## Bring in files for length ----
## Eventmeasure Lengths ----
lengths <-
  list.files(path="Data",
             recursive=T,
             pattern="Lengths.txt",
             full.names=T) %>% 
  map_df(~read_files_txt(.))%>%
  rename(sample=opcode)

unique(lengths$campaignid) # 64

# ## Eventmeasure 3D Points ----
# threedpoints <-
#   list.files(path="Data",
#              recursive=T,
#              pattern="3DPoints.txt",
#              full.names=T) %>% 
#   map_df(~read_files_txt(.))%>%
#   rename(sample=opcode)
# 
# unique(points$campaignid) # 80


## Generic Length ----
length <-
  list.files(path="Data",
             recursive=T,
             pattern="Length.csv",
             full.names=T) %>% 
  map_df(~read_files_csv(.))

unique(lengths$campaignid) # 64

