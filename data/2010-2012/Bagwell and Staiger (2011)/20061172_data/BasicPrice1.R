#This file is the same as Basic.R, with the exception that we are dividing import values by the world price.  
# Code to estimate the following regressions:
# Appendix, Table 1a, right panel
# Appendix, Table 1b, right panel
# Appendix, Table 2b, just add "MisMatch" (referred to as "outsiders" in the paper) as a regressor 

rm(list=ls(all=TRUE))

library(stats)
library(survival)
library(car)

cd<-matrix(nrow=1,ncol=11)
cd[1,1]<-"Sample"
cd[1,2]<-"Obs"
cd[1,3]<-"OLS(B1)"
cd[1,4]<-""
cd[1,5]<-"OLS(B2)"
cd[1,6]<-""
cd[1,7]<-"R2"
cd[1,8]<-"Tobit(B1)"
cd[1,9]<-""
cd[1,10]<-"Tobit(B2)"
cd[1,11]<-""

write.table(cd,"C:/TOT_Project/Estimation Code/Baseline Estimates/Results/BasicPrice1.TXT",row.names=FALSE, col.names = FALSE, append=FALSE)

#Load Data 
NewmemberAll_Pre<-read.table("C:/TOT_Project/Estimation Data/MainData.TXT", header=TRUE)

IDBreakdown<-read.table("C:/TOT_Project/Estimation Data/IDBREAK.TXT", header=TRUE)
IDLOW<-IDBreakdown$IDLOW
IDHIGH<-IDBreakdown$IDHIGH

