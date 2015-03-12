jsInput <- function(inputId,label) {
  tagList(
    singleton(
      tags$head(
        tags$script(src="js/jsBinding.js")
      )
    ),
    tags$label(label, `for` = inputId),
    tags$input(id=inputId,type='text',class="jsInput")
  )        
}
updateJS <- function(session, inputId, value = NULL) {
  session$sendInputMessage(inputId, value)
}