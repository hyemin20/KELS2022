###' ###########################################################################'
###' 
###' Project(project name): KELS2022
###' 
###' Category(stage in the project): Data management
###' 
###' Task(specific task in the category): Data cleaning
###' 
###' Data(data source): `KELS Y3Y4`
###' 
###' Date: 2022-09-15 `initiated`
###' 
###' Author: Hyemin Park(`hyemin.park@snu.ac.kr`)
###' 
###'

###' ###########################################################################'
###' 
###' Basic settings
###' 
###' 

### Start with clean state
gc(); rm(list=ls())


### Set working directory and data directory
work_dir <- c("D:/HYEM'S/GraduatedSchool/PROJECTS/MyProjects/KELS2022")
data_dir <- file.path(work_dir, "datasets")
setwd(work_dir)


### Call libraries
library(tidyverse)
library(readr)



###' ###########################################################################'
###' 
###' Import survey items
###' 
###' 

### Set file path
file_path <- file.path(data_dir, "1_DataCleaning_1_data_extract_from.csv")
file_path_db <- file.path(data_dir, "1_DataCleaning_2_data_extract_to.csv")
df <- read_csv(file = file_path) %>% tibble()
etc <- read_csv(file = file_path_db) %>% tibble()


### combine necessary colums
names(df)
names(etc)
etc_f <- etc %>%
  select(L2Y3_SCHID, L2Y3_REG, L2Y3DB2_2_2, L2Y3DB2_3_1, L2Y3DB2_3_2) %>%
  rename('schID' = L2Y3_SCHID)


df_f <- left_join(df, etc_f, by='schID')
names(df_f)

write.csv(df_f,file="data_extract_2.csv")
