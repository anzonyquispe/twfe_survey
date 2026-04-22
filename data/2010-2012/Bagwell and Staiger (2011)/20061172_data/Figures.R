
rm(list=ls(all=TRUE))

#x<-read.table("C:/TOT_Project/Estimation Data/AugustData2.TXT", header=TRUE) # For figure 1
x<-read.table("C:/TOT_Project/AER-Data/NonLinearData2.txt", header=TRUE) # For Figure 2

Prod<-x$Product
ImpP<-(x$Import/((x$Price2*10)))
ImpP2<-(x$Import/((x$Price2)^2))
BND<-ifelse(is.na(x$WBND)==FALSE,x$WBND,x$BND)
MFN<-ifelse(is.na(x$WMFN)==FALSE,x$WMFN,x$MFN)
country<-x$Country


Price2<-x$Price2
DomPrice<-Price2*(1+MFN)
#Imp<-ImpP2 # For Figure 1
Imp<-(ImpP/DomPrice)*x$Sigma*(x$InvOmega) # For Figure 2


CompuData<-data.frame(Prod,country,BND,MFN,Imp,ImpP,ImpP2)

countries<-levels(as.factor(as.character(CompuData$country)))

#######By Industry Deciles

for(k in 10:10){

data1<-matrix(nrow=1,ncol=5)
data1[1,1]<-"Imp"
data1[1,2]<-"Bins"
data1[1,3]<-"Bound"
data1[1,4]<-"MeanCon"
data1[1,5]<-"WMeanCon"

if(k<=9){subYear<-subset(CompuData,Prod>=(k*100000)&Prod<((k+1)*100000))}
if(k>9){subYear<-CompuData}
subYear<-subset(subYear,is.na(Imp)==FALSE)
subYear<-subset(subYear,is.na(BND)==FALSE)
subYear<-subset(subYear,is.na(MFN)==FALSE)
imprank<-rank(subYear$Imp,na.last=NA)
subYear2<-data.frame(subYear,imprank)
binsize<-nrow(subYear2)/10
meanconc<-mean(subYear2$MFN-subYear2$BND,na.rm=TRUE)
weights<-subYear2$Imp/sum(subYear2$Imp,na.rm=TRUE)
Wmeanconc<-weighted.mean(subYear2$MFN-subYear2$BND,weights,na.rm=TRUE)

for(j in 1:10){
subRank<-subset(subYear2,imprank<=(binsize*j))
subRank<-subset(subRank,imprank>binsize*(j-1))
meanconcB<-mean(subRank$MFN-subRank$BND,na.rm=TRUE)
weightsB<-subRank$Imp/sum(subRank$Imp,na.rm=TRUE)
WmeanconcB<-weighted.mean(subRank$MFN-subRank$BND,weightsB,na.rm=TRUE)

data2<-matrix(nrow=1,ncol=5)
data2[1,1]<-mean(subRank$Imp,na.rm=TRUE)
data2[1,2]<-j
data2[1,3]<-mean(subRank$BND,na.rm=TRUE)
data2[1,4]<-(meanconcB-meanconc)
data2[1,5]<-((meanconcB-meanconc)*100/abs(meanconc))
data1<-rbind(data1,data2)
}

write.table(data1,"C:/TOT_Project/Estimation Code/New stuff/BLW/Results/Figures/Deciles.TXT")


wconc<-as.numeric(data1[2:nrow(data1),5])
conc<-as.numeric(data1[2:nrow(data1),4])
rank<-as.numeric(data1[2:nrow(data1),2])
imp<-as.character(round(as.numeric(data1[2:nrow(data1),1]),digits=1))
conlabel<-seq(max(conc,.1),max(conc,.1),length=length(conc))
Wconlabel<-seq(max(wconc,.1),max(wconc,.1),length=length(wconc))

jpeg(file=paste("C:/TOT_Project/Estimation Code/New stuff/BLW/Results/Figures/",paste(as.character(k),"_Conc.jpg",sep=""),sep=""),width=650,height=650,bg="white")
{plot(conc~rank,col="black",type="h",lwd=15,ylim=c(min(min(conc)-1,-1),max(1,conc+1)),xlim=c(.5,10.5),xlab='Import Decile',ylab='Deviation from Mean Concession - in quota')
if(k<10){title(paste("Deviation from Mean Concession by Decile - HS",as.character(k),sep=""),cex.main=1,font.main=2)}
if(k==10){title(paste("Deviation from Mean Concession by Decile - ","All",sep=""),cex.main=1,font.main=2)}
text(rank,conlabel,pos=3,cex=.7,label=imp)
}
dev.off()
jpeg(file=paste("C:/TOT_Project/Estimation Code/New stuff/BLW/Results/Figures/",paste(as.character(k),"_ConcW.jpg",sep=""),sep=""),width=650,height=650,bg="white")
###{plot(wconc~rank,col="black",type="h",lwd=15,ylim=c(min(min(wconc)-1,-1),max(1,wconc+1)),xlim=c(.5,10.5),xlab='Inverse_Omega Decile',ylab='Percent Deviation from Mean Concession')
{plot(wconc~rank,col="black",type="h",lwd=15,ylim=c(min(min(wconc)-1,-1),max(1,wconc+1)),xlim=c(.5,10.5),xlab='(M/P)*(Sigma/Omega) Decile',ylab='Percent Deviation from Mean Concession')
if(k<10){title(paste("Percent Deviation from Mean Concession by Decile - in quota - HS",as.character(k),sep=""),cex.main=1,font.main=2)}
if(k==10){title(paste("Percent Deviation from Mean Concession by Decile ","All",sep=""),cex.main=1,font.main=2)}
text(rank,Wconlabel,pos=3,cex=.7,label=imp)
}
dev.off()
}

binsize
