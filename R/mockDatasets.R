
#' Create a `local` cdm_reference from a dataset.
#'
#' @param datasetName Name of the mock dataset. See `availableMockDatasets()`
#' for possibilities.
#'
#' @return A local cdm_reference object.
#' @export
#'
#' @examples
#' library(omock)
#'
#' mockDatasetsFolder(tempdir())
#' downloadMockDataset(datasetName = "GiBleed")
#' cdm <- mockCdmFromDataset(datasetName = "GiBleed")
#' cdm
#'
mockCdmFromDataset <- function(datasetName = "GiBleed") {
  # initial check
  datasetName <- validateDatasetName(datasetName)
  cn <- omock::mockDatasets$cdm_name[omock::mockDatasets$dataset_name == datasetName]
  cv <- omock::mockDatasets$cdm_version[omock::mockDatasets$dataset_name == datasetName]

  # make dataset available
  datasetPath <- datasetAvailable(datasetName)

  # folder to unzip
  tmpFolder <- file.path(tempdir(), omopgenerics::uniqueId())
  if (dir.exists(tmpFolder)) {
    unlink(x = tmpFolder, recursive = FALSE)
  }
  dir.create(tmpFolder)

  # unzip
  utils::unzip(zipfile = datasetPath, exdir = tmpFolder)
  cli::cli_inform(c(i = "Reading {.pkg {datasetName}} tables."))
  tables <- readTables(tmpFolder, cv)

  # delete csv files
  unlink(x = tmpFolder, recursive = TRUE)

  # add drug strength
  cli::cli_inform(c(i = "Adding {.pkg drug_strength} table."))
  if (datasetName == "GiBleed") {
    tables$drug_strength <- eunomiaDrugStrength
  } else {
    concepts <- tables$concept$concept_id
    tables$drug_strength <- getDrugStrength() |>
      dplyr::filter(
        .data$drug_concept_id %in% .env$concepts &
          .data$ingredient_concept_id %in% .env$concepts
      )
  }

  omopgenerics::cdmFromTables(tables = tables, cdmName = cn, cdmVersion = cv)
}
readTables <- function(tmpFolder, cv) {
  tables <- list.files(tmpFolder, full.names = TRUE, pattern = "\\.parquet$", recursive = TRUE)
  names(tables) <- substr(basename(tables), 1, nchar(basename(tables)) - 8)
  tables <- as.list(tables)
  x <- omopgenerics::omopTableFields(cdmVersion = cv)
  for (nm in names(tables)) {
    # read file
    tables[[nm]] <- arrow::read_parquet(file = tables[[nm]]) |>
      # cast columns
      castColumns(name = nm, version = cv)
  }

  tables
}
getDrugStrength <- function() {
  drugStregthZip <- file.path(mockDatasetsFolder(), "drug_strength.csv")

  # download if it does not exist
  if (!file.exists(drugStregthZip)) {
    cli::cli_inform(c("i" = "Downloading {.pkg drug_strength} table."))
    dropbox_url <- "https://www.dropbox.com/scl/fi/gw6eou1wrneh2h5w3r5we/drug_strength.zip?rlkey=dssh3kpt56xuenguvym1ml7cc&st=e76jev5j&dl=1"
    utils::download.file(
      url = dropbox_url, destfile = drugStregthZip, mode = "wb", quiet = FALSE
    )
  }

  # unzip
  tempFolder <- file.path(tempdir(), omopgenerics::uniqueId())
  dir.create(tempFolder, showWarnings = FALSE)
  utils::unzip(zipfile = drugStregthZip, exdir = tempFolder)

  # read drug_strength
  drugStrength <- readr::read_delim(
    file = file.path(tempFolder, "drug_strength.csv"),
    delim = "\t",
    col_types = c(
      drug_concept_id = "i", ingredient_concept_id = "i", amount_value = "d",
      amount_unit_concept_id = "i", numerator_value = "d",
      numerator_unit_concept_id = "i", denominator_value = "d",
      denominator_unit_concept_id = "i", box_size = "i", valid_start_date = "D",
      valid_end_date = "D", invalid_reason = "c"
    )
  ) |>
    suppressWarnings()

  # delete csv file
  unlink(tempFolder, recursive = TRUE)

  return(drugStrength)
}

