library(dplyr)
library(tidyr)
library(devtools)
library(stringr)
#library(RCurl)

document()

build()

check()   #have to manually correct the NAMESPACE - not anymore

install()

library(GlobalArchive)

library(dplyr)


citation("GlobalArchive")

# Test
clean_names(cars)

create.