library(dplyr)
library(readr)
library(zip)

append_historic_data <- function(historic_path, new_path) {
  # Temporary directories for extraction and writing
  folder_path <- "data/butte.zip"
  temp_dir <- tempdir()
  temp_dir <- normalizePath(temp_dir, winslash = "/")
  original_wd <- getwd()

  # Unzip new_path
  unzip(folder_path, exdir = temp_dir)
  new_file <- file.path(temp_dir, basename(new_path))

  # Load historic data
  historic_data <- readr::read_csv(historic_path)
  # Load and filter new data
  new_data <- if (grepl("butte_catch.csv", new_path)) {
    readr::read_csv(new_file)
  } else {
    readr::read_csv(new_file)
  }
  # Combine data
  full_data <- dplyr::bind_rows(historic_data, new_data)
  col_order <- c("ProjectDescriptionID",
                 "catchRawID",
                 "trapVisitID",
                 "commonName",
                 "releaseID",
                 "atCaptureRun",
                 "fishOrigin",
                 "lifeStage",
                 "forkLength",
                 "totalLength",
                 "n",
                 "visitTime",
                 "visitType",
                 "siteName",
                 "subSiteName",
                 "finalRun",
                 "actualCount")
  full_data <- full_data[,col_order]
  # Write updated data back to the temporary directory
  write_csv(full_data, new_file)
  setwd(temp_dir)
  files_to_zip <- list.files(pattern = "^butte", recursive = TRUE)

  zip(
    zipfile = file.path(original_wd, folder_path),
    files =  files_to_zip
  )
  setwd(original_wd)

}

path <- sort(c("butte_catch.csv", "butte_trap.csv"))
full_historic_path <- paste0("data/historic_data/", path)
full_new_data_path <- paste0("data/butte.zip/", path)

mapply(append_historic_data, full_historic_path, full_new_data_path)

