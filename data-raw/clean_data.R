library(tidyverse)
library(readxl)
library(googleCloudStorageR)


# set up for google cloud -------------------------------------------------
gcs_auth(json_file = Sys.getenv("GCS_AUTH_FILE"))
gcs_global_bucket(bucket = Sys.getenv("GCS_DEFAULT_BUCKET"))


# CAMP database table - 2015-2023
catch <- read_xlsx(here::here("data-raw", "butte_catch_edi.xlsx"),
                   sheet = "Catch_Raw_EDI",
                   col_types = c("numeric", "numeric", "numeric", "text", "numeric",
                                "text", "text", "text", "numeric", "numeric",
                                "numeric", "date", "text", "text", "text",
                                "text", "text")) |>
  mutate(subSiteName = case_when(subSiteName == "Okie RST" ~ "PP RST",
                                TRUE ~ subSiteName),
         siteName = ifelse(siteName %in% c("Okie RST", "Parrot-Phelan RST", "Parrott-Phelan canal trap box"),
                           "Parrot-Phelan", siteName),
         commonName = tolower(commonName),
         atCaptureRun = tolower(atCaptureRun),
         lifeStage = tolower(lifeStage),
         siteName = tolower(siteName),
         subSiteName = tolower(subSiteName)) |> glimpse()

# historical table
gcs_get_object(object_name = "standard-format-data/standard_rst_catch.csv",
               bucket = gcs_get_global_bucket(),
               saveToDisk = here::here("data-raw", "standard_catch.csv"),
               overwrite = TRUE)
# filter standard catch to exclude years already covered by CAMP table and to Butte Creek
# standardize variable names (siteName and subSiteName differ between tables)
# and remove columns not included in original
butte_historical_catch <- read_csv("data-raw/standard_catch.csv") |>
  filter(stream == "butte creek",
         date < min(catch$visitTime, na.rm = T)) |>
  rename(visitTime = date,
         atCaptureRun = run,
         forkLength = fork_length,
         lifeStage = lifestage,
         siteName = site,
         releaseID = release_id,
         n = count,
         commonName = species,
         subSiteName = subsite) |>
  select(-c(dead, interpolated, stream, site_group, weight,
            is_yearling, run_method, adipose_clipped)) |>
  mutate(releaseID = as.numeric(releaseID),
         siteName = ifelse(siteName == "okie dam", "parrot-phelan", siteName),
         subSiteName = case_when(subSiteName == "okie dam 1" ~ "pp rst",
                                 subSiteName == "okie dam 2" ~ "pp rst 2",
                                 subSiteName == "okie dam fyke trap" ~ "canal trap box",
                                 TRUE ~ subSiteName)) |>
  glimpse()

# combine
final_catch <- bind_rows(catch, butte_historical_catch) |>
  glimpse()


write_csv(final_catch, here::here("data","butte_catch_edi.csv"))

# CAMP database table - 2015-2023
trap <- read_xlsx(here::here("data-raw", "butte_trap_edi.xlsx"),
                  sheet = "Trap_Visit_EDI") |>
  mutate(subSiteName = case_when(subSiteName == "Okie RST" ~ "PP RST",
                                 TRUE ~ subSiteName),
         siteName = ifelse(siteName %in% c("Okie RST", "Parrot-Phelan RST", "Parrott-Phelan canal trap box"),
                           "Parrot-Phelan", siteName),
         dissolvedOxygen = as.numeric(dissolvedOxygen)) |> glimpse()

# historical table
gcs_get_object(object_name = "standard-format-data/standard_rst_trap.csv",
               bucket = gcs_get_global_bucket(),
               saveToDisk = here::here("data-raw", "standard_trap.csv"),
               overwrite = TRUE)
butte_historical_trap <- read_csv("data-raw/standard_trap.csv") |>
  filter(stream == "butte creek") |>
  glimpse()

min(trap$visitTime, na.rm = T)
min(butte_historical_trap$trap_visit_date, na.rm = T)
# TODO standard_rst_trap.csv does not contain any records earlier than those
# already in the CAMP table for butte

# combine
write_csv(trap, here::here("data", "butte_trap_edi.csv"))

# forkLength and totalLength are NA bc they haven't been measuring recaptured fish
# removed actualcountID
recapture <- read_xlsx(here::here("data-raw", "butte_recapture_edi.xlsx"),
                       sheet = "Recapture_EDI",
                       col_types = c("numeric", "numeric", "numeric", "text", "numeric",
                                     "text", "text", "text", "text", "text", "numeric",
                                     "numeric", "numeric", "numeric", "date",
                                     "text", "text", "text", "text", "text",
                                     "text", "text")) |>
  select(-actualCountID) |> glimpse()
write_csv(recapture, here::here("data","butte_recapture_edi.csv"))

# I do not think we need to upload this right now but will have it available for in the future
release_fish <- read_xlsx(here::here("data-raw", "butte_releasefish_edi.xlsx"))
write_csv(release_fish, here::here("data", "butte_releasefish_edi.csv"))


release <- read_xlsx(here::here("data-raw", "butte_release_edi.xlsx"),
                     sheet = "Release_EDI",
                     col_types = c("numeric", "numeric", "text", "text", "text",
                                   "text", "text", "text", "text", "numeric",
                                   "date", "numeric", "text", "text", "text",
                                   "text", "text")) |> glimpse()
write_csv(release, here::here("data","butte_release_edi.csv"))

# TODO write code that checks the data with lookups
# flag if not in the lookup table

# Create lookup table
project <- 11
fish_origin <- unique(catch$fishOrigin)
lifestage <- unique(catch$lifeStage)
mort <- unique(catch$mort)
actual_count <- unique(catch$actualCount)
site <- unique(catch$siteName)
subsite <- unique(catch$subSiteName)
visit_type <- unique(catch$visitType)
fish_processed <- unique(trap$fishProcessed)
trap_functioning <- unique(trap$trapFunctioning)
include_catch <- unique(trap$includeCatch)
marked_run <- unique(release$markedRun)
marked_lifestage <- unique(release$markedLifeStage)
marked_origin <- unique(release$markedFishOrigin)
source_fish <- unique(release$sourceOfFishSite)
release_site <- unique(release$releaseSite)
release_subsite <- unique(release$releaseSubSite)
mark_type <- unique(release$appliedMarkType)
mark_color <- unique(release$appliedMarkColor)
mark_position <- unique(release$appliedMarkPosition)

# define existing codes
# check data
# warning message if new code, data type, print

