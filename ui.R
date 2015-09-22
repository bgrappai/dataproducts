
# ui.R (shiny web app)
#

library(shiny)
library(devtools)
library(rCharts)

shinyUI(
    navbarPage("Storm Analytics",
        tabPanel("Plot",
                sidebarPanel(
                    sliderInput("range", 
                        "Year Range:", 
                        min = 1950, 
                        max = 2011, 
                        value = c(1993, 2011),
                        format="####"),
                    uiOutput("evtypeControls"),
                    actionButton(inputId = "clear_all", label = "Clear All", icon = icon("check-square")),
                    actionButton(inputId = "select_all", label = "Select All", icon = icon("check-square-o"))
                ),
  
                mainPanel(                        
                        # Data by state
                        p(icon("map-marker"), "By State"),
                            column(3,
                                wellPanel(
                                    radioButtons(
                                        "populationCategory",
                                        "Population Impact:",
                                        c("Both" = "Both", "Injuries" = "Injuries", "Fatalities" = "Fatalities"))
                                )
                            ),
                            column(3,
                                wellPanel(
                                    radioButtons(
                                        "economicCategory",
                                        "Economic Impact:",
                                        c("Both" = "Both", "Property Damage" = "property", "Crops Damage" = "crops"))
                                )
                            ),
                            column(7,
                                plotOutput("populationImpactByState"),
                                plotOutput("economicImpactByState")
                            )
                                                          
                )                       
        
                        ),
        tabPanel("About",
                 mainPanel(
                         includeMarkdown("include.md")
                 )
        )             
    )
)
