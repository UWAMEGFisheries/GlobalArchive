##  ----
#' create.length3dpoints function
#'
#' The create.length3dpoints function finds all files ending in "Lengths.txt","3DPoints.txt" and "Count.csv" and combines them into one dataframe \code{\link{GlobalArchive}}
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#' create.length3dpoints()
#'
#' @export
create.length3dpoints<-function(dat){
  
  threedpoints.files <-list.files.GA("3DPoints.txt") # list all files ending in "3DPoints.txt"
  threedpoints.files$lines<-sapply(threedpoints.files,countLines) # Count lines in files (to avoid empty files breaking the script)
  threedpoints<-as.data.frame(threedpoints.files)%>%
    mutate(campaign=row.names(.))%>%
    filter(lines>1)%>% # filter out all empty text files
    select(campaign)%>%
    as_vector(.)%>% # remove all empty files
    purrr::map_df(~read_files_txt(.))
  
  # Combine all downloaded Lengths txt files into one data frame (EM)
  lengths.files <-list.files.GA("Lengths.txt") # list all files ending in "Lengths.txt"
  lengths.files$lines<-sapply(lengths.files,countLines) # Count lines in files (to avoid empty files breaking the script)
  lengths<-as.data.frame(lengths.files)%>%
    mutate(campaign=row.names(.))%>%
    filter(lines>1)%>% # filter out all empty text files
    select(campaign)%>%
    as_vector(.)%>% # remove all empty files
    purrr::map_df(~read_files_txt(.))
  
  # Combine all downloaded generic Length.csv files into one data frame
  length.files <-list.files.GA("Length.csv") # list all files ending in "Lengths.txt"
  length.files$lines<-sapply(length.files,countLines) # Count lines in files (to avoid empty files breaking the script)
  length <-as.data.frame(length.files)%>%
    mutate(campaign=row.names(.))%>%
    filter(lines>1)%>% # filter out all empty text files
    select(campaign)%>%
    as_vector(.)%>% # list all files ending in "Length.csv"
    purrr::map_df(~read_files_csv(.))
  
  # If both Eventmeasure and Generic outputs
  if (dim(lengths)[1] > 0 & dim(length)[1] > 0) {
    length3dpoints<-lengths%>%
      plyr::rbind.fill(threedpoints)%>%
      plyr::rbind.fill(length)%>%
      dplyr::mutate(number=ifelse(number%in%c(0,NA),count,number))%>%
      dplyr::select(-c(count))%>%
      dplyr::mutate(length=as.numeric(length))%>%
      dplyr::mutate(number=as.numeric(number))
    return(length3dpoints)
    
    # If only Eventmeausure ouputs
  } else if (dim(lengths)[1] > 0 & dim(length)[2] == 0) {
    length3dpoints<-lengths%>%
      plyr::rbind.fill(threedpoints)%>%
      dplyr::mutate(length=as.numeric(length))%>%
      dplyr::mutate(number=as.numeric(number))
    return(length3dpoints)
    
    # if only Generic outputs
  } else (dim(lengths)[2] == 0 & dim(length)[1] > 0)
  length3dpoints<-length%>%
    dplyr::rename(number=count)%>%
    dplyr::mutate(length=as.numeric(length))%>%
    dplyr::mutate(number=as.numeric(number))
  return(length3dpoints)
}