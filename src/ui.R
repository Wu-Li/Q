library(shiny)
library(rmongodb)

source('R/mapBinding.R')
source('R/jsBinding.R')

shinyUI(
    fluidPage(
        id="page",
        title="QuoiR",
        tags$head(
            tags$link(rel="icon",href="Q.png"),
            #CSS
            tags$link(rel="stylesheet",href="css/lib/mapjs-default-styles.css"),
            tags$link(rel="stylesheet",href="js/lib/jquery-ui/jquery-ui.min.css"),
            tags$link(rel="stylesheet",href="css/prompt.css"),
            tags$link(rel="stylesheet",href="css/panels.css"),
            tags$link(rel="stylesheet",href="css/views.css"),
            tags$link(rel="stylesheet",href="css/mobile.css"),
            tags$link(rel="stylesheet",href="css/syntax.css"),
            #JS
            tags$script(src = "js/lib/jquery-2.0.2.min.js"),
            tags$script(src = "js/lib/jquery.nicescroll.min.js"),
            tags$script(src = "js/lib/jquery-ui/jquery-ui.min.js"),
            tags$script(src = "js/interface.js")
            #withMathJax()
        ),
        #Tabs
        div(id='tabs-wrapper',
            uiOutput("views"),
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
                    tabPanel("Q",value="Q",div(id="chat",p("Hello World!"),p("...or whoever you are."),p("May I help you with something?"))),
                    tabPanel("",value="help",icon=icon("question-circle"),
                             div(id="help-panel",
                                 uiOutput("help")
                             )
                    ),
                    tabPanel("",value="config",icon=icon("cogs"),
                             div(id='config-panel',
                                 tableOutput("database"),
                                 jsInput("dbSave",'dbSave'),
                                 jsInput("dbLoad",'dbLoad'),
                                 jsInput("js",'js'),
                                 jsInput("jsError",'jsError'),
                                 numericInput("panelWidth","panelWidth",64),
                                 numericInput("panelHeight","panelHeight",950)
                             )
                    ),
                    #conditionalPanel(condition='output.showPlot',
                        tabPanel("",value="plot",icon=c(icon("cubes")),
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