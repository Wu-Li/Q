#Console Panel
output$console <- renderUI({
    if(is.null(console$.out)) {return(div())}
    results <- console$.out$results
    types   <- console$.out$types
    hovers  <- console$.out$hovers
    widths  <- console$.out$widths
    div(withMathJax(mapply(
        function(result,type,hover,width) {
            tag <- 'p'
            if (type=='style') { tags$style(result) }
            else { tags$p(result,class=type,title=hover,style=width) }
        },results,types,hovers,widths,SIMPLIFY=F),
        tags$script('Q.panels.console.trigger("change");'))
    ) 
})
#JS
observe({
    if(is.null(input$js)){ return(NULL) }
    console$.js <- input$js
    toConsole(input$js,'out','javascript')   
})
observe({ 
    if(is.null(input$jsError)){ return(NULL) }
    toConsole(input$jsError,'error','javascript error') 
})
toConsole <- function(values,type,hover=type){
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
    return(NULL)
}

#Evaluate
#evaluate <- function(x,...) UseMethod('evaluate')
evaluate <- function(entry) {
    prompt$panel <- 'console'
    if (entry == 'clear') { return(clear()) }
    if (entry %in% prompt$commands) { entry <- paste0(entry,'()') }    
    if (entry %in% prompt$maps) { entry <- paste0('run.map("',substr(entry, 1, nchar(entry)-2),'")') }
    if (grepl("@",entry)) {
        entry <- gsub("@(?=\\()", "run.map", entry, perl=T) 
        entry <- gsub("@(?=[A-Za-z])", ".map[[1]]$", entry, perl=T) 
        #entry <- gsub("@(?=[[])", ".map[[1]]", entry, perl=T) 
        entry <- gsub("@", ".map[1]", entry)
        
    } 
    console$.map <- isolate(active$map)
    entry <- gsub("\\$(?=\\()", "select", entry, perl=T) 
    tryCatch(
        {
            values <- eval(parse(text=entry), console )
            if ('R' %in% class(values)) {
                rapply(values,evaluate)
            } else if('CSS' %in% class(values)) {
                lapply(values,evaluate.CSS)
            } else if('ggplot' %in% class(values)){
                prompt$panel <- 'plot'
                prompt$plot <- values
            } else {
                toConsole(capture.output(values),'out',try(paste0(class(eval(values)),collapse=' ')))      
            }
        },
        warning = function(w){
            w <- sub('simpleWarning in eval(expr, envir, enclos)','warning',w,fixed=T)
            toConsole(w,'warning')
            values <- suppressWarnings( eval(parse(text=entry), console ) )
            toConsole(capture.output(values),'out',.try(paste0(class(eval(values)),collapse=' ')))      
        },
        error = function(e) {
            e <- sub(' in eval(expr, envir, enclos)','',e,fixed=T)
            e <- sub(' in parse(text = entry)','',e,fixed=T)
            toConsole(e,'error')
        }
    )
    updateTabsetPanel(session, "panels", selected = prompt$panel)
}
evaluate.R <- function(entry) rapply(values,evaluate)
evaluate.help <- function(entry) {
    prompt$help <- entry     
}
evaluate.JS <- function(entry) {    
    updateJS(session,'js',entry)
}
evaluate.CSS <- function(entry) {
    mapply(function(sel,val){
        mapply(function(a,v){
            if(length(names(v))==0){
                toConsole(values=paste0(sel,' {',a,':',v,';}'),type='style')
            } else {
                child <- NULL
                child[[paste0(sel,' ',a)]] <- val[[a]]
                evaluate.CSS(child)
            }
        },names(val),val)
    },names(entry),entry)
}