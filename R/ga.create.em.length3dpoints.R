##  ----
#' ga.create.em.length3dpoints function
#'
#' The ga.create.em.length3dpoints function finds all files ending in "Lengths.txt","3DPoints.txt" and combines them into one dataframe 
#'
#' @param object file to be manipulated
#'
#' @return None
#'
#' @examples
#'
#' @export
ga.create.em.length3dpoints<-function(dat){
  
  threedpoints.files <-ga.list.files("3DPoints.txt") # list all files ending in "3DPoints.txt"
  threedpoints.files$lines<-sapply(threedpoints.files,countLines) # Count lines in files (to avoid empty files breaking the script)
  threedpoints<-as.data.frame(threedpoints.files)%>%
    dplyr::mutate(campaign=row.names(.))%>%
    dplyr::filter(lines>1)%>% # filter out all empty text files
    dplyr::select(campaign)%>%
    as_vector(.)%>% # remove all empty files
    purrr::map_df(~ga.read.files_em.txt(.))
  
  # Combine all downloaded Lengths txt files into one data frame (EM)
  lengths.files <-ga.list.files("Lengths.txt") # list all files ending in "Lengths.txt"
  lengths.files$lines<-sapply(lengths.files,countLines) # Count lines in files (to avoid empty files breaking the script)
  lengths<-as.data.frame(lengths.files)%>%
    dplyr::mutate(campaign=row.names(.))%>%
    dplyr::filter(lines>1)%>% # filter out all empty text files
    dplyr::select(campaign)%>%
    as_vector(.)%>% # remove all empty files
    purrr::map_df(~ga.read.files_em.txt(.))
  
  length3dpoints<-lengths%>%
    plyr::rbind.fill(threedpoints)%>%
    dplyr::mutate(length=as.numeric(length))%>%
    dplyr::mutate(number=as.numeric(number))
  return(length3dpoints)
  
}