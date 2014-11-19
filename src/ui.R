library(shiny)

source('R/mapBinding.R')

shinyUI(
    fluidPage(
        id="page",
        title="LSpace",
        tags$head(
            tags$link(rel="icon",href="Q.png"),
            #CSS
            tags$link(rel="stylesheet",href="css/lib/mapjs-default-styles.css"),
            tags$link(rel="stylesheet",href="js/lib/jquery-ui/jquery-ui.min.css"),
            tags$link(rel="stylesheet",href="css/panels.css"),
            tags$link(rel="stylesheet",href="css/maps.css"),
            tags$link(rel="stylesheet",href="css/colors.css"),
            #JS
             tags$script(src = "js/lib/jquery-2.0.2.min.js"),
             tags$script(src = "js/lib/jquery.nicescroll.min.js"),
             tags$script(src = "js/lib/jquery-ui/jquery-ui.min.js"),
             tags$script(src = "js/panels.js")
        ),   
        #Prompt
        div(id="prompt-box",
            textInput("prompt",">",""),
            actionButton("submit", "")
        ),
        #Tabs
        tabsetPanel(id="tabs",
                    selected="Queries",
                    tabPanel("Sources",value="Sources",icon=icon("puzzle-piece",class='fa-2x'),mapInput("Sources")),
                    tabPanel("Names",value="Names",icon=icon("tags",class='fa-2x'),mapInput("Names")),
                    tabPanel("Tests",value="Tests",icon=icon("tachometer",class='fa-2x'),mapInput("Tests")), 
                    tabPanel("Styles",value="Styles",icon=icon("fire",class='fa-2x'),mapInput("Styles",value='{"title":"Styles","id":1,"formatVersion":2,"ideas":{"11":{"title":"maps","id":4,"ideas":{"1":{"title":"tray","id":11,"attr":{"position":[99.5,200,5],"style":{}}},"0.5":{"title":"colors","id":5,"attr":{"style":{},"position":[69.5,-311,4]}}},"attr":{"style":{}}},"-0.5":{"title":"panels","id":2,"ideas":{"1":{"title":"console","id":6},"2":{"title":"plot","id":7},"3":{"title":"database","id":8},"4":{"title":"help","id":9}},"attr":{"position":[178.5,-230,1],"style":{}}},"-11":{"title":"prompt","id":12,"attr":{"style":{},"position":[268.5,255,2]}}}}')),
                    tabPanel("Views",value="Views",icon=icon("eye",class='fa-2x'),mapInput("Views",value='{"title":"Views","id":1,"formatVersion":2,"ideas":{"10":{"title":"ggplot(mtcars, aes(wt, mpg)) + geom_line(aes(colour=hp,size=disp))","id":6,"attr":{"style":{}}}},"links":[]}')),
                    tabPanel("Formula",value="Formula",icon=icon("sitemap",class='fa-2x'),mapInput("Formula")),
                    tabPanel("Units",value="Units",icon=icon("cogs",class='fa-2x'),mapInput("Units")),
                    tabPanel("Data",value="Data",icon=icon("table",class='fa-2x'),mapInput("Data")),
                    tabPanel("Queries",value="Queries",icon=icon("crosshairs",class='fa-2x'),mapInput("Queries"))    
        ),
        div(id='global-tray',
            div(class='save',actionButton("save","",icon=icon("save"))),
            div(class='load',actionButton("load","",icon=icon("external-link",class="fa-flip-horizontal")))
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
                    tabPanel("",value="environments",icon=icon("asterisk"),
                             uiOutput("environments")
                    ),
                    tabPanel("",value="database",icon=icon("code-fork"),
                             textInput("consoleMap","console map:"),
                             textInput("query","save JSON:"),
                             numericInput("panelWidth","width",64),
                             numericInput("panelHeight","height",950),
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
                    
        )
    )
)