library(tidyverse)
library(readxl)

catch <- read_xlsx(here::here("data-raw", "butte_catch_edi.xlsx"),
                   sheet = "Catch_Raw_EDI",
                   col_types = c("numeric", "numeric", "numeric", "text", "numeric",
                                "text", "text", "text", "numeric", "numeric",
                                "numeric", "date", "text", "text", "text",
                                "text", "text")) |>
  mutate(subSiteName = case_when(subSiteName == "Okie RST" ~ "PP RST",
                                TRUE ~ subSiteName),
         siteName = case_when(siteName == "Okie RST" ~ "Parrot-Phelan RST",
                              TRUE ~ siteName)) |> glimpse()
write_csv(catch, here::here("data","butte_catch_edi.csv"))


trap <- read_xlsx(here::here("data-raw", "butte_trap_edi.xlsx"),
                  sheet = "Trap_Visit_EDI") |>
  mutate(subSiteName = case_when(subSiteName == "Okie RST" ~ "PP RST",
                                 TRUE ~ subSiteName),
         siteName = case_when(siteName == "Okie RST" ~ "Parrot-Phelan RST",
                              TRUE ~ siteName),
         dissolvedOxygen = as.numeric(dissolvedOxygen)) |> glimpse()
write_csv(trap, here::here("data", "butte_trap_edi.csv"))

# forkLength and totalLength are NA bc they haven't been measuring recaptured fish
# removed actualcountID
recapture <- read_xlsx(here::here("data-raw", "butte_recapture_edi.xlsx"),
                       sheet = "Recapture_EDI",
                       col_types = c("numeric", "numeric", "numeric", "text", "numeric",
                                     "text", "text", "text", "text", "numeric",
                                     "numeric", "numeric", "numeric", "numeric", "date",
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

