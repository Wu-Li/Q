setwd('C:/Users/WuLiMammoth/Google Drive/Workspace/Q')
options(width=55)
library(shiny)
options("shiny.launch.browser"=T)
library(pryr)
library(jsonlite)
library(rmongodb)
library(xtable)
library(stargazer)
library(highlight)

shinyServer(function(input, output, session) {
    cat("\014")
    
    #Console
    values <- reactiveValues(prompt = NA)
    observe({ if (input$submit > 0) { 
        values$prompt <- isolate(input$prompt) 
    } })
    types   <- c('in')
    results <- c('')
    output$console <- renderUI ({ 
        prompt <- values$prompt
        switch(
            prompt,{
                if(prompt !="") {
                    results <<- c(results,paste0("> ",prompt))
                    types <<- c(types,'in')
                    tryCatch({
                        r <- capture.output({
                                eval( parse(text=prompt), sys.frame() )
                            })
                        lapply(r,function(x) {
                            results <<- c(results,x)
                            types <<- c(types,'out')
                        })   
                        
                    },
                    warning = function(w) {
                        r <- capture.output({eval(parse(text=prompt))})
                        results <<- c(results,toString(w))
                        types <<- c(types,'warning')
                        lapply(r,function(x) {
                            results <<- c(results,x)
                            types <<- c(types,'out')
                        })
                    },
                    error = function(e) {
                        results <<- c(results,toString(e))
                        types <<- c(types,'error')
                    },
                    finally = {
                        out <<- data.frame(results,stringsAsFactors=F)
                    })
                    updateTextInput( session, "prompt", value = "")
                    mapply(function(x,y) tags$pre(x,class=y), results, types, SIMPLIFY=F)
                }           
            },
            "clear" = {
                cat("\014")
                types   <<- c('in')
                results <<- c('')
                updateTextInput( session, "prompt", value = "")
                results
            },
            "exit" = {
                stopApp(returnValue = NULL)
            },
            "@" = {
                query <- capture.output({fromJSON(input$query)})
                lapply(query,function(x) {
                    results <<- c(results,x)
                    types <<- c(types,'map')
                })
                mapply(function(x,y) tags$pre(x,class=y), results, types, SIMPLIFY=F)
            }
        ) 
    })
    
    #QBase
    qbase <- mongo.create()
    dbstats <- c()
    if (mongo.is.connected(qbase)){
        output$qbase <- renderUI({ 
            query = input$query
            if(query != ""){
                mongo.insert(qbase, "qbase", query)
            }
        })
    }
})