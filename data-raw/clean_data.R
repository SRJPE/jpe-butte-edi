library(tidyverse)
library(readxl)
library(googleCloudStorageR)

# This script is used to generate historic data that do not exist in
# the CAMP database. Data in the CAMP database are emailed and updated
# automatically. Historic data are generated, saved in a static file, and
# appended to the current data.

# set up for google cloud -------------------------------------------------
gcs_auth(json_file = Sys.getenv("GCS_AUTH_FILE"))
gcs_global_bucket(bucket = Sys.getenv("GCS_DEFAULT_BUCKET"))

# historical table
gcs_get_object(object_name = "standard-format-data/standard_rst_catch_081225.csv",
               bucket = gcs_get_global_bucket(),
               saveToDisk = here::here("data-raw", "standard_catch.csv"),
               overwrite = TRUE)
# filter standard catch to exclude years already covered by CAMP table and to Butte Creek
# standardize variable names (siteName and subSiteName differ between tables)
# and remove columns not included in original
# TODO we don't have data for 2009, 2010, 2011
butte_historical_catch <- read_csv("data-raw/standard_catch.csv")
butte_historical_catch <- butte_historical_catch |>
  filter(stream == "butte creek") |>
         # date < min(butte_historical_catch$visitTime, na.rm = T)) |>
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
  mutate(time = "12:00:00",
         visitTime = lubridate::ymd_hms(paste(visitTime, time)),
         releaseID = as.numeric(releaseID),
         siteName = ifelse(siteName == "okie dam", "parrot-phelan", siteName),
         subSiteName = case_when(subSiteName == "okie dam 1" ~ "pp rst",
                                 subSiteName == "okie dam 2" ~ "pp rst 2",
                                 subSiteName == "okie dam fyke trap" ~ "canal trap box",
                                 TRUE ~ subSiteName)) |>
  filter(visitTime < "2015-11-3") |># if we don't filter out dates greater than 11-3-2015 it will result in duplicates
  select(-c(time)) |> glimpse()
write_csv(butte_historical_catch, "data/historic_data/butte_catch.csv")

# historical table
gcs_get_object(object_name = "standard-format-data/standard_rst_trap.csv",
               bucket = gcs_get_global_bucket(),
               saveToDisk = here::here("data-raw", "standard_trap.csv"),
               overwrite = TRUE)

# TODO missing 2009, 2010, 2011
butte_historical_trap <- read_csv("data-raw/standard_trap.csv") |>
  filter(stream == "butte creek",
         trap_stop_date < min(trap$visitTime, na.rm = T)) |>
  mutate(visitTime = as_datetime(paste0(trap_stop_date, " ", trap_stop_time)),
         siteName = ifelse(site == "okie dam", "parrot-phelan", site),
         subSiteName = case_when(subsite == "okie dam 1" ~ "pp rst",
                                 subsite == "okie dam 2" ~ "pp rst 2",
                                 subsite == "okie dam fyke trap" ~ "canal trap box",
                                TRUE ~ subsite),
         trapVisitID = as.numeric(trap_visit_id),
         includeCatch = ifelse(include == TRUE, "Yes", "No")) |>
  rename(visitType = visit_type,
         fishProcessed = fish_processed,
         trapFunctioning = trap_functioning,
         counterAtStart = counter_start,
         counterAtEnd = counter_end,
         rpmRevolutionsAtStart = rpms_start,
         rpmRevolutionsAtEnd = rpms_end) |>
  select(-c(site, subsite, trap_stop_date, trap_visit_date,
            trap_visit_time, trap_start_date, trap_start_time,
            gear_type, in_thalweg, partial_sample,
            is_half_cone_configuration, depth_adjust,
            debris_volume, debris_level,
            time, sample_period_revolutions,
            comments, trap_visit_id, include, trap_stop_time,
            stream, counterAtStart)) |>
  filter(visitTime < "2015-11-3") |># if we don't filter out dates greater than 11-3-2015 it will result in duplicates
  glimpse()

write_csv(butte_historical_trap, "data/historic_data/butte_trap.csv")


