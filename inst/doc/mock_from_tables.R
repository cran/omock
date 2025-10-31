## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(omock)
library(dplyr, warn.conflicts = FALSE)
library(PatientProfiles)

## ----warning = FALSE----------------------------------------------------------
# Define a list of user-defined cohort tables
cohortTables <- list(
  cohort1 = tibble(
    subject_id = 1:10L,
    cohort_definition_id = rep(1L, 10),
    cohort_start_date = as.Date("2020-01-01") + 1:10,
    cohort_end_date = as.Date("2020-01-01") + 11:20
  ),
  cohort2 = tibble(
    subject_id = 11:20L,
    cohort_definition_id = rep(2L, 10),
    cohort_start_date = as.Date("2020-02-01") + 1:10,
    cohort_end_date = as.Date("2020-02-01") + 11:20
  )
)

# Create a mock CDM object from the user-defined tables
cdm <- mockCdmFromTables(tables = cohortTables)

cdm

## -----------------------------------------------------------------------------
cdm$cohort1 |>
  addInObservation()
cdm$observation_period

## -----------------------------------------------------------------------------
person <- tibble(person_id = 1:5L, gender_concept_id = 8532L, year_of_birth = 1992)

## -----------------------------------------------------------------------------
drugExposure <- tibble(
  person_id = rep(1:5L, 2),
  drug_concept_id = 19073188L,
  drug_exposure_start_date = rep(as.Date(c("2000-01-01", "2000-06-1")), each = 5),
  drug_exposure_end_date = drug_exposure_start_date + c(10L, 20L, 100L, 140L, 30L, 50L, 30L, 20L, 45L, 35L)
)

## ----eval = FALSE-------------------------------------------------------------
# cdm <- mockCdmFromTables(tables = list(person = person, drug_exposure = drugExposure))
# 
# cdm

## ----eval = FALSE-------------------------------------------------------------
# cdm$drug_exposure |>
#   addInObservation() |>
#   group_by(in_observation) |>
#   tally()

