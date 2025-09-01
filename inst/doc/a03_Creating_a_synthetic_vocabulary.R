## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----message=FALSE, warning=FALSE---------------------------------------------
library(omock)
library(dplyr)

## -----------------------------------------------------------------------------
cdm <- emptyCdmReference(cdmName = "synthetic cdm") |>
  mockPerson(nPerson = 10, birthRange = as.Date(c("1960-01-01", "1980-12-31"))) |>
  mockObservationPeriod()

## -----------------------------------------------------------------------------
cdm <- mockVocabularyTables(cdm, vocabularySet = "mock")
cdm$vocabulary |> print()

## -----------------------------------------------------------------------------
cdm <- mockVocabularyTables(cdm, vocabularySet = "eunomia")
cdm$vocabulary |> print()

## -----------------------------------------------------------------------------
myConceptTable <- data.frame(
  concept_id = 1:3,
  concept_name = c("Condition A", "Condition B", "Drug C"),
  domain_id = c("Condition", "Condition", "Drug"),
  vocabulary_id = c("SNOMED", "SNOMED", "RxNorm"),
  concept_class_id = c("Clinical Finding", "Clinical Finding", "Ingredient"),
  standard_concept = c("S", "S", "S"),
  concept_code = c("111", "222", "333"),
  valid_start_date = as.Date("1970-01-01"),
  valid_end_date = as.Date("2099-12-31"),
  invalid_reason = NA
)

cdm <- mockVocabularyTables(cdm, 
                            vocabularySet = "eunomia",
                            concept = myConceptTable) 

cdm$concept |> print()

