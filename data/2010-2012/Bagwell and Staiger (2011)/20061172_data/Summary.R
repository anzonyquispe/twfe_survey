#--Summary Statistics-- Tables 2a-b#
#--Commenting is similar to the regression files.  We first arrange the dataset, and then calculate summary statistics--"

rm(list=ls(all=TRUE))

cd<-matrix(nrow=1,ncol=10)
cd[1,1]<-"Low"
cd[1,2]<-"High"
cd[1,3]<-"Variable"
cd[1,4]<-"Mean"
cd[1,5]<-"SD"
cd[1,6]<-"Median"
cd[1,7]<-"Min"
cd[1,8]<-"Max"
cd[1,9]<-"NObs"
cd[1,10]<-"NObs=0"

write.table(cd,"C:/TOT_Project/Estimation Code/DataSummary/Results/Summary1.TXT",row.names=FALSE, col.names = FALSE, append=FALSE)

#Load Data
NewmemberAll_Pre<-read.table("C:/TOT_Project/Estimation Data/MainData.TXT", header=TRUE)


IDBreakdown<-read.table("C:/TOT_Project/Estimation Data/IDBREAK.TXT", header=TRUE)
IDLOW<-IDBreakdown$IDLOW
IDHIGH<-IDBreakdown$IDHIGH

h=2

