library(tidyverse); library(sf); library(rnaturalearth)

taxa_data <- function(taxa){
  if(taxa == 'mammal'){
    d <- read.csv(here::here("../LaSelva-MetaNetwork-data/data/L1/L1_taxa_data/L1_mammal_occs_ixns.csv"))
  } else {
    if(taxa == 'arthropod'){
      d <- read.csv(here::here("../LaSelva-MetaNetwork-data/data/L1/L1_taxa_data/L1_arthropod_occs_ixns.csv"))
    }
    else {
      if(taxa == 'bird'){
        d <- read.csv(here::here("../LaSelva-MetaNetwork-data/data/L1/L1_taxa_data/L1_bird_occs_ixns.csv"))
      } else {
        d <- read.csv(here::here("../LaSelva-MetaNetwork-data/data/L1/L1_taxa_data/L1_plant_occs_ixns.csv"))
      }
    }
  }
}


create_map <- function(taxa, sp){
  d <- taxa_data(taxa)
  
  d <- d %>%
    filter(sp1_gbif == sp)
  
  species_sf <- st_as_sf(d, 
                         coords = c("longitude", "latitude"),
                         crs = 4326)
  
  CR_states <- ne_states(country = "Costa Rica", returnclass = "sf")
  
  la_selva <- st_read(
    here::here("../LaSelva-MetaNetwork-data/data/L0/shapefiles/la_selva.gpkg"),
    quiet = TRUE
  )
  
  VB <- st_read(
    here::here("../LaSelva-MetaNetwork-data/data/L0/shapefiles/braulio_carrillo_np.gpkg"),
    quiet = TRUE
  )
  
  transect <- st_read(
    here::here("../LaSelva-MetaNetwork-data/data/L0/shapefiles/transect.gpkg"),
    quiet = TRUE
  )
  transect <- transect %>%
    filter(tipo_acceso %in% c('sección fuera de trocha','transecto principal'))
  
  ggplot() +
    geom_sf(data = CR_states, fill = 'gray95', color = 'gray80') +
    geom_sf(data = VB, aes(fill = nombre_asp), color = 'gray80', alpha = 0.5) +
    geom_sf(data = la_selva, aes(fill = LANDUSE), color = 'gray80') +
    geom_sf(data = species_sf, color = 'black') +
    coord_sf(xlim = c(-84.19, -83.87), ylim = c(9.98, 10.6))+
    scale_fill_manual(
      values = c('gray80', 'gray70'),
      labels = c("Braulio Carrillo National Park", "La Selva Biological Station")) +
    labs(fill = "") +
    theme_void() +
    theme(
      legend.text = element_text(size = 12),
      legend.key.spacing.y = unit(0.1, "cm"))
  }

    
    