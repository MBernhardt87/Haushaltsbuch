## Load libs
library(shiny)
library(dplyr)
library(lubridate)
library(stringr)
library(DT)
library(rpivotTable)
library(tibble)
library(ggplot2)
library(rhandsontable)

##Source Util Files


## Adjust Options
options(scipen=10)
options(shiny.launch.browser = TRUE)

shinyApp(ui = source("ui.R"), server = source("server.R"))

