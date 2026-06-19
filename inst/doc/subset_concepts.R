## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(omock)
library(dplyr)

## -----------------------------------------------------------------------------
cdm <- mockCdmReference() |>
  mockVocabularyTables()

cdm$concept |>
  tally()

## -----------------------------------------------------------------------------
cdm_subset <- cdm |>
  subsetVocabularyTables(conceptSet = c(8507L, 8532L))

cdm_subset$concept |>
  select(concept_id, concept_name, domain_id, vocabulary_id)

## -----------------------------------------------------------------------------
cdm_strict <- cdm |>
  subsetVocabularyTables(
    conceptSet = c(8507L, 8532L),
    includeRelated = FALSE
  )

cdm_strict$concept |>
  count(domain_id)

## -----------------------------------------------------------------------------
cdm_no_defaults <- cdm |>
  subsetVocabularyTables(
    conceptSet = c(8507L, 8532L),
    includeRelated = FALSE,
    keepDomains = character(0)
  )

cdm_no_defaults$concept |>
  select(concept_id, concept_name, domain_id)

## -----------------------------------------------------------------------------
cdm_clinical <- mockVocabularyTables() |>
  mockPerson(nPerson = 10, seed = 1) |>
  mockObservationPeriod(seed = 1) |>
  mockConditionOccurrence(seed = 1)

cdm_clinical_small <- cdm_clinical |>
  subsetVocabularyTables(conceptSet = c(8507L, 8532L))

cdm_clinical_small$concept |>
  tally()

## -----------------------------------------------------------------------------
cdm_example <- mockVocabularyTables(
  concept = dplyr::tibble(
    concept_id = c(1L, 2L, 3L),
    concept_name = c("condition a", "condition b", "gender"),
    domain_id = c("Condition", "Condition", "Gender"),
    vocabulary_id = c("SNOMED", "SNOMED", "Gender"),
    standard_concept = "S",
    concept_class_id = c("Clinical Finding", "Clinical Finding", "Gender"),
    concept_code = "1",
    valid_start_date = as.Date(NA),
    valid_end_date = as.Date(NA),
    invalid_reason = NA_character_
  )
) |>
  mockCdmFromTables(tables = list(
    person = dplyr::tibble(
      person_id = c(1L, 2L),
      gender_concept_id = c(3L, 3L),
      year_of_birth = c(1990L, 1991L)
    ),
    condition_occurrence = dplyr::tibble(
      condition_occurrence_id = c(1L, 2L),
      person_id = c(1L, 2L),
      condition_concept_id = c(1L, 2L),
      condition_start_date = as.Date(c("2020-01-01", "2020-01-02")),
      condition_end_date = as.Date(c("2020-01-01", "2020-01-02")),
      condition_type_concept_id = c(0L, 0L)
    )
  ))

cdm_example_small <- cdm_example |>
  subsetVocabularyTables(
    conceptSet = 1L,
    includeRelated = FALSE,
    keepDomains = "Gender"
  )

cdm_example_small$concept |>
  select(concept_id, domain_id)

cdm_example_small$condition_occurrence |>
  select(person_id, condition_concept_id)

