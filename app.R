# Load required libraries
library(shiny)
library(leaflet)
library(shinyjs)
library(htmlwidgets)
library(dplyr)

# Define the path to your CSV file
csv_file_path <- "user_submissions_20241222.csv"

# UI
ui <- fluidPage(
  leafletOutput("map", height = "100vh"),
  absolutePanel(
    top = "10px", right = "10px", width = 300,
    style = "background-color: white; padding: 10px;",
    tags$p(
      style = "font-size: 20px; font-weight: bold;",
      "Mapping Women of the Arctic"),
    p("Mapping Women of the Arctic is a mapping project spotlighting the stories, contributions and geolocations of women* of the Arctic from all walks of life – women who live in, work in, or engage with the Arctic."),
    p("The project and map seek to challenge “what makes a person notable” – and the pervasive heroic male and colonial historical narrative of the Arctic."),
    p("*any individual who identifies as a woman")
  ),
  shinyjs::useShinyjs()
)

# Server
server <- function(input, output, session) {
  
  map_data <- reactiveValues(
    points = data.frame(
      lon = numeric(0),
      lat = numeric(0),
      name = character(0),
      age = character(0),
      gender = character(0),
      history = character(0)
    )
  )
  
  loadPointsFromCSV <- function() {
    if (file.exists(csv_file_path)) {
      existing_data <- read.csv(csv_file_path)
      
      # Ensure required columns exist
      required_cols <- c("lon", "lat", "name", "age", "gender", "history")
      missing_cols <- setdiff(required_cols, names(existing_data))
      
      if (length(missing_cols) > 0) {
        for (col in missing_cols) {
          existing_data[[col]] <- NA
        }
      }
      
      map_data$points <- existing_data
      print("Points loaded from CSV file.")
    } else {
      print("No CSV file found.")
    }
  }
  
  loadPointsFromCSV()
  
  output$map <- renderLeaflet({
    leaflet(map_data$points) %>%
      addTiles() %>%
      addMarkers(
        lng = ~lon,
        lat = ~lat,
        popup = ~paste(
          "<b>Name:</b>", name, "<br>",
          "<b>Age:</b>", age, "<br>",
          "<b>Gender:</b>", gender, "<br>",
          "<b>About:</b>", history
        )
      ) %>%
      setView(lng = 0, lat = 60, zoom = 4)
  })
  
  # Single observeEvent (fixed)
  observeEvent(input$map_click, {
    showModal(modalDialog(
      title = "Add Your Data",
      p("To add your data, please click the link below:"),
      tags$a(
        href = "https://forms.gle/NFcUAMsUCvNZHBbC8",
        target = "_blank",
        "Submit your data here"
      ),
      easyClose = TRUE,
      footer = NULL
    ))
  })
}

shinyApp(ui, server)
