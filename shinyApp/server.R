.libPaths(c(.libPaths(), "C:/Program Files/R-3.2.3/library"))
library(shiny)#, lib.loc = "C:/Program Files/R-3.2.3/library")
library(DT)#, lib.loc = "C:/Program Files/R-3.2.3/library")
library(plotly)#, lib.loc = "C:/Program Files/R-3.2.3/library")
library(plotrix)#, lib.loc = "C:/Program Files/R-3.2.3/library")

scene <- list(
  xaxis = list(
    title = "",
    showspikes = FALSE,
    zeroline = FALSE,
    showline = FALSE,
    showticklabels = FALSE,
    showgrid = FALSE
  ),
  yaxis = list(
    title = "",
    showspikes = FALSE,
    zeroline = FALSE,
    showline = FALSE,
    showticklabels = FALSE,
    showgrid = FALSE
  ),
  zaxis = list(
    title = "",
    showspikes = FALSE,
    zeroline = FALSE,
    showline = FALSE,   
    showticklabels = FALSE,
    showgrid = FALSE
  )
)

getIndex <- function(variable){

  switch(variable,
         "Volume" = 6,
         "Length" = 7,
         "Radius" = 12,
         "Tortuosity" = 11,
         "Soil Angle" = 13,
         "Branching Angle" = 16,
         "Radial Angle" = 10)
		 
}