#' Available mock OMOP CDM Synthetic Datasets
#'
#' These are the mock OMOP CDM Synthetic Datasets that are available to download
#' using the `omock` package.
#'
#' @format A data frame with 4 variables:
#' \describe{
#'   \item{dataset_name}{Name of the dataset.}
#'   \item{url}{url to download the dataset.}
#'   \item{cdm_name}{Name of the cdm reference created.}
#'   \item{cdm_version}{OMOP CDM version of the dataset.}
#'   \item{size}{Size in bytes of the dataset.}
#'   \item{size_mb}{Size in Mega bytes of the dataset.}
#' }
#'
#' @examples
#' mockDatasets
#'
"mockDatasets"

#' Download an OMOP Synthetic dataset.
#'
#' @param datasetName Name of the mock dataset. See `availableMockDatasets()`
#' for possibilities.
#' @param path Path where to download the dataset.
#' @param overwrite Whether to overwrite the dataset if it is already
#' downloaded. If NULL the used is asked whether to overwrite.
#'
#' @return The path to the downloaded dataset.
#' @export
#'
#' @examples
#' \donttest{
#' library(omock)
#'
#' isMockDatasetDownloaded("GiBleed")
#' downloadMockDataset("GiBleed")
#' isMockDatasetDownloaded("GiBleed")
#' }
#'
downloadMockDataset <- function(datasetName = "GiBleed",
                                path = mockDatasetsFolder(),
                                overwrite = NULL) {
  # initial checks
  datasetName <- validateDatasetName(datasetName)
  path <- validatePath(path)
  omopgenerics::assertLogical(overwrite, length = 1, null = TRUE)

  datasetFile <- file.path(path, paste0(datasetName, ".zip"))
  # is available
  if (file.exists(datasetFile)) {
    if (isTRUE(overwrite)) {
      file.remove(datasetFile)
    } else if (isFALSE(overwrite)) {
      cli::cli_inform(c(i = "Prior download of {datasetName} is present set `overwrite = TRUE` to overwrite."))
      return(invisible(datasetFile))
    } else {
      if (question("Do you want to overwrite prior existing dataset? Y/n")) {
        if (!rlang::is_interactive()) {
          cli::cli_inform(c(i = "Deleting prior version of {datasetName}."))
        }
        file.remove(datasetFile)
      } else {
        return(invisible(datasetFile))
      }
    }
  }

  # download dataset
  url <- omock::mockDatasets$url[omock::mockDatasets$dataset_name == datasetName]
  utils::download.file(url = url, destfile = datasetFile)

  invisible(datasetFile)
}

#' Check if a certain dataset is downloaded.
#'
#' @param datasetName Name of the mock dataset. See `availableMockDatasets()`
#' for possibilities.
#' @param path Path where to search for the dataset.
#'
#' @return Whether the dataset is available or not.
#' @export
#'
#' @examples
#' \donttest{
#' library(omock)
#'
#' isMockDatasetDownloaded("GiBleed")
#' downloadMockDataset("GiBleed")
#' isMockDatasetDownloaded("GiBleed")
#' }
#'
isMockDatasetDownloaded <- function(datasetName = "GiBleed",
                                    path = mockDatasetsFolder()) {
  # initial checks
  datasetName <- validateDatasetName(datasetName)
  path <- validatePath(path)

  file.exists(file.path(path, paste0(datasetName, ".zip")))
}

#' List the available datasets
#'
#' @return A character vector with the available datasets.
#' @export
#'
#' @examples
#' library(omock)
#'
#' availableMockDatasets()
#'
availableMockDatasets <- function() {
  omock::mockDatasets$dataset_name
}

#' Check the availability of the OMOP CDM datasets.
#'
#' @return A message with the availability of the datasets.
#' @export
#'
#' @examples
#' library(omock)
#'
#' mockDatasetsStatus()
#'
mockDatasetsStatus <- function() {
  x <- omock::mockDatasets |>
    dplyr::select("dataset_name") |>
    dplyr::mutate(exists = dplyr::if_else(file.exists(file.path(
      mockDatasetsFolder(), paste0(.data$dataset_name, ".zip")
    )), 1, 0)) |>
    dplyr::arrange(dplyr::desc(.data$exists), .data$dataset_name) |>
    dplyr::mutate(status = dplyr::if_else(.data$exists == 1, "v", "x"))
  cli::cli_inform(rlang::set_names(x = x$dataset_name, nm = x$status))
  invisible(x)
}

