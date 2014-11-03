jsonInput <- function(inputId, value = "") {
    tagList(
        singleton(tags$head(tags$script(src = "/js/jsonBinding.js"))),
        tags$input(id = inputId,
                   class = "json",
                   type = "text",
                   value = value)
    )
}