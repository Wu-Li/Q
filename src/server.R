cat("\014")
library(shiny)
library(rmongodb)
library(ggplot2)
library(pryr)
library(jsonlite)
library(gridExtra)
shinyServer(function(input, output, session) {
  console <- new.env()
  .Q$clear <- function() {
    cat("\014")
    console$.results <- NULL
    console$.types   <- NULL
    console$.hovers  <- NULL 
    console$.widths  <- NULL
  }
  .Q$clear()
  .Q$exit <- function() { stopApp(returnValue = NULL) }
  observe({ console$.ME <- session })
  observe({ console$.SE <- environment(session$sendInputMessage) })
  print("--Session--")
  
  
  ###Maps###
  getMap <- function(inputId) {
    map <- eval( parse(text = paste0('input$',inputId)))
    if ('list' %in% class(map)) { 
      map <- rapply(map, 
                    function(node) tryCatch(
                        { eval( parse(text = node) ) },
                        error = function(e) { e } ), 
                    how = 'replace') 
    } 
  }
  active <- reactiveValues( map = NA )
  observe({ 
    map <- getMap(input$tabs)
    if (is.null(map)) { map <- input$tabs }
    active$map <- map
  })
  observe({
    console$Queries <- getMap('Queries')[[1]]
    console$Data    <- getMap('Data')[[1]]
    console$Units   <- getMap('Units')[[1]]
    console$Formula <- getMap('Formula')[[1]]
    console$Views   <- getMap('Views')[[1]]
    console$Styles  <- getMap('Styles')[[1]]
    console$Tests   <- getMap('Tests')[[1]]
    console$Names   <- getMap('Names')[[1]]
    console$Sources <- getMap('Sources')[[1]]
  })
  
  
  ###Panel Controller###
  prompt <- reactiveValues(
    keywords = c('clear','exit'),
    panel = 'console',
    console = NA,
    javascript = NA,
    help = NA,
    plot = NA
  )
  observe({ 
    if (input$submit > 0) {
      entry <- isolate(input$prompt)
      if (!is.na(entry) && entry != '') {
        if (entry %in% prompt$keywords) { entry <- paste0('.Q$',entry,'()') }
        switch(substr(entry, 1, 1), { #R
            .Q$toConsole(paste0("> ",entry),'in','expression')
            tryCatch({
              console$.map <- isolate(active$map)
              if (grepl("@",entry)) {
                entry <- gsub("@(?=\\()", ".draw", entry, perl=T) 
                entry <- gsub("@(?=[A-Za-z])", ".map[[1]]$", entry, perl=T) 
                entry <- gsub("@(?=[[])", ".map[[1]]", entry, perl=T) 
                entry <- gsub("@", ".map", entry)
              } 
              entry <- eval( parse(text=entry), console )
              if ('ggplot' %in% class(entry)) { 
                prompt$plot <- entry
                prompt$panel <- 'plot'
              } else {
                .Q$toConsole(capture.output(entry),'out',paste0(class(entry),collapse=' '))  
                prompt$panel <- 'console'
              }
            },
            warning = function(w){
              w <- sub('simpleWarning in eval(expr, envir, enclos)','warning',w,fixed=T)
              .Q$toConsole(w,'warning','warning')
              entry <- suppressWarnings( eval(parse(text=entry), console ) )
              .Q$toConsole(caputure.output(entry),'out',paste0(class(entry),collapse=' ')) }, 
            error = function(e) {
              e <- sub(' in eval(expr, envir, enclos)','',e,fixed=T)
              e <- sub(' in parse(text = entry)','',e,fixed=T)
              .Q$toConsole(e,'error','error') }
            )
          },
         '$' = {
             .Q$toConsole(entry,'in','javascript')
             entry <- substring(entry, 2)
             .Q$updateJS(session,'JS',entry)
             prompt$panel <- 'console'
             },
         '?' = { 
            .Q$toConsole(entry,'in','help')
            prompt$panel <- 'help'
            prompt$help <- entry }
        )
        updateTextInput(session, "prompt", value = "")
        updateTabsetPanel(session, "panels", selected = prompt$panel)
      }
    }
  })

  ##Console##
  observe({ options(width=input$panelWidth) })
  .Q$toConsole <- function(lines,type,hover){
    mw <- paste0('width:',8*as.integer(options('width')),'px;')
    lapply(lines,function(line) {
      console$.results <- c(console$.results,line)
      console$.types   <- c(console$.types,type)
      console$.hovers  <- c(console$.hovers,hover)
      console$.widths  <- c(console$.widths,mw)
    })
  }
  observe({ 
    console$.js <- input$JS
    .Q$toConsole(input$JS,'out','javascript') 
  })
  observe({ 
    .Q$toConsole(input$jserr,'error','javascript error') 
  })
  output$console <- renderUI({
    input$JS
    input$prompt
    div(mapply(function(w,x,y,z) tags$pre(w,class=x,title=y,style=z), 
               console$.results, 
               console$.types, 
               console$.hovers, 
               console$.widths,
               SIMPLIFY=F),
        tags$script('Q.panels.console.trigger("change");')) 
  })
  
  ##Plot##
  source('R/plotTheme.R')
  panelWidth  <- function(){ as.integer(input$panelWidth)*8 }
  panelHeight <- function(){ as.integer(input$panelHeight)*.85 }
  output$plot <- renderPlot({
      prompt$plot
    } + .Q$theme_console(), 
        bg='transparent', 
        width=panelWidth, 
        height=panelHeight
  )
  
  ##Help##
  output$help <- renderUI({
    if (!is.na(prompt$help)) {
      url <- capture.output(eval( 
        parse(text=prompt$help), 
        sys.frame() 
      ))
      print(url <- substring(url,6,nchar(url)-1))
      tags$iframe(src=url)
    } else {
      url <- capture.output(eval(
        parse(text='help.start(browser=print)'), 
        sys.frame() 
      ))[2]
      url <- substring(url,2,nchar(url)-10)
      tags$iframe(src=url)
    }
  })        
  
  ##Database##
  #qbase <- mongo.create()
  qbase <- mongo.create(host="ds051110.mongolab.com:51110/qbase",username="qsys",password="snooze4u",db="qbase")
  qb <- reactiveValues(
    saveRO = NA,
    insert = NA
  )
  observe({ if (input$save > 0) {
      qb$saveRO <- isolate(active$map)
      qb$insert <- mongo.insert(qbase,'qbase.test',qb$saveRO)
  }})
  if (mongo.is.connected(qbase)){
    output$database <- renderUI({ div(
        tags$li("Database:",style='display:inline-flex;',tags$ul(
          tags$li(paste0("connected: ",mongo.is.connected(qbase))),
          #tags$li(paste0("primary: ",mongo.get.primary(qbase))),
          tags$li("databases:"),
          tags$ul( lapply(mongo.get.databases(qbase), function(x) tags$li(paste0("",x)) )),
          tags$li(paste0("collections: ",mongo.get.database.collections(qbase,"test"))),
          tags$li(paste0("count: ",mongo.count(qbase,"qbase.test"))),
          tags$li(paste0("insert: ",qb$insert)),
          tags$ul( lapply(qb$saveRO, function(x) tags$li(paste0("",x)) )),
          tags$li(paste0("last error: ",mongo.get.last.err(qbase,"qbase.test"))),
          #tags$li(paste0("prev error: ",mongo.get.prev.err(qbase,"qbase.test"))),
          tags$li(paste0("error: ",mongo.get.err(qbase))),
          #tags$li(paste0("server error: ",mongo.get.server.err(qbase))),
          tags$li(paste0("server error string: ",mongo.get.server.err.string(qbase)))
        )),hr(),br(),
        tags$li("Environment",style='display:inline-flex;',
                tags$ul( lapply(ls(console), function(x) tags$li(paste0("",x)) ))
        ),hr(),br()
        #tags$li("Map:",style='display:inline-flex;',tags$ul(
        #  tags$ul( lapply(active$map, function(x) tags$li(paste0("",x)) ))
        #)),hr(),br()
    )}) 
  }
})