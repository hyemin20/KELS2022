###' ###########################################################################'
###' 
###' Project(project name): KELS2022
###' 
###' Category(stage in the project): Data management
###' 
###' Task(specific task in the category): Data Descriptive Analysis
###' 
###' Data(data source): `KELS Y1Y2`
###' 
###' Date: 2022-09-20 `initiated`
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
work_dir <- c("D:/HYEM'S/GraduatedSchool/PROJECTS/MyProjects/KELS2022/datasets")
data_dir <- file.path(work_dir, "ele_6")
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
file_path <- file.path(data_dir, "1_DataCleaning_5_cleaned.csv")
df <- read_csv(file = file_path) %>% tibble()


### combine necessary colums
names(df)
table(df$trans)
length(which(df$trans == 0 & df$trans_Y1 == 1))


###' ###########################################################################'
###' 
###' Import survey items
###' 
###' 


file_path_a <- file.path(data_dir, "1_DataCleaning_2_data_combined.csv")
file_path_b <- file.path(data_dir, "1_DataCleaning_3_school_level.csv")

data <- read_csv(file = file_path_a) %>% tibble()
school <- read_csv(file = file_path_b) %>% tibble()


### combine necessary colums
names(data)
school


df_a <- left_join(data, school, by='schID')

nrow(df_a)
names(df_a)

write.csv(df_a,file="1_DataCleaning_4_combind.csv")

