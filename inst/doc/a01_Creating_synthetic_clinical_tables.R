## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----message=FALSE, warning=FALSE---------------------------------------------
library(omock)
library(dplyr)
library(ggplot2)

## -----------------------------------------------------------------------------
cdm <- emptyCdmReference(cdmName = "synthetic cdm") %>% 
  mockPerson(nPerson = 1000) %>% 
  mockObservationPeriod()

cdm

cdm$person %>% glimpse()

cdm$observation_period %>% glimpse()

## -----------------------------------------------------------------------------
cdm <- emptyCdmReference(cdmName = "synthetic cdm") %>% 
  mockPerson(nPerson = 1000,
             birthRange = as.Date(c("1960-01-01", "1980-12-31"))) %>% 
  mockObservationPeriod()

## -----------------------------------------------------------------------------
cdm$person %>% 
  collect() %>% 
  ggplot() +
  geom_histogram(aes(as.integer(year_of_birth)), 
                 binwidth = 1, colour = "grey") +
  theme_minimal() + 
  xlab("Year of birth")

