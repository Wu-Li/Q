###Server###
{
    cat("\014")
    library(shiny)
    library(rmongodb)
    library(ggplot2)
    library(pryr)
    library(jsonlite)   
    library(reshape2)
}
shinyServer(function(input, output, session) {
    
###Session###
{
    console <- new.env()
    console$.out <- reactiveValues(
        results = NULL,
        types   = NULL,
        hovers  = NULL,
        widths  = NULL
    )
    .Q$clear <- function() {
        cat("\014")
        console$.out$results <- NULL
        console$.out$types   <- NULL
        console$.out$hovers  <- NULL
        console$.out$widths  <- NULL
    }
    .Q$clear()
    .Q$exit <- function() { stopApp(returnValue = NULL) }
    .Q$ls <- ls
    observe({ console$.ME <- session })
    observe({ console$.SE <- environment(session$sendInputMessage) })
    options(root='qb')
    print("--Session--")
}

###Panel Controller###
{
    prompt <- reactiveValues(
        keywords = c('exit','path','classify','ls'),
        maps = lapply(c('Queries','Data','Views','Styles','Tests','Sources','Names'),function(x) paste0(x,'()')),
        panel = NA,
        help = NA,
        plot = NA
    )
    observe({ options(width=as.integer(input$panelWidth)) })
    observe({ 
        if (input$submit == 0) { return(NULL) }
        entry <- isolate(input$prompt)
        if(is.null(entry)){return(NULL)}
        if(entry == ''){return(NULL)}
        switch(substr(entry, 1, 1), { 
            .Q$evaluate(entry)
        },
        '#' = {
            .Q$toConsole(entry,'in','javascript')
            entry <- substring(entry, 2)
            .Q$updateJS(session,'js',entry)
        },
        '?' = { 
            .Q$toConsole(entry,'in','help')
            prompt$panel <- 'help'
            prompt$help <- entry 
        })
        updateTextInput(session, "prompt", value = "")
        updateTabsetPanel(session, "panels", selected = prompt$panel)
    })
    #Evaluate
    .Q$evaluate <- function(entry) {
        lines <- NULL
        .Q$toConsole(paste0("> ",entry),'in','expression')
        if (entry == 'clear') { return(.Q$clear()) }
        if (entry %in% prompt$keywords) { entry <- paste0('.Q$',entry,'()') }
        if (entry %in% prompt$maps) { entry <- paste0('.Q$runMap(input$"',substr(entry, 1, nchar(entry)-2),'")') }
        prompt$panel <- 'console'
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
                if ('run' %in% class(values)) {
                    rapply(values,.Q$evaluate)
                } else if('ggplot' %in% class(values)){
                    prompt$panel <- 'plot'
                    prompt$plot <- values
                } else {
                    .Q$toConsole(capture.output(values),'out',.Q$classify(values))      
                }
            },
            warning = function(w){
                w <- sub('simpleWarning in eval(expr, envir, enclos)','warning',w,fixed=T)
                .Q$toConsole(w,'warning')
                values <- suppressWarnings( eval(parse(text=entry), console ) )
                .Q$toConsole(capture.output(values),'out',.Q$classify(values))      
            },
            error = function(e) {
                e <- sub(' in eval(expr, envir, enclos)','',e,fixed=T)
                e <- sub(' in parse(text = entry)','',e,fixed=T)
                .Q$toConsole(e,'error')
            }
        )
        updateTabsetPanel(session, "panels", selected = prompt$panel)
    }
    .Q$classify <- function(node) { try(paste0(class(eval(node)),collapse=' ')) }
    #Maps
    .Q$getMap <- function(inputId=isolate(input$tabs)) { 
        map <- eval( parse(text = paste0('input$',inputId))) 
    }
    .Q$runMap <- function(map=isolate(active$map)) { 
        class(map) <- c(class(map),'run')
        map
    }
}

