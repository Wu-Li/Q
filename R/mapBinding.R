mapInput <- function(inputId, 
                     value = paste0('{"title": "',inputId,'","id": 1,"formatVersion": 2, "ideas": {  } }')) 
{
    tagList(
        singleton(tags$head(
            tags$script(src="/js/mapjs/lib/jquery-2.0.2.min.js", type="text/javascript"),
            tags$script(src="/js/mapjs/lib/jquery.hotkeys.js"),
            tags$script(src="/js/mapjs/lib/hammer.min.js"),
            tags$script(src="/js/mapjs/lib/jquery.hammer.min.js"),
            tags$script(src="/js/mapjs/lib/underscore-1.4.4.js", type="text/javascript"),
            tags$script(src="/js/mapjs/lib/color-0.4.1.min.js"),        
            tags$script(src="/js/mapjs/mapjs.js"),
            tags$script(src="/js/mapjs/observable.js"),
            tags$script(src="/js/mapjs/url-helper.js"),
            tags$script(src="/js/mapjs/content.js"),
            tags$script(src="/js/mapjs/layout.js"),
            tags$script(src="/js/mapjs/clipboard.js"),
            tags$script(src="/js/mapjs/hammer-draggable.js"),
            tags$script(src="/js/mapjs/map-model.js"),
            tags$script(src="/js/mapjs/map-toolbar-widget.js"),
            tags$script(src="/js/mapjs/link-edit-widget.js"),
            tags$script(src="/js/mapjs/image-drop-widget.js"),
            tags$script(src="/js/mapjs/dom-map-view.js"),
            tags$script(src="/js/mapjs/dom-map-widget.js"),
            tags$script(src="/js/mapjs/attachments.js"),
            tags$script(src="/js/mapBinding.js"),
            tags$script(src="/js/mapKeys.js")
        )),
        
        tags$div(id = inputId, class = "qmap",
                 tags$script(paste0(
                     'loadMap($("#',inputId,'"),',value,');'
                 )),
                 tags$div(id = paste0(inputId,"-tray"),class="tray")
        )
    )
}