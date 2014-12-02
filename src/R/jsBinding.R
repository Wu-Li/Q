.Q$jsInput <- function(inputId) {
  tagList(
    singleton(
      tags$head(
        tags$script(src="js/jsBinding.js")
      )
    ),
    tags$input(id=inputId, class="jsInput")
  )        
}
.Q$updateJS <- function(session, inputId, value = NULL) {
  session$sendInputMessage(inputId, value)
}