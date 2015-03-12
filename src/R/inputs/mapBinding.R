mapInput <- function(inputId, 
                     value=list(a=1,b=2,c=list(d=3,e=list(f=4,5)))
) {
    value$`_id` <- NULL
    idea <- toJSON(list(title=inputId,children=value),auto_unbox=T)
    tagList(
        singleton(tags$head(
            tags$script(src="js/mapjs/lib/jquery.hotkeys.js"),
            tags$script(src="js/mapjs/lib/hammer.min.js"),
            tags$script(src="js/mapjs/lib/jquery.hammer.min.js"),
            tags$script(src="js/mapjs/lib/underscore-1.4.4.js"),
            tags$script(src="js/mapjs/lib/color-0.4.1.min.js"),        
            
            #tags$script(src="js/mapjs/mapjs-compiled.js"),
            tags$script(src="js/mapjs/observable.js"),
            tags$script(src="js/mapjs/mapjs.js"),
            tags$script(src="js/mapjs/url-helper.js"),
            tags$script(src="js/mapjs/content.js"),
            tags$script(src="js/mapjs/layout.js"),
            tags$script(src="js/mapjs/clipboard.js"),
            tags$script(src="js/mapjs/map-model.js"),
            tags$script(src="js/mapjs/map-toolbar-widget.js"),
            tags$script(src="js/mapjs/link-edit-widget.js"),
            tags$script(src="js/mapjs/image-drop-widget.js"),
            tags$script(src="js/mapjs/hammer-draggable.js"),
            tags$script(src="js/mapjs/dom-map-view.js"),
            tags$script(src="js/mapjs/dom-map-widget.js"),
            tags$script(src="js/mapjs/attachments.js"),
            tags$script(src="js/mapBinding.js")
        )),
        tags$div(id=inputId, class="qmap", value=idea,
                 tags$script(paste0(
                    'mapBinding.setValue($("#',inputId,'"),',idea,');'
                 ))
        )        
    )
}

registerInputHandler('Q.mapBinding',function(x,session,name){
    return(x[[1]])
},force=T)