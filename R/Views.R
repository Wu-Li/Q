{ views <- c(
    'Sources',
    'Classes',
    'Tables',
    'Indices',
    'Labels',
    'Styles',
    'Views',
    'Workspace'
  )
  
  getViews <- function() {
    return(views)
  }
  
  getTab <- function(title) {
    tabPanel(title,renderUI(title))
  }
  basicPage()
}