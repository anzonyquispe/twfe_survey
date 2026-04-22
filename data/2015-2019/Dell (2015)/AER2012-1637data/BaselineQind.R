library(ggplot2)


data=read.csv("C:/Users/melissa.dell/Dropbox (Melissa Dell)/governance/reprod/BaselineQextensive.csv")

period.n = as.numeric(as.character(data$period))
data$annotation = ifelse(period.n <= -1,
                         'Pre-period',
                         'Post-period')
data$annotation[data$period=="LD1a"] = 'Lame Duck 1'
data$annotation[data$period=="LD1b"] = 'Lame Duck 2'
data$Period <- factor(data$annotation, levels = c("Pre-period", "Lame Duck 1", "Post-period", "Lame Duck 2"))


data$Quarter <- factor(data$period, levels = c(as.character(seq(-2,-1, by=1)), "LD1a", as.character(seq(1,9, by=1)), "LD1b"))

pdf(file ="C:/Users/melissa.dell/Dropbox (Melissa Dell)/governance/reprod/BaselineQext.pdf", width=14*.5, height=8*.5)


subdata=subset(data, bw=="5%" & RDpoly=="quadnofe") 

ggstandard = ggplot(data=subdata, aes(x =Quarter, y = coeff, ymin = cn5, ymax=cp5))

print(ggstandard
      + geom_linerange(aes(color=Period), size = .65)
      + geom_linerange(aes(x =Quarter, y = coeff, ymin = cn10, ymax=cp10, color=Period), size = 1.35)   
      + geom_point(aes(x = Quarter, y = coeff, color=Period), size = 3.5) 
      + geom_hline(y = 0)
      + scale_x_discrete(breaks=c(-2, -1, "LD1a", 1, 2, 3, 4, 5, 6, 7, 8, 9, "LD1b"),labels=c(-2, -1, "LD", 1, 2, 3, 4, 5, 6, 7, 8, 9, "LD"))
      + scale_y_continuous(name="Homicide Probability")
      + scale_colour_manual(values=c("#000000", "#FF0000", "#009E73", "#D55E00"))
      + theme_bw()
      #       + ggtitle("5% bandwidth, quad, no fe")
)

dev.off()
