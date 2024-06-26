% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mockPerson.R
\name{mockPerson}
\alias{mockPerson}
\title{mockPerson}
\usage{
mockPerson(
  cdm = mockCdmReference(),
  nPerson = 10,
  birthRange = as.Date(c("1950-01-01", "2000-12-31")),
  proportionFemale = 0.5,
  seed = 1
)
}
\arguments{
\item{cdm}{Name of the cdm object}

\item{nPerson}{number of mock person to create in person table}

\item{birthRange}{birthday range of the person in person table}

\item{proportionFemale}{proportion of person in the person table are female}

\item{seed}{random seed}
}
\value{
A cdm reference with the mock person table
}
\description{
mockPerson
}
\examples{
\donttest{
library(omock)
cdm <- mockPerson(cdm = mockCdmReference(),nPerson = 10)

cdm$person


}

}
