#Demo
mtcars$gear <- factor(mtcars$gear,levels=c(3,4,5),labels=c("3gears","4gears","5gears"))
mtcars$am   <- factor(mtcars$am,levels=c(0,1),labels=c("Automatic","Manual"))
mtcars$cyl  <- factor(mtcars$cyl,levels=c(4,6,8),labels=c("4cyl","6cyl","8cyl"))

demo <- list(
    Queries = icon('crosshairs',class='fa-2x'),
    Data = icon('table',class='fa-2x'),
    Views = icon('eye',class='fa-2x'),
    Styles = icon('fire',class='fa-2x'),
    Classes = icon('sitemap',class='fa-2x'),
    Sources = icon('code-fork',class='fa-2x'),
    Tests = icon('tachometer',class='fa-2x')
)
sorter <- function(title) {
    rep(seq_along(names(demo)),
        sapply(names(demo), length))[match(title,unlist(names(demo)))]
}