#' Check or set the datasets Folder
#'
#' @param path Path to a folder to store the synthetic datasets. If NULL the
#' current OMOP_DATASETS_FOLDER is returned.
#'
#' @return The dataset folder.
#' @export
#'
#' @examples
#' \donttest{
#' mockDatasetsFolder()
#' mockDatasetsFolder(file.path(tempdir(), "OMOP_DATASETS"))
#' mockDatasetsFolder()
#' }
#'
mockDatasetsFolder <- function(path = NULL) {
  if (is.null(path)) {
    if (Sys.getenv(mockDatasetsKey) == "") {
      tempMockDatasetsFolder <- file.path(tempdir(), mockDatasetsKey)
      dir.create(tempMockDatasetsFolder, showWarnings = FALSE)
      if (rlang::is_interactive()) {
        cli::cli_inform(c("i" = "`{mockDatasetsKey}` temporarily set to {.path {tempMockDatasetsFolder}}."))
        cli::cli_inform(c("!" = "Please consider creating a permanent `{mockDatasetsKey}` location."))
      }
      arg <- rlang::set_names(x = tempMockDatasetsFolder, nm = mockDatasetsKey)
      do.call(what = Sys.setenv, args = as.list(arg))
    }
    return(Sys.getenv(mockDatasetsKey))
  } else {
    omopgenerics::assertCharacter(x = path, length = 1)
    if (!dir.exists(path)) {
      cli::cli_inform(c("i" = "Creating {.path {path}}."))
      dir.create(path)
    }
    arg <- rlang::set_names(x = path, nm = mockDatasetsKey)
    do.call(what = Sys.setenv, args = as.list(arg))
    if (rlang::is_interactive()) {
      c("i" = "If you want to create a permanent `{mockDatasetsKey}` write the following in your `.Renviron` file:",
        "", " " = "{.pkg {mockDatasetsKey}}=\"{path}\"", "") |>
        cli::cli_inform()
    }
    return(invisible(Sys.getenv(mockDatasetsKey)))
  }
}

datasetAvailable <- function(datasetName, call = parent.frame()) {
  folder <- mockDatasetsFolder()
  if (!isMockDatasetDownloaded(datasetName = datasetName, path = folder)) {
    if (question(paste0("`", datasetName, "` is not downloaded, do you want to download it? Y/n"))) {
      downloadMockDataset(datasetName = datasetName, path = folder)
    } else {
      cli::cli_abort(c(x = "`{datasetName}` is not downloaded."), call = call)
    }
  }
  file.path(folder, paste0(datasetName, ".zip"))
}
question <- function(message) {
  if (rlang::is_interactive()) {
    x <- ""
    while(!x %in% c("yes", "no")) {
      cli::cli_inform(message = message)
      x <- tolower(readline())
      x[x == "y"] <- "yes"
      x[x == "n"] <- "no"
    }
    x == "yes"
  } else {
    TRUE
  }
}
validateDatasetName <- function(datasetName, call = parent.frame()) {
  omopgenerics::assertChoice(datasetName, choices = availableMockDatasets(), length = 1, call = call)
  invisible(datasetName)
}
validatePath <- function(path, call = parent.frame()) {
  omopgenerics::assertCharacter(x = path, length = 1, call = call)
  if (!dir.exists(path)) {
    cli::cli_abort(c(x = "Path {.path {path}} does not exist."), call = call)
  }
  invisible(path)
}
castColumns <- function(x, name, version) {
  cols <- omopgenerics::omopTableFields(cdmVersion = version) |>
    dplyr::filter(.data$cdm_table_name == .env$name) |>
    dplyr::filter(.data$cdm_field_name %in% !!colnames(x))

  for (k in seq_len(nrow(cols))) {
    type <- cols$cdm_datatype[k]
    if (grepl("varchar", type)) {
      fun <- as.character
    } else {
      fun <- switch(type,
                    integer = as.integer,
                    datetime = as.POSIXct,
                    date = as.Date,
                    float = as.numeric,
                    logical = as.logical,
                    NULL)
    }
    if (!is.null(fun)) {
      x[[cols$cdm_field_name[k]]] <- do.call(fun, list(x[[cols$cdm_field_name[k]]]))
    }
  }

  x
}
