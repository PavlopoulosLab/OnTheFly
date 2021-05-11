library(shiny)

locations <- data.frame(City=c("Ames", "Beaumont", "Beaumont", "Portland", "Portland"),
                        State=c("IA", "CA", "TX", "ME", "OR"),
                        value=c("10010", "20020", "30030", "40040", "50050"))

locations$label = paste(locations$City, locations$State, sep=", ")

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectizeInput("locationInput", "Location", choices=NULL, selected=NULL, multiple = T),
      textOutput("values")
    ),
    mainPanel("Main Panel")
  )
)

server <- function(input, output, session) {
  updateSelectizeInput(session, 'locationInput',
                       choices = locations,
                       server = TRUE
  )
  
  output$values <- renderText({
    paste("Zip code =", input$locationInput)
  })
}
shinyApp(ui, server)