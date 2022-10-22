.libPaths(c(.libPaths(), "C:/Program Files/R-3.2.3/library"))
library(shiny)#, lib.loc = "C:/Program Files/R-3.2.3/library")
library(DT)#, lib.loc = "C:/Program Files/R-3.2.3/library")
library(plotly)#, lib.loc = "C:/Program Files/R-3.2.3/library")

shinyUI(fluidPage(
  
  titlePanel("DynamicRoots Traits"),
  
  sidebarLayout(
    sidebarPanel(
      actionButton("choosefile", "Choose File"),
      textOutput("path"),

      plotlyOutput("myWebGL", width = "100%")
    ),
    
  mainPanel(
    tabsetPanel(id = "tabs",
      tabPanel("Table", 
               fixedRow(
               htmlOutput("FilterExp"),
               htmlOutput("FilterButton"),
               dataTableOutput('contents', width = 1000))
               ),
      
      tabPanel("Scatter Plot",
               fixedRow(
                 column(3, selectInput("xcol", "X Variable", 
                                       c("Volume", "Length", "Radius", "Tortuosity",
                                         "Soil Angle", "Branching Angle"))),
                 column(3, selectInput("ycol", "Y Variable", 
                                       c("Volume", "Length", "Radius", "Tortuosity",
                                         "Soil Angle", "Branching Angle"), selected = "Length"))
               ),
               plotlyOutput("scatterPlot")),
      
      tabPanel("Distribution Plot", 
               fixedRow(
                 column(3, selectInput("variables", "Variable", 
                                       c("Volume", "Length", "Radius", "Tortuosity",
                                         "Soil Angle", "Branching Angle", "Radial Angle"))),
                 column(3, selectInput("types", "Root type", 
                                       c("Lateral", "First-order Lateral", "Secondary Lateral"))),
                 column(3, sliderInput("bins", "Number of bins", min = 1, max = 50, value = 10))
               ),
               textOutput("text"),
               plotOutput("histPlot"))
      )
    )
  )
))