shinyServer(function(input, output) {
  
  path <- eventReactive(input$choosefile, {
    choose.files(multi = FALSE, filters = Filters["txt", ])
  })
  
  
  traits_raw <- reactive({
    # inFile <- input$file1
    
    if (input$choosefile == 0)
      return(NULL)
    # data <- read.csv(inFile$datapath, header = FALSE, sep = "\t")
    data <- read.csv(path(), header = FALSE, sep = "\t")
    data <- data[-ncol(data)]
    traitsData <- data[, seq(2, ncol(data), 2)]
    TraitNames <- as.matrix(data[1, seq(1, ncol(data), 2)])
    TraitNames[13] <- gsub("vert", "soil", TraitNames[13])
    colnames(traitsData) <- TraitNames
    
    ### Av_radius 1.#J
    if(is.factor(traitsData[, 12]))
      traitsData[, 12] <- as.numeric(levels(traitsData[, 12])[traitsData[, 12]])
    
    traitsData[, 13] <- traitsData[, 13] - 90
  
    traitsData
    
  })
  
  VTKdata <- reactive({
    
    if (input$choosefile == 0)
      return(NULL)
    vtkFile <- gsub("_per_branch_dynamics.txt", "_pp_no_seed.vtk", path())
    read.table(vtkFile, sep = "\n")
    
  })
  
  points <- reactive({
    
    if (is.null(VTKdata()))
      return(NULL)
    NumofPoints <- as.numeric(strsplit(as.character(VTKdata()[4,1]), " ")[[1]][2])
    read.table(text = as.character(VTKdata()[5:(4+NumofPoints), 1]), sep = " ")
    
  })
  
  points_color <- reactive({
    
    if (is.null(VTKdata()))
      return(NULL)
    NumofPoints <- as.numeric(strsplit(as.character(VTKdata()[4,1]), " ")[[1]][2])
    as.character(VTKdata()[(nrow(VTKdata())-NumofPoints+1):nrow(VTKdata()), 1])
    
  })
  
  branch_colors <- reactive({
    
    if ( is.null(traits()) || is.null(points()) || is.null(points_color()) )
      return(NULL)
    tipXYZ <- strsplit(as.character(traits()[, 10]), "[^0-9.]+")
    tipXYZ <- data.frame(matrix(as.numeric(unlist(tipXYZ)), ncol = 4, byrow = TRUE))
    
    branchx_colors <- c()
    for ( i in 1:nrow(tipXYZ) )
    {
      branchx_colors[i] <- points_color()[points()[, 1]==tipXYZ[i, 2] & points()[, 2]==tipXYZ[i, 3]
                                       & points()[, 3]==tipXYZ[i, 4]]
    }
    
    branchx_colors
    
  })
  
  points_id <- reactive({
    
    if ( is.null(points_color()) || is.null(branch_colors()) )
      return(NULL)
    
    point_id <- c()
    for ( i in 1:length(points_color()))
    {
      point_id[i] <- which(branch_colors() == points_color()[i])[1]
    }
    
    point_id
  
  })

  output$path <- renderText(basename(path()))
  output$contents <- renderDataTable(traits(), filter = 'top', options = list(scrollX = TRUE, scrollY = 500,
                                                                  paging = FALSE, scrollCollapse = TRUE))
  output$myWebGL <- renderPlotly({
    
    if (!is.null(traits())){

#     if (is.null(input$contents_rows_selected))
#     {
#       
#       #points3d(points(), col = rgb(read.table(text = points_color(), sep = " ")))
#       p <- plot_ly(points(), x = V1, y = V2, z = V3, 
#                    hoverinfo = "text",
#                    text = paste("Branch: ", traits()[points_id(), 1],
#                                 "<br>Volume: ", traits()[points_id(), 6],
#                                 "<br>Length: ", traits()[points_id(), 7]),
#                    type = "scatter3d", mode = "markers",
#                    marker = list(color = rgb(read.table(text = points_color(), sep = " ")),
#                                  size = 1)) 
#       layout(p, scene = scene,
#              xaxis = list(title = ""), 
#              yaxis = list(title = ""), 
#              zaxis = list(title = ""))
#       
#     } else{
      
      if (is.null(input$contents_rows_selected))
        indices <- c(1:nrow(traits()))
      else 
        indices <- as.numeric(input$contents_rows_selected)
      
      find_branch_colors <- c()
      find_branch_points <- c()
      find_branch_ids <- c()
      find_point_ids <- c()
      
      find_branches <- branch_colors()[indices]
      for ( i in 1:length(find_branches) )
        {
           branchx_points <- points()[points_color() == find_branches[i], ]
           find_branch_points <- rbind(find_branch_points, branchx_points)
           find_branch_colors <- append(find_branch_colors, rep(find_branches[i], nrow(branchx_points)))
           find_branch_ids <- append(find_branch_ids, rep(traits()[i, 1], nrow(branchx_points)))
           find_point_ids <- append(find_point_ids, rep(indices[i], nrow(branchx_points)))
         }
      #points3d(find_branch_points, col = rgb(read.table(text = find_branch_colors, sep = " ")))
       p <- plot_ly(find_branch_points, x = V1, y = V2, z = V3, 
                    #hoverinfo = "text",
                    text = paste("Branch: ", traits()[find_point_ids, 1],#find_branch_ids,
                                  "<br>Volume: ", traits()[find_point_ids, 6],
                                  "<br>Length: ", traits()[find_point_ids, 7]),
                    type = "scatter3d", mode = "markers",
                    marker = list(color = rgb(read.table(text = find_branch_colors, sep = " ")), 
                                  size = 1)) 
#       p <- plot_ly(find_branch_points, x = V1, y = V2, z = V3, text = paste("id: ", find_branch_ids),
#                    type = "scatter3d", mode = "markers",
#                    marker = list(color = rgb(read.table(text = find_branch_colors, sep = " ")), 
#                                  size = 1))
      layout(p, scene = scene,
             xaxis = list(title = "x"), 
             yaxis = list(title = "y"), 
             zaxis = list(title = "z"))
      #}
    
    } else{
    
    #points3d(NULL)
    #axes3d()
    plotly_empty()
    }
  })
  
  
   observe({
     
     if ( !is.null(traits_raw()) )
     {
       output$FilterExp <- renderUI({
         textInput("filter", "expression: (e.g. length > 5 & volume > 50)", '')
       })
       
       output$FilterButton <- renderUI({
         actionButton("Subset", "Get subset")
       })
       
#       maxLength <- max(traits_raw()[, 7])
#       output$LengthFilter <- renderUI({
#         sliderInput("LFilter", "Filter by length", min = 0, max = maxLength, value = c(0, maxLength))
#       })
#       
#       maxVolume <- max(traits_raw()[, 6])
#       output$VolumeFilter <- renderUI({
#         sliderInput("VFilter", "Filter by volume", min = 0, max = maxVolume, value = c(0, maxVolume))
#       })
#       
#       maxOder <- max(traits_raw()$H)
#       output$OrderFilter <- renderUI({
#         sliderInput("OFilter", "Filter by branching order", step = 1, 
#                     min = 0, max = maxOder, value = c(0, maxOder))
#       })
#       
#       maxSoilAngle <- max(traits_raw()[, 13])
#       minSoilAngle <- min(traits_raw()[, 13])
#       output$SoilAngleFilter <- renderUI({
#         sliderInput("SAFilter", "Filter by soil angle", min = minSoilAngle, max = maxSoilAngle, value = c(minSoilAngle, maxSoilAngle))
#       })
#       
     }
   })
  
  filterVal <- reactiveValues(str = NULL)
  
  observeEvent(input$Subset, {
    filterVal$str <- input$filter})
  
  #output$filterText <- renderText(filterVal())
  
  traits <- reactive({
    
    if ( !is.null(traits_raw()) & (!is.null(filterVal$str)) )
    {
      if (filterVal$str != "" ) {
        filterVal1 <- filterVal$str
        filterVal1 <- gsub("length", "traits_raw()[, 7]", filterVal1)
        filterVal1 <- gsub("volume", "traits_raw()[, 6]", filterVal1)
        filterVal1 <- gsub("order", "traits_raw()[, 5]", filterVal1)
        filterVal1 <- gsub("soil_angle", "traits_raw()[, 13]", filterVal1)
        filterVal1 <- gsub(" ", "", filterVal1)
        filtedData <- NULL
        filtedData <- try(do.call(subset, list(traits_raw(), parse(text = filterVal1))), silent = TRUE)
        
        if(!is(filtedData, 'try-error')) {
          if(is.data.frame(filtedData)) {
            filtedData
          }
        }
        else
          traits_raw()
      }
      else 
        traits_raw()
    }
      #traits_raw()
    else if (!is.null(traits_raw()))
      traits_raw()
    
    else
      return(NULL)
    


  })
  
  observe({ 
    
    if ( input$tabs == "Distribution Plot" )
    {
      selectedData <- reactive({
        
        if ( is.null(traits()) )
          return(NULL)
        
        traits()[, getIndex(input$variables)]
        
      })
      
      
      filtedData <- reactive({
        
        if ( is.null(selectedData()) )
          return(NULL)
        
        if (input$types == "Lateral")
          filtedData <- selectedData()[traits()$Class %in% " Lateral"]
        else if (input$types == "First-order Lateral")
          filtedData <- selectedData()[traits()$H == 1 & traits()$Class %in% " Lateral"]
        else if (input$types == "Secondary Lateral")
          filtedData <- selectedData()[traits()$H == 2 & traits()$Class %in% " Lateral"]
        
        if (length(filtedData)==0)
          return(NULL)
        
        filtedData
        
      })
      
      
      output$text <- renderText({
        #if (input$types == "First-order Lateral")
        paste("Number of branches:", length(filtedData()))
      })
      
      output$histPlot <- renderPlot({
        if ( !is.null(filtedData()) )
        {
          
          #       maxx <- max(selectedData())
          #       minx <- min(selectedData())
          if ( input$variables == "Radial Angle" )
          {
            tipXYZ <- strsplit(as.character(filtedData()), "[^0-9.]+")
            tipXYZ <- data.frame(matrix(as.numeric(unlist(tipXYZ)), ncol = 4, byrow = TRUE))
            centroid_X <- mean(tipXYZ[, 2])
            centroid_Y <- mean(tipXYZ[, 3])
            radial_angle <- atan2(tipXYZ[, 3]-centroid_Y, tipXYZ[, 2]-centroid_X)
            h <- hist(radial_angle, breaks = seq(-pi, pi, pi/input$bins), plot = FALSE)
            
            radial.plot(h$counts/length(filtedData()), h$breaks[-1], rp.type = "p", line.col = "skyblue",
                        label.pos = h$breaks, labels = NULL)
          }
          
          else {
            if (input$variables == "Branching Angle")
              h <- hist(filtedData(), breaks = seq(0, 180, 180/input$bins), plot = FALSE)
            else if (input$variables == "Soil Angle")
              h <- hist(filtedData(), breaks = seq(-90, 90, 180/input$bins), plot = FALSE)
            else 
              h <- hist(filtedData(), breaks = input$bins, plot = FALSE)
            
            h$density <- h$counts / length(filtedData())
            plot(h, freq = FALSE, col = "skyblue",
                 xlab = input$variables,
                 main = NULL)
          }
        }
      })
    }
      
      })
  
  
  observe({
    
    if (input$tabs == "Scatter Plot")
    {
      output$scatterPlot <- renderPlotly({
        
        if ( !is.null(traits()) )
        {
          #       plot(traits()[, getIndex(input$xcol)], traits()[, getIndex(input$ycol)],
          #            xlab = input$xcol, ylab = input$ycol, col = traits()[, 5])
          sp <- plot_ly(traits(), x = traits()[, getIndex(input$xcol)], y = traits()[, getIndex(input$ycol)], 
                        mode = "markers", color = as.factor(paste("Order:", traits()[, 5]))) 
          layout(sp, xaxis = list(title = input$xcol), 
                 yaxis = list(title = input$ycol),
                 legend = list(traceorder = "reversed"))
          
        }
        else
          plotly_empty()
        
      })
    }
    
  })
 

 
})
