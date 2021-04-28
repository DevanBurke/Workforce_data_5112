# load packages -----------------------------------
library(readxl)
library(readr)
library(dplyr)
library(janitor)
library(here)
library(purrr)
library(glue)
library(lubridate)
library(ggplot2)

# pull data from data.ca.gov, this may take a few minutes
# do we need type_convert?
all_years_5112 <- readr::read_csv(url('https://data.ca.gov/dataset/e620a64f-6b86-4ce0-ab4b-03d06674287b/resource/d308f328-6b5b-41c1-8bc2-a4afcfcee3d1/download/5112-inline-report_12.31.20.csv')) %>%
  type_convert()

# Add year column to dataset
with_date <- all_years_5112 %>% mutate("As Of Date"= as.Date("2020-12-31"))

# Filtering for EPA and related BDOs 
epa_5112 <- with_date %>% filter(Department == "Air Resources Board"|
                    Department == "Environmental Health Hazard Assessment, Office of"|
                    Department == "Environmental Protection Agency"|
                    Department == "Pesticide Regulation, Department of"|
                     Department == "Resources Recycling and Recovery, Department of"|
                     Department == "Toxic Substances Control, Department of"|
                     Department == "Water Resources Control Board")

plot_1 <- ggplot() +
  geom_bar(data = epa_5112, aes(Ethnicity)) +
  coord_flip()

# !!!!!!!!!!!!!!! ENTER THE RANGE OF YEARS WITH 5102 REPORTS !!!!!!!!!!!!!!!
# IF YOU JUST WANT ONE YEAR, INPUT THAT ONE YEAR AS FIRST AND SECOND
first_year <- 2011
second_year <- 2011

# creates date values
first_date <- first_year %>% glue('-01-01')
second_date <- second_year %>% glue('-12-31')
year_range <- as.Date(as.Date(first_date):as.Date(second_date), origin="1970-01-01")


# save the original column names - may want to revert back to these when saving the output file
names_all_5102_report <- names(all_years_5102) 


# clean up the column names to make them easier to work with in R
all_years_5102 <- all_years_5102 %>% 
  clean_names() 


# check the number of NAs in the original dataset (to be sure there's a value for each record)
# this should come out as 0
sum(is.na(all_years_5102$as_of_date))


# filters for the years you want to view
my_years_5102 <- all_years_5102 %>% filter(between(as_of_date, as.Date(first_date), as.Date(second_date)))
View(my_years_5102)


# write the processed data to a new file -----------------------------------
# revert back to the original names 
# (assuming that we want the output dataset to have the same column names as the source datasets)
names(my_years_5102) <- names_all_5102_report


# write the data to the '03_data_processed' folder
# NOTE: writing the data to a gzip file rather than a regular csv to save space - you can 
# read/write using this format directly with R using the readr package, and you can extract 
# it to a regular csv using 7zip (or some other software)
write_csv(x = my_years_5102, 
          file = "my_years_5102.csv",
          col_names = TRUE)


# also writing  a copy of the data directly to the shiny folder, since all of the code/data for 
# the app needs to be contained within a single folder in order to load to shinyapps.io
#if they want to do this multiple times, would they just have to change it themselves? or a for loop?
dir.create("calhr_5102_shiny")
write_csv(x = my_years_5102, 
          file = here('calhr_5102_shiny',
                      glue('calhr_5102_',
                           first_year,
                           '_to_',
                           second_year,
                           '.csv')))