library(dplyr)
library(tidyr)
library(devtools)
library(stringr)

("C:/Program Files/R/R-3.6.0/library")

install.packages("rcmdcheck","H:/My Documents/R/win-library/3.6")

document()
# 
build()
# 
# 
# 
check()   #have to manually correct the NAMESPACE

install()

library(GlobalArchive)

library(dplyr)



citation("GlobalArchive")

# Test
clean_names(cars)

GlobalArchive::c

q<-query.pattern("sdfsd")
