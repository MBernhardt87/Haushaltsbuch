## Load libs
library(shiny)
library(dplyr)
library(lubridate)
library(stringr)
library(DT)
library(rpivotTable)
library(tibble)
library(ggplot2)

##Source Util Files


## Adjust Options
options(scipen=10)
options(shiny.launch.browser = TRUE)

ui <- navbarPage(
  
)

server <- function(input, output) {
  
}

shinyApp(ui = ui, server = server)

