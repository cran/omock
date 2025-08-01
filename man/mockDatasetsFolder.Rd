% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mockDatasets.R
\name{mockDatasetsFolder}
\alias{mockDatasetsFolder}
\title{Check or set the datasets Folder}
\usage{
mockDatasetsFolder(path = NULL)
}
\arguments{
\item{path}{Path to a folder to store the synthetic datasets. If NULL the
current OMOP_DATASETS_FOLDER is returned.}
}
\value{
The dataset folder.
}
\description{
Check or set the datasets Folder
}
\examples{
\donttest{
mockDatasetsFolder()
mockDatasetsFolder(file.path(tempdir(), "OMOP_DATASETS"))
mockDatasetsFolder()
}

}
