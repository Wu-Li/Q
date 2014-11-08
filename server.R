library(shiny)
library(jsonlite)
library(rmongodb)
library(ggplot2)

options(width=55)
options("shiny.launch.browser"=T)

# try({setwd('c:/users/wulimammoth/google drive/workspace/Q')
#     addResourcePath('r'  , 'r')
#     addResourcePath('www/css', 'www/css')
#     addResourcePath('www/css/lib', 'www/css/lib')
#     addResourcePath('www/js' , 'www/js')
#     addResourcePath('www/js/mapjs' , 'www/js/mapjs')
#     addResourcePath('www/js/mapjs/lib' , 'www/js/mapjs/lib')
# },silent=T)

shinyServer(function(input, output, session) {
    cat("\014")
        
    values <- reactiveValues(
        prompt = NA,
        error = NA,
        help = NA,
        plot = NA,
        saveJSON = NA,
        saveRO = NA,
        insert = NA,
        activeMap = NA
    )
    observe({ 
        values$activeMap <- eval(parse(text = paste0('input$',input$tabs)))
    })

    #Console
    types   <- c('in')
    results <- c('')
    output$console <- renderUI ({
        if (input$submit > 0) {
            prompt <- isolate(input$prompt)
            results <<- c(results,paste0("> ",prompt))
            types <<- c(types,'in')
            tryCatch({
                switch(
                    prompt,{
                        if (substr(prompt, 1, 1)=='?') {
                            values$help <- substring(prompt,2)
                        } else {
                            map <<- isolate(values$activeMap)
                            prompt <- gsub("@(?=\\S)", "map$", prompt, perl=T) 
                            prompt <- gsub("@", "map", prompt)
                            p <- eval( parse(text=prompt), sys.frame() )
                            print(class(p))
                            lapply(capture.output(p),function(x) {
                                results <<- c(results,x)
                                types <<- c(types,'out')
                            })  
                            if ('ggplot' %in% class(p)) { 
                                values$plot <- p
                            } 
                        }
                    },"clear" = {
                        cat("\014")
                        types   <<- c('in')
                        results <<- c('')
                    },"exit" = { stopApp(returnValue = NULL) 
                    }
                )

            }, warning = function(w){
                p <- capture.output({eval(parse(text=prompt), sys.frame() )})
                results <<- c(results,toString(w))
                types <<- c(types,'warning')
                lapply(p,function(x) {
                    results <<- c(results,x)
                    types <<- c(types,'out')
                })
                if ('ggplot' %in% class(p)) { values$plot <- p } 
            }, error = function(e) {
                results <<- c(results,toString(e))
                types <<- c(types,'error')
            })
            updateTabsetPanel(session, "panels", selected = "console")
            updateTextInput( session, "prompt", value = "")
            div(mapply(function(x,y) tags$pre(x,class=y), results, types, SIMPLIFY=F),
            tags$script('Q.panels.console.trigger("change");')) 
        }
    })

    #Plot
    output$plot <- renderPlot({
        # ggplot(mtcars, aes(wt, mpg)) + geom_line()
        if(!is.na(values$plot)){
            updateTabsetPanel(session, "panels", selected = "plot")
            values$plot
        } 
    })
    
    #Help
    output$help <- renderUI({
        if (!is.na(values$help)) {
            updateTextInput( session, "prompt", value = "")
            updateTabsetPanel(session, "panels", selected = "help")
            values$help
        }
    })

    #Database
    qbase <- mongo.create() #Local
    #qbase <- mongo.create( #MongoLab.com
    #    host = "ds051110.mongolab.com:51110/qbase", 
    #    username="qsys",password="snooze4u",
    #    db="qbase")
    
    observe({
        if (input$save > 0) {
            values$saveJSON <- isolate(values$activeMap)
            values$saveRO <- fromJSON(values$saveJSON)
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
                    tags$li(paste0("primary: ",mongo.get.primary(qbase))),
                    tags$li(paste0("socket: ",mongo.get.socket(qbase))),
                    tags$li("databases:"),
                    tags$ul( lapply(mongo.get.databases(qbase), function(x) tags$li(paste0("",x)) )),
                    tags$li(paste0("collections: ",mongo.get.database.collections(qbase,"test"))),
                    tags$li(paste0("count: ",mongo.count(qbase,"qbase.test"))),
                    tags$li("save: "),
                    tags$ul( lapply(values$saveJSON, function(x) tags$li(paste0("",x)) )),
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