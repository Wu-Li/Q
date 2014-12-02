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
            tags$link(rel="stylesheet",href="css/panels.css"),
            tags$link(rel="stylesheet",href="css/maps.css"),
            tags$link(rel="stylesheet",href="css/mobile.css"),
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
                    tabPanel("Names",value="Names",icon=icon("tags",class='fa-2x'),.Q$mapInput("Names",value='{"title":"Names","id":1,"formatVersion":2,"ideas":{"11":{"title":"Units","id":3},"21":{"title":"Formula","id":4},"31":{"title":"Views","id":5},"41":{"title":"Styles","id":6},"51":{"title":"Tests","id":7},"61":{"title":"Sources","id":8},"5.5":{"title":"Data","id":9,"attr":{"style":{}}}},"links":[]}')),
                    tabPanel("Sources",value="Sources",icon=icon("puzzle-piece",class='fa-2x'),.Q$mapInput("Sources")),
                    tabPanel("Tests",value="Tests",icon=icon("tachometer",class='fa-2x'),.Q$mapInput("Tests")), 
                    tabPanel("Styles",value="Styles",icon=icon("fire",class='fa-2x'),.Q$mapInput("Styles",value='{"title":"Styles","id":1,"formatVersion":2,"ideas":{"11":{"title":"maps","id":4,"ideas":{"1":{"title":"tray","id":11,"attr":{"position":[99.5,200,5],"style":{}}},"0.5":{"title":"map colors","id":5,"attr":{"style":{},"position":[69.5,-311,4]}}},"attr":{"style":{}}},"-0.5":{"title":"panels","id":2,"ideas":{"1":{"title":"console","id":6},"2":{"title":"console plot","id":7},"3":{"title":"database","id":8},"4":{"title":"R help","id":9}},"attr":{"position":[178.5,-230,1],"style":{}}},"-11":{"title":"Q prompt","id":12,"attr":{"style":{},"position":[268.5,255,2]}}}}')),
                    tabPanel("Views",value="Views",icon=icon("eye",class='fa-2x'),.Q$mapInput("Views",value='{"title":"Views","id":1,"formatVersion":2,"ideas":{"10":{"title":"ggplot(mtcars, aes(wt, mpg)) + geom_line(aes(colour=hp,size=disp))","id":6,"attr":{"style":{}}}},"links":[]}')),
                    tabPanel("Formula",value="Formula",icon=icon("sitemap",class='fa-2x'),.Q$mapInput("Formula")),
                    tabPanel("Units",value="Units",icon=icon("cogs",class='fa-2x'),.Q$mapInput("Units")),
                    tabPanel("Data",value="Data",icon=icon("table",class='fa-2x'),.Q$mapInput("Data",value='{"title":"Data","id":1,"formatVersion":2,"ideas":{"1":{"title":"mtcars","id":2,"ideas":{}}}}')),
                    tabPanel("Queries",value="Queries",icon=icon("crosshairs",class='fa-2x'),.Q$mapInput("Queries",value='{"title":"Queries","id":1,"formatVersion":2,"ideas":{"5.5":{"title":"@","id":43,"ideas":{"2":{"title":"Data","id":2,"ideas":{"1":{"title":"mtcars","id":11,"attr":{"style":{}}}},"attr":{"style":{}}},"3":{"title":"Units","id":3,"ideas":{"3":{"title":"$","id":12,"ideas":{"1":{"title":"Demo.Units","id":24,"ideas":{}}},"attr":{"style":{}}}},"attr":{"style":{}}},"4":{"title":"Formula","id":4,"ideas":{"3":{"title":"$","id":13,"ideas":{"1":{"title":"Demo.Formula","id":25,"ideas":{}}},"attr":{"style":{}}}},"attr":{"style":{}}},"5":{"title":"Views","id":5,"ideas":{"3":{"title":"$","id":14,"ideas":{"1":{"title":"Demo.Views","id":26,"ideas":{}}},"attr":{"style":{}}}},"attr":{"style":{}}},"6":{"title":"Styles","id":6,"ideas":{"3":{"title":"$","id":15,"ideas":{"1":{"title":"Demo.Styles","id":27,"ideas":{}}},"attr":{"style":{}}}},"attr":{"style":{}}},"7":{"title":"Tests","id":7,"ideas":{"3":{"title":"$","id":17,"ideas":{"1":{"title":"Demo.Tests","id":28,"ideas":{}}},"attr":{"style":{}}}},"attr":{"style":{}}},"8":{"title":"Sources","id":8,"ideas":{"3":{"title":"$","id":18,"ideas":{"1":{"title":"Demo.Sources","id":29,"ideas":{}}},"attr":{"style":{}}}},"attr":{"style":{}}},"9":{"title":"Names","id":9,"ideas":{"3":{"title":"$","id":10,"ideas":{"1":{"title":"*","id":30,"ideas":{}}},"attr":{"style":{}}}},"attr":{"style":{}}}},"attr":{"style":{}}}},"links":[]}'))    
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
                    tabPanel("",value="database",icon=icon("code-fork"),
                             uiOutput("database"),
                             .Q$jsInput("JS"),
                             .Q$jsInput("jserr"),
                             numericInput("panelWidth","width",64),
                             numericInput("panelHeight","height",950)
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