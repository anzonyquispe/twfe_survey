
# Code fot Table 5b

rm(list=ls(all=TRUE))

library(stats)
library(survival)
library(car)

cd<-matrix(nrow=1,ncol=7)
cd[1,1]<-"Low"
cd[1,2]<-"High"
cd[1,3]<-"Country"
cd[1,4]<-"OLS(B2)"
cd[1,5]<-"OLS(B1)"
cd[1,6]<-"Tobit(B2)"
cd[1,7]<-"Tobit(B1)"

write.table(cd,"C:/TOT_Project/Estimation Code/NTBMeasures/Results/NTB2.TXT",row.names=FALSE, col.names = FALSE, append=FALSE)

#Load Data
NewmemberAll_Pre<-read.table("C:/TOT_Project/Estimation Data/AVEData.TXT", header=TRUE)

IDBreakdown<-read.table("C:/TOT_Project/Estimation Data/IDBREAK.TXT", header=TRUE)
IDLOW<-IDBreakdown$IDLOW
IDHIGH<-IDBreakdown$IDHIGH

for(j in 10:10){

h=2

NewmemberAll<-subset(NewmemberAll_Pre,is.na(TariffFinal)==FALSE)
NewmemberAll<-subset(NewmemberAll,is.na(Import)==FALSE)
NewmemberAll<-subset(NewmemberAll,Import>0)
NewmemberAll<-subset(NewmemberAll,(Product>=IDLOW[j]&Product<IDHIGH[j]))

countries<-levels(as.factor(as.character(NewmemberAll$Country)))

for(w in 0:0){

if(w==0){NewmemberAll0<-NewmemberAll}
if(w>0){NewmemberAll0<-subset(NewmemberAll,Country==countries[w])}


Id<-as.factor(NewmemberAll0$Product)  #Product ID HS6
Country<-as.factor(as.character(NewmemberAll0$Country))
Import<-(NewmemberAll0$Import)
TariffBase<-NewmemberAll0$TariffBase+(NewmemberAll0$Ave_cd)*100  #Pre-accession MFN Tariff plus pre-accession NTBs
TariffFinal<-NewmemberAll0$TariffFinal 
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

if(nrow(subset(NewmemberAll1,is.na(Import)==FALSE))>0){

TVar<-var(NewmemberAll1$TariffBase,na.rm=TRUE)

if(TVar>0){
OLS<-lm(TariffFinal~TariffBase+as.factor(HS)+Import*as.factor(Country)-Import-1,data=NewmemberAll1)
TobitHS4<-{survreg(Surv(TariffFinal,TariffFinal>=0.001,type='left')~TariffBase+as.factor(HS)+Import*as.factor(Country)-Import-1,data=NewmemberAll1,dist='gaussian',iter.max=500)}
}
if(TVar==0){
OLS<-lm(TariffFinal~as.factor(HS)+Import*as.factor(Country)-Import-1,data=NewmemberAll1)
TobitHS4<-{survreg(Surv(TariffFinal,TariffFinal>=0.001,type='left')~as.factor(HS)+Import*as.factor(Country)-Import-1,data=NewmemberAll1,dist='gaussian',iter.max=500)}
}

sterr<-as.numeric(sqrt(diag(vcov(OLS))))
pvalues<-pt(as.numeric(coef(OLS))/sterr,df.residual(OLS),lower.tail=FALSE)

nations<-levels(Country)

ImportEst<-as.numeric(coef(OLS)[(length(coef(OLS))-(length(nations)-1)):length(coef(OLS))])
ImportErr<-sterr[(length(sterr)-(length(nations)-1)):length(sterr)]
ImportP<-pvalues[(length(pvalues)-(length(nations)-1)):length(pvalues)]

Wsterr<-as.numeric(sqrt(diag(hccm(OLS,type='hc1'))))
Wpvalues<-pt(as.numeric(coef(OLS))/Wsterr,df.residual(OLS),lower.tail=FALSE)
Wsterr3<-as.numeric(sqrt(diag(hccm(OLS))))
Wpvalues3<-pt(as.numeric(coef(OLS))/Wsterr3,df.residual(OLS),lower.tail=FALSE)

WImportEst<-as.numeric(coef(OLS)[(length(coef(OLS))-(length(nations)-1)):length(coef(OLS))])
WImportErr<-Wsterr[(length(Wsterr)-(length(nations)-1)):length(Wsterr)]
WImportP<-pt(WImportEst/WImportErr,df.residual(OLS),lower.tail=FALSE)
WImportEst3<-as.numeric(coef(OLS)[(length(coef(OLS))-(length(nations)-1)):length(coef(OLS))])
WImportErr3<-Wsterr3[(length(Wsterr3)-(length(nations)-1)):length(Wsterr3)]
WImportP3<-pt(WImportEst3/WImportErr3,df.residual(OLS),lower.tail=FALSE)

Tsterr<-sqrt(diag(TobitHS4$var)[1:(length(diag(TobitHS4$var))-1)])
TobitP<-{pt(as.numeric(coef(TobitHS4))/sqrt(diag(TobitHS4$var)[1:(length(diag(TobitHS4$var))-1)]),df.residual(TobitHS4),lower.tail=FALSE)}

TImportEst<-as.numeric(coef(TobitHS4)[(length(coef(TobitHS4))-(length(nations)-1)):length(coef(TobitHS4))])
TImportErr<-Tsterr[(length(Tsterr)-(length(nations)-1)):length(Tsterr)]
TImportP<-TobitP[(length(TobitP)-(length(nations)-1)):length(TobitP)]

if(TVar==0){
BaseEst<-"NA"
BaseErr<-"NA"
BaseP<-"NA"
WBaseErr<-"NA"
WBaseP<-"NA"
WBaseErr3<-"NA"
WBaseP3<-"NA"
TBaseEst<-"NA"
TBaseErr<-"NA"
TBaseP<-"NA"
}

if(TVar>0){
BaseEst<-as.numeric(coef(OLS)[1])
BaseErr<-sterr[1]
BaseP<-pvalues[1]
WBaseErr<-Wsterr[1]
WBaseP<-Wpvalues[1]
WBaseErr3<-Wsterr3[1]
WBaseP3<-Wpvalues3[1]
TBaseEst<-as.numeric(coef(TobitHS4)[1])
TBaseErr<-Tsterr[1]
TBaseP<-TobitP[1]
}

for(z in 1:(length(nations))){

cd2<-matrix(nrow=1,ncol=7)
cd2[1,1]<-ifelse(z==1,IDLOW[j],"")
cd2[1,2]<-ifelse(z==1,IDHIGH[j],"")
cd2[1,3]<-nations[z]
cd2[1,4]<-round(as.numeric(ImportEst[z]),digits = 4)
cd2[1,5]<-ifelse(z==1,round(as.numeric(BaseEst),digits = 4),"")
cd2[1,6]<-round(as.numeric(TImportEst[z]),digits = 4)
cd2[1,7]<-ifelse(z==1,round(as.numeric(TBaseEst),digits = 4),"")

write.table(cd2,"C:/TOT_Project/Estimation Code/NTBMeasures/Results/NTB2.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

cd2<-matrix(nrow=1,ncol=7)
cd2[1,1]<-nrow(NewmemberAll1)
cd2[1,2]<-ifelse(z==1,summary(OLS)$r.squared,"")
cd2[1,3]<-""
cd2[1,4]<-round((as.numeric(WImportErr[z])*(-1)),digits = 4)
cd2[1,5]<-ifelse(z==1,round((as.numeric(WBaseErr)*(-1)),digits=4),"")
cd2[1,6]<-round((as.numeric(TImportErr[z])*(-1)),digits = 4)
cd2[1,7]<-ifelse(z==1,round((as.numeric(TBaseErr)*(-1)),digits = 4),"")

write.table(cd2,"C:/TOT_Project/Estimation Code/NTBMeasures/Results/NTB2.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

cd2<-matrix(nrow=1,ncol=7)
cd2[1,1]<-""
cd2[1,2]<-ifelse(z==1,summary(OLS)$adj.r.squared,"")
cd2[1,3]<-""
cd2[1,4]<-round(as.numeric(WImportP[z]), digits = 3)
cd2[1,5]<-ifelse(z==1,round(as.numeric(WBaseP), digits = 3),"")
cd2[1,6]<-round(as.numeric(TImportP[z]), digits = 3)
cd2[1,7]<-ifelse(z==1,round(as.numeric(TBaseP), digits = 3),"")
write.table(cd2,"C:/TOT_Project/Estimation Code/NTBMeasures/Results/NTB2.TXT",row.names=FALSE, col.names = FALSE, append=TRUE)

}

rm(OLS)
rm(sterr)
rm(TobitHS4)
}
}
}

warnings()
