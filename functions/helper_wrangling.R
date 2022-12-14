###'#############################################################################
###'
###' Helper functions for data wrangling
###' 
###' by Joonho Lee
###'
###'

### Package dependency
library(tidyverse)
library(scales)



###'#############################################################################
###'
###' tabdf(): Tabulate frequencies
###'
###'

tabdf <- function(df,
                  variable){
  
  ### Enquote variables
  x <- enquo(variable)
  
  ### Generate table
  tibble_tbl <- df %>%
    group_by(!!x) %>%
    summarise(Freq = n()) %>%
    ungroup() %>%
    mutate(total_n = sum(Freq, na.rm = TRUE),
           Percent = round((Freq/total_n)*100,1),
           CumFreq = cumsum(Freq),
           CumPercent = round((CumFreq/total_n)*100,1)) %>%
    dplyr::select(-total_n)
  
  ### Display table as data.frame format
  data.frame(tibble_tbl)
  
}



###'#############################################################################
###'
###' classmode(): Check classes and modes of selected variables
###'
###'

classmode <- function(df, ...){
  
  ### Enquote variables
  vars <- quos(...) # any rules for dplyr::selct() works. ex) everything(), ends_with(), etc.
  
  ### Select variables
  df_select <- df %>%
    dplyr::select(!!!vars)
  
  ### Return classes and modes
  mat <- cbind(sapply(df_select,class),
               sapply(df_select,mode))
  
  ### Convert to data.frame format
  df_mat <- data.frame(rownames(mat), mat)
  rownames(df_mat) <- NULL
  names(df_mat) <- c("variable","class","mode")
  
  
  return(df_mat)
  
}



###'#############################################################################
###'
###' listvars(): list selected variables
###'
###'

listvars <- function(df, ..., nrow = 100){
  
  ### Enquote variables
  vars <- quos(...) # any rules for dplyr::selct() works. ex) everything(), ends_with(), etc.
  
  ### Select variables
  df_select <- df %>%
    dplyr::select(!!!vars)
  
  ### Return rows for the selected varialbes
  df_select[1:nrow,]
  
}



###'#############################################################################
###'
###' empty_as_na(): Convert empty strings to NA
###' 
###' it's important to include 'trinws' to remove black spaces
###'
###'

empty_as_na <- function(x){
  
  if('factor' %in% class(x)) x <- as.character(x)
  
  ## since ifelse wont work with factors
  
  ifelse(trinws(as.character(x)) != "", x, NA)
  
}



###'#############################################################################
###'
###' operation14(): Remove districts with insufficient years of data
###' 
###' => Analyze only traditional schools in elementary, high, and unified
###'    school districts that have been in continuous operation (14 years)
###'    in California from 2003 through 2017
###'
###'

 # setwd(work_dir)
 # load("~/processd_data/years_of_operation.rda")
 # data dependency: years_of_operation.csv

operation14 <- function(df){
  
  df %>%
    left_join(years_of_operation[, !names(years_of_operation) %in% c("Dname","Dtype")],
              by = c("Ccode","Dcode")) %>%
    filter(opr_years == 24)
  
}



###'#############################################################################
###'
###' get_weighted_mean(): Get weighted district averages
###'
###'

get_weighted_mean <- function(df,
                              x = Fiscalyear,
                              y = sum_value_PP_16,
                              weight = K12ADA_C,
                              ...){
  
  ### Enquote variables
  x <- enquo(x)
  y <- enquo(y)
  weight <- enquo(weight)
  group_var <- quos(...)
  
  
  df %>%
    group_by(!!x, !!!group_var) %>%
    summarise(mean_value = round(weighted.mean(!!y, !!weight, na.rm = TRUE), 2))
  
}



###'#############################################################################
###'
###' group_percent(): Calculate percentages based on groups
###'
###'

group_percent <- function(df,
                          value = mean_value,
                          ...){
  
  ### Enquote variables
  value <- enquo(value)
  group <- quos(...)
  
  #' (1) Calculate the percentages
  #' (2) Format the labels and calculate their positions
  df %>%
    group_by(!!!group) %>%
    mutate(group_sum = sum(!!value, na.rm = TRUE),
           percent = !!value/group_sum*100,
           # don't need to calculate the label positions from ggplot 2.1.0
           # position = cumsum(amount) - 0.5 * amount,
           label_text = paste0(sprintf("%.1f",percent), "%")) -> df
  return(df)
  
}



###'#############################################################################
###'
###' is.numeric.elementwise():
###' Check whether each element is numeric
###'
###'

is.numeric.elementwise <- function(vector){
  
  lvector <- c()
  
  for (i in seq_along(vector)){
    
    element <- vector[i]
    
    elem_TF <- is.na(as.numeric(element))
    
    lvector <- c(lvector, elem_TF)
    
  }
  
}



###'#############################################################################
###'
###' get_lm_est_df(): Get a dataframe of regression estimates
###'
###'

get_lm_est_df <- function(lm_fit){
  
  summary <- summary(lm_fit)
  
  df <- data.frame(summary$coefficients)
  
  names(df) <- c("estimate", "std_error", "t_value", "p_value")
  
  df <- round(df, 3)
  
  df$variables <- rownames(df)
  rownames(df) <- NULL
  
  df <- df %>%
    dplyr::select(varialbe, everything())
  
  df
    
}