for(j in 1:length(IDLOW)){

NewmemberAll<-subset(NewmemberAll_Pre,is.na(BND)==FALSE)
NewmemberAll<-subset(NewmemberAll,is.na(Import)==FALSE)
NewmemberAll<-subset(NewmemberAll,Import>0)
NewmemberAll<-subset(NewmemberAll,(Product>=IDLOW[j]&Product<IDHIGH[j]))

for(w in 0:0){

if(w==0){NewmemberAll0<-NewmemberAll}
if(w>0){NewmemberAll0<-subset(NewmemberAll,Country==countries[w])}

Id<-as.factor(NewmemberAll0$Product)  #Product ID HS6
Country<-NewmemberAll0$Country
Import<-NewmemberAll0$Import
TariffBase<-ifelse(is.na(NewmemberAll0$WMFN),NewmemberAll0$MFN,NewmemberAll0$WMFN)
TariffFinal<-ifelse(is.na(NewmemberAll0$WBND),NewmemberAll0$BND,NewmemberAll0$WBND)
Id.num<-NewmemberAll0$Product
IDCHAR_pre<-as.character(Id.num)
IDCHAR<-ifelse(nchar(IDCHAR_pre)>5,IDCHAR_pre,paste("0",IDCHAR_pre,sep=""))
HSCLASS<-as.numeric(substr(IDCHAR,1,h))
HS<-as.factor(HSCLASS)
#MisMatch<-(NewmemberAll0$M0)
#NTB<-(NewmemberAll0$AVEcore)

rm(NewmemberAll0)

NewmemberAll2<-data.frame(HS,Country,Import,TariffBase,TariffFinal)#,MisMatch,NTB)
NewmemberAll2<-subset(NewmemberAll2,is.na(Import)==FALSE)
NewmemberAll2<-subset(NewmemberAll2,is.na(TariffFinal)==FALSE)
NewmemberAll2<-subset(NewmemberAll2,is.na(TariffBase)==FALSE)
#NewmemberAll2<-subset(NewmemberAll2,is.na(MisMatch)==FALSE)

#subroutine for cleaning

allproducts<-levels(as.factor(NewmemberAll2$HS))

for(z in 1:length(allproducts)){
subsample<-subset(NewmemberAll2,HS==allproducts[z])
subsample<-subset(subsample,is.nan(TariffBase)==FALSE)
if(nrow(subsample)<=2){
NewmemberAll2<-subset(NewmemberAll2,as.numeric(HS)!=z)
}
}

NewmemberAll1<-NewmemberAll2
rm(NewmemberAll2)

cd2<-matrix(nrow=1,ncol=10)
cd2[1,1]<-IDLOW[j]
cd2[1,2]<-IDHIGH[j]
cd2[1,3]<-"Imports"
cd2[1,4]<-mean(NewmemberAll1$Import,na.rm=TRUE)
cd2[1,5]<-sqrt(var(NewmemberAll1$Import,na.rm=TRUE))
cd2[1,6]<-median(NewmemberAll1$Import,na.rm=TRUE)
cd2[1,7]<-min(NewmemberAll1$Import,na.rm=TRUE)
cd2[1,8]<-max(NewmemberAll1$Import,na.rm=TRUE)
cd2[1,9]<-length(NewmemberAll1$Import)
cd2[1,10]<-sum(ifelse(NewmemberAll1$Import==0,1,0),na.rm=TRUE)
write.table(cd2,"C:/TOT_Project/Estimation Code/DataSummary/Results/Summary1.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

cd2<-matrix(nrow=1,ncol=10)
cd2[1,1]<-IDLOW[j]
cd2[1,2]<-IDHIGH[j]
cd2[1,3]<-"Base Tariff"
cd2[1,4]<-mean(NewmemberAll1$TariffBase,na.rm=TRUE)
cd2[1,5]<-sqrt(var(NewmemberAll1$TariffBase,na.rm=TRUE))
cd2[1,6]<-median(NewmemberAll1$TariffBase,na.rm=TRUE)
cd2[1,7]<-min(NewmemberAll1$TariffBase,na.rm=TRUE)
cd2[1,8]<-max(NewmemberAll1$TariffBase,na.rm=TRUE)
cd2[1,9]<-length(NewmemberAll1$TariffBase)
cd2[1,10]<-sum(ifelse(NewmemberAll1$TariffBase==0,1,0),na.rm=TRUE)
write.table(cd2,"C:/TOT_Project/Estimation Code/DataSummary/Results/Summary1.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

cd2<-matrix(nrow=1,ncol=10)
cd2[1,1]<-IDLOW[j]
cd2[1,2]<-IDHIGH[j]
cd2[1,3]<-"Bound Tariff"
cd2[1,4]<-mean(NewmemberAll1$TariffFinal,na.rm=TRUE)
cd2[1,5]<-sqrt(var(NewmemberAll1$TariffFinal,na.rm=TRUE))
cd2[1,6]<-median(NewmemberAll1$TariffFinal,na.rm=TRUE)
cd2[1,7]<-min(NewmemberAll1$TariffFinal,na.rm=TRUE)
cd2[1,8]<-max(NewmemberAll1$TariffFinal,na.rm=TRUE)
cd2[1,9]<-length(NewmemberAll1$TariffFinal)
cd2[1,10]<-sum(ifelse(NewmemberAll1$TariffFinal==0,1,0),na.rm=TRUE)
write.table(cd2,"C:/TOT_Project/Estimation Code/DataSummary/Results/Summary1.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

}
}

h=2


NewmemberAll<-subset(NewmemberAll_Pre,is.na(BND)==FALSE)
NewmemberAll<-subset(NewmemberAll,is.na(Import)==FALSE)
NewmemberAll<-subset(NewmemberAll,Import>0)
#NewmemberAll<-subset(NewmemberAll,(Product>=IDLOW[j]&Product<IDHIGH[j]))
countries<-levels(as.factor(as.character(NewmemberAll$Country)))

for(w in 1:length(countries)){

if(w==0){NewmemberAll0<-NewmemberAll}
if(w>0){NewmemberAll0<-subset(NewmemberAll,Country==countries[w])}

Id<-as.factor(NewmemberAll0$Product)  #Product ID HS6
Country<-NewmemberAll0$Country
Import<-NewmemberAll0$Import
TariffBase<-ifelse(is.na(NewmemberAll0$WMFN),NewmemberAll0$MFN,NewmemberAll0$WMFN)
TariffFinal<-ifelse(is.na(NewmemberAll0$WBND),NewmemberAll0$BND,NewmemberAll0$WBND)
Id.num<-NewmemberAll0$Product
IDCHAR_pre<-as.character(Id.num)
IDCHAR<-ifelse(nchar(IDCHAR_pre)>5,IDCHAR_pre,paste("0",IDCHAR_pre,sep=""))
HSCLASS<-as.numeric(substr(IDCHAR,1,h))
HS<-as.factor(HSCLASS)


rm(NewmemberAll0)

NewmemberAll2<-data.frame(HS,Country,Import,TariffBase,TariffFinal)
NewmemberAll2<-subset(NewmemberAll2,is.na(Import)==FALSE)
NewmemberAll2<-subset(NewmemberAll2,is.na(TariffFinal)==FALSE)
NewmemberAll2<-subset(NewmemberAll2,is.na(TariffBase)==FALSE)
#NewmemberAll2<-subset(NewmemberAll2,is.na(MisMatch)==FALSE)

#subroutine for cleaning

allproducts<-levels(as.factor(NewmemberAll2$HS))

for(z in 1:length(allproducts)){
subsample<-subset(NewmemberAll2,HS==allproducts[z])
subsample<-subset(subsample,is.nan(TariffBase)==FALSE)
if(nrow(subsample)<=2){
NewmemberAll2<-subset(NewmemberAll2,as.numeric(HS)!=z)
}
}

NewmemberAll1<-NewmemberAll2
rm(NewmemberAll2)

cd2<-matrix(nrow=1,ncol=10)
cd2[1,1]<-""
cd2[1,2]<-countries[w]
cd2[1,3]<-"Imports"
cd2[1,4]<-mean(NewmemberAll1$Import,na.rm=TRUE)
cd2[1,5]<-sqrt(var(NewmemberAll1$Import,na.rm=TRUE))
cd2[1,6]<-median(NewmemberAll1$Import,na.rm=TRUE)
cd2[1,7]<-min(NewmemberAll1$Import,na.rm=TRUE)
cd2[1,8]<-max(NewmemberAll1$Import,na.rm=TRUE)
cd2[1,9]<-length(NewmemberAll1$Import)
cd2[1,10]<-sum(ifelse(NewmemberAll1$Import==0,1,0),na.rm=TRUE)
write.table(cd2,"C:/TOT_Project/Estimation Code/DataSummary/Results/Summary1.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

cd2<-matrix(nrow=1,ncol=10)
cd2[1,1]<-""
cd2[1,2]<-countries[w]
cd2[1,3]<-"Base Tariff"
cd2[1,4]<-mean(NewmemberAll1$TariffBase,na.rm=TRUE)
cd2[1,5]<-sqrt(var(NewmemberAll1$TariffBase,na.rm=TRUE))
cd2[1,6]<-median(NewmemberAll1$TariffBase,na.rm=TRUE)
cd2[1,7]<-min(NewmemberAll1$TariffBase,na.rm=TRUE)
cd2[1,8]<-max(NewmemberAll1$TariffBase,na.rm=TRUE)
cd2[1,9]<-length(NewmemberAll1$TariffBase)
cd2[1,10]<-sum(ifelse(NewmemberAll1$TariffBase==0,1,0),na.rm=TRUE)
write.table(cd2,"C:/TOT_Project/Estimation Code/DataSummary/Results/Summary1.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

cd2<-matrix(nrow=1,ncol=10)
cd2[1,1]<-""
cd2[1,2]<-countries[w]
cd2[1,3]<-"Bound Tariff"
cd2[1,4]<-mean(NewmemberAll1$TariffFinal,na.rm=TRUE)
cd2[1,5]<-sqrt(var(NewmemberAll1$TariffFinal,na.rm=TRUE))
cd2[1,6]<-median(NewmemberAll1$TariffFinal,na.rm=TRUE)
cd2[1,7]<-min(NewmemberAll1$TariffFinal,na.rm=TRUE)
cd2[1,8]<-max(NewmemberAll1$TariffFinal,na.rm=TRUE)
cd2[1,9]<-length(NewmemberAll1$TariffFinal)
cd2[1,10]<-sum(ifelse(NewmemberAll1$TariffFinal==0,1,0),na.rm=TRUE)
write.table(cd2,"C:/TOT_Project/Estimation Code/DataSummary/Results/Summary1.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)
}

warnings()
