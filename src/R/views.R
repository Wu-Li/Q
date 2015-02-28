##Ideas##
source('.//R//ideas.R',local=T)

##Demo##
source('.//R//demo.R',local=T)  

##Open##
{
    #Timer
    ready <- list(init=F)#,Styles=F,Data=F,Views=F)
    lintr <- 100
    timer <- observe({
        if( !(F %in% ready) ) {
            pp('--Ready:   ',round(Sys.time() - begin,2),'s')
            timer$destroy()
        } else invalidateLater(100,session)
    })
    #Open Views
    active <- reactiveValues( map = NA )
    observe({
        if(is.null(input$tabs)) return(NULL) 
        active$map <- get.map(input$tabs)
    })
    open <- reactiveValues( Queries = select('Queries') )
    observe({ console$Queries <- input$Queries[[1]] })
    output$views <- renderUI ({
        open <- rvtl(open)
        open <- open[!sapply(open,is.null)]
        order <- sapply(open,attr,'order')
        open <- open[order(order,decreasing=F)]
        titles <- c(names(open),'new')
        tabPanels = lapply(titles, function(t) {
            if(t=='new') {
                t <- ''
                c <- mapInput(t)
                v <- 'new'
                i <- icon('plus',class='fa-3x')
            } else {
                idea <- open[[t]]    
                v <- t
                i <- attr(idea,'icon')
                c <- mapInput(t,value=idea)
            }          
            tabPanel(t,c,value=v,icon=i)
        })        
        tabPanels$id <- 'tabs'
        tabPanels$selected <- 'Queries'
        do.call(tabsetPanel, tabPanels)
    })
    observeEvent( length(rvtl(open)), {
        open <- rvtl(open)
        open <- open[!sapply(open,is.null)]
        L <- length(open)
        L <- 100/(L + 1)
        w <- paste0(L,'%')
        evaluate.CSS(list(`#tabs.nav > li`=list(width=w)))
        evaluate.CSS(list(`#new`=list(width=w)))
    })
}


