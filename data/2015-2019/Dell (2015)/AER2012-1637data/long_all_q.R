library(ggplot2)

data=read.csv("C:/Users/melissa.dell/Dropbox (Melissa Dell)/governance/reprod/allQ.csv")

period.n = as.numeric(as.character(data$period))
data$annotation = ifelse(period.n <= -1,
                         'Pre-period',
                         'Post Term 1')
data$annotation[data$period=="LD1a"] = 'Lame Duck 1'
data$annotation[data$period=="LD1b"] = 'Lame Duck 2'
data$annotation[is.na(data$annotation)] = 'Post Term 2'
data$Period <- factor(data$annotation, levels = c("Pre-period", "Lame Duck 1", "Post Term 1", "Lame Duck 2", "Post Term 2"))

data$Quarter <- factor(data$period, levels = c(as.character(seq(-69,-1, by=1)), "LD1a", as.character(seq(1,9, by=1)), "LD1b", "1_b", "2_b", "3_b", "4_b", "5_b", "6_b", "7_b"))

pdf(file ="C:/Users/melissa.dell/Dropbox (Melissa Dell)/governance/reprod/inegiQ0708_all.pdf", width=14, height=8*.5)

subdata=subset(data, bw=="5%" & RDpoly=="quadnofe") 

ggstandard = ggplot(data=subdata, aes(x =Quarter, y = coeff, ymin = cn5, ymax=cp5))

print(ggstandard
      + geom_linerange(aes(color=Period), size = .95)
      + geom_linerange(aes(x =Quarter, y = coeff, ymin = cn10, ymax=cp10, color=Period), size = 1.35)   
      + geom_point(aes(x = Quarter, y = coeff, color=Period), size = 3.5) 
      + geom_hline(y = 0)
      + scale_x_discrete(breaks=c(-69, -65, -60,-55, -50,-45, -40,-35, -30,-25, -20,-15, -10,-5, "LD1a", 1, 4, 8, "LD1b", "1_b", "4_b", "7_b"),labels=c(-69, -65, -60,-55, -50,-45, -40,-35, -30,-25, -20,-15, -10,-5, "LD", "1",4, 8, "LD", "1", 4, 7))
      + scale_y_continuous(name="Homicide Rate")
      + scale_colour_manual(values=c("#000000", "#FF0000", "#009E73", "#D55E00", "#000066"))
      + theme_bw()
     
)


dev.off()
