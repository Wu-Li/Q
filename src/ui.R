library(shiny)

.Q <<- new.env()
source('R/mapBinding.R')
source('R/jsBinding.R')

shinyUI(
    fluidPage(
        id="page",
        title="LSpace",
        tags$head(
            tags$link(rel="icon",href="Q.png"),
            #CSS
            tags$link(rel="stylesheet",href="css/lib/mapjs-default-styles.css"),
            tags$link(rel="stylesheet",href="js/lib/jquery-ui/jquery-ui.min.css"),
            tags$link(rel="stylesheet",href="css/prompt.css"),
            tags$link(rel="stylesheet",href="css/panels.css"),
            tags$link(rel="stylesheet",href="css/maps.css"),
            tags$link(rel="stylesheet",href="css/mobile.css"),
            tags$link(rel="stylesheet",href="css/colors.css"),
            #JS
            tags$script(src = "js/lib/jquery-2.0.2.min.js"),
            tags$script(src = "js/lib/jquery.nicescroll.min.js"),
            tags$script(src = "js/lib/jquery-ui/jquery-ui.min.js"),
            tags$script(src = "js/interface.js"),
            withMathJax()
        ),
        #Tabs
        div(id='tabs-wrapper',
            tabsetPanel(id="tabs",
                        selected="Queries",
                        tabPanel("Names",value="Names",icon=icon("sitemap",class='fa-2x'),.Q$mapInput("Names")),
                        tabPanel("Sources",value="Sources",icon=icon("code-fork",class='fa-2x'),.Q$mapInput("Sources")),
                        tabPanel("Tests",value="Tests",icon=icon("tachometer",class='fa-2x'),.Q$mapInput("Tests")), 
                        tabPanel("Styles",value="Styles",icon=icon("fire",class='fa-2x'),.Q$mapInput("Styles")),
                        tabPanel("Views",value="Views",icon=icon("eye",class='fa-2x'),.Q$mapInput("Views")),
                        tabPanel("Data",value="Data",icon=icon("table",class='fa-2x'),dataTableOutput("Data")),
                        tabPanel("Queries",value="Queries",icon=icon("crosshairs",class='fa-2x'),.Q$mapInput("Queries"))    
                        ),
            div(id='tray',
                actionButton("save","",icon=icon("save")),
                actionButton("redo","",icon=icon("undo",class="fa-flip-horizontal")),
                actionButton("undo","",icon=icon("undo")),
                actionButton("run","",icon=icon("play")),
                actionButton("print","",icon=icon("external-link",class="fa-flip-horizontal"))
            )
                        ),
        #Panels
        tabsetPanel(id="panels",
                    type="pills",
                    selected="console",
                    tabPanel("Q",value="Q"),
                    tabPanel("",value="help",icon=icon("question-circle"),
                             div(id="help-panel",
                                 uiOutput("help")
                             )
                    ),
                    tabPanel("",value="config",icon=icon("cogs"),
                             div(id='config-panel',
                                 tableOutput("database"),
                                 .Q$jsInput("dbSave",'dbSave'),
                                 .Q$jsInput("dbLoad",'dbLoad'),
                                 .Q$jsInput("js",'js'),
                                 .Q$jsInput("jsError",'jsError'),
                                 numericInput("panelWidth","panelWidth",64),
                                 numericInput("panelHeight","panelHeight",950)
                             )
                    ),
                    #conditionalPanel(condition='output.showPlot',
                        tabPanel("",value="plot",icon=icon("bar-chart-o"),
                             plotOutput("plot")   
                    #    )
                    ),
                    tabPanel("",value="console",icon=icon("chevron-right"),
                             div(id="console-panel",
                                 div(id="fadeup"),
                                 uiOutput("console")
                             )
                    )
                    
        ),
        #Prompt
        div(id="prompt-box",
            textInput("prompt",">",""),
            actionButton("submit", "")
        )
            )
        )