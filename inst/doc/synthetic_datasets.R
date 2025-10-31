## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----echo=FALSE---------------------------------------------------------------
options(timeout = 600)

## -----------------------------------------------------------------------------
library(omock)

## ----echo=FALSE---------------------------------------------------------------
niceSize <- function(x) {
  purrr::map_chr(x, \(x) {
    if (x < 1024) {
      x <- fprintf("%i B", x)
    } else if (x < 1024**2) {
      x <- x / 1024
      x <- paste(formatC(x, digits = 3, format = "fg", flag = "#"), "kB")
    } else if (x < 1024**3) {
      x <- x / 1024**2
      x <- paste(formatC(x, digits = 3, format = "fg", flag = "#"), "MB")
    } else {
      x <- x / 1024**3
      x <- paste(formatC(x, digits = 3, format = "fg", flag = "#"), "GB")
    }
    stringr::str_squish(x)
  })
}
mockDatasets |>
  dplyr::mutate(
    size = niceSize(.data$size),
    link = paste0("[🔗](", .data$url, ")"),
    dplyr::across(
      c("number_individuals", "number_records", "number_concepts"),
      \(x) format(x, big.mark = ",")
    )
  ) |>
  dplyr::select(
    "datasetName" = "dataset_name", "CDM name" = "cdm_name",
    "CDM version" = "cdm_version", "Size" = "size",
    "Number individuals" = "number_individuals",
    "Number records" = "number_records", "Number concepts" = "number_concepts",
    "Link" = "link"
  ) |>
  gt::gt() |>
  gt::fmt_markdown("Link")

## -----------------------------------------------------------------------------
availableMockDatasets()

## -----------------------------------------------------------------------------
omopDataFolder()

## -----------------------------------------------------------------------------
downloadMockDataset(datasetName = "GiBleed")

## -----------------------------------------------------------------------------
list.files(path = omopDataFolder(), recursive = TRUE)

## -----------------------------------------------------------------------------
cdm <- mockCdmFromDataset(datasetName = "GiBleed")
cdm

## -----------------------------------------------------------------------------
cdm <- mockCdmFromDataset(datasetName = "GiBleed")
cdm

## -----------------------------------------------------------------------------
cdm <- mockCdmFromDataset(datasetName = "GiBleed", source = "duckdb")
cdm

