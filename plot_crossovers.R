args = commandArgs(trailingOnly=TRUE)
hist_file=args[2]
dir=args[1]
hist_data<-read.csv(hist_file)
setwd(dir)
library(ggplot2)
Cleanup<- theme(panel.grid.major=element_blank(),#remove teh major gridlines
                panel.grid.minor=element_blank(),#remoce the minor gridlines
                panel.background=element_blank(),#remove the grey background 
                axis.line=element_line(color="black"))#make the axis line black



tiff("crossover_frequency.tiff", height = 12, width = 12, units = 'cm', 
     compression = "lzw", res = 300)
ggplot(hist_data, aes(x=crossovers))+geom_histogram(binwidth=1,color='dark blue',fill='gray70')+Cleanup+labs(x='Number of Crossovers', y='Frequency')+ggtitle('Crossover Frequency Among Reads') + theme(plot.title = element_text(hjust = 0.5)) + scale_x_continuous(breaks=seq(0,5,1), limits=c(0,5))+scale_y_continuous(breaks=seq(0,100,2), limits=c(0,30))
dev.off()


