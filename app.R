library(shiny)
library(leaflet)

ui <- fluidPage(
  titlePanel("Basic Leaflet Map"),
  leafletOutput("map")
)

server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -0.1276, lat = 51.5074, zoom = 10)
  })
}

shinyApp(ui, server)
