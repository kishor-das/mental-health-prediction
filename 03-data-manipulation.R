library(tidyverse)
library(readxl)
library(dplyr)

Ranked_Measure_Data <- function(year) {

  
  # Read the Excel file
  file_path <- paste0('./data/', year, '.csv')
  df_ranked_measure_data <- read_excel(file_path, sheet = 'Ranked Measure Data', skip = 1)
  
  # Get real column names
  real_col_names <- names(read_excel(file_path, sheet = 'Ranked Measure Data', skip = 1))
  
  # Convert column names to lowercase
  col_names_transf <- tolower(names(df_ranked_measure_data))
  
  # Rename columns
  names(df_ranked_measure_data) <- col_names_transf
  
  # Define columns to keep
  keep_col_lst <- c(
    'FIPS',
    'State',
    'County',
    'Population',
    'Income Ratio',
    '% Physically Inactive',
    'Physical Inactivity',
    'Household Income',
    'Average Number of Physically Unhealthy Days',
    'Average Number of Mentally Unhealthy Days',
    '% Adults with Obesity',
    'Total deaths',
    'Deaths',
    'Physically Unhealthy Days',
    'Mentally Unhealthy Days',
    '% Obese',
    'Median Household Income',
    'Teen Birth Rate',
    'No of Medicare enrollees',
    '% unemployed',
    '% Single-Parent Households',
    'Violent Crimes',
    '# Medicare enrollees',
    '% Unemployed',
    '# Some College',
    'Annual Violent Crimes',
    'Food Environment Index',
    '# Deaths',
    '# Violent Crimes',
    '% Insufficient Sleep'
  )
  
  # Transform keep column list to lowercase
  keep_col_lst_transf <- tolower(keep_col_lst)
  
  # Select only the columns that exist in both the dataframe and the keep list
  existing_cols <- intersect(names(df_ranked_measure_data), keep_col_lst_transf)
  df_ranked_measure_data <- df_ranked_measure_data[, existing_cols, drop = FALSE]
  
  # Add year column
  df_ranked_measure_data$year <- as.character(year)
  
  # Assign to global environment (equivalent to Python's locals())
  assign(paste0('df_Ranked_Measure_Data_', year), df_ranked_measure_data, envir = .GlobalEnv)
  
  return(df_ranked_measure_data)
}


Additional_Measure_Data <- function(year) {
  # Read the Excel file
  file_path <- paste0('./data/', year, '.csv')
  df_additional_measure_data <- read_excel(file_path, sheet = 'Additional Measure Data', skip = 1)
  
  # Get real column names
  real_col_names <- names(read_excel(file_path, sheet = 'Additional Measure Data', skip = 1))
  
  # Convert column names to lowercase
  col_names_transf <- tolower(names(df_additional_measure_data))
  
  # Rename columns
  names(df_additional_measure_data) <- col_names_transf
  
  # Define columns to keep
  keep_col_lst <- c(
    'FIPS',
    'State',
    'County',
    'Population',
    'Income Ratio',
    '% Physically Inactive',
    'Physical Inactivity',
    'Household Income',
    'Average Number of Physically Unhealthy Days',
    'Average Number of Mentally Unhealthy Days',
    '% Adults with Obesity',
    'Total deaths',
    'Deaths',
    'Physically Unhealthy Days',
    'Mentally Unhealthy Days',
    '% Obese',
    'Median Household Income',
    'Teen Birth Rate',
    'No of Medicare enrollees',
    '% unemployed',
    '% Single-Parent Households',
    'Violent Crimes',
    '# Medicare enrollees',
    '% Unemployed',
    '# Some College',
    'Annual Violent Crimes',
    'Food Environment Index',
    '# Deaths',
    '# Violent Crimes',
    '% Insufficient Sleep'
  )
  
  # Transform keep column list to lowercase
  keep_col_lst_transf <- tolower(keep_col_lst)
  
  # Select only the columns that exist in both the dataframe and the keep list
  existing_cols <- intersect(names(df_additional_measure_data), keep_col_lst_transf)
  df_additional_measure_data <- df_additional_measure_data[, existing_cols, drop = FALSE]
  
  # Add year column
  df_additional_measure_data$year <- as.character(year)
  
  # Assign to global environment (equivalent to Python's locals())
  assign(paste0('df_Additional_Measure_Data_', year), df_additional_measure_data, envir = .GlobalEnv)
  
  return(df_additional_measure_data)
}


library(dplyr)

# Define the years to iterate over
iter_Years <- c(2015, 2016, 2017, 2018, 2019, 2020)

# Initialize empty data frame for Ranked Measure Data
df_Ranked_Measure_Data_final <- data.frame()

# Loop through years for Ranked Measure Data
for (i in iter_Years) {
  # Get data for current year
  current_data <- Ranked_Measure_Data(i)
  
  # Remove duplicate columns (keep first occurrence)
  current_data <- current_data[, !duplicated(names(current_data))]
  
  # Combine with final dataframe
  df_Ranked_Measure_Data_final <- bind_rows(df_Ranked_Measure_Data_final, current_data)
}

# Initialize empty data frame for Additional Measure Data
df_Additional_Measure_Data_final <- data.frame()

# Loop through years for Additional Measure Data
for (i in iter_Years) {
  # Get data for current year
  current_data <- Additional_Measure_Data(i)
  
  # Remove duplicate columns (keep first occurrence)
  current_data <- current_data[, !duplicated(names(current_data))]
  
  # Combine with final dataframe
  df_Additional_Measure_Data_final <- bind_rows(df_Additional_Measure_Data_final, current_data)
}

write_csv(df_Ranked_Measure_Data_final, './data/df_Ranked_Measure_Data_final.csv')
write_csv(df_Additional_Measure_Data_final, './data/df_Additional_Measure_Data_final.csv')

