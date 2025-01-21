clrmem(1)



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

