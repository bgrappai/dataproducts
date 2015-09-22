## function Aggregate dataset by state
## 
## param dt data.table
## param year_min integer
## param year_max integer
## param evtypes character vector
## return data.table
##
aggregate_by_state <- function(dt, year_min, year_max, evtypes) {
    replace_na <- function(x) ifelse(is.na(x), 0, x)
    round_2 <- function(x) round(x, 2)
    
    states <- data.table(STATE=sort(unique(dt$STATE)))
    
    aggregated <- dt %>% filter(YEAR >= year_min, YEAR <= year_max, EVTYPE %in% evtypes) %>%
            group_by(STATE) %>%
            summarise_each(funs(sum), COUNT:CROPDMG)

    # caculate for all states
    left_join(states,  aggregated, by = "STATE") %>%
        mutate_each(funs(replace_na), FATALITIES:CROPDMG) %>%
        mutate_each(funs(round_2), PROPDMG, CROPDMG)    
}


## function Add Affected column based on category
##
## param dt data.table
## param category character
## return data.table
##
compute_affected <- function(dt, category) {
    dt %>% mutate(Affected = {
        if(category == 'both') {
            INJURIES + FATALITIES
        } else if(category == 'fatalities') {
            FATALITIES
        } else {
            INJURIES
        }
    })
}

## function Add Damages column based on category
## 
## param dt data.table
## param category character
## return data.table
##
compute_damages <- function(dt, category) {
    dt %>% mutate(Damages = {
        if(category == 'both') {
            PROPDMG + CROPDMG
        } else if(category == 'crops') {
            CROPDMG
        } else {
            PROPDMG
        }
    })
}

## function Prepare map of economic and/or population impact
## 
## param dt data.table
## param states_map data.frame returned from map_data("state")
## param year_min integer
## param year_max integer
## param fill character name of the variable
## param title character
## param low character hex
## param high character hex
## return ggplot
## 
plot_impact_by_state <- function (dt, states_map, year_min, year_max, fill, title, low = "white", high = "red") {
    title <- sprintf(title, year_min, year_max)
    p <- ggplot(dt, aes(map_id = STATE))
    p <- p + geom_map(aes_string(fill = fill), map = states_map, colour='black')
    p <- p + expand_limits(x = states_map$long, y = states_map$lat)
    p <- p + coord_map() + theme_bw()
    p <- p + labs(x = "Long", y = "Lat", title = title)
    p + scale_fill_gradient(low = low, high = high)
}
