library(shiny)
library(rmongodb)
library(ggplot2)
library(pryr)
library(jsonlite)
library(gridExtra)

shinyServer(function(input, output, session) {
  cat("\014")
  print("--New Session--")    
  
  values <- reactiveValues(
    prompt = NA,
    error = NA,
    help = NA,
    plot = NA,
    saveRO = NA,
    insert = NA,
    activeMap = NA,
    panelHeight = NA
  )
  observe({ 
    sessionData <<- session$clientData  
  })
  observe({ 
    mapJSON <<- eval(parse(text = paste0('input$',input$tabs)))
    mj <<- unbox(mapJSON)
    qmap  <<- fromJSON(mapJSON)
    
    evalNode <<- function(node) {
      atts <- attributes(node)
      for (a in atts) {
        print(a)
      }
    }
    #       tryCatch({
    #         capture.output ({ eval( parse(text=node), sys.frame() ) })
    #       }, error = function (e) {
    #         node
    #       })
    #       for (child in node.children) {
    #         
    #       }
    #   
    #     }
    #     values$activeMap <- rapply(as.list(qmap),evalNode)
    
    values$activeMap <- qmap
  })
  
  
  #Console    
  observe({ options(width=input$panelWidth) })
  types   <- NULL
  results <- NULL
  widths  <- NULL
  output$console <- renderUI ({
    if (input$submit > 0) {
      prompt <- isolate(input$prompt)
      if (prompt != ''){
        results <<- c(results,paste0("> ",prompt))
        types <<- c(types,'in')
        mw <<- paste0('width:',8*as.integer(options('width')),'px;')
        widths  <<- c(widths,mw)
        panel <- 'console'
        tryCatch({
          switch(
            prompt,{
              if (substr(prompt, 1, 1)=='?') {
                values$help <- prompt
              } else {
                consoleMap <<- isolate(values$activeMap)
                if (grepl("@",prompt)) {
                  prompt <- gsub("@(?=[A-Za-z])", "consoleMap$", prompt, perl=T) 
                  prompt <- gsub("@", "consoleMap", prompt)    
                  p <- eval( parse(text=prompt), sys.frame() )
                  mapJSON <<- gsub("\\[","",gsub("]","",toJSON(consoleMap)))
                  updateTextInput(session, "consoleMap", value = mapJSON)
                  #updateMapInput(session, "Queries", value = mapJSON)
                } else {
                  p <- eval( parse(text=prompt), sys.frame() )
                }
                print(class(p))
                lapply(capture.output(p),function(x) {
                  results <<- c(results,x)
                  types <<- c(types,'out')
                  widths <<- c(widths,mw)
                })  
                if ('ggplot' %in% class(p)) { 
                  values$plot <- p
                  panel <- 'plot'
                } 
              }
            },"clear" = {
              cat("\014")
              types   <<- NULL
              results <<- NULL
              widths  <<- NULL
            },"exit" = { stopApp(returnValue = NULL) }
          )
        }, warning = function(w){
          p <- capture.output({eval(parse(text=prompt), sys.frame() )})
          results <<- c(results,toString(w))
          types <<- c(types,'warning')
          lapply(p,function(x) {
            results <<- c(results,x)
            types <<- c(types,'out')
            widths <<- c(widths,mw)
          })
          if ('ggplot' %in% class(p)) { values$plot <- p } 
        }, error = function(e) {
          #e <- capture.output(e)
          e <- toString(e)
          e <- sub(' in eval(expr, envir, enclos)','',e,fixed=T)
          e <- sub(' in parse(text = prompt)','',e,fixed=T)
          results <<- c(results,e)
          types <<- c(types,'error')
          widths <<- c(widths,mw)
        })
        updateTabsetPanel(session, "panels", selected = panel)
        updateTextInput( session, "prompt", value = "")
        div(mapply(function(x,y,z) tags$pre(x,class=y,style=z), results, types, widths, SIMPLIFY=F),
            tags$script('Q.panels.console.trigger("change");')) 
      } else {
        div(mapply(function(x,y,z) tags$pre(x,class=y,style=z), results, types, widths, SIMPLIFY=F),
            tags$script('Q.panels.console.trigger("change");')) 
      }
    }
  })
  
  #Plot
  source('R/plotTheme.R')
  panelWidth  <- function(){ as.integer(input$panelWidth)*8 }
  panelHeight <- function(){ as.integer(input$panelHeight)*.85 }
  output$plot <- renderPlot({
    # ggplot(mtcars, aes(wt, mpg)) + geom_line()
    #if(!is.na(values$plot)){
    print(values$plot)
    isolate(values$plot)
    #}
  } + theme_console(), bg='transparent', width=panelWidth, height=panelHeight)
  
  #Help
  output$help <- renderUI({
    print(values$help)
    if (!is.na(values$help)) {
      updateTabsetPanel(session, "panels", selected = "help")
      url <- capture.output(eval( 
        parse(text=values$help), 
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
  
  #Database
  #qbase <- mongo.create() #Local
    qbase <- mongo.create( #MongoLab.com
      host = "ds051110.mongolab.com:51110/qbase", 
      username="qsys",password="snooze4u",
      db="qbase")
  
  observe({
    if (input$save > 0) {
      values$saveRO <- isolate(values$activeMap)
      values$insert <- mongo.insert(qbase,'qbase.test',values$saveRO)
      updateTabsetPanel(session, "panels", selected = "database")
    }
  })
  if (mongo.is.connected(qbase)){
    output$database <- renderUI({ 
      tags$ul(
        tags$li("Database Status"),
        tags$ul(
          tags$li(paste0("connected: ",mongo.is.connected(qbase))),
          #tags$li(paste0("primary: ",mongo.get.primary(qbase))),
          tags$li(paste0("socket: ",mongo.get.socket(qbase))),
          tags$li("databases:"),
          tags$ul( lapply(mongo.get.databases(qbase), function(x) tags$li(paste0("",x)) )),
          tags$li(paste0("collections: ",mongo.get.database.collections(qbase,"test"))),
          tags$li(paste0("count: ",mongo.count(qbase,"qbase.test"))),
          tags$li("save: "),
          tags$ul( lapply(values$saveRO, function(x) tags$li(paste0("",x)) )),
          tags$li(paste0("insert: ",values$insert))
        ),
        tags$li("Database Errors"),
        tags$ul(
          tags$li(paste0("last error: ",mongo.get.last.err(qbase,"qbase.test"))),
          tags$li(paste0("prev error: ",mongo.get.prev.err(qbase,"qbase.test"))),
          tags$li(paste0("error: ",mongo.get.err(qbase))),
          tags$li(paste0("server error: ",mongo.get.server.err(qbase))),
          tags$li(paste0("server error string: ",mongo.get.server.err.string(qbase)))
        ),
        tags$li("Active Map"),
        tags$ul( lapply(values$activeMap, function(x) tags$li(paste0("",x)) ))
      ) 
    }) 
  }
  
})