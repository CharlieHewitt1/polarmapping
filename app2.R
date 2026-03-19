# Load required libraries
library(shiny)
library(leaflet)
library(shinyjs)
library(htmlwidgets)
library(dplyr)
library(leaflet.extras)

# Define the path to your CSV file
csv_file_path <- "user_submissions_20241222.csv"  # Update this with the actual file path
#base_url <- "https://forms.gle/NFcUAMsUCvNZHBbC8"  # Fixed Google Forms link
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
    p("The project and map seek to challenge “what makes a person notable” – and the pervasive heroic male and colonial historical narrative of the Arctic. We particularly will seek and feature Indigenous Women of the Arctic from across the circumpolar region."),
    p("Inspired by efforts to (re-)map women’s stories through female place names and toponymies in Antarctica and other contemporary mapping initiatives, Mapping Women of the Arctic is an attempt to redress a structural imbalance, and to honour women’s contributions and help tell their stories. We do so while also recognizing that there are also unrecognized men, particularly Indigenous men who have contributed diversely to the Arctic."),
    p("*any individual who identifies as a woman")
  ),
  shinyjs::useShinyjs()
)

# Server
server <- function(input, output, session) {
  
  # Reactive values to store map data
  map_data <- reactiveValues(points = data.frame(lon = numeric(0), lat = numeric(0), name = character(0)))
  
  # Function to read points from the local CSV file
  loadPointsFromCSV <- function() {
    if (file.exists(csv_file_path)) {
      existing_data <- read.csv(csv_file_path)
      map_data$points <- existing_data
      print("Points loaded from CSV file.")
    } else {
      print("No CSV file found.")
    }
  }
  
  # Load points from the CSV file when the app is first opened
  loadPointsFromCSV()
  
  # Render the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addMarkers(lng = map_data$points$lon, lat = map_data$points$lat, popup = paste("Name:", map_data$points$name, "<br>",
                                                                                     "Age:", map_data$points$age, "<br>",
                                                                                     "Gender:", map_data$points$gender, "<br>",
                                                                                     "About:", map_data$points$history)) %>%
      setView(lng = 0, lat = 60, zoom = 4) %>%
      addFullscreenControl()  # Set the initial view to the northern hemisphere
  })
  
  observeEvent(input$map_click, {
    click <- input$map_click
    updateTextInput(session, "lat", value = click$lat)
    updateTextInput(session, "long", value = click$lng)
    showModal(modalDialog(
      title = "Add Marker",
      textInput("name", "Name"),
      textInput("age", "Age"),
      textInput("gender", "Gender"),
      textInput("history", "Description"),
      textOutput("confirmation"), 
      actionButton("submitBtn", "Submit")
    ))
  })
  
  observeEvent(input$map_click, {
    # Redirect to Google Form link to add data
    showModal(modalDialog(
      title = "Add Your Data",
      p("To add your data, please click the link below:"),
      tags$a(href = "https://forms.gle/NFcUAMsUCvNZHBbC8", target = "_blank", "Submit your data here"),
      easyClose = TRUE,
      footer = NULL
    ))
  })
}

# Run the application
shinyApp(ui, server)
