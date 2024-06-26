% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mockConditionOccurrence.R
\name{mockConditionOccurrence}
\alias{mockConditionOccurrence}
\title{Function to generate condition occurrence table}
\usage{
mockConditionOccurrence(cdm, recordPerson = 1, seed = 1)
}
\arguments{
\item{cdm}{the CDM reference into which the synthetic cohort will be added}

\item{recordPerson}{The expected number of records per person within each cohort. This can help simulate the frequency of observations for individuals in the cohort.}

\item{seed}{A random seed to ensure reproducibility of the generated data.}
}
\value{
A cdm reference with the mock tables
}
\description{
Function to generate condition occurrence table
}
\examples{
\donttest{
library(omock)

cdm <- mockCdmReference() |> mockPerson() |> mockObservationPeriod() |>
mockConditionOccurrence()

cdm$condition_occurrence

}
}
