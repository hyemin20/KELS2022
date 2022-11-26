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
###' Date: 2022-09-16 `initiated`
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
file_path <- file.path(data_dir, "1_DataCleaning_4_data_cleaned.csv")
file_path_a <- file.path(data_dir, "1_DataCleaning_5_region_dummy.csv")
file_path_b <- file.path(data_dir, "1_DataCleaning_5_school_level_a.csv")

df <- read_csv(file = file_path) %>% tibble()
region <- read_csv(file = file_path_a) %>% tibble()
school <- read_csv(file = file_path_b) %>% tibble()


### combine necessary colums
names(df)
region
school


df_a <- left_join(df, region, by='stuID')
df_b <- left_join(df_a, school, by='schID')

nrow(df_b)
names(df_b)

write.csv(df_b,file="1_DataCleaning_6_cleaned_combind.csv")
