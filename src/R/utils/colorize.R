##Colorize##
{
    gen.scheme <- function(step=20,lower=10,upper=250,
                           rs=step,rl=lower,ru=upper,
                           gs=step,gl=lower,gu=upper,
                           bs=step,bl=lower,bu=upper
    ) {
        L <- length(active$views)
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
            active$views[[t]]@color <- c
        },names(active$views),scheme,SIMPLIFY=F)
        lapply(names(active$views),apply.color)
        return(data.frame(red,green,blue,row.names=names(active$views)))
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
    get.nav <- function(title,tab.order) {
        nav <- '#tabs.nav > li:first-child'
        if(tab.order > 0) {
            nli <- paste0(rep(' + li',tab.order - 1),collapse='')
            nav <- paste0(nav,nli)    
        }
        return(nav)
    }
    apply.color <- function(title) {
        nav <- get.nav(title)
        selector <- paste0('#',title,', ',nav)
        attribute <- 'background'
        color <- active$views[[title]]@color
        style <- list()
        style[[selector]][[attribute]] <- color
        evaluate.CSS(style)
        return(c(title,color))
    }
}