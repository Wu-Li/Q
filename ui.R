options("shiny.launch.browser"=T)

library(shiny)

source('R/jsonBinding.R')
source('R/mapBinding.R')

shinyUI(fluidPage(id="page",title="LSpace",
    
    tags$head(
        tags$link(rel="icon",href="Q.png"),
    
        #CSS
        tags$link(rel="stylesheet",href="css/lib/mapjs-default-styles.css"),
        tags$link(rel="stylesheet",href="css/layout.css"),
        tags$link(rel="stylesheet",href="css/panels.css"),
        tags$link(rel="stylesheet",href="css/maps.css"),
        tags$link(rel="stylesheet",href="css/colors.css"),
        
        #JS
        tags$script(src = "js/console.js")
    ),    
    
    #Begin Layout
    sidebarLayout(
        sidebarPanel(id="sidebar",
           span("Q",id="Q"),
           tabsetPanel(id="panels",type="pills",selected="console",
                       tabPanel("",value="help",icon=icon("question-circle"),
                                uiOutput("help")
                       ),
                       tabPanel("",value="database",icon=icon("code-fork"),
                                jsonInput("query"),
                                uiOutput("database")
                       ),
                       tabPanel("",value="plot",icon=icon("bar-chart-o"),
                                plotOutput("plot")       
                        ),
                       tabPanel("",value="console",icon=icon("chevron-right"),
                                div(id="console-panel",
                                    div(id="fadeup"),
                                    uiOutput("console")
                                )
                       )
            ),
            div(id="prompt-box",
               textInput("prompt",">",""),
               actionButton("submit", "")
            )
        ),
        mainPanel(
            tabsetPanel(id="tabs",selected="Queries",
                tabPanel("Sources",value="Sources",icon=icon("puzzle-piece"),mapInput("Sources")),
                tabPanel("Names",value="Names",icon=icon("tags"),mapInput("Names")),
                tabPanel("Tests",value="Tests",icon=icon("tachometer"),mapInput("Tests")), 
                tabPanel("Styles",value="Styles",icon=icon("fire"),mapInput("Styles")),
                tabPanel("Views",value="Views",icon=icon("eye"),mapInput("Views")),
                tabPanel("Formula",value="Formula",icon=icon("sitemap"),mapInput("Formula")),
                tabPanel("Units",value="Units",icon=icon("cogs"),mapInput("Units")),
                tabPanel("Data",value="Data",icon=icon("table"),
                         mapInput("Data",
                                  value='{"title": "ggplot(mtcars, aes(wt, mpg)) + geom_line()","id": 1,"formatVersion": 2, "ideas": {  } }'
                         )
                 ),
                tabPanel("Queries",value="Queries",icon=icon("crosshairs"),mapInput("Queries"))    
            ),
        div(class='save',actionButton("save","",icon=icon("save"))),
        div(class='load',actionButton("load","",icon=icon("external-link")))
        )
    )
))