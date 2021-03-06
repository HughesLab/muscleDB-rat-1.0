theme_xOnly<- function(textSize) {
  theme(title = element_text(size = 32, color = grey90K),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_text(size = textSize, color = grey60K),
        axis.text.y = element_text(vjust = 0.1),
        axis.title.x = element_text(size = 19, color = grey60K), 
        axis.title.y = element_blank(), 
        legend.position="none",
        panel.border = element_rect(colour = grey90K, size = 0.25, fill = NA),
        panel.grid.major = element_line(color = grey60K, size = 0.2),
        panel.grid.major.y = element_blank(),
        panel.spacing = unit(15, units = 'points'),
        panel.background = element_blank(), 
        strip.text = element_text(size = 13, face = 'bold', color = grey60K),
        strip.background = element_blank()
  )
}

grey90K = '#414042'
grey60K = '#808285'
nPlots = 25

cardColor = '#ad494a'
skelColor = '#5254a3'
smoothColor = '#bd9e39'

cols = c(
  'soleus (female)' = skelColor,
  'EDL (female)' = skelColor,
  'soleus (male)' = skelColor,
  'EDL (male)' = skelColor)

getPage <- reactive({
  page = (input$nextPage - input$prevPage)
  
  if (page < 0) {
    page = 0
  } else {
    page = page
  }
})

output$plot1 <- renderPlot({
  
  pageNum = getPage()
  
  
  iBeg = (pageNum)*nPlots + 1
  iEnd = (pageNum + 1)*nPlots
  
  
  filteredData = filterData()
  
  # transcriptList = unique(filteredData$transcript)[1:nPlots]
  transcriptList = unique(filteredData$transcript)[iBeg:iEnd]
  
  data2Plot = filteredData %>% 
    filter(transcript %in% transcriptList) %>% 
    mutate(transFacet = paste0(gene, '\n (', transcript, ')')) # Merge names for more informative output.
  
  numTissues = length(unique(data2Plot$tissue))
  
  textSize = ifelse(numTissues <= 8, 16, 20 - numTissues/2)
  
  if(nrow(data2Plot) == 0) {
    # no data
    ggplot(data2Plot, aes(y= expr, x=tissue)) +
      geom_blank() +
      theme_void()
    
  } else {
    maxExpr = max(data2Plot$expr)
    
    yLim = c(-0.1*maxExpr, maxExpr)
    
    
    # bar plot
    ggplot(data2Plot, aes(y = expr, x = tissue, 
                          label = round(expr, 1))) +
      
      coord_flip(ylim = yLim) +
      
      scale_fill_manual(values = c(rep(skelColor, 4)),
                        limits = c('soleus (female)',
                                   'EDL (female)', 
                                   'soleus (male)',
                                   'EDL (male)')) +
      
      
      # lollipops
      geom_segment(aes(x = tissue, 
                       xend = tissue,
                       y = 0, yend = expr), colour = grey90K,
                   size = 0.1) +
      # error bars
      geom_segment(aes(x = tissue, 
                       xend = tissue,
                       y = lb, yend = ub), 
                   size = 1.5,
                   colour = grey50K, alpha = 0.5) +
      # points
      geom_point(aes(fill = tissue),
                 size = 4, colour = grey90K, 
                 stroke = 0.2, shape = 21) + 
      
      geom_text(aes(x = tissue, y = 0), hjust = 1.1,
                colour = grey60K) +
      
      
      ylab('expression (FPKM)') + 
      facet_wrap(~transFacet) +
      theme_xOnly(textSize)
  }
  
})