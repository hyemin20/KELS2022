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
###' Date: 2022-09-17 `initiated`
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
file_path <- file.path(data_dir, "1_DataCleaning_6_cleaned_combind.csv")
file_path_a <- file.path(data_dir, "1_DataCleaning_7_transfer_before.csv")

df <- read_csv(file = file_path) %>% tibble()
transe <- read_csv(file = file_path_a) %>% tibble()


### combine necessary colums
transe_f <- transe %>%
  select(stuID, trans_Y1, trans_Y2, trans_Y3)


df_f <- left_join(df, transe_f, by='stuID')

nrow(df_f)
names(df_f)

write.csv(df_f,file="1_DataCleaning_8_transfer_combind.csv")
