qb <- reactiveValues(
    root = getOption('root'),
    path = NA,
    save.path = NA,
    save.title = NA,
    save.id = NA,
    save.id.new = NA,
    saved = NA
)
pub <- T
if(!pub) {
    qbase <- mongo.create(db=getOption('root'))
    mlab  <- mongo.create(host="ds043200.mongolab.com:43200/qb",username="qsys",password="snooze4u",db=getOption('root'))
} else {
    qbase  <- mongo.create(host="ds043200.mongolab.com:43200/qb",username="qsys",password="snooze4u",db=getOption('root'))
}
observe({ qb$path <- paste0(qb$root,'.',input$tabs) })
path <- function() { qb$path }

#Panel
observe ({
    if (!mongo.is.connected(qbase)){ return(NULL) }  
    output$root <- renderTable({ 
        input$tabs
        input$save
        input$prompt
        path <- isolate(qb$path)
        root <- isolate(qb$root)
        rows <- c('connected','count',
                  'databases','collections',
                  'last.error',
                  'prev.error','error','server.error','server.error.string')
        values <- c(
            mongo.is.connected(qbase),
            mongo.count(qbase,path),
            
            paste0(mongo.get.databases(qbase),collapse=', '),
            paste0(mongo.get.database.collections(qbase,root),collapse=', '),
            
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
fa <- list(
    Classes = icon('sitemap',class='fa-2x'),
    Sources = icon('code-fork',class='fa-2x'),
    Tests = icon('tachometer',class='fa-2x'),
    Styles = icon('fire',class='fa-2x'),
    Views = icon('eye',class='fa-2x'),
    Data = icon('table',class='fa-2x'),
    Queries = icon('crosshairs',class='fa-2x')
)
sorted <- c('Queries','Data','Views','Styles','Tests','Classes','Sources')

##Database I/O##
{
    oid    <- function() { mongo.oid.to.string(mongo.oid.create()) }
    #Select
    find   <- function(query=mongo.bson.empty(),ns=qb$path) { 
        mongo.find(qbase,ns,query) 
    }
    select <- function(collection,query=NULL,id=NULL) {
        path <- paste0(getOption('root'),'.',collection)
        if      (!is.null(id))    cursor <- find(ns=path,list(`_id`=id)) 
        else if (!is.null(query)) cursor <- find(ns=path,query)  
        else                      cursor <- find(ns=path) 
        ideas <- mongo.cursor.to.list(cursor)
        if(length(ideas)==0) {
            toConsole(
                paste0('$(',path,') returned no matches')
            ,'warning','message')
            idea <- structure(
                toJSON(list(title=collection,id=1,formatVersion=2,`_id` <- oid()),auto_unbox=T),
                class='idea',
                title=collection,
                icon=fa[[collection]],
                order=rep(seq_along(sorted), sapply(sorted, length))[match(collection,unlist(sorted))]
            )
        } else if (length(ideas)==1) {
            toConsole(paste0('$(',path,') returned ',length(ideas),' match'),'message','message')
           ideas <- lapply(ideas, function(idea) {
                t <- idea$title
                if(is.null(t)) return(NULL)
                idea$`_id` <- mongo.oid.to.string(idea$`_id`)
                idea <- toJSON(idea,auto_unbox=T)
                idea <- structure(idea,
                    class='idea',
                    title=t,
                    icon=fa[[t]],
                    order=rep(seq_along(sorted), sapply(sorted, length))[match(t,unlist(sorted))]
                )       
            })
            ideas[[1]]
        } else {
            toConsole(paste0('$(',path,') returned ',length(ideas),' matches'),'message','message')
            ideas <- lapply(ideas, function(idea) {
                t <- idea$title
                if(is.null(t)) return(NULL)
                idea$`_id` <- mongo.oid.to.string(idea$`_id`)
                idea <- toJSON(idea,auto_unbox=T)
                idea <- structure(idea,
                    class='idea',
                    title=t,
                    icon=fa[[t]],
                    order=rep(seq_along(sorted), sapply(sorted, length))[match(t,unlist(sorted))]
                )       
            })
            ideas[[1]]
        }
    }
    
    #Save
    observe({ 
        if (input$save == 0) { return(NULL) }
        getIdea <- paste0('Q.models["',isolate(input$tabs),'"].getIdea()')
        updateJS(session,'dbSave',getIdea) 
    })
    observe({
        if (is.null(input$dbSave)) { return(NULL) }
        path <- isolate(qb$path)
        save <- isolate(input$dbSave)
        save <- fromJSON(save)
        save$`_id` <- mongo.oid.from.string(save$`_id`)
        save(path,save)
    })
    insert <- function(b,ns=qb$path) { 
        if(pub) mongo.insert(qbase,ns,b)
        else if(mongo.insert(qbase,ns,b)) 
                mongo.insert(mlab,ns,b) 
        else F 
    }
    update <- function(b,ns=qb$path,query=list(`_id`=b$`_id`)) { 
        if(pub) mongo.update(qbase,ns,query,b)
        else if(mongo.update(qbase,ns,query,b)) 
                mongo.update(mlab,ns,query,b) 
        else F 
    }
    save <- function(path,save) {
        if(update(save,path)){
            save.string <- paste0(
                'saved: ',path,
                '(',mongo.count(qbase,path),')',
                '#',save$`_id`,
                ' <- ',save$title)
            type <- 'in'
            hover <- 'message'
        } else {
            save.string <- 'Save error'
            type <- 'error'
            hover <- 'error'
        }
        toConsole(save.string,type,hover)
        updateTabsetPanel(session,'panels','console')
    }
    
    #Delete
    remove <- function(b,ns=qb$path,query=list(`_id`=b$`_id`)) {
        if(mongo.remove(qbase,ns,query)) mongo.remove(mlab,ns,query) else F 
    }
    drop <- function(...) { 
        if(mongo.drop(qbase,...)) mongo.drop(mlab,...) else F 
    }
}