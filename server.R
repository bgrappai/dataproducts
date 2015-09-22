library(shiny)

# Plotting 
library(ggplot2)
library(rCharts)
library(ggvis)

# Data processing libraries
library(data.table)
library(reshape2)
library(dplyr)

# Required by Markdown
library(markdown)

# shinyapps.io requirement
library(mapproj)
library(maps)
library(maptools)

# Load helper functions
source("helpers.R", local = TRUE)


# Load data : NOAA information
states_map <- map_data("state")
dt <- fread('data/events.agg.csv') %>% mutate(EVTYPE = tolower(EVTYPE))
evtypes <- sort(unique(dt$EVTYPE))


# Shiny server 
shinyServer(function(input, output, session) {
    
    # Define and initialize reactive values
    values <- reactiveValues()
    values$evtypes <- evtypes
    
    # Create event type checkbox
    output$evtypeControls <- renderUI({
        checkboxGroupInput('evtypes', 'Event types', evtypes, selected=values$evtypes)
    })
    
    # Add observers on clear and select all buttons
    observe({
        if(input$clear_all == 0) return()
        values$evtypes <- c()
    })
    
    observe({
        if(input$select_all == 0) return()
        values$evtypes <- evtypes
    })

    # Preapre datasets
    
    # Prepare dataset for maps
    dt.agg <- reactive({
        aggregate_by_state(dt, input$range[1], input$range[2], input$evtypes)
    })
    
    # Render Plots
    
    # Population impact by state
    output$populationImpactByState <- renderPlot({
        print(plot_impact_by_state (
            dt = compute_affected(dt.agg(), input$populationCategory),
            states_map = states_map, 
            year_min = input$range[1],
            year_max = input$range[2],
            title = "Pop. impact %d - %d (affected #)",
            fill = "Affected"
        ))
    })
    
    
    # Economic impact by state
    output$economicImpactByState <- renderPlot({
        print(plot_impact_by_state(
            dt = compute_damages(dt.agg(), input$economicCategory),
            states_map = states_map, 
            year_min = input$range[1],
            year_max = input$range[2],
            title = "Econ. impact %d - %d (Million USD)",
            fill = "Damages"
        ))
    })
    
})