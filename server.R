library(shiny)
library(dplyr)
library(leaflet)
library(ggplot2)

shinyServer(function(input, output) {
    
    # download raw data
    download.file("https://opendata.arcgis.com/datasets/68637d248eb24d0d853342cba02d4af7_0.csv", "fire.csv", "curl")
    fires <- read.csv("fire.csv", as.is=TRUE)
    fires <- as.data.frame(rename(fires, lat=Y, long=X)) # rename latitude/longitude columns
    fires <- fires[, c(2,1,3:dim(fires)[2])]
    fires$fddate <- as.Date(fires$FireDiscoveryDateTime, "%Y/%m/%d %H:%M:%S")
    fires$DailyAcres[is.na(fires$DailyAcres)] <- 0 # set NA acre increases to 0
    fires$POOCity[is.na(fires$POOCity)] <- "" # set NA city names to blank
    fires$POOState[is.na(fires$POOState)] <- "" # set NA state names to blank
    dat <- reactive({subset(fires, fddate >= input$ddate[1] & fddate <= input$ddate[2])})
    # labels for map markers
    lbls <- reactive({sprintf("Location: %s, %s\n Discovered %s \n %0.2f acres daily", dat()$POOCity, dat()$POOState, dat()$FireDiscoveryDateTime, dat()$DailyAcres)})
    output$mymap <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$Stamen.TonerLite,
                             options = providerTileOptions(noWrap = TRUE)
            ) %>%
            addMarkers(data=dat()[,1:2], 
                       clusterOptions = markerClusterOptions(),
                       popup=lbls())
    })
    output$freqplot <- renderPlot({qplot(fddate, data=dat(), xlab="Date of Discovery", ylab="Count")})
    output$acreplot <- renderPlot({ggplot(data=dat(), aes(fddate, DailyAcres)) + 
            geom_point() + scale_x_date(date_breaks="months", date_labels="%b %y") + 
            labs(x="Date of Discovery", y="Acres Daily")})
    output$nf <- renderText(sprintf("Number of fires discovered: %d", dim(dat())[1]))
    output$mm <- renderText(sprintf("Mean: %0.2f Median: %0.2f", mean(dat()$DailyAcres), median(dat()$DailyAcres)))
})
