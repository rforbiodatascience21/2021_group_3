# Clear workspace ---------------------------------------------------------
rm(list = ls())


# Load libraries ----------------------------------------------------------
library("tidyverse")
library(broom)
library(purrr)
library(vroom)


# Define functions --------------------------------------------------------
#source(file = "R/99_project_functions.R")


# Load data ---------------------------------------------------------------
gravier_x <- read_tsv(file = "data/gravier_x.tsv.gz")
gravier_y <- read_tsv(file = "data/gravier_y.tsv.gz")

# Wrangle data ------------------------------------------------------------
my_data_clean_aug <- bind_cols(gravier_x, gravier_y)

# Write data --------------------------------------------------------------
write_tsv(x = my_data_clean_aug,
          path = "data/gravier_clean_aug.tsv.gz")