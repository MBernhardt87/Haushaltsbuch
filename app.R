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
library(readr)

##Source Util Files
source("./Utils/BackendLogic.R")

## Adjust Options
options(scipen=10)
#options(shiny.launch.browser = TRUE)
options(shiny.launch.browser = .rs.invokeShinyWindowViewer)

## Launch Shiny App
shinyApp(ui = source("ui.R"), server = source("server.R"))

