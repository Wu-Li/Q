library(shiny)
library(rmongodb)
library(ggplot2)
library(pryr)
library(jsonlite)
library(gridExtra)
options(width=64)
options(browser=print)
shinyServer(function(input, output, session) {
  cat("\014")
  print("--New Session--")
  observe({ ME <<- session })
  observe({ SE <<- environment(session$sendInputMessage) })
  observe({
    Queries <<- tryCatch({input$Queries[[1]]},error={input$Queries})
    Data    <<- tryCatch({input$Data[[1]]},error={input$Data})
    Units   <<- tryCatch({input$Units[[1]]},error={input$Units})
    Formula <<- tryCatch({input$Formula[[1]]},error={input$Formula})
    Views   <<- tryCatch({input$Views[[1]]},error={input$Views})
    Styles  <<- tryCatch({input$Styles[[1]]},error={input$Styles})
    Tests   <<- tryCatch({input$Tests[[1]]},error={input$Tests})
    Names   <<- tryCatch({input$Names[[1]]},error={input$Names})
    Sources <<- tryCatch({input$Sources[[1]]},error={input$Sources})
  })
  values <- reactiveValues(
    prompt = NA,
    error = NA,
    help = NA,
    plot = NA,
    saveRO = NA,
    insert = NA,
    activeTab = NA,
    activeMap = NA,
    panelHeight = NA,
    isPlot = F
  )
  observe({ 
    values$activeMap <<- eval( parse(text = paste0('input$',input$tabs)))
  })
    
  #Console    
  observe({ options(width=input$panelWidth) })
  types   <- NULL
  results <- NULL
  widths  <- NULL
  classes <- NULL
  output$console <- renderUI ({
    if (input$submit > 0) {
      prompt <- isolate(input$prompt)
      if (!is.na(prompt) && prompt != '') {
        mw <<- paste0('width:',8*as.integer(options('width')),'px;')
        panel <- 'console'
        results <<- c(results,paste0("> ",prompt))
        types   <<- c(types,'in')
        widths  <<- c(widths,mw)
        classes <<- c(classes,'')
        tryCatch({
          switch(
            prompt,{
              if (substr(prompt, 1, 1)=='?') {
                panel <- 'help'
                values$help <- prompt
              } else {
                consoleMap <<- isolate(values$activeMap)
                if (grepl("@",prompt)) {
                  prompt <- gsub("@(?=[A-Za-z])", "consoleMap$", prompt, perl=T) 
                  prompt <- gsub("@", "consoleMap", prompt)    
                  p <- eval( parse(text=prompt), sys.frame() )
                  mapJSON <<- gsub("\\[","",gsub("]","",toJSON(consoleMap)))
                  updateTextInput(session, "consoleMap", value = mapJSON)
                } else {
                  p <- eval( parse(text=prompt), sys.frame() )
                }
                lapply(capture.output(p),function(x) {
                  results <<- c(results,x)
                  types   <<- c(types,'out')
                  widths  <<- c(widths,mw)
                  classes <<- c(classes,paste0(class(p),collapse=' '))
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
              classes <<- NULL
            },"exit" = { stopApp(returnValue = NULL) }
          )
        }, warning = function(w){
          p <- capture.output({eval(parse(text=prompt), sys.frame() )})
          w <- sub('simpleWarning in eval(expr, envir, enclos)','warning',w,fixed=T)
          results <<- c(results,toString(w))
          types <<- c(types,'warning')
          widths <<- c(widths,mw)
          classes <<- c(classes,'warning')
          lapply(p,function(x) {
            results <<- c(results,x)
            types   <<- c(types,'out')
            widths  <<- c(widths,mw)
            classes <<- c(classes,paste0(class(p),collapse=' '))
          })
          if ('ggplot' %in% class(p)) { values$plot <- p } 
        }, error = function(e) {
          #e <- capture.output(e)
          e <- toString(e)
          e <- sub(' in eval(expr, envir, enclos)','',e,fixed=T)
          e <- sub(' in parse(text = prompt)','',e,fixed=T)
          results <<- c(results,e)
          types   <<- c(types,'error')
          widths  <<- c(widths,mw)
          classes <<- c(classes,'error')
        })
        updateTabsetPanel(session, "panels", selected = panel)
        updateTextInput( session, "prompt", value = "")
        div(mapply(function(w,x,y,z) tags$pre(w,class=x,style=y,title=z), results, types, widths, classes, SIMPLIFY=F),
            tags$script('Q.panels.console.trigger("change");')) 
      } else {
        div(mapply(function(w,x,y,z) tags$pre(w,class=x,style=y,title=z), results, types, widths, classes, SIMPLIFY=F),
            tags$script('Q.panels.console.trigger("change");')) 
      }
    }
  })
  
  #Plot
  source('R/plotTheme.R')
  panelWidth  <- function(){ as.integer(input$panelWidth)*8 }
  panelHeight <- function(){ as.integer(input$panelHeight)*.85 }
  output$plot <- renderPlot({ 
      values$plot
    } + theme_console(), 
        bg='transparent', 
        width=panelWidth, 
        height=panelHeight
  )
  
  #Help
  output$help <- renderUI({
    if (!is.na(values$help)) {
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
  qbase <- mongo.create(host="ds051110.mongolab.com:51110/qbase",username="qsys",password="snooze4u",db="qbase")
  observe({ if (input$save > 0) {
      values$saveRO <- isolate(values$activeMap)
      values$insert <- mongo.insert(qbase,'qbase.test',values$saveRO)
      updateTabsetPanel(session, "panels", selected = "database")
  }})
  if (mongo.is.connected(qbase)){
    output$database <- renderUI({ 
      div(
        tags$li("Database:",style='display:inline-flex;',tags$ul(
          tags$li(paste0("connected: ",mongo.is.connected(qbase))),
          #tags$li(paste0("primary: ",mongo.get.primary(qbase))),
          tags$li("databases:"),
          tags$ul( lapply(mongo.get.databases(qbase), function(x) tags$li(paste0("",x)) )),
          tags$li(paste0("collections: ",mongo.get.database.collections(qbase,"test"))),
          tags$li(paste0("count: ",mongo.count(qbase,"qbase.test"))),
          tags$li(paste0("insert: ",values$insert)),
          tags$ul( lapply(values$saveRO, function(x) tags$li(paste0("",x)) )),
          tags$li(paste0("last error: ",mongo.get.last.err(qbase,"qbase.test"))),
          #tags$li(paste0("prev error: ",mongo.get.prev.err(qbase,"qbase.test"))),
          tags$li(paste0("error: ",mongo.get.err(qbase))),
          #tags$li(paste0("server error: ",mongo.get.server.err(qbase))),
          tags$li(paste0("server error string: ",mongo.get.server.err.string(qbase)))
        )),hr(),br(),
        tags$li("Environment",style='display:inline-flex;',
                tags$ul( lapply(ls(sys.frame()), function(x) tags$li(paste0("",x)) ))
        ),hr(),br(),
        tags$li("Map:",style='display:inline-flex;',tags$ul(
          tags$ul( lapply(values$activeMap, function(x) tags$li(paste0("",x)) ))
        )),hr(),br()
      )
    }) 
  }
  
})