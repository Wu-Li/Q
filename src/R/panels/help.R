output$help <- renderUI({
    if (!is.na(prompt$help)) {
        url <- capture.output(eval( 
            parse(text=prompt$help), 
            sys.frame() 
        ))
        print(url <- substring(url,6,nchar(url)-1))
        tags$iframe(src=url)
    } else {
        url <- capture.output(eval(
            parse(text='help.start(browser=print)'), 
            sys.frame() 
        ))[2]
        url <- substring(url,2,nchar(url)-10)
        tags$iframe(src=url)
    }
})        