##Console##
{
    .Q$toConsole <- function(values,type,hover=type){
        mw <- paste0('width:',8*as.integer(options('width')),'px;')
        results <- isolate(console$.out$results)
        types   <- isolate(console$.out$types)
        hovers  <- isolate(console$.out$hovers)
        widths  <- isolate(console$.out$widths)
        lapply(values, function(result) {
            results <<- c(results,result)
            types   <<- c(types,type)
            hovers  <<- c(hovers,hover)
            widths  <<- c(widths,mw)    
        })
        console$.out$results <- results
        console$.out$types   <- types
        console$.out$hovers  <- hovers
        console$.out$widths  <- widths
    }
    #Console Out
    output$console <- renderUI({
        if(is.null(console$.out)) {return(div())}
        results <- console$.out$results
        types   <- console$.out$types
        hovers  <- console$.out$hovers
        widths  <- console$.out$widths
        div(withMathJax(mapply(
                            function(w,x,y,z) tags$p(w,class=x,title=y,style=z), 
                                   results, types, hovers, widths,
                            SIMPLIFY=F),
           tags$script('Q.panels.console.trigger("change");'))
        ) 
    })
    #JS
    observe({
        if(is.null(input$js)){ return(NULL) }
        console$.js <- input$js
        .Q$toConsole(input$js,'out','javascript')   
    })
    observe({ 
        if(is.null(input$jsError)){ return(NULL) }
        .Q$toConsole(input$jsError,'error','javascript error') 
    })
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
#     output$showPlot <- reactive ({
#         !is.na(prompt$plot[[1]])
#     })
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

##Database##
{
    #qbase <- mongo.create()
    qbase <- mongo.create(host="ds043200.mongolab.com:43200/qb",username="qsys",password="snooze4u",db="qb")
    qb <- reactiveValues(
        database = getOption('root'),
        path = NA,
        save.path = NA,
        save.title = NA,
        save.id = NA,
        save.id.new = NA,
        saved = NA
    )
    observe({ qb$path = paste0(qb$database,'.',input$tabs) })
    .Q$path <- function() { qb$path }
    #Panel
    observe ({
        if (!mongo.is.connected(qbase)){ return(NULL) }  
        output$database <- renderTable({ 
            input$tabs
            input$save
            input$prompt
            path <- isolate(qb$path)
            database <- isolate(qb$database)
            rows <- c('connected','count',
                      'databases','collections',
                      'last.error',
                      'prev.error','error','server.error','server.error.string')
            values <- c(
                mongo.is.connected(qbase),
                mongo.count(qbase,path),
                
                paste0(mongo.get.databases(qbase),collapse=', '),
                paste0(mongo.get.database.collections(qbase,database),collapse=', '),
                
                paste0(mongo.get.last.err(qbase,path),collapse=', '),
                paste0(mongo.get.prev.err(qbase,path),collapse=', '),
                mongo.get.err(qbase),
                mongo.get.server.err(qbase),
                mongo.get.server.err.string(qbase)
            )
            console$.db <- data.frame(values,row.names=rows)
            colnames(console$.db) <- c(qb$path)
            console$.db 
        }, env = console) 
    })
}

###Tabs###
{
    
    ##Tray##
    #Print Map
    observe({ 
        if(input$print == 0){ return(NULL) }
        map <- isolate(input$tabs)
        .Q$evaluate(map)
    })
    #Run Map
    observe({
        if(input$run == 0){ return(NULL) }
        isolate(.Q$evaluate(paste0(isolate(input$tabs),'()')))
    })
    e <- function(...) { eval(parse(text=paste0(...))) }
    drop <- function (...) { mongo.drop(qbase,...) }
    
    #Save
    {
    observe({ 
        if (input$save == 0) { return(NULL) }
        getIdea <- paste0('Q.models["',isolate(input$tabs),'"].getIdea()')
        .Q$updateJS(session,'dbSave',getIdea) 
    })
    observe({
        #input$save
        if (is.null(input$dbSave)) { return(NULL) }
        path <- isolate(qb$path)
        save <- isolate(input$dbSave)
        save <- fromJSON(save)
        save$`_id` <- mongo.oid.from.string(save$`_id`)
        .Q$save(path,save)
    })
    .Q$save <- function(path,save) {
        if(mongo.update(qbase,path,list(`_id`=save$`_id`),save,flags=1L)){
            save.string <- paste0(
                'saved: ',path,
                '(',mongo.count(qbase,path),')',
                '#',save$`_id`,
                ' <- ',save$title)
            type <- 'out'
        } else {
            save.string <- 'Save error'
            type <- 'error'
        }
        .Q$toConsole(save.string,type)
        updateTabsetPanel(session,'panels','console')
    }
}

    #Select
    .Q$select <- function(path=isolate(qb$path),query=NULL,id=NULL) {
        if  (!is.null(id)) {  
            cursor <- mongo.find(qbase,path,list(`_id`=id)) 
        } else if (!is.null(query)) { 
            cursor <- mongo.find(qbase,path,query)  
        } else { 
            cursor <- mongo.find(qbase,path) 
        }
        ideas <- mongo.cursor.to.list(cursor)
        if(length(ideas)==0) {
            .Q$toConsole(paste0(path,'$',query,'$ returned no matches'),'warning','message')
            return(NULL)
        } else if (length(ideas)==1) {
            .Q$toConsole(paste0(path,'$',query,'$ returned ',length(ideas),' match'),'out','message')
        } else {
            .Q$toConsole(paste0(path,'$',query,'$ returned ',length(ideas),' matches'),'out','message')
        }
        ideas
    }
           
    #Draw Map
    .Q$draw.map <- function(
        name=isolate(input$tabs),
        idea=.Q$select()
    ) {
        if(is.null(idea)) { 
            idea$`_id` <- mongo.oid.create()
            idea$title <- name
            idea$id <- 1
            idea$formatVersion <- 2
        }
        idea$`_id` <- mongo.oid.to.string(idea$`_id`)
        idea <- toJSON(idea,auto_unbox=T)
        load <- paste0('Q.models["',name,'"].setIdea(MAPJS.content(',idea,'))')
        .Q$updateJS(session,'dbLoad',load)
        observe(assign(name,.Q$getMap(name),console))
    }
    
    .Q$draw.map('Queries',.Q$select('qb.Queries')[[1]])
    output$Data <- renderDataTable(mtcars)
    observe(console$Data       <- mtcars)
    .Q$draw.map('Views',.Q$select('qb.Views')[[1]])
    .Q$draw.map('Styles',.Q$select('qb.Styles')[[1]])
    .Q$draw.map('Tests',.Q$select('qb.Tests')[[1]])
    .Q$draw.map('Sources',.Q$select('qb.Sources')[[1]])
    .Q$draw.map('Names',.Q$select('qb.Names')[[1]])
    
    active <- reactiveValues( map = NA )
    observe({ active$map <- .Q$getMap(input$tabs) })
}

###Computer Algebra System###
{
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