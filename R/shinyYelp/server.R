library(leaflet)
library(maps)
library(ggplot2)

# Load auxiliar functions
source("helpers.R")

rest_data = load_businesses()
rev_data = load_reviews()

shinyServer(function(input, output, session) {
  # Reactive businesses
  rest_in_bounds = reactive({
    # Between bounds auxiliar selection function
    betweenBounds = function(x, y, bounds) {
      x_bounds = c(bounds$north, bounds$south)
      y_bounds = c(bounds$east, bounds$west)
      return(x <= x_bounds[1] & x >= x_bounds[2] &
               y <= y_bounds[1] & y >= y_bounds[2])
    }
    # Reactive functionality
    if (is.null(input$map_bounds)) {
      data = rest_data
    } else {
      data = subset(rest_data, betweenBounds(Latitude, Longitude, input$map_bounds))
    }
    
    # Filter according to user preference
    data = filterByPreference(data, input$pref)
    # Filter according to city
    data = filterByCities(data, input$cities)
    # Filter according to take out
    data = filterByTakeOut(data, input$takeout)

    return(data)
  })
  
  # Events
  ## Reactive map on datatable click event
  observeEvent(input$rows, {
    leafletProxy("map", session) %>% setView(as.numeric(input$rows[4]),
                                             as.numeric(input$rows[5]),
                                             18)
    lng = as.numeric(input$rows[4])
    lat = as.numeric(input$rows[5])
    data = rest_in_bounds()
    idx = which.min(abs(data$Longitude - lng) + abs(data$Latitude - lat)) 
    output$table2 = DT::renderDataTable({
      DT::datatable(
        subset(rev_data[rev_data$ID==data[idx,]$ID,], select=-c(ID, Name)),
        selection="none"
      )
    })
    output$clickedResName = renderText({
      paste("Reviews for restaurant ", data[idx,]$Name, 
            "placed at ", data[idx,]$Address)
    })
  })
  
  ## Reactive map on applied filters
  observeEvent(rest_in_bounds(), {
    leafletProxy("map", session) %>% clearMarkers() %>% clearMarkerClusters() %>% 
      addMarkersGroup(rest_in_bounds(), "select")
  })
  
  ## Reactive reviews data table on clicked marker
  observeEvent(input$map_marker_click, {
    if (!is.null(input$map_marker_click)) {
      lng = as.numeric(input$map_marker_click$lng)
      lat = as.numeric(input$map_marker_click$lat)
      data = rest_in_bounds()
      idx = which.min(abs(data$Longitude - lng) + abs(data$Latitude - lat)) 
      output$table2 = DT::renderDataTable({
        DT::datatable(
          subset(rev_data[rev_data$ID==data[idx,]$ID,], select=-c(ID, Name)),
          selection="none"
        )
      })
      output$clickedResName = renderText({
        paste("Reviews for restaurant ", data[idx,]$Name, 
              "placed at ", data[idx,]$Address)
      })
    }
    else {
      output$clickedResName = renderText({
        "No restaurant has been selected."
      })
    }
  }, ignoreNULL = FALSE)
  
  # Output elements
  output$hist = renderPlot({
    data = rest_in_bounds()
    if (length(data) == 0) {
      ggplot() + geom_blank()
    } else {
      ggplot(data = data, aes(x = Stars)) +
        geom_histogram(fill = "darkblue", bins = 9, show.legend = TRUE)
    }
  })
  
  output$map = renderLeaflet({
    # Build out a leaflet object
    map = leaflet() %>%
      addTiles() %>%
      mapOptions(zoomToLimits = "always") %>%
      clearBounds() %>%
      addMarkersGroup(rest_data, "all")
  })
  
  output$table = DT::renderDataTable({
    DT::datatable(
      subset(rest_in_bounds(), select = c(Name, Address, Longitude,
                                     Latitude, Stars)),
      selection = "single",
      callback = JS(
        "table.on('click.dt', 'tr', function() {
        $(this).toggleClass('selected');
        Shiny.onInputChange('rows',
        table.rows('.selected').data().toArray());
        $(this).toggleClass('selected');});"),
      options=list(columnDefs = list(list(visible=FALSE, targets=c(3, 4))))
    )
  })
  
  # Input elements update
  updateSelectizeInput(session, 'cities', choices=as.character(unique(rest_data$City)), 
                       server=TRUE)
})