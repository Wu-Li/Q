##Connect##
{
    qbase <- if (is.null(getOption('local'))) {
        mongo.create(host="ds043200.mongolab.com:43200/qb",username="qsys",password="snooze4u",db='qb')
    } else {
        mlab  <- mongo.create(host="ds043200.mongolab.com:43200/qb"   ,username="qsys",password="snooze4u",db='qb')              
        qback <- mongo.create(host="ds045511.mongolab.com:45511/qback",username="qsys",password="snooze4u",db='qback')
        mongo.create(db='qb')
    }
    pp('--MongoDB: ',attr(qbase,'host'))
}

##Panel##
{
    observe ({
        if (!mongo.is.connected(qbase)) return()
        output$database <- renderTable({ 
            input$save
            input$prompt
            path <- paste0('qb.',input$tabs)
            rows <- c('connected','count','databases','collections',
                      'last.error','prev.error','error','server.error','server.error.string')
            values <- c(
                mongo.is.connected(qbase),
                mongo.count(qbase,path),
                paste0(mongo.get.databases(qbase),collapse=', '),
                paste0(mongo.get.database.collections(qbase,'qb'),collapse=', '),
                paste0(mongo.get.last.err(qbase,'qb'),collapse=', '),
                paste0(mongo.get.prev.err(qbase,'qb'),collapse=', '),
                mongo.get.err(qbase),
                mongo.get.server.err(qbase),
                mongo.get.server.err.string(qbase)
            )
            console$.db <- data.frame(values,row.names=rows)
            colnames(console$.db) <- paste0('qb.',input$tabs)
            console$.db 
        }, env = console) 
    })
    show.config <- function() {
        evaluate.JS('$("#panels.nav > li:first-child + li + li").show()')
        prompt$panel <- 'config'
    }
    hide.config <- function() {
        evaluate.JS('$("#panels.nav > li:first-child + li + li").hide()')
        invisible()
    }
}

##Database I/O##
{
    #Select
    find   <- function(path,query=mongo.bson.empty()) mongo.find(qbase,path,query) 
    select <- function(collection,query=NULL,id=NULL) {
        path <- paste0('qb','.',collection)
        if      (!is.null(id))    cursor <- find(path,list(`_id`=id)) 
        else if (!is.null(query)) cursor <- find(path,query)  
        else                      cursor <- find(path) 
        maps <- mongo.cursor.to.list(cursor)
        if(length(maps)==0) {
            toConsole(paste0('$("',collection,'") returned no matches'),'warning','message')
            return()
        } else {
            toConsole(paste0('$("',collection,'") returned ',length(maps),' match',
                             (if(length(maps) > 1) 'es')),'message','message')
            maps <- lapply(maps,function(map){
                attr(map,'_id') <- mongo.oid.to.string(map$`_id`)
                map$`_id` <- NULL
                attr(map,'context') <- map$context
                map$context <- NULL
                return(map)
            })
            return(maps[[1]])      
        } 
    }
    #Save
    {
        insert <- function(path,save) {
            mongo.insert(qbase,path,save)
        }
        update <- function(path,save,query=list(`_id`=save$`_id`)){
            mongo.update(qbase,path,query,save)
        }
        upsert <- function(...){
            if      (insert(...)) c(T,'inserted: ')
            else if (update(...)) c(T,'updated: ')
            else F
        }
        save <- function(path,save,title) {
            saved <- upsert(path,save)
            if(saved[[1]]){
                save.string <- paste0(
                    saved[[2]],path,
                    '(',mongo.count(qbase,path),')',
                    '#',save$`_id`,' <- ',title
                )
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
        remove.dots <- function(x) {
            n <- names(x)
            if(!is.null(n)){
                n <- gsub('\\.','&#46;',n)
                names(x) <- n
                x <- lapply(x,function(xx) remove.dots(xx) )    
            }
            return(x)
        }
        observe({ 
            if (input$save == 0) { return(NULL) }
            path <- paste0('qb.',isolate(input$tabs))
            cv <- isolate(current$view)
            cm <- isolate(current$map)
            cm$`_id` <- cv@`_id`
            if(!is.null(cv@context)) cm$context <- cv@context
            cm <- remove.dots(cm)
            save(path,cm,cv@title)
            sv <- list(`_id`=cv@vid)
            sv[[cv@title]] <- list(
                oid=mongo.oid.to.string(cv@`_id`),
                tabIcon=as.character(cv@tabIcon),
                color=cv@color
            )
            save('qb.Views',sv,cv@title)
                        
        })
    }
    #Delete
    {
        remove <- function(path,query) mongo.remove(qbase,path,query)
        drop <- function(...) mongo.drop(qbase,paste0('qb.',...))
    }
    #Replication
    {
        copydb <- function(from,from.path,to,to.path) {
            status <- list()
            collections <- mongo.get.database.collections(from,from.path)
            lapply(collections, function(col) {
                cursor <- mongo.find(from,col)
                while(mongo.cursor.next(cursor)) {
                    v <- mongo.cursor.value(cursor)
                    id <- list(`_id`=mongo.bson.to.list(v)$`_id`)
                    col <- sub(from.path,to.path,col)
                    if(mongo.update(to,col,id,v,flags=mongo.update.upsert)) 
                        status[[col]] <- 'saved'
                    else status[[col]] <- 'failed'
                }
                return(status)
            })
        }
        backup  <- function() copydb(qbase,'qb',qback,'qback')
        restore <- function() copydb(qback,'qback',qbase,'qb')
        publish <- function() copydb(qbase,'qb',mlab,'qb')
    }
}