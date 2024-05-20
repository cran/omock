## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup,message=FALSE, warning=FALSE---------------------------------------
library(omock)
library(dplyr)
library(lubridate)

## ----warning = FALSE----------------------------------------------------------
# Define a list of user-defined cohort tables
cohortTables <- list(
  cohort1 = tibble(
    subject_id = 1:10,
    cohort_definition_id = rep(1, 10),
    cohort_start_date = as.Date('2020-01-01') + 1:10,
    cohort_end_date = as.Date('2020-01-01') + 11:20
  ),
  cohort2 = tibble(
    subject_id = 11:20,
    cohort_definition_id = rep(2, 10),
    cohort_start_date = as.Date('2020-02-01') + 1:10,
    cohort_end_date = as.Date('2020-02-01') + 11:20
  )
)

# Create a mock CDM object from the user-defined tables
cdm <- mockCdmReference() |> mockCdmFromTables(tables = cohortTables)

cdm |> glimpse()


