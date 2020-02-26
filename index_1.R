library(shiny)
library(tidyverse)
library(dplyr)
library(magrittr)
library(shinyjs)
library(Stat2Data)

data<- as.data.frame(Titanic)
# Define UI for application that draws a histogram
data_sex = levels(data$Sex)
data_class= levels(data$Class)

headerRow<- div(id="header", useShinyjs(),
    selectInput("selSex",
                "Select the gender",
                multiple=TRUE,
                choices = data_sex), 
    selectInput("selClass",
                "Select the Class",
                multiple=TRUE,
                choices = data_class)
)

plotlyPanel <- tabPanel("Gender", 
                        plotly::plotlyOutput("plotlyData")
                        )
plotlyPanelC <- tabPanel("Class", 
                        plotly::plotlyOutput("plotlyDataC")
)
ui <-navbarPage("Titanic App",
                plotlyPanel,plotlyPanelC,
                header= headerRow
)

server = function(input, output) {
    data_filtered <- reactive({
        req(input$selSex)
        data %>% filter(Sex %in% input$selSex)
        })
    

    output$plotlyData = plotly::renderPlotly({
      data_filtered() %>%
        ggplot(aes(x=Sex, y=Freq, fill=Sex)) + 
            geom_boxplot(position=position_dodge())
    })
    data_filteredC <- reactive({
      req(input$selClass)
      data %>% filter(Class %in% input$selClass)
    })
    
    output$plotlyDataC = plotly::renderPlotly({
      data_filteredC() %>%
        ggplot(aes(x=Class, y=Freq, fill=Class)) + 
        geom_boxplot(position=position_dodge())
    })
#    output$plot_hoverinfo <- renderPrint({
#        cat("Hover (throttled):\n")
#        str(input$plot_hover)
#    })

    countryname<- reactive({
        req(countryIndex() > 0 & countryIndex()<= length(input$selCountry))
        str_sort(input$selCountry)[countryIndex()]
        })
    output$txtCountry<- renderText(countryname())
    SexIndex<- reactive({
        req(input$plot_hover$x)
        ceiling((input$plot_hover$x-round(input$plot_hover$x)+0.5) * length(input$selSex))
    })
    Sexname<- reactive({
        req(SexIndex() > 0 & SexIndex()<= length(input$selSex))
        str_sort(input$selSex)[SexIndex()]
    })
    output$txtSex<- renderText(Sexname())
    output$txtPop<- renderText(
        data %>% filter(Sex== Sexname()))
}

# Run the application 
shinyApp(ui = ui, server = server)