library(leaflet)


g4 = c("Breakfast"="breakfast", "Lunch"="lunch", "Dinner"="dinner", "Dessert"="dessert")

shinyUI(navbarPage("Find your place to eat!",
  tabPanel("Map",
    fluidRow(
        fluidRow(
           column(1),
           column(3,
                  br(), h3("Distribution of ratings")),
           column(3,
                  selectInput('pref', 'What do you fancy?', c("Anything"="", g4), 
                              selectize=FALSE)),
           column(3,
                  selectInput('cities', 'In which city?', NULL, multiple=TRUE, 
                              selectize=TRUE)),
           column(2,
                  br(),
                  checkboxInput('takeout', 'To take out?', FALSE))
        )
    ),
    sidebarLayout(
      sidebarPanel(
        plotOutput("hist")
      ),
      mainPanel(
          leafletOutput("map"),
          br(),
          DT::dataTableOutput("table")
      )
    )
  ),
  tabPanel("Reviews",
           textOutput("clickedResName"),
           br(),
           DT::dataTableOutput("table2")
  )
))