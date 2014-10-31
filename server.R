options("shiny.launch.browser"=T)
library(shiny)
library(pryr)
library(jsonlite)
library(rmongodb)
library(xtable)

shinyServer(function(input, output, session) {
    cat("\014")
    
    #Console
    values <- reactiveValues(prompt = NA)
    observe({
        if (input$submit > 0) { 
            values$prompt <- isolate(input$prompt) 
        }
    })
    lines <- c()
    output$console <- renderUI ({
        
        prompt <- values$prompt
        
        switch(prompt,
          "clear" = {
               lines <<- c()
               updateTextInput( session, "prompt", value = "")          
               tags$li(lines,id="out")
           },
           "map" = {
               q <- fromJSON(input$query)
               print(q)
               lines <<- c(lines,paste0("> ",prompt),q)
               updateTextInput( session, "prompt", value = "")          
               lapply(lines, function(x) tags$li(x))
           },
           {#default5
               if(prompt !="") {
                   results <<- tryCatch(
                       { capture.output({ eval( parse( text=prompt )) }) },
                       warning = function(w) 
                           { c(w,capture.output({ eval( parse( text=prompt )) })) },
                       error = function(e) 
                           { print(e) })
                   lines <<- c(lines,paste0("> ",prompt),toString(results),"\r\n")
                   updateTextInput( session, "prompt", value = "")
                   lapply(lines, function(x) tags$li(x))
               } else { lapply(lines, function(x) tags$li(x)) }           
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
                 q <- fromJSON(query)
                 mongo.insert(qbase, "qbase", query)
             }
         })
     }
})