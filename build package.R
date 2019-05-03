library(dplyr)
library(tidyr)
library(devtools)
library(stringr)
library(audio)
#library(RCurl)

document()

build()

check()   #have to manually correct the NAMESPACE - not anymore

install()

library(GlobalArchive)

library(dplyr)

GlobalArchive::create.maxn()

citation("GlobalArchive")

# Test
clean_names(cars)

GlobalArchive::c

q<-query.pattern("sdfsd")