###'#############################################################################
###'
###' school_composition_count()
###'
###'

school_composition_count <- function(df,
                                     var_to_count,
                                     factor,
                                     levels_to_replace = NULL,
                                     tavle_name = "Staff Type",
                                     year = NULL){
  
  ### Enquote variables
  var_to_count <- enquo(var_to_count)
  factor <- enquo(factor)
  
  ### Calculate Subtotal
  df_subtotal <- df %>%
    group_by(CountyCode, DistrictCode, SchoolCode) %>%
    summarise(subtotal = n_distint(!!var_to_count))
  
  ### Calculate Subgroup Counts
  df_by_subgroup <- df %>%
    group_by(CountyCode, DistrictCode, SchoolCode,
             !!!factor) %>%
    summarise(N = n_distinct(!!var_to_count))
  
  ### Calculate Subgroup Percentages
  df_by_subgroup <- df_by_subgroup %>%
    left_join(df_subtotal,
              by = c("CountyCode", "DistrictCode", "SchoolCode")) %>%
    mutate(PCT = 100*(N/subtotal))
  
  ###' Reshape from long to wide data format
  ###' (1) Long data format to spread multiple variables
  df_temp <- df_by_subgroup %>%
    gather(stat, value, N, PCT)
  
  ###' Recode factor levels to brief names
  df_temp <- df_temp %>%
    rename(factor = !!factor)
  
  levels(df_temp$factor) <- levels_to_replace
  
  ###' (3) Reshape to wide format
  df_temp <- df_temp %>%
    unite(key, stat, factor) %>%
    spread(key = key, value = value, fill = 0)
  
  ### Add table name & AcademicYear
  df_temp <- df_temp %>%
    mutate(table = table_name,
           AcademicTear = as.numeric(year))
  
  ### Reorder variables by factor levels
  N_vars <- paste0("N_", levels_to_replace)
  PCT_vars <- paste0("PCT_", levels_to_replace)
  
  N_vars_select <- N_vars[N_vars %in% names(df_temp)]
  PCT_vars_select <- PCT_vars[PCT_vars %in% names(df_temp)]
  
  df_temp <- df_temp %>%
    dplyr::select(ends_with("Code"),
                  table, AcademicYear, subtotal,
                  N_vars_select,
                  PCT_vars_select)
  
  return(df_temp)
  
}



###'#############################################################################
###'
###' school_composition_sum()
###' 
###' => Generate table for summarizing school-level compositions
###' => Based on "SUMMATION" of variable
###'
###'

school_composition_sum <- function(df,
                                     var_to_sum,
                                     factor,
                                     levels_to_replace = NULL,
                                     tavle_name = "Staff Type",
                                     year = NULL){
  
  ### Enquote variables
  var_to_sum <- enquo(var_to_sum)
  factor <- enquo(factor)
  
  ### Calculate Subtotal
  df_subtotal <- df %>%
    group_by(CountyCode, DistrictCode, SchoolCode) %>%
    summarise(subtotal = sum(!!var_to_sum, na.rm = TRUE))
  
  ### Calculate Subgroup Counts
  df_by_subgroup <- df %>%
    group_by(CountyCode, DistrictCode, SchoolCode,
             !!!factor) %>%
    summarise(N = sum(!!var_to_sum, na.rm = TRUE))
  
  ### Calculate Subgroup Percentages
  df_by_subgroup <- df_by_subgroup %>%
    left_join(df_subtotal,
              by = c("CountyCode", "DistrictCode", "SchoolCode")) %>%
    mutate(PCT = 100*(N/subtotal))
  
  ###' Reshape from long to wide data format
  ###' (1) Long data format to spread multiple variables
  df_temp <- df_by_subgroup %>%
    gather(stat, value, N, PCT)
  
  ###' Recode factor levels to brief names
  df_temp <- df_temp %>%
    rename(factor = !!factor)
  
  levels(df_temp$factor) <- levels_to_replace
  
  ###' (3) Reshape to wide format
  df_temp <- df_temp %>%
    unite(key, stat, factor) %>%
    spread(key = key, value = value, fill = 0)
  
  ### Add table name & AcademicYear
  df_temp <- df_temp %>%
    mutate(table = table_name,
           AcademicTear = as.numeric(year))
  
  ### Reorder variables by factor levels
  N_vars <- paste0("N_", levels_to_replace)
  PCT_vars <- paste0("PCT_", levels_to_replace)
  
  N_vars_select <- N_vars[N_vars %in% names(df_temp)]
  PCT_vars_select <- PCT_vars[PCT_vars %in% names(df_temp)]
  
  df_temp <- df_temp %>%
    dplyr::select(ends_with("Code"),
                  table, AcademicYear, subtotal,
                  N_vars_select,
                  PCT_vars_select)
  
  return(df_temp)
  
}



###'#############################################################################
###'
###' school_summarize()
###' 
###' => Generate descriptive statistics table
###'    for summarizing distribution of continuous variable
###'
###'

school_summarize <- function(df,
                             var_to_summarize,
                             table_name,
                             year = NULL){
  
  # unkown
}




  



















