#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(readxl)
library(dplyr)
library(tidyverse)
library(purrr)
library(kableExtra)
library(stringi)
library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(
            fileInput("datain", "Upload excel layout", buttonLabel = "Choose file..."),
            downloadButton("csv_for_bulk_upload", "Get .csv for bulk upload")),
        
        
        mainPanel("Generate the .csv file to complete the bulk upload in WHIP. Upload the excel layout and click
        on 'Get .csv for bulk upload'")
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    

    output$csv_for_bulk_upload <- downloadHandler(
        
        filename = function() { 
            paste("WHIP_bulk_upload_", Sys.Date(), ".csv", sep="")
        },
        
        content = function(file) {
            
            # event<-read_excel(input$datain$datapath, 
            #                   sheet = "Event", 
            #                   col_types = "text")
            # 
            # 
            # obs<-read_excel(input$datain$datapath, 
            #                 sheet = "Observation", 
            #                 col_types = "text")
            # 
            # spec<-read_excel(input$datain$datapath, 
            #                  sheet = "Specimen", 
            #                  col_types = "text")
            # 
            # 
            # necropsy<-read_excel(input$datain$datapath, 
            #                      sheet = "Necropsy", 
            #                      col_types = "text")
            # 
            # diag<-read_excel(input$datain$datapath, 
            #                  sheet = "Diagnostics", 
            #                  col_types = "text")
            # 
            # 
            # samples<-read_excel(input$datain$datapath, 
            #                     sheet = "Samples", 
            #                     col_types = "text")
            # 
            # tests<-read_excel(input$datain$datapath, 
            #                   sheet = "Tests", 
            #                   col_types = "text")
            # 
            # diagnosis<-read_excel(input$datain$datapath, 
            #                       sheet = "Diagnosis", 
            #                       col_types = "text")
            
            source("/Users/DMontecino/Desktop/OneDrive - Wildlife Conservation Society/BULK UPLOAD/DTRA_CAMBODIA_LAOS_VIETNAM/create_csv_layout_for_WHIP_bulk_upload_WHN/Create_csv_to_upload_from_excel_layout.R")
            
            write.csv(out6, file, row.names = F, na="")
            
        })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
