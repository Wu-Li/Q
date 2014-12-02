.Q$mapInput <- function(inputId, 
    value = paste0('{"title": "',inputId,'","id": 1,"formatVersion": 2, "ideas": {  } }')) 
{
    tagList(
        singleton(tags$head(
            tags$script(src="js/mapjs/lib/jquery.hotkeys.js"),
            tags$script(src="js/mapjs/lib/hammer.min.js"),
            tags$script(src="js/mapjs/lib/jquery.hammer.min.js"),
            tags$script(src="js/mapjs/lib/underscore-1.4.4.js", type="text/javascript"),
            tags$script(src="js/mapjs/lib/color-0.4.1.min.js"),        
            tags$script(src="js/mapjs/mapjs-compiled.js"),
            tags$script(src="js/mapjs/attachments.js"),
            
            tags$script(src="js/mapBinding.js"),
            tags$script(src="js/mapKeys.js")
        )),
        
        tags$div(id=inputId, class="qmap", value=value,
                 tags$script(paste0(
                    'mapBinding.setValue($("#',inputId,'"),',value,');'
                 ))
        )        
    )
}

.Q$getMapLayout <- function(inputId) {
  tags$script(paste0('var layout = Q.models["',inputId,'"].getCurrentLayout();
                      $("#consoleMap").val(layout);'))
}