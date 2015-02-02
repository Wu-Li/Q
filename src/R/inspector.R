theme_console <- function(base_size=16,base_family="") {
    theme_grey(base_size=base_size,base_family=base_family) %+replace%
        theme(
            axis.line=element_blank(), 
            panel.background=element_rect(fill="#777777",color='#777777'), 
            #plot.background=element_blank(),
            plot.background=element_rect(fill="#444444",color='#444444'),
            axis.line = element_blank(),
            axis.title=element_text(color='light grey'),
            legend.background=element_blank(), 
            legend.text=element_text(color="light grey"),
            legend.key=element_blank(), 
            legend.title=element_text(color='light grey')
        )
}

panelWidth  <- function(){ as.integer(input$panelWidth)*8 }
panelHeight <- function(){ as.integer(input$panelHeight)*.85 }
output$plot <- renderPlot({
    prompt$plot
} + theme_console(), 
    bg='transparent', 
    width=panelWidth, 
    height=panelHeight
)