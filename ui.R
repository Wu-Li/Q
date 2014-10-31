options("shiny.launch.browser"=T)

library(shiny)

#JSON Input Binding
jsonInput <- function(inputId, value = "") {
  tagList(
    singleton(tags$head(tags$script(src = "/js/jsonBinding.js"))),
    tags$input(id = inputId,
                class = "json",
                type = "text",
                value = value)
  )
}
#Reactive Map Binding
mapInput <- function(inputId, 
  value = paste0('{"title": "',inputId,'","id": 1,"formatVersion": 2, "ideas": {  } }')) 
{
  tagList(
    singleton(tags$head(
        tags$script(src="/js/mapjs/lib/jquery-2.0.2.min.js", type="text/javascript"),
        tags$script(src="/js/mapjs/lib/jquery.hotkeys.js"),
        tags$script(src="/js/mapjs/lib/hammer.min.js"),
        tags$script(src="/js/mapjs/lib/jquery.hammer.min.js"),
        tags$script(src="/js/mapjs/lib/underscore-1.4.4.js", type="text/javascript"),
        tags$script(src="/js/mapjs/lib/color-0.4.1.min.js"),
        
        tags$script(src="/js/mapjs/mapjs.js"),
        tags$script(src="/js/mapjs/observable.js"),
        tags$script(src="/js/mapjs/url-helper.js"),
        tags$script(src="/js/mapjs/content.js"),
        tags$script(src="/js/mapjs/layout.js"),
        tags$script(src="/js/mapjs/clipboard.js"),
        tags$script(src="/js/mapjs/hammer-draggable.js"),
        tags$script(src="/js/mapjs/map-model.js"),
        tags$script(src="/js/mapjs/map-toolbar-widget.js"),
        tags$script(src="/js/mapjs/link-edit-widget.js"),
        tags$script(src="/js/mapjs/image-drop-widget.js"),
        tags$script(src="/js/mapjs/dom-map-view.js"),
        tags$script(src="/js/mapjs/dom-map-widget.js"),
        
        tags$script(src="/js/mapjs/attachments.js"),

        tags$script(src="/js/mapBinding.js")
    )),
    
    tags$div(id = inputId, class = "qmap",
            tags$script(paste0(
                'loadMap($("#',inputId,'"),',value,');'
            )),
            tags$div(id = paste0(inputId,"-tray"),class="tray",
                    actionButton(paste0(inputId,"-save"),"",icon=icon("save")),
                    actionButton(paste0(inputId,"-load"),"",icon=icon("external-link"))
            )
    )
  )
}

shinyUI(fluidPage(id="page",title="Q",
    
    tags$link(rel="stylesheet",href="/css/lib/mapjs-default-styles.css"),
    tags$link(rel="stylesheet",href="/css/core.css"),
    tags$link(rel="stylesheet",href="/css/console.css"),
    tags$link(rel="stylesheet",href="/css/maps.css"),
    tags$link(rel="stylesheet",href="/css/tray.css"),
    tags$link(rel="stylesheet",href="/css/inspector.css"),
    tags$link(rel="stylesheet",href="/css/user.css"),
    
    tags$script(src = "/js/ui.js"),
    
    #Begin Layout
    sidebarLayout(
        sidebarPanel(id="console",
           span("Q",id="Q"),
           div(id="fadeup"),
           div(id="faderight"),
           tags$ol(id="out",
               uiOutput("console"),
               jsonInput("query"),
               uiOutput("qbase")
           ),
           div(id="prompt-box",
               textInput("prompt",">",""),
               actionButton("submit", "")
           )
        ),
        mainPanel(tabsetPanel(id="tabs",selected="Workspace",
            tabPanel("Formulae",icon=icon("superscript"),mapInput("Formulae")), 
            tabPanel("Units",icon=icon("tachometer"),mapInput("Units")),
            tabPanel("Classes",icon=icon("sitemap"),mapInput("Classes")),
            tabPanel("Sources",icon=icon("puzzle-piece"),mapInput("Sources")),
            tabPanel("Data",icon=icon("table"),mapInput("Data")),
            tabPanel("Names",icon=icon("tags"),mapInput("Names")),
            tabPanel("Styles",icon=icon("fire"),mapInput("Styles")),
            tabPanel("Views",icon=icon("eye"),mapInput("Views")),
            tabPanel("Workspace",icon=icon("code-fork"),mapInput("Workspace"))
        ))
    )
))