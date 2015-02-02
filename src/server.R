###Server###
{
    cat("\014")
    library(shiny)
    library(ggplot2)
    library(pryr)
    library(jsonlite)   
    library(reshape2)
    library(Ryacas)    
    options(root='qb')
}

shinyServer(function(input, output, session) {
    
###Session###
{
    console <- new.env()
    observe({ console$.SE <- environment(session$sendInputMessage) })
    observe({ console$.ME <- session })
    console$.out <- reactiveValues(
        results = NULL,
        types   = NULL,
        hovers  = NULL,
        widths  = NULL
    )
    source('.//R//helpers.R',local=T)
    source('.//R//CAS.R',local=T)
    clear()    
    print("--Session--")
}

##Panel Controller##
{
    prompt <- reactiveValues(
        commands = c('exit','path','classify','ls'),
        maps = lapply(c('Queries','Data','Views','Styles','Tests','Sources','Names'),function(x) paste0(x,'()')),
        panel = NA,
        help = NA,
        plot = NA,
        ready = F
    )
    observe({ options(width=as.integer(input$panelWidth)) })
    observe({ 
        if (input$submit == 0) { return(NULL) }
        entry <- isolate(input$prompt)
        if(is.null(entry)){return(NULL)}
        if(entry == ''){return(NULL)}
        switch(substr(entry, 1, 1), {
            toConsole(paste0("> ",entry),'in','expression')
            prompt$panel <- 'console'
            evaluate(entry)
        },
        '#' = {
            toConsole(entry,'in','javascript')
            prompt$panel <- 'console'
            entry <- substring(entry, 2)
            class(entry) <- 'JS'
            evaluate.JS(entry)
        },
        '?' = { 
            toConsole(entry,'in','help')
            prompt$panel <- 'help'
            class(entry) <- 'help' 
            evaluate.help(entry)
        })
        #evaluate(entry)
        updateTextInput(session, "prompt", value = "")
        updateTabsetPanel(session, "panels", selected = prompt$panel)
    })
}
##Console##
source('.//R//console.R',local=T)
##Inspector##
source('.//R//inspector.R',local=T)
##Help##
source('.//R//help.R',local=T)
##Database##
source('.//R//qbase.R',local=T)

##Views##
source('.//R//views.R',local=T)  

})###