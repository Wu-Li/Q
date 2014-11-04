options("shiny.launch.browser"=T)

library(shiny)

source('R/jsonBinding.R')
source('R/mapBinding.R')

shinyUI(fluidPage(id="page",title="Q",
    
    tags$head(
        tags$link(rel="icon",href="Q.png"),
    
        #CSS
        tags$link(rel="stylesheet",href="/css/lib/mapjs-default-styles.css"),
        tags$link(rel="stylesheet",href="/css/layout.css"),
        tags$link(rel="stylesheet",href="/css/panels.css"),
        tags$link(rel="stylesheet",href="/css/maps.css"),
        tags$link(rel="stylesheet",href="/css/colors.css"),
        
        #JS
        tags$script(src = "/js/console.js")
    ),    
    
    #Begin Layout
    sidebarLayout(
        sidebarPanel(id="sidebar",
           span("Q",id="Q"),
           tabsetPanel(id="panels",type="pills",
                tabPanel("",icon=icon("chevron-right"),
                     div(id="console-panel",
                         div(id="fadeup"),
                         uiOutput("console")
                     )
                 ),
                tabPanel("",icon=icon("code-fork"),
                     jsonInput("query"),
                     uiOutput("qbase")
                )
            ),
            div(id="prompt-box",
               textInput("prompt",">",""),
               actionButton("submit", "")
            )
        ),
        mainPanel(
            tabsetPanel(id="tabs",selected="Workspace",
                tabPanel("Formulae",value="Formulae",icon=icon("superscript"),mapInput("Formulae")), 
                tabPanel("Units",value="Units",icon=icon("tachometer"),mapInput("Units")),
                tabPanel("Classes",value="Classes",icon=icon("sitemap"),mapInput("Classes")),
                tabPanel("Sources",value="Sources",icon=icon("puzzle-piece"),mapInput("Sources")),
                tabPanel("Data",value="Data",icon=icon("table"),mapInput("Data")),
                tabPanel("Names",value="Names",icon=icon("tags"),mapInput("Names")),
                tabPanel("Styles",value="Styles",icon=icon("fire"),mapInput("Styles")),
                tabPanel("Views",value="Views",icon=icon("eye"),mapInput("Views")),
                tabPanel("Workspace",value="Workspace",icon=icon("crosshairs"),mapInput("Workspace"))    
            ),
        div(class='save',actionButton("save","",icon=icon("save"))),
        div(class='load',actionButton("load","",icon=icon("external-link")))
        )
    )
))