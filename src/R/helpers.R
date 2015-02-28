##Helpers##

#Shortcuts
pp <- function(...) { print(paste0(...)) }
ev <- function(...) { eval(parse(text=paste0(...))) }
yax <- function(...) { yacas(expression(...)) }
rvtl <- function(...) reactiveValuesToList(...)

#UI
clear <- function() {
    cat("\014")
    console$.out$results <- NULL
    console$.out$types   <- NULL
    console$.out$hovers  <- NULL
    console$.out$widths  <- NULL
}
tab <- function(tab) {
    updateTabsetPanel(session,'tabs',tab)
    return(tab)
}
what <- function(...) { 
    w <- capture.output(str(...))
    w <- gsub('\\\\','',w)
    w <- gsub('\\\"','\\\'',w)
}

#String manipulation
left  <- function(x, n) substr(x, 1, n)
right <- function(x, n) substr(x, nchar(x)-n+1, nchar(x))

#Vector manipulation
rotate <- function (v,n) {
    x <- NULL
    L <- length(v)
    n <- n %% L
    for(i in 1:L) {
        if(n+i > L) x[i] <- v[(n+i)-L]
        else x[i] <- v[n+i]
    }
    names(x) <- names(v)
    return(x)
}
center <- function(v,n=1) {
    #peaks= 2^(n-1)
    v <- sort(v)
    for(i in 1:n) v <- recenter(v)
    return(v)
}
recenter <- function(v) {
    L <- length(v)
    M <- L%/%2 + L%%2
    v1 <- v[1:M*2-L%%2]
    v2 <- rev(v[1:(M-1)*2-(L%%2-1)])
    return(c(v1,v2))
}
