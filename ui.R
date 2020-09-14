library(shiny)
library(dplyr)
library(leaflet)
library(ggplot2)

# Define UI for application
shinyUI(fluidPage(

    # Application title
    titlePanel("Wildfires in the US"),
    
    # Sidebar with date input
    sidebarLayout(
        sidebarPanel(
            dateRangeInput("ddate", "Date of discovery (range): ", "2020-01-01"),
            submitButton("Find"),
            br(),
            p("Select date range above (inclusive on both ends) and press \"Find\""),
            p("Click on a pin on the map for more information about a specific fire")
        ),
        
        # Show map
        mainPanel(
            leafletOutput("mymap"),
            plotOutput("acreplot"),
            plotOutput("freqplot"),
            p("Acres covered daily"),
            textOutput("nf"),
            textOutput("mm"),
            br(),
            HTML("<p>Wildfire data from the National Interagency Fire Center (<a href='https://opendata.arcgis.com/datasets/68637d248eb24d0d853342cba02d4af7_0.csv'>raw</a>)</p>")
        )
    )
))
