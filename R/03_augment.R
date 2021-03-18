# Clear workspace ---------------------------------------------------------
rm(list = ls())


# Load libraries ----------------------------------------------------------
library("tidyverse")


# Define functions --------------------------------------------------------
#source(file = "R/99_project_functions.R")


# Load data ---------------------------------------------------------------
my_data_clean <- read_tsv(file = "data/gravier_clean_aug.tsv.gz")


# Wrangle data ------------------------------------------------------------
my_data_clean_aug <- my_data_clean %>%
  mutate(value = case_when(value == "good" ~ 0,
                           value == "poor" ~ 1))

# Write data --------------------------------------------------------------
write_tsv(x = my_data_clean_aug,
          path = "data/gravierbinarized_clean_aug.tsv")