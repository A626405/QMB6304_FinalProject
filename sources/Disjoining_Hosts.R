#cleaned<-readRDS("data/internal/rds/cleaned.RDS")
#source("sources/functions.R")
gc()
load(file = "data/internal/rda/cleaned.RDA")

require(tidyr)
require(tibble)
require(tidyselect)
require(dplyr)

maindf <- cleaned |> group_by(Datetime) |> arrange(.by_group = T)
rm(cleaned)


EUHoneypot <- maindf |>
  filter(Host == "groucho_eu")


SAHoneypot <- maindf |>
  filter(Host == "groucho_sa")


AUSHoneypot <- maindf |>
  filter(Host == "groucho_sydney")


TOKHoneypot <- maindf |>
  filter(Host == "groucho_tokyo")


SINGHoneypot <- maindf |>
  filter(Host == "groucho_singapore")


USEASTHoneypot <- maindf |>
  filter(Host == "groucho_us_east")


OREGONHoneypot <- maindf |>
  filter(Host == "groucho_oregon")


ZEPNORCALHoneypot <- maindf |>
  filter(Host == "zeppo_norcal")


GRNORCALHoneypot <- maindf |>
  filter(Host == "groucho_norcal")