##Draw##
{
    draw <- function(
        object,
        title=NULL,
        icon=NULL,
        order=NULL
    ) { 
        if(is.null(title)) title <- attr(object,'title')
        if(is.null(icon))  icon  <- attr(object,'icon')
        if(is.null(order)) order <- attr(object,'order')
        if(is.null(title)) title <- deparse(substitute(object))
        if(is.null(icon))  icon  <- icon('square-o',class='fa-2x')
        if(is.null(order)) order <- length(reactiveValuesToList(open))+1
        attr(object,'title') <- title
        attr(object,'icon')  <- icon
        attr(object,'order') <- order
        open[[title]] <- object
        observe( console[[title]] <- input[[title]][[1]] )
        tab(title)
    }
    new.tab <- reactiveValues(
        is.new = F,
        counter = 1
    )
    observe({
        if(is.null(input$tabs)) return()
        if(input$tabs != 'new') return()
        new.tab$is.new <- T
    })
    observeEvent( new.tab$is.new,{
        if(!new.tab$is.new) return()
        object <- list('I','II','III')
        attr(object,'title') <- paste0('Title',new.tab$counter)
        object <- as.idea.list(object)
        draw(object)
        new.tab$counter <- new.tab$counter + 1
        new.tab$is.new <- F
    })
    close <- function(title) {
        open[[title]] <- NULL
    }
    observeEvent( input$close,{
        close(input$tabs)
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
    run.map <- function(inputId) { 
        map <- get.map(inputId)
        if(is.null(map[1][[1]])) {
            running[[inputId]] <- observe({
                map <- isolate(get.map(inputId))
                if(is.null(map[1][[1]])) {
                    ready[[inputId]] <<- F
                    invalidateLater(lintr,session)
                    return()
                } else {
                    class(map) <- c(class(map),attr(map,'context'))
                    if('CSS' %in% class(map)) evaluate.CSS(map[[1]])
                    else isolate(evaluate(map))
                    running[[inputId]]$destroy()
                    ready[[inputId]] <<- NULL
                }
            })
        } 
        class(map) <- c(attr(map,'context'))
        map
    }
    observe({ 
        if((input$run == 0) && ready$init) return()
        if(is.null(isolate(input$tabs))){
            invalidateLater(lintr,session)
            return()
        }
        tab <- paste0(isolate(input$tabs),'()')
        toConsole(paste0("> ",tab),'in','expression')
        isolate(evaluate(tab))
        ready$init <<- NULL
    })
}

##Get##
{
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
    get.view <- function(title) {
        idea <- get.idea(title)
        view <- structure(as.list(idea)[[title]],
                          class='view',
                          title=idea$title,
                          oid=idea$`_id`)
    }
}

##Colorize##
{
    gen.scheme <- function(step=20,lower=10,upper=250,
                           rs=step,rl=lower,ru=upper,
                           gs=step,gl=lower,gu=upper,
                           bs=step,bl=lower,bu=upper
    ) {
        L <- length(rvtl(open))
        M <- L%/%2 + L%%2
        gen.color <- function(step,lower,upper,anchor=c('random','left','right','center')) {
            lower <- lower %/% step
            upper <- upper %/% step
            range <- lower:upper * step
            while(length(range) < L) range <- rep(range,2)
            colors <- sort(sample(range,L))
            if(anchor=='random') anchor <- sample(c('left','right','center'),1)
            if(anchor=='left') colors <- rev(colors)
            else if(anchor=='center') colors <- center(colors) 
            return(colors)
        }
        red <- gen.color(rs,rl,ru,'random')
        green <- gen.color(gs,gl,gu,'random')
        blue <- gen.color(bs,bl,bu,'random')
    
        #combine
        scheme <- paste0('rgba(',red,',',green,',',blue,',.2)')
        mapply(function(t,c) {
            tab.colors[[t]] <<- c
        },names(rvtl(open)),scheme,SIMPLIFY=F)
        lapply(names(rvtl(open)),apply.color)
        return(data.frame(red,green,blue,row.names=names(rvtl(open))))
    }
    tab.colors <- list(
        Queries='rgba( 205, 255,  255, .2)',
        Data=   'rgba( 200, 125,   75, .2)',
        Views=  'rgba( 175, 175,  100, .2)',
        Styles= 'rgba( 150, 225,  125, .2)',
        Classes='rgba( 125, 200,  150, .2)',
        Sources='rgba( 100, 150,  175, .2)',
        Tests=  'rgba(  75, 100,  200, .2)'
    )
    get.nav <- function(title) {
        selector <- '#tabs.nav > li:first-child'
        i <- attr(rvtl(open)[[title]],'order') - 1
        if(i > 0) {
            nli <- paste0(rep(' + li',i),collapse='')
            selector <- paste0(selector,nli)    
        }
        return(selector)
    }
    
    apply.color <- function(title) {
        selector <- get.nav(title)
        selector <- paste0('#',title,', ',selector)
        attribute <- 'background'
        color <- tab.colors[[title]]
        style <- list()
        style[[selector]][[attribute]] <- color
        evaluate.CSS(style)
        return(c(title,color))
    }
}

### View #RC##
{
    setOldClass('mongo.oid')
    setOldClass('shiny.tag')
    setOldClass('idea')
    view <- setRefClass(
        'view',
        fields = list(
            title='character',
            icon='shiny.tag',
            context='character',
            oid='mongo.oid',
            map='list',
            idea='idea'                            
        ),
        methods = list(
            initialize=function(title,...){
                title <<- title
                icon <<- icon('table')
                context <<- 'R'
                oid <<- mongo.oid.create()
                map <<- list(title=title)
            },
            draw=function(){
                #draw
            },
            save=function(){
                #save
            },
            print=function(){
                #print
            },
            run=function(){
                #run  
            }
        )
    )
}