
##Graph##
{
    setOldClass('mongo.oid')
    setOldClass('shiny.tag')
    setOldClass('json')
    Graph <- setRefClass(
        'Graph',
        fields=c(
            title='character',
            oid='mongo.oid',
            icon='shiny.tag',
            color='character',
            tab.order='numeric',
            tab='shiny.tag'
        ),
        methods=
            list(
                initialize=function(
                    title,
                    content=list(title),
                    icon='square-o',
                    color='rgba(205,255,255,.2)',
                    tab.order=1
                ) {
                    title <<- title
                    oid <<- mongo.oid.create()
                    if('shiny.tag' %in% class(icon)) icon <<- icon
                    else if('character' %in% class(icon)) icon <<- icon(icon,class='fa-2x')
                    color <<- color
                    tab.order <<- tab.order
                    content <- mapInput(title,content)
                    tab <<- tabPanel(title,content,value=title,icon=.self$icon)
                }
            )
    )
}