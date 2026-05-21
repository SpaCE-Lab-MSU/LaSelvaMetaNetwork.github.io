library(shiny)
library(tidyverse)
library(leaflet)
library(dplyr)
library(sf)

mammals <- read_csv("data/L1_mammal_occs_ixns.csv")
arthropods <- read_csv("data/L1_arthropod_occs_ixns.csv")
birds <- read_csv("data/L1_bird_occs_ixns.csv")
plants <- read_csv("data/L1_plant_occs_ixns.csv")

la_selva <- st_read("shapefiles/la_selva.shp", quiet = TRUE)
VB <- st_read("shapefiles/VB.shp", quiet = TRUE)

la_selva <- st_transform(la_selva, 4326)
VB <- st_transform(VB, 4326)

all_data <- bind_rows(mammals, arthropods, birds, plants) %>%
  filter(!is.na(longitude), !is.na(latitude)) %>%
  mutate(sp1_scientific = trimws(sp1_scientific))


ui <- fluidPage(
  
  titlePanel("Species Occurrence Map"),
  
  sidebarLayout(
    sidebarPanel(
      selectizeInput(
        "species",
        "Search species",
        choices = NULL,
        multiple = FALSE
      )
    ),
    
    mainPanel(
      leafletOutput("map", height = "800px")
    )
  )
)


server <- function(input, output, session) {
  
  species_list <- sort(unique(all_data$sp1_scientific))
  
  # -------------------------
  # INIT DROPDOWN
  # -------------------------
  observe({
    updateSelectizeInput(
      session,
      "species",
      choices = species_list,
      selected = character(0),
      server = TRUE
    )
  })
  
  # -------------------------
  # INPUT -> URL
  # -------------------------
  observeEvent(input$species, {
    updateQueryString(
      paste0("?species=", URLencode(input$species)),
      mode = "replace"
    )
  }, ignoreInit = TRUE)
  
  # -------------------------
  # URL -> INPUT
  # -------------------------
  observe({
    
    query <- parseQueryString(session$clientData$url_search)
    
    if (!is.null(query$species)) {
      
      sp <- trimws(query$species)
      
      if (sp %in% species_list) {
        updateSelectizeInput(
          session,
          "species",
          selected = sp
        )
      }
    }
  })
  
  # -------------------------
  # FILTER
  # -------------------------
  filtered <- reactive({
    req(input$species)
    filter(all_data, sp1_scientific == input$species)
  })
  
  # -------------------------
  # MAP
  # -------------------------
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(data = la_selva, fillColor = "gray90", color = "gray70") %>%
      addPolygons(data = VB, fillColor = "gray", color = "gray70") %>%
      fitBounds(-84.19, 9.7, -83.87, 10.4)
  })
  
  # -------------------------
  # POINTS
  # -------------------------
  observe({
    
    req(input$species)
    
    leafletProxy("map") %>%
      clearMarkers() %>%
      addCircleMarkers(
        data = filtered(),
        lng = ~longitude,
        lat = ~latitude,
        radius = 4,
        popup = ~sp1_scientific
      )
  })
}

shinyApp(ui, server)