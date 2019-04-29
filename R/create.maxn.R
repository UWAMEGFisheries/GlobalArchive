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
#' create.maxn()
#'
#' @export
create.maxn<-function(dat,include.count.files=FALSE){
  points <-list.files.GA("_Points.txt")%>% # list all files ending in "_Points.txt"
    purrr::map_df(~read_files_txt(.))
  
  if(include.count.files==TRUE){count <-list.files.GA("Count.csv")%>% # list all files ending in "Count.csv"
    purrr::map_df(~read_files_csv(.))
  } 
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
  
  if(include.count.files==TRUE){maxn<-maxn%>% 
    plyr::rbind.fill(count)%>%
    tidyr::replace_na(list(maxn=0))%>%
    dplyr::mutate(maxn=ifelse(maxn%in%c(0,NA),count,maxn))%>% 
    dplyr::mutate(maxn=as.numeric(maxn))%>%
    dplyr::select(-c(count))%>%
    dplyr::filter(maxn>0)
  
  } 
}