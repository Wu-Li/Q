#Helpers
pp <- function(...) { print(paste0(...)) }

ev <- function(...) { eval(parse(text=paste0(...))) }

yax <- function(...) { yacas(as.expression(...)) }

clear <- function() {
    cat("\014")
    console$.out$results <- NULL
    console$.out$types   <- NULL
    console$.out$hovers  <- NULL
    console$.out$widths  <- NULL
}

exit <- function() { stopApp(returnValue = NULL) }