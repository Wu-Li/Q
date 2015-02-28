ali <- function(title) {
    tab(title)
    as.list(get.idea(title))
}
get.idea <- function(title) {
    idea <- fromJSON(open[[title]],simplifyVector=F)
    class(idea) <- 'idea'
    return(idea)
}
as.list.idea <- function(idea) {
    if('ideas' %in% names(idea)) {
        names(idea$ideas) <- lapply(idea$ideas,function(i) {
            if('ideas' %in% names(i)) { 
                if(right(i$title,2) == '()') ''
                else if(right(i$title,1) == '=') substr(i$title,1,nchar(i$title)-1)
                else i$title
            } else ''
        })
        node <- if(right(idea$title,2) == '()') {
            fun <- substr(idea$title,1,nchar(idea$title)-1)
            args <- laply(idea$ideas,as.list.idea)
            args <- paste0(args,collapse=',')
            paste0(fun,args,')')
        } else lapply(idea$ideas,as.list.idea)
    } else node <- idea$title
    if('formatVersion' %in% names(idea)) attr(node,'title') <- idea$title
    return(node)
}
as.idea <- function(x) UseMethod('as.idea',x)
as.idea.list <- function(x) {
    if('title' %in% names(attributes(x)))      
        title <- attr(x,'title')
    else title <- deparse(substitute(x))
    idea <- list(`_id`=oid(),title=title)
    counter.id <- 0
    counter <- function() counter.id <<- counter.id + 1
    idea$id <- counter()
    idea$formatVersion <- 2
    as.node <- function(k,n,y) {
        if('character' %in% class(y)) y <- paste0("'",y,"'")
        if(!n=='') n <- paste0(n,'=')
        else if (length(y)==1) return(list(id=counter(),title=as.character(y)))
        else n <- 'c()'
        node <- list(
            id=counter(),
            title=n
        )
        node$ideas <- if('list' %in% class(y)) {
            if(is.null(names(y))) names(y) <- rep('',length(y))
            print(names(y))
            mapply(as.node,as.character(1:length(y)),names(y),as.list(y),SIMPLIFY=F,USE.NAMES=T)
        } else lapply(y, function(z) list(title=as.character(z),id=counter()))        
        return(node)
    }
    if(is.null(names(x))) names(x) <- rep('',length(x))
    idea$ideas <- mapply(as.node,as.character(1:length(x)),names(x),as.list(x),SIMPLIFY=F,USE.NAMES=T)
    idea$links <- list()
    idea <- toJSON(idea,auto_unbox=T)
    attr(idea,'title') <- title
    attr(idea,'icon')  <- demo[[title]]
    attr(idea,'order') <- sorter(title)
    if(is.na(attr(idea,'order'))) attr(idea,'order') <- length(rvtl(open)) + 1
    class(idea) <- 'idea'
    return(idea)
}