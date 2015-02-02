#Demo
mtcars$gear <- factor(mtcars$gear,levels=c(3,4,5),labels=c("3gears","4gears","5gears"))
mtcars$am <- factor(mtcars$am,levels=c(0,1),labels=c("Automatic","Manual"))
mtcars$cyl <- factor(mtcars$cyl,levels=c(4,6,8),labels=c("4cyl","6cyl","8cyl"))
mtcars <- structure(mtcars,title='Data',icon=icon('table',class='fa-2x'))
data <- paste0('{"title": "Data","id": 1,"formatVersion": 2, "ideas": {  } }') 
attr(data,'icon')  <- icon('table',class='fa-2x')
attr(data,'title') <- 'Data'
attr(data,'order') <- 2

##Open##
active <- reactiveValues( map = NA )
observe({
    if(is.null(input$tabs)) return(NULL) 
    active$map <- get.map(input$tabs)
})
open <- reactiveValues( Queries = select('Queries') )

observe({ console$Queries <- input$Queries[[1]] })
output$views <- renderUI ({
    open <- reactiveValuesToList(open)
    order <- sapply(open,attr,'order')
    open <- open[order(order,decreasing=T)]
    titles <- names(open)
    tabPanels = lapply(titles, function(t) {
        idea <- open[[t]]
        i <- attr(idea,'icon')
        tabPanel(t,value=t,icon=i,mapInput(t,value=idea))
    })
    tabPanels$id <- 'tabs'
    tabPanels$selected <- 'Queries'
    do.call(tabsetPanel, tabPanels)
})

##Draw##
draw <- function(object) { 
    t <- attr(object,'title')
    open[[t]] <- object
    observe( console[[t]] <- input[[t]][[1]] )
    return(t)
}

##Get##
get.map <- function(inputId) { 
    map <- eval( parse(text = paste0('input$',inputId))) 
    if     (inputId=='Styles')  ctx <- 'CSS'
    else if(inputId=='Sources') ctx <- 'sources'
    else                        ctx <- 'R'
    map <- structure(map,
                     class='map',
                     title=inputId,
                     context=ctx)
}

##Print##
observe({ 
    if(input$print == 0) return() 
    tab <- isolate(input$tabs)
    toConsole(paste0("> ",tab),'in','expression')
    isolate(evaluate(tab))
})
##Run##
run <- function(x) UseMethod('run')
run.map <- function(inputId) { 
    map <- get.map(inputId)
    class(map) <- c(class(map),attr(map,'context'))
    map
}

observe({ 
    if((input$run == 0) && prompt$ready) return()
    if(is.null(isolate(input$tabs))){
        invalidateLater(1000,session)
        return()
    } else prompt$ready <- T
    tab <- paste0(isolate(input$tabs),'()')
    toConsole(paste0("> ",tab),'in','expression')
    isolate(evaluate(tab))
})