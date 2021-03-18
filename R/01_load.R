# Clear workspace ---------------------------------------------------------
rm(list = ls())
# check check

# Load libraries ----------------------------------------------------------
library("tidyverse")


# Define functions --------------------------------------------------------
#source(file = "R/99_project_functions.R")


# Load data ---------------------------------------------------------------
load(file = "data/_raw/gravier.RData")
#my_data_raw <- read_tsv(file = "data/_raw/gravier.RData")


# Wrangle data ------------------------------------------------------------
my_data_x <- gravier %>%
  pluck("x")
my_data_y <- gravier %>%
  pluck("y") %>%
  as_tibble()

# Write data --------------------------------------------------------------
write_tsv(x = my_data_x,
          path = "data/gravier_x.tsv.gz")
write_tsv(x = my_data_y,
          path = "data/gravier_y.tsv.gz")
