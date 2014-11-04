setwd('C:/Users/WuLiMammoth/Google Drive/Workspace/Q')
options(width=55)
library(shiny)
options("shiny.launch.browser"=T)
library(jsonlite)
library(rmongodb)

shinyServer(function(input, output, session) {
    cat("\014")
    qbase <- mongo.create()
    
    values <- reactiveValues(
        prompt = NA, 
        saveJSON = NA,
        insert = NA,
        activeMap = NA
    )
    observe({ 
        values$activeMap <- eval(parse(text = paste0('input$',input$tabs)))   
        if (input$submit > 0) { 
            values$prompt <- isolate(input$prompt) 
        }
    })
    observe({
        if (input$save > 0) {
            values$saveJSON <- isolate(values$activeMap)
            values$insert <- mongo.insert(qbase,'test.test',values$saveJSON)
        }
    })
    
    #Console
    types   <- c('in')
    results <- c('')
    output$console <- renderUI ({ 
        prompt <- values$prompt
        if(!is.na(prompt)){
            results <<- c(results,paste0("> ",prompt))
            types <<- c(types,'in')
            tryCatch({
                switch(
                    prompt,{
                        r <- capture.output({eval( parse(text=prompt), sys.frame() )})
                        lapply(r,function(x) {
                            results <<- c(results,x)
                            types <<- c(types,'out')
                        })  
                    },"clear" = {
                        cat("\014")
                        types   <<- c('in')
                        results <<- c('')
                    },"exit" = { stopApp(returnValue = NULL) 
                    },"@" = {
                        activetab <<- isolate(input$tabs)
                        query <- capture.output({
                            isolate(eval(parse(text = paste0('input$',activetab))))
                        })
                        lapply(query,function(x) {
                            results <<- c(results,x)
                            types <<- c(types,'map')
                        })
                    }
                )
            },warning = function(w) {
                r <- capture.output({eval(parse(text=prompt))})
                results <<- c(results,toString(w))
                types <<- c(types,'warning')
                lapply(r,function(x) {
                    results <<- c(results,x)
                    types <<- c(types,'out')
                })
            },error = function(e) {
                results <<- c(results,toString(e))
                types <<- c(types,'error')
            })
            updateTextInput( session, "prompt", value = "")
            mapply(function(x,y) tags$pre(x,class=y), results, types, SIMPLIFY=F)       
        }
    })
    
    #QBase
    dblog <- function(label, message) {
        tags$li(paste0(label,message))
    }
        
    if (mongo.is.connected(qbase)){
        output$qbase <- renderUI({ 
            tags$ul(
                tags$li("Database Status"),
                tags$ul(
                    dblog("connected: ",mongo.is.connected(qbase)),
                    dblog("primary: ",mongo.get.primary(qbase)),
                    dblog("socket: ",mongo.get.socket(qbase)),
                    tags$li("databases:"),
                    tags$ul( lapply(mongo.get.databases(qbase), function(x) dblog("",x)) ),
                    dblog("collections: ",mongo.get.database.collections(qbase,"test")),
                    dblog("count: ",mongo.count(qbase,"test.test")),
                    tags$li("save: "),
                    tags$ul( lapply(values$saveJSON, function(x) dblog("",x)) ),
                    dblog("insert: ",values$insert)
                ),
                tags$li("Database Errors"),
                tags$ul(
                    dblog("last error: ",mongo.get.last.err(qbase,"test.test")),
                    dblog("prev error: ",mongo.get.prev.err(qbase,"test.test")),
                    dblog("error: ",mongo.get.err(qbase)),
                    dblog("server error: ",mongo.get.server.err(qbase)),
                    dblog("server error string: ",mongo.get.server.err.string(qbase))
                ),
                tags$li("Active Map"),
                tags$ul( lapply(values$activeMap, function(x) dblog("",x)) )
            ) 
        }) 
    }
})