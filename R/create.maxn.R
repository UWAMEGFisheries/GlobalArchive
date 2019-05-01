##  ----
#' create.maxn function
#'
#' The create.maxn function finds all files ending in "Points.txt" and "Count.csv" and combines them into a maxn file \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export
create.maxn<-function(dat){
  
  points.files <-list.files.GA("Points.txt") # list all files ending in "Lengths.txt"
  points.files$lines<-sapply(points.files,countLines) # Count lines in files (to avoid empty files breaking the script)
  
  points<-as.data.frame(points.files)%>%
    dplyr::mutate(campaign=row.names(.))%>%
    filter(lines>1)%>% # filter out all empty text files
    dplyr::select(campaign)%>%
    as_vector(.)%>% # remove all empty files
    purrr::map_df(~read_files_txt(.))
  
  count.files <-list.files.GA("Count.csv") # list all files ending in "Lengths.txt"
  count.files$lines<-sapply(count.files,countLines) # Count lines in files (to avoid empty files breaking the script)
  
  count<-as.data.frame(count.files)%>%
    dplyr::mutate(campaign=row.names(.))%>%
    dplyr::filter(lines>1)%>% # filter out all empty text files
    dplyr::select(campaign)%>%
    as_vector(.)%>% # remove all empty files
    purrr::map_df(~read_files_csv(.))
  
  # If count is blank but there are points
  if (dim(count)[1] == 0 & dim(points)[1] > 0) {
    maxn<-points%>%
      dplyr::group_by(campaignid,sample,frame,family,genus,species)%>%
      dplyr::mutate(number=as.numeric(number))%>%
      dplyr::summarise(maxn=sum(number))%>%
      dplyr::group_by(campaignid,sample,family,genus,species)%>%
      dplyr::slice(which.max(maxn))%>%
      dplyr::ungroup()%>%
      dplyr::filter(!is.na(maxn))%>%
      dplyr::select(-frame)%>%
      tidyr::replace_na(list(maxn=0))%>%
      dplyr::mutate(maxn=as.numeric(maxn))%>%
      dplyr::filter(maxn>0)
    return(maxn)
    
    # if both aren't blank
  } else if (dim(count)[1] > 0 & dim(points)[1] > 0) {
    maxn <-points%>%
      dplyr::group_by(campaignid,sample,frame,family,genus,species)%>%
      dplyr::mutate(number=as.numeric(number))%>%
      dplyr::summarise(maxn=sum(number))%>%
      dplyr::group_by(campaignid,sample,family,genus,species)%>%
      dplyr::slice(which.max(maxn))%>%
      dplyr::ungroup()%>%
      dplyr::filter(!is.na(maxn))%>%
      dplyr::select(-frame)%>%
      tidyr::replace_na(list(maxn=0))%>%
      dplyr::mutate(maxn=as.numeric(maxn))%>%
      dplyr::filter(maxn>0)%>% 
      plyr::rbind.fill(count)%>%
      tidyr::replace_na(list(maxn=0))%>%
      dplyr::mutate(maxn=ifelse(maxn%in%c(0,NA),count,maxn))%>% 
      dplyr::mutate(maxn=as.numeric(maxn))%>%
      dplyr::select(-c(count))%>%
      dplyr::filter(maxn>0)
    return(maxn)
    
    # if only count
  } else (dim(count)[1] > 0 & dim(points)[1] == 0)
  maxn <-count%>%
    dplyr::group_by(campaignid,sample,family,genus,species)%>%
    dplyr::rename(maxn=count)%>%
    dplyr::slice(which.max(maxn))%>%
    dplyr::ungroup()%>%
    dplyr::filter(!is.na(maxn))
  return(maxn)
}