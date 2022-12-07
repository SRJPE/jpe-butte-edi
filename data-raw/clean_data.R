library(tidyverse)
library(readxl)

# TODO run is NA (is the join not working?)
# TODO do we need the releaseID column? Probably not.
# Decided to leave releaseID so it is really clear that this does not include recapture fish
# TODO actualCount is still encoded. Need to add join
catch <- read_xlsx(here::here("data-raw", "butte_catch_edi.xlsx"))
write_csv(catch, here::here("data","butte_catch_edi.csv"))

# TODO what are the units used for discharge, waterVel, waterTemp, turbidity
# TODO are there other environmental we want to add?
trap <- read_xlsx(here::here("data-raw", "butte_trap_edi.xlsx"))
write_csv(trap, here::here("data", "butte_trap_edi.csv"))

# TODO run is NA (is the join not working?)
# TODO actualCount is still encoded. Need to add join
recapture <- read_xlsx(here::here("data-raw", "butte_recapture_edi.xlsx"))
write_csv(recapture, here::here("data","butte_recapture_edi.csv"))

# TODO I do not think we need to upload this right now but will have it available for in the future
release_fish <- read_xlsx(here::here("data-raw", "butte_releasefish_edi.xlsx"))
write_csv(release_fish, here::here("data", "butte_releasefish_edi.csv"))

# TODO we can remove the releaseID = 255 or releaseID = 0
release <- read_xlsx(here::here("data-raw", "butte_release_edi.xlsx"))
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