for(j in 1:length(IDLOW)){

h=2

NewmemberAll<-subset(NewmemberAll_Pre,is.na(BND)==FALSE)
NewmemberAll<-subset(NewmemberAll,is.na(Import)==FALSE)
NewmemberAll<-subset(NewmemberAll,Import>0)
NewmemberAll<-subset(NewmemberAll,(Product>=IDLOW[j]&Product<IDHIGH[j]))

if(nrow(NewmemberAll)>0){

countries<-levels(as.factor(as.character(NewmemberAll$Country)))

for(w in 0:0){

if(w==0){NewmemberAll0<-NewmemberAll}
if(w>0){NewmemberAll0<-subset(NewmemberAll,Country==countries[w])}

Id<-as.factor(NewmemberAll0$Product)  #Product ID HS6
Country<-NewmemberAll0$Country
Import<-(NewmemberAll0$Import/(NewmemberAll0$Price2)^2)
TariffBase<-ifelse(is.na(NewmemberAll0$WMFN),NewmemberAll0$MFN,NewmemberAll0$WMFN)
TariffFinal<-ifelse(is.na(NewmemberAll0$WBND),NewmemberAll0$BND,NewmemberAll0$WBND)
Id.num<-NewmemberAll0$Product
Herf<-NewmemberAll0$Herf
IDCHAR_pre<-as.character(Id.num)
IDCHAR<-ifelse(nchar(IDCHAR_pre)>5,IDCHAR_pre,paste("0",IDCHAR_pre,sep=""))
HSCLASS<-as.numeric(substr(IDCHAR,1,h))
HS<-as.factor(HSCLASS)
MisMatch<-(NewmemberAll0$MisMatch/(NewmemberAll0$Price2)^2)
NoNeg<-(NewmemberAll0$NoNeg/(NewmemberAll0$Price2)^2)


rm(NewmemberAll0)

NewmemberAll2<-data.frame(HS,Country,Import,TariffBase,TariffFinal,MisMatch,Herf)
NewmemberAll2<-subset(NewmemberAll2,is.na(Import)==FALSE)
NewmemberAll2<-subset(NewmemberAll2,is.na(TariffFinal)==FALSE)
NewmemberAll2<-subset(NewmemberAll2,is.na(TariffBase)==FALSE)
NewmemberAll2<-subset(NewmemberAll2,is.na(MisMatch)==FALSE)

#subroutine for cleaning

allproducts<-levels(as.factor(NewmemberAll2$HS))

for(z in 1:1){#length(allproducts)){
subsample<-subset(NewmemberAll2,HS==allproducts[z])
subsample<-subset(subsample,is.nan(TariffBase)==FALSE)
if(nrow(subsample)<=2){
NewmemberAll2<-subset(NewmemberAll2,as.numeric(HS)!=z)
}
}

HS<-NewmemberAll2$HS  #Product ID HS6
Country<-NewmemberAll2$Country
Import<-(NewmemberAll2$Import/mean(NewmemberAll2$Import,na.rm=TRUE))
TariffBase<-NewmemberAll2$TariffBase
TariffFinal<-NewmemberAll2$TariffFinal
Herf<-NewmemberAll2$Herf
MisMatch<-(NewmemberAll2$MisMatch/mean(NewmemberAll2$MisMatch,na.rm=TRUE))

NewmemberAll1<-data.frame(HS,Country,Import,TariffBase,TariffFinal,MisMatch,Herf)
rm(NewmemberAll2)

if(nrow(subset(NewmemberAll1,is.na(Import)==FALSE))>0){

TVar<-var(NewmemberAll1$TariffBase,na.rm=TRUE)

if(w==0){if(TVar>0){
OLS<-lm(TariffFinal~Import+TariffBase+as.factor(HS)+as.factor(Country)-1,data=NewmemberAll1)
TobitHS4<-{survreg(Surv(TariffFinal,TariffFinal>=0.001,type='left')~Import+TariffBase+as.factor(HS)+as.factor(Country)-1,data=NewmemberAll1,dist='gaussian',iter.max=500)}
}
if(TVar==0){
OLS<-lm(TariffFinal~Import+as.factor(HS)+as.factor(Country)-1,data=NewmemberAll1)
TobitHS4<-{survreg(Surv(TariffFinal,TariffFinal>=0.001,type='left')~Import+as.factor(HS)+as.factor(Country)-1,data=NewmemberAll1,dist='gaussian',iter.max=500)}
}}

sterr<-as.numeric(sqrt(diag(vcov(OLS))))
pvalues<-pt(as.numeric(coef(OLS))/sterr,df.residual(OLS),lower.tail=FALSE)

ImportEst<-as.numeric(coef(OLS)[1])

Wsterr<-as.numeric(sqrt(diag(hccm(OLS,type="hc1"))))
Wpvalues<-pt(as.numeric(coef(OLS))/Wsterr,df.residual(OLS),lower.tail=FALSE)
Wpvalues1<-pt((as.numeric(coef(OLS)))/Wsterr,df.residual(OLS),lower.tail=FALSE)

WImportEst<-as.numeric(coef(OLS)[1])
WImportErr<-Wsterr[1]
WImportP<-Wpvalues[1]

Tsterr<-sqrt(diag(TobitHS4$var)[1:(length(diag(TobitHS4$var))-1)])
TobitP<-{pt(as.numeric(coef(TobitHS4))/sqrt(diag(TobitHS4$var)[1:(length(diag(TobitHS4$var))-1)]),df.residual(TobitHS4),lower.tail=FALSE)}
TobitP1<-{pt((as.numeric(coef(TobitHS4)))/sqrt(diag(TobitHS4$var)[1:(length(diag(TobitHS4$var))-1)]),df.residual(TobitHS4),lower.tail=FALSE)}

TImportEst<-as.numeric(coef(TobitHS4)[1])
TImportErr<-Tsterr[1]
TImportP<-TobitP[1]

if(TVar==0){
BaseEst<-"NA"
WBaseErr<-"NA"
WBaseP<-"NA"
TBaseEst<-"NA"
TBaseErr<-"NA"
TBaseP<-"NA"
}

if(TVar>0){
BaseEst<-as.numeric(coef(OLS)[2])
WBaseErr<-Wsterr[2]
WBaseP<-Wpvalues1[2]
TBaseEst<-as.numeric(coef(TobitHS4)[2])
TBaseErr<-Tsterr[2]
TBaseP<-TobitP1[2]
}

cd2<-matrix(nrow=1,ncol=11)
cd2[1,1]<-IDLOW[j]
cd2[1,2]<-nrow(NewmemberAll1)
cd2[1,3]<-round(as.numeric(BaseEst),digits = 4)
cd2[1,4]<-{ifelse(BaseEst>0,ifelse(WBaseP<=0.005,"***",ifelse(WBaseP<=0.025,"**",ifelse(WBaseP<=0.05,"*",""))),
ifelse(WBaseP>=0.995,"***",ifelse(WBaseP>=0.975,"**",ifelse(WBaseP>=.95,"*",""))))}
cd2[1,5]<-round(as.numeric(ImportEst),digits = 4)
cd2[1,6]<-{ifelse(ImportEst>0,ifelse(WImportP<=0.005,"***",ifelse(WImportP<=0.025,"**",ifelse(WImportP<=0.05,"*",""))),
ifelse(WImportP>=0.995,"***",ifelse(WImportP>=0.975,"**",ifelse(WImportP>=.95,"*",""))))}
cd2[1,7]<-round(summary(OLS)$r.squared,digits = 4)
cd2[1,8]<-round(as.numeric(TBaseEst),digits = 4)
cd2[1,9]<-{ifelse(TBaseEst>0,ifelse(TBaseP<=0.005,"***",ifelse(TBaseP<=0.025,"**",ifelse(TBaseP<=0.05,"*",""))),
ifelse(TBaseP>=0.995,"***",ifelse(TBaseP>=0.975,"**",ifelse(TBaseP>=.95,"*",""))))}
cd2[1,10]<-round(as.numeric(TImportEst),digits = 4)
cd2[1,11]<-{ifelse(TImportEst>0,ifelse(TImportP<=0.005,"***",ifelse(TImportP<=0.025,"**",ifelse(TImportP<=0.05,"*",""))),
ifelse(TImportP>=0.995,"***",ifelse(TImportP>=0.975,"**",ifelse(TImportP>=.95,"*",""))))}

write.table(cd2,"C:/TOT_Project/Estimation Code/Baseline Estimates/Results/BasicPrice1.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

cd2<-matrix(nrow=1,ncol=11)
cd2[1,1]<-""
cd2[1,2]<-""
cd2[1,3]<-paste(paste("(",round((as.numeric(WBaseErr)),digits = 4),sep=""),")",sep="")
cd2[1,4]<-""
cd2[1,5]<-round((as.numeric(WImportErr)*(-1)),digits = 4)
cd2[1,6]<-""
cd2[1,7]<-""
cd2[1,8]<-round((as.numeric(TBaseErr)*(-1)),digits = 4)
cd2[1,9]<-""
cd2[1,10]<-round((as.numeric(TImportErr)*(-1)),digits = 4)
cd2[1,11]<-""

write.table(cd2,"C:/TOT_Project/Estimation Code/Baseline Estimates/Results/BasicPrice1.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

rm(OLS)
rm(sterr)
rm(TobitHS4)
}
}
}
}



for(h in 2:2){

NewmemberAll<-subset(NewmemberAll_Pre,is.na(BND)==FALSE)


NewmemberAll<-subset(NewmemberAll,is.na(Import)==FALSE)
NewmemberAll<-subset(NewmemberAll,Import>0)

countries<-levels(as.factor(as.character(NewmemberAll$Country)))

for(w in 1:length(countries)){

if(w==0){NewmemberAll0<-NewmemberAll}
if(w>0){NewmemberAll0<-subset(NewmemberAll,Country==countries[w])}

Id<-as.factor(NewmemberAll0$Product)  #Product ID HS6
Country<-NewmemberAll0$Country
Import<-(NewmemberAll0$Import/(NewmemberAll0$Price2)^2)
TariffBase<-ifelse(is.na(NewmemberAll0$WMFN),NewmemberAll0$MFN,NewmemberAll0$WMFN)
TariffFinal<-ifelse(is.na(NewmemberAll0$WBND),NewmemberAll0$BND,NewmemberAll0$WBND)
Id.num<-NewmemberAll0$Product
Herf<-NewmemberAll0$Herf
IDCHAR_pre<-as.character(Id.num)
IDCHAR<-ifelse(nchar(IDCHAR_pre)>5,IDCHAR_pre,paste("0",IDCHAR_pre,sep=""))
HSCLASS<-as.numeric(substr(IDCHAR,1,h))
HS<-as.factor(HSCLASS)
MisMatch<-(NewmemberAll0$MisMatch/(NewmemberAll0$Price2)^2)



rm(NewmemberAll0)

NewmemberAll2<-data.frame(HS,Country,Import,TariffBase,TariffFinal,MisMatch,Herf)
NewmemberAll2<-subset(NewmemberAll2,is.na(Import)==FALSE)
NewmemberAll2<-subset(NewmemberAll2,is.na(TariffFinal)==FALSE)
NewmemberAll2<-subset(NewmemberAll2,is.na(TariffBase)==FALSE)
NewmemberAll2<-subset(NewmemberAll2,is.na(MisMatch)==FALSE)

#subroutine for cleaning

allproducts<-levels(as.factor(NewmemberAll2$HS))

for(z in 1:length(allproducts)){
subsample<-subset(NewmemberAll2,HS==allproducts[z])
subsample<-subset(subsample,is.nan(TariffBase)==FALSE)
if(nrow(subsample)<=2){
NewmemberAll2<-subset(NewmemberAll2,as.numeric(HS)!=z)
}
}

HS<-NewmemberAll2$HS  #Product ID HS6
Country<-NewmemberAll2$Country
Import<-(NewmemberAll2$Import/mean(NewmemberAll2$Import,na.rm=TRUE))
TariffBase<-NewmemberAll2$TariffBase
TariffFinal<-NewmemberAll2$TariffFinal
Herf<-NewmemberAll2$Herf
MisMatch<-(NewmemberAll2$MisMatch/mean(NewmemberAll2$MisMatch,na.rm=TRUE))

NewmemberAll1<-data.frame(HS,Country,Import,TariffBase,TariffFinal,MisMatch,Herf)
rm(NewmemberAll2)

if(nrow(subset(NewmemberAll1,is.na(Import)==FALSE))>0){

TVar<-var(NewmemberAll1$TariffBase,na.rm=TRUE)

if(TVar==0){
OLS<-lm(TariffFinal~Import+as.factor(HS)-1,data=NewmemberAll1)
TobitHS4<-{survreg(Surv(TariffFinal,TariffFinal>=0.001,type='left')~Import+as.factor(HS)-1,data=NewmemberAll1,dist='gaussian',iter.max=500)}
}

if(TVar>0){
OLS<-lm(TariffFinal~Import+TariffBase+as.factor(HS)-1,data=NewmemberAll1)
TobitHS4<-{survreg(Surv(TariffFinal,TariffFinal>=0.001,type='left')~Import+TariffBase+as.factor(HS)-1,data=NewmemberAll1,dist='gaussian',iter.max=500)}
}

sterr<-as.numeric(sqrt(diag(vcov(OLS))))
pvalues<-pt(as.numeric(coef(OLS))/sterr,df.residual(OLS),lower.tail=FALSE)

ImportEst<-as.numeric(coef(OLS)[1])

Wsterr<-as.numeric(sqrt(diag(hccm(OLS,type="hc1"))))
Wpvalues<-pt(as.numeric(coef(OLS))/Wsterr,df.residual(OLS),lower.tail=FALSE)
Wpvalues1<-pt((as.numeric(coef(OLS)))/Wsterr,df.residual(OLS),lower.tail=FALSE)


WImportEst<-as.numeric(coef(OLS)[1])
WImportErr<-Wsterr[1]
WImportP<-Wpvalues[1]


Tsterr<-sqrt(diag(TobitHS4$var)[1:(length(diag(TobitHS4$var))-1)])
TobitP<-{pt(as.numeric(coef(TobitHS4))/sqrt(diag(TobitHS4$var)[1:(length(diag(TobitHS4$var))-1)]),df.residual(TobitHS4),lower.tail=FALSE)}
TobitP1<-{pt((as.numeric(coef(TobitHS4)))/sqrt(diag(TobitHS4$var)[1:(length(diag(TobitHS4$var))-1)]),df.residual(TobitHS4),lower.tail=FALSE)}


TImportEst<-as.numeric(coef(TobitHS4)[1])
TImportErr<-Tsterr[1]
TImportP<-TobitP[1]

if(TVar==0){
BaseEst<-"NA"
WBaseErr<-"NA"
WBaseP<-"NA"
TBaseEst<-"NA"
TBaseErr<-"NA"
TBaseP<-"NA"
}

if(TVar>0){
BaseEst<-as.numeric(coef(OLS)[2])
WBaseErr<-Wsterr[2]
WBaseP<-Wpvalues1[2]
TBaseEst<-as.numeric(coef(TobitHS4)[2])
TBaseErr<-Tsterr[2]
TBaseP<-TobitP1[2]
}

cd2<-matrix(nrow=1,ncol=11)
cd2[1,1]<-countries[w]
cd2[1,2]<-nrow(NewmemberAll1)
cd2[1,3]<-round(as.numeric(BaseEst),digits = 4)
cd2[1,4]<-{ifelse(BaseEst>0,ifelse(WBaseP<=0.005,"***",ifelse(WBaseP<=0.025,"**",ifelse(WBaseP<=0.05,"*",""))),
ifelse(WBaseP>=0.995,"***",ifelse(WBaseP>=0.975,"**",ifelse(WBaseP>=.95,"*",""))))}
cd2[1,5]<-round(as.numeric(ImportEst),digits = 4)
cd2[1,6]<-{ifelse(ImportEst>0,ifelse(WImportP<=0.005,"***",ifelse(WImportP<=0.025,"**",ifelse(WImportP<=0.05,"*",""))),
ifelse(WImportP>=0.995,"***",ifelse(WImportP>=0.975,"**",ifelse(WImportP>=.95,"*",""))))}
cd2[1,7]<-round(summary(OLS)$r.squared,digits = 4)
cd2[1,8]<-round(as.numeric(TBaseEst),digits = 4)
cd2[1,9]<-{ifelse(TBaseEst>0,ifelse(TBaseP<=0.005,"***",ifelse(TBaseP<=0.025,"**",ifelse(TBaseP<=0.05,"*",""))),
ifelse(TBaseP>=0.995,"***",ifelse(TBaseP>=0.975,"**",ifelse(TBaseP>=.95,"*",""))))}
cd2[1,10]<-round(as.numeric(TImportEst),digits = 4)
cd2[1,11]<-{ifelse(TImportEst>0,ifelse(TImportP<=0.005,"***",ifelse(TImportP<=0.025,"**",ifelse(TImportP<=0.05,"*",""))),
ifelse(TImportP>=0.995,"***",ifelse(TImportP>=0.975,"**",ifelse(TImportP>=.95,"*",""))))}

write.table(cd2,"C:/TOT_Project/Estimation Code/Baseline Estimates/Results/BasicPrice1.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

cd2<-matrix(nrow=1,ncol=11)
cd2[1,1]<-""
cd2[1,2]<-""
cd2[1,3]<-round((as.numeric(WBaseErr)*(-1)),digits = 4)
cd2[1,4]<-""
cd2[1,5]<-round((as.numeric(WImportErr)*(-1)),digits = 4)
cd2[1,6]<-""
cd2[1,7]<-""
cd2[1,8]<-round((as.numeric(TBaseErr)*(-1)),digits = 4)
cd2[1,9]<-""
cd2[1,10]<-round((as.numeric(TImportErr)*(-1)),digits = 4)
cd2[1,11]<-""

write.table(cd2,"C:/TOT_Project/Estimation Code/Baseline Estimates/Results/BasicPrice1.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

rm(OLS)
rm(sterr)
rm(TobitHS4)
}
}
}

warnings()
