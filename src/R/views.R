##Ideas##
source('.//R//ideas.R',local=T)
##Demo##
source('.//R//utils//demo.R',local=T) 
##Colorize##
source('.//R//utils//colorize.R',local=T)

##View##
{
    setOldClass('mongo.oid')
    setOldClass('shiny.tag')
    View <- setClass(
        'View',
        slots=c(
            title="character",
            `_id`='mongo.oid',
            vid='mongo.oid',
            tabIcon='character',
            color='character',
            tab.order='numeric',
            tab='shiny.tag'
        ),
        contains='list'
    )
    setMethod(initialize, 'View', 
              function(.Object,title,content,
                       `_id`=mongo.oid.create(),
                       tabIcon='square-o',
                       color='transparent',
                       tab.order=1
              ) {
                  toid <- paste0(title,'.oid')
                  vq <- list()
                  vq[[toid]] <- mongo.oid.to.string(`_id`)
                  v <- select('Views',vq)
                  if(!is.null(v)){
                      vid     <- mongo.oid.from.string(attr(v,'_id'))
                      tabIcon <- v[[title]]$tabIcon
                      color   <- v[[title]]$color
                  } else {
                      vid <- mongo.oid.create()
                  }
                  if(is.null(tabIcon)) tabIcon <- 'square-o'
                  .Object@title     <- title
                  .Object@`_id`     <- `_id`
                  .Object@vid       <- vid
                  .Object@tabIcon   <- tabIcon
                  .Object@color     <- color
                  .Object@tab.order <- tab.order
                  .Object@tab       <- tabPanel(title,content,value=title,icon=icon(.Object@tabIcon,class='fa-2x'))
                  style <- list()
                  selector <- paste0('#',title,', ',get.nav(title,tab.order))
                  style[[selector]][['background']] <- color
                  evaluate.CSS(style)
                  return(.Object)
              }
    )
}
##Idea##
{
    Idea <- setClass(
        'Idea',
        slots = list(
            map='list',
            context='character'
        ),
        contains='View'
    )
    setMethod(initialize, 'Idea',
              function(.Object,title,map=NULL,context='R',...) {
                  if(is.null(map)) map <- list()
                  if(is.null(attr(map,'_id'))) attr(map,'_id') <- mongo.oid.to.string(mongo.oid.create())
                  if(!is.null(attr(map,'context'))) context <- attr(map,'context')
                  .Object@map <- map
                  .Object@context <- context
                  content <- mapInput(title,map)    
                  id = mongo.oid.from.string(attr(map,'_id'))
                  callNextMethod(.Object,title=title,content=content,`_id`=id,...) 
              }
    )
}

##Active Views##
{
    #Timer
    ready <- list(init=F,Styles=F)
    timer <- observe({
        if( !(F %in% ready) ) {
            pp('--Ready:   ',round(Sys.time() - begin,2),'s')
            timer$destroy()
        } else invalidateLater(100,session)
    })
    current <- reactiveValues( 
        map=NA,
        view=NA
    )
    observe({
        if(is.null(input$tabs)) return()
        current$map <- input[[input$tabs]]
    })
    observe({
        if(is.null(input$tabs)) return()
        current$view <- active$views[[input$tabs]]
    })
    active <- reactiveValues( 
        views = list( Queries = new('Idea','Queries',select('Queries')) )
    )
    observe({ console$Queries <- input$Queries })
    new.view  <- tabPanel('',mapInput(''),value='new',icon=icon('plus',class='fa-3x'))
    output$views <- renderUI ({
        tabPanels <- lapply(active$views, function(v) v@tab )
        tabPanels[[length(tabPanels) + 1]] <- new.view
        tabPanels$id <- 'tabs'
        tabPanels$selected <- 'Queries'
        do.call(tabsetPanel, tabPanels)
    })
    observeEvent( length(active$views), {
        active.views <- active$views
        active.views <- active.views[!sapply(active.views,is.null)]
        w <- paste0(100 / (length(active.views) + 1),'%')
        evaluate.CSS(list(`#tabs.nav > li`=list(width=w)))
    })
}

##Draw##
{
    draw <- function(title) {        
        ord <- length(active$views) + 1
        isolate(active$views[[title]] <- new('Idea',title,select(title),tab.order=ord))
        observe( console[[title]] <- input[[title]] )
        tab(title)
    }
    #New Tab
    tabs <- reactiveValues(
        is.new = F,
        counter = 1
    )
    observe({
        if(is.null(input$tabs)) return()
        if(input$tabs != 'new') return()
        tabs$is.new <- T
    })
    observe({
        if(!tabs$is.new) return()
        title <- as.character(as.roman(tabs$counter))
        draw(title)
        tabs$counter <- tabs$counter + 1
        tabs$is.new <- F
    })
    #Close
    close.tab <- function(title) {
        active$views[[title]] <- NULL
    }
    observeEvent( input$close,{
        close.tab(input$tabs)
    })
    observe({
        if(is.null(input$tabs)) return()
        if(input$tabs=='Queries'){
            evaluate.CSS(list(`#close`=list(visibility='hidden')))
        } else {
            evaluate.CSS(list(`#close`=list(visibility='visible')))
        }
    })
    
}

##Print##
{
    observe({ 
        if(input$print == 0) return() 
        tab <- isolate(input$tabs)
        toConsole(paste0("> ",tab),'in','expression')
        isolate(evaluate(tab))
    })
}

##Run##
{
    run <- function(x) UseMethod('run')
    running <- list()
    run.map <- function(title) { 
        map <- isolate(input[[title]])
        view <- isolate(active$views[[title]])
        if(is.null(map)) {
            running[[title]] <- observe({
                if(is.null(map)) {
                    ready[[title]] <<- F
                    invalidateLater(100,session)
                    return()
                } else {
                    class(map) <- append(class(map),view@context)
                    if('CSS' %in% class(map)) evaluate.CSS(map)
                    else isolate(evaluate(map))
                    running[[title]]$destroy()
                    ready[[title]] <<- NULL
                }
            })
            return()
        } 
        class(map) <- append(class(map),view@context)
        return(map)
    }
    observe({ 
        if((input$run == 0) && ready$init) return()
        #if(input$run == 0) return()
        if(is.null(isolate(input$tabs))){
            invalidateLater(100,session)
            return()
        }
        tab <- paste0(isolate(input$tabs),'()')
        toConsole(paste0("> ",tab),'in','expression')
        isolate(evaluate(tab))
        ready$init <<- NULL
    })
}
