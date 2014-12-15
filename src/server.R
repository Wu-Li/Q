###Server###
{
    cat("\014")
    library(shiny)
    library(rmongodb)
    library(ggplot2)
    library(pryr)
    library(jsonlite)    
}
shinyServer(function(input, output, session) {
    
###Session###
{
    console <- new.env()
    .Q$clear <- function() {
        cat("\014")
        results <- '> clear'
        types <- 'in'
        hovers <- 'command'
        widths <- paste0('width:',8*as.integer(options('width')),'px;')
        console$.out <- data.frame(results,types,hovers,widths,stringsAsFactors=F)
        NULL
    }
    .Q$clear()
    .Q$exit <- function() { stopApp(returnValue = NULL) }
    observe({ console$.ME <- session })
    observe({ console$.SE <- environment(session$sendInputMessage) })
    print("--Session--")
}

###Panel Controller###
{
    prompt <- reactiveValues(
        keywords = c('clear','exit','path'),
        maps = lapply(c('Queries','Data','Views','Styles','Tests','Sources','Names'),function(x) paste0(x,'()')),
        panel = NA,
        help = NA,
        plot = NA
    )
    observe({ options(width=as.integer(input$panelWidth)) })
    observe({ 
        if (input$submit > 0) {
            prompt$panel <- 'console'
            entry <- isolate(input$prompt)
            if(is.null(entry)){return(NULL)}
            if(entry == ''){return(NULL)}
            switch(substr(entry, 1, 1), { 
                .Q$toConsole(paste0("> ",entry),'in','expression')
                .Q$evaluate(entry)
            },
            '#' = {
                .Q$toConsole(entry,'in','javascript')
                entry <- substring(entry, 2)
                .Q$updateJS(session,'JS',entry)
            },
            '?' = { 
                .Q$toConsole(entry,'in','help')
                prompt$panel <- 'help'
                prompt$help <- entry 
            })
            updateTextInput(session, "prompt", value = "")
            updateTabsetPanel(session, "panels", selected = prompt$panel)
        }
    })
    #Evaluate
    .Q$evaluate <- function(entry) {
        lines <- NULL
        if (entry %in% prompt$keywords) { entry <- paste0('.Q$',entry,'()') }
        if (entry %in% prompt$maps) { entry <- paste0('.Q$runMap("',substr(entry, 1, nchar(entry)-2),'")[[1]]') }
        tryCatch({
                console$.map <- isolate(active$map)
                if (grepl("@",entry)) {
                    entry <- gsub("@(?=\\()", ".Q$runMap", entry, perl=T) 
                    entry <- gsub("@(?=[A-Za-z])", ".map$", entry, perl=T) 
                    entry <- gsub("@(?=[[])", ".map[[1]]", entry, perl=T) 
                    entry <- gsub("@", ".map", entry)
                } 
                entry <- gsub("\\$(?=\\()", ".Q$select", entry, perl=T) 
                values <- eval(parse(text=entry), console )
                if('list' %in% class(values)) {
                    classes <<- NULL
                    rapply(values, function(value) {
                        classes <<- c(classes,paste0(class(parse(text=value)),collapse=' '))
                    },how='replace')    
                    mapply(function(v,cl) {
                        .Q$toConsole(v,'out',cl)
                    },capture.output(values),classes)
                } else {
                    .Q$toConsole(capture.output(values),'out',paste0(class(values),collapse=' '))    
                }
            },
            warning = function(w){
                w <- sub('simpleWarning in eval(expr, envir, enclos)','warning',w,fixed=T)
                .Q$toConsole(w,'warning')
                values <- suppressWarnings( eval(parse(text=entry), console ) )
                .Q$toConsole(values,'out',paste0(class(values),collapse=' '))
            },
            error = function(e) {
                e <- sub(' in eval(expr, envir, enclos)','',e,fixed=T)
                e <- sub(' in parse(text = entry)','',e,fixed=T)
                .Q$toConsole(e,'error')
            }
        )
    }
    

}

##Console##
{
    .Q$toConsole <- function(values,type,hover=type){
        mw <<- paste0('width:',8*as.integer(options('width')),'px;')
        results <<- console$.out$results
        types   <<- console$.out$types
        hovers  <<- console$.out$hovers
        widths  <<- console$.out$widths
        lapply(values, function(result) {
            results <<- c(results,result)
            types   <<- c(types,type)
            hovers  <<- c(hovers,hover)
            widths  <<- c(widths,mw)    
        })
        console$.out <- data.frame(results,types,hovers,widths,stringsAsFactors=F)
    }
    output$console <- renderUI({
        input$prompt
        div(mapply(function(w,x,y,z) tags$pre(w,class=x,title=y,style=z), 
                   console$.out$results, 
                   console$.out$types,
                   console$.out$hovers, 
                   console$.out$widths,
                   SIMPLIFY=F),
            tags$script('Q.panels.console.trigger("change");')) 
    })
    #JS
#     observe({
#         input$prompt
#         console$.js <- input$JS
#         .Q$toConsole(list(
#             results=input$JS,
#             types='js-out',
#             hovers='javascript'
#         ))   
#     })
#     observe({ 
#         input$prompt
#         .Q$toConsole(list(
#             results=input$jserr,
#             types='error',
#             hovers='javascript error'
#         ))
#     })
}

##Plot##
{
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
}

##Configuration## 
{
    #Database
    qbase <- mongo.create()
    #qbase <- mongo.create(host="ds051110.mongolab.com:51110/qbase",username="qsys",password="snooze4u",db="qbase")
    observe ({
        if (!mongo.is.connected(qbase)){ return(NULL) }  
        output$database <- renderTable({ 
            rows <- c('connected','count',
                      'databases','collections',
                      'last.error','prev.error','error','server.error','server.error.string',
                      'insert')
            values <- c(
                mongo.is.connected(qbase),
                mongo.count(qbase,qb$path),
                
                paste0(mongo.get.databases(qbase),collapse=', '),
                paste0(mongo.get.database.collections(qbase,qb$database),collapse=', '),
                
                paste0(mongo.get.last.err(qbase,qb$path),collapse=', '),
                paste0(mongo.get.prev.err(qbase,qb$path),collapse=', '),
                mongo.get.err(qbase),
                mongo.get.server.err(qbase),
                mongo.get.server.err.string(qbase),
                
                qb$insert
            )
            db <<- data.frame(values,row.names=rows)
            colnames(db) <- c(qb$path)
            db
        }, env = console) 
    })
}

##Help##
{
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
}

###Tabs###
{
    #Maps
    .Q$getMap <- function(inputId) { eval( parse(text = paste0('input$',inputId))) }
    .Q$runMap <- function(inputId = NULL) {
        if (is.null(inputId)) { inputId = input$tabs }
        map <- eval( parse(text = paste0('input$',inputId)))
        rapply(map, function(node) { .Q$evaluate(node) }, how='replace')
    }
    
    #Database
    qb <- reactiveValues(
        saveRO = NA,
        insert = NA,
        database = 'My',
        path = NA
    )
    observe({ qb$path = paste0(qb$database,'.',input$tabs) })
    .Q$path <- function() { qb$path }
    
    #Save
    observe({ 
        if (input$save == 0) { return(NULL) }
        idea <- paste0('Q.models["',isolate(input$tabs),'"].getIdea()')
        .Q$updateJS(session,'jsSave',idea)
    })
    observe({
        if (is.null(input$db.save)) { return(NULL) }
        qb$saveRO <- input$db.save
        qb$insert <- paste0(mongo.insert(qbase,isolate(qb$path),qb$saveRO),' - ',isolate(qb$path))
        updateTabsetPanel(session,'panels','database')
    })
    
    #Load
    # observe({ if (input$load == 0) { return(NULL) }
    #           idea <- mongo.find.one(qbase,qb$path)
    #           js <- paste0('Q.models.["',input$tabs,'"].setIdea(',idea,')')
    #           .Q$updateJS(session,'jsLoad',js)
    #})
    #.Q$drawMap <- function(title,query) {}
  
    #Select
    .Q$select <- function(query = NA) {
        print(query)
        if(is.na(query)) { 
            cursor <- mongo.find(qbase,qb$path) 
        } else { 
            cursor <- mongo.find(qbase,qb$path) 
        }
        mongo.cursor.to.list(cursor)
    }
    
    active <- reactiveValues( map = NA )
    observe({ active$map <- .Q$getMap(input$tabs) })
    observe({
        console$Queries    <- .Q$getMap('Queries')[[1]]  
        console$Data       <- mtcars
        console$Views      <- .Q$getMap('Views')[[1]]
        console$Styles     <- .Q$getMap('Styles')[[1]]
        console$Tests      <- .Q$getMap('Tests')[[1]]
        console$Names      <- .Q$getMap('Names')[[1]]
        console$Sources    <- .Q$getMap('Sources')[[1]]
    })    
    output$Data <- renderDataTable(mtcars)
    
    
    ##Computer Algebra System##
    quad <- function(A,B,C){
        A <- as.complex(A)
        B <- as.complex(B)
        C <- as.complex(C)
        x_1 = (-B + sqrt(4*A*C)) / (2*A)
        x_2 = (-B - sqrt(4*A*C)) / (2*A)
        if(Im(x_1) == 0) { x_1 <- Re(x_1) }
        if(Im(x_2) == 0) { x_2 <- Re(x_2) }
        c(x_1,x_2)
    }
    solve <- function(n,...) {
        v <- c(...)
        print(v)
        m <- matrix(v,ncol=n)
        m <- t(m)
        rref(m)
    }
}
    
})###