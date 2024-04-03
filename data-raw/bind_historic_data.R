library(dplyr)
library(readr)

append_historic_data <- function(historic_path, new_path){
  historic_data <- readr::read_csv(historic_path)
  if (new_path == "data/butte_catch.csv"){
    new_data <- readr::read_csv(new_path)
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
    write.csv(full_data, new_path, row.names = FALSE)
      # filter(ProjectDescriptionID == 7) do i need to filter
  }else{
    new_data <- readr::read_csv(new_path)
    full_data <- dplyr::bind_rows(historic_data, new_data)
    col_order <- c("projectDescriptionID",
                   "trapVisitID",
                   "siteName",
                   "subSiteName",
                   "visitTime",
                   "visitType",
                   "fishProcessed",
                   "trapFunctioning",
                   "counterAtEnd",
                   "rpmRevolutionsAtStart",
                   "rpmRevolutionsAtEnd",
                   "includeCatch",
                   "discharge",
                   "waterVel",
                   "waterTemp",
                   "turbidity")
    full_data <- full_data[,col_order]
    write.csv(full_data, new_path, row.names = FALSE)
  }
}

path <- sort(c("butte_catch.csv", "butte_trap.csv"))
full_historic_path <- paste0("data/historic_data/", path)
full_new_data_path <- paste0("data/", path)

mapply(append_historic_data, full_historic_path, full_new_data_path)

