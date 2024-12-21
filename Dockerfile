# Base image: Rocker Shiny
FROM rocker/shiny:latest

# Install system libraries
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libpq-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    unixodbc-dev \
    libudunits2-dev \
    xdg-utils && \
    apt-get clean

RUN R -e "install.packages('leaflet.extras')"
RUN apt-get install -y libxml2 libcurl4-openssl-dev libssl-dev

# Install R packages
RUN R -e "install.packages(c('shiny', 'leaflet', 'RPostgreSQL', 'shinyjs', 'htmlwidgets', 'dplyr', 'leaflet.extras'), dependencies = TRUE)"

# Set the working directory
WORKDIR /srv/shiny-server

# Copy the app files into the container
COPY . .

# Make port 3838 available
EXPOSE 3838

# Run the Shiny app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server', host = '0.0.0.0', port = 3838)"]
