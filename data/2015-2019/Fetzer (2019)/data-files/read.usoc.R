#
DTUniqueBy <- function(data, varvec) {
  data <- as.data.table(data)
  data[!duplicated(data.frame(data[, varvec, with=F]))]
}


preProcess<-function (content, keepnum = FALSE, keepperiod = FALSE, keepcomma = FALSE, 
    tolower = TRUE) 
{
    if (keepperiod == TRUE) {
        content <- gsub("[^[:alnum:].,;]", " ", content)
    }
    else {
        content <- gsub("[^[:alnum:]]", " ", content)
    }
    content <- gsub("[[:space:]]+", " ", content)
    if (tolower == TRUE) {
        content <- tolower(content)
    }
    content <- gsub("^ *", "  ", content)
    if (keepnum == FALSE) {
        content <- gsub("([0-9])*", "", content)
    }
    content <- gsub("^-*", "", content)
    content <- gsub(" +", " ", content)
    content <- gsub(" *$", "", content)
    content <- gsub(" *$", "", content)
    content <- gsub("^ *", "", content)
    content
}

options(stringsAsFactors=FALSE)
library(zoo)
library(foreign)
library(lubridate)
library(data.table)
library(plyr)
library(sjlabelled)
library(haven)

#code written for R 3.3.3 
setwd("/Users/thiemo/Dropbox/Research/Austerity and Brexit/Replication V2/data files/usoc")

ffsa<-list.files("/Users/thiemo/Dropbox/Research/Austerity and Brexit/Replication V2/data files/usoc", include.dirs=TRUE, recursive=TRUE)

ffsa<-grep("^ukhls_w",ffsa,value=TRUE)


##this is loading the income tabulations for households/individual respondents -- it either reads an rdata file or it reads the raw data building the combined USOC-INCOME.rdata archive

ffs<-grep("income.dta", ffsa, value=TRUE)
DAT<-lapply(ffs, function(x) data.table(read.dta(file=x)))



HH<-NULL

for(i in 1:length(DAT)) {
cat(i, " ")
sub<-substr(ffs[i], 10,10)

TEMP<-DAT[[i]]
setnames(TEMP, names(TEMP), gsub(paste(sub,"_",sep=""),"", names(TEMP)))

#keep these variables
VARS<-c(grep("^hidp|^pno|pidp|^frval|^frmnth|^ficode|^frmnthimp_dv",names(DAT[[i]]),value=TRUE))

HH[[i]]<-data.table(file=ffs[i], TEMP[, VARS,with=F])

}

HH<-rbindlist(HH, fill=TRUE)

HH[, ficode := tolower(as.character(ficode))]
HH[, wavechar := substr(file,10,10)]
HH[, file := NULL]
HH[, ficode := tolower(as.character(ficode))]
HH<-join(HH,HH[, .N, by=wavechar][, list(wavechar, wavenum = 1:8)])

FICODE<-data.table(read.csv(file="harmonization mappers/FICODE.csv"))
FICODE<-FICODE[!is.na(ficode_num)]

FICODE[, ficode := tolower(ficode)]

FICODE.POP<-HH[, .N, by=ficode]
FICODE.POP1<-FICODE.POP[nchar(ficode)>3]

FICODE.POP2<-FICODE.POP[nchar(ficode)<3]
FICODE.POP2 <-join(FICODE.POP2[, list(ficode_num= ficode)], FICODE)[!is.na(ficode)]

FICODES<-rbind(FICODE.POP1[, list(ficode, ficodesd=ficode)], FICODE.POP2[, list(ficode=ficode_num, ficodesd=ficode)])
HH <-join(HH, FICODES)
HH[, ficodesd := str_trim(ficodesd)]
HH[, ficode := ficodesd]


FICODE.SD <-data.table(read.csv(file="harmonization mappers/FICODE_SD_LONG.csv"))

HH<-join(HH, FICODE.SD)


BENALL <-HH[, list(sample=.N), by=c("hidp", "pidp", "wavechar")]

for(bb in c("council_tax_benefit","housing_benefit","dla_pip")) { 

TEMP<-HH[ficode_standard==bb, list(amt=sum(frmnthimp_dv)), by=c("hidp", "pidp", "wavechar")]
BENALL<-join(BENALL, TEMP)
BENALL[is.na(amt), amt:=0]

setnames(BENALL, "amt", paste("ben_",bb,sep=""))

}


HH[, housing_ben_rec := 0]
HH[grep("housing benefit", ficode), housing_ben_rec := 1]

HH[, dla_rec := 0]
HH[grep("disability living allowance", ficode), dla_rec := 1]

HH[, council_tax_ben_rec := 0]
HH[grep("council tax benefit", ficode), council_tax_ben_rec := 1]

bens<-c("council_tax_ben_rec", "housing_ben_rec","dla_rec")

IN<-HH

#remove some obviously wrong numbers 
INCOMEALL<-HH[frmnth_dv>=0 & frmnth_dv!=999999 & frval!= 22222222 & frval!=11111111]

INCOMEALL<-INCOMEALL[, list(incomeall = sum(frmnth_dv)), by=c("hidp","pidp","wavechar")]

#data entry error
HH[frval == 18001800, frmnth_dv:= 150 ]

CREDIT<-NULL

i=1

for(var in bens) {

setnames(HH,var,"temp")
TEMP<-HH[temp==1 & frmnth_dv>=0 &  frmnth_dv!=999999 & frval!= 22222222 & frval!=11111111]


TEMP<-TEMP[, list(temp_sum = sum(frmnth_dv)), by=c("hidp","pidp","wavechar")]

TEMP$temp<-1

INCOMEALL<-join(INCOMEALL, TEMP)

INCOMEALL[is.na(temp), temp_sum := 0]
INCOMEALL[is.na(temp), temp := 0]

setnames(INCOMEALL, "temp", var)
setnames(INCOMEALL, "temp_sum", paste(var,"_sum",sep=""))

setnames(HH, "temp", var)

i=i+1

}


#household level data file
ffs<-grep("hhresp.dta", ffsa, value=TRUE)
DAT<-lapply(ffs, function(x) data.table(read.dta(file=x)))


HH<-NULL

for(i in 1:length(DAT)) {
cat(i, " ")
sub<-substr(ffs[i], 10,10)

TEMP<-DAT[[i]]
setnames(TEMP, names(TEMP), gsub(paste("^",sub,"_",sep=""),"", names(TEMP)))

##grab the variabless to keep
VARS<-c(grep("^hidp|^fihhmnprben_dv|^fihhmnpen_dv|^rentg$|^rent$|^tenure_dv|^xphsdb$|^xphsdct|^fihhmngrs_dv|^fihhmnlabgrs_dv|^fihhmninv_dv|^fihhmnsben_dv|hsbeds|hhsize|nkids|hhtype_dv",names(DAT[[i]]),value=TRUE))

HH[[i]]<-data.table(file=ffs[i], TEMP[, VARS,with=F])

}

HH<-rbindlist(HH, fill=TRUE)
HH[, wavechar := substr(file,10,10)]
HH[, file := NULL]

#standardize
for(var in c("xphsdb","xphsdct","tenure_dv")) {
setnames(HH, var, "temp")
HH[, temp := tolower(as.character(temp))]
setnames(HH, "temp",var)
}

for(var in c("xphsdb","xphsdct")) {

setnames(HH, var, "temp")

HH[temp %in% c("inapplicable","don't know","refused","missing","refusal"), temp := NA]

setnames(HH, "temp",var)

}


###now load individual respondent data which includes disability benefit status
ffs<-grep("indresp.dta", ffsa, value=TRUE)
DAT<-lapply(ffs, function(x) data.table(read.dta(file=x)))

OUT<-NULL
for(i in 1:length(DAT)) {
cat(i, " ")
sub<-substr(ffs[i], 10,10)
TEMP<-DAT[[i]]
setnames(TEMP, names(TEMP), gsub(paste(sub,"_",sep=""),"", names(TEMP)))
VARS<-c("pidp","sex","hidp","dvage", grep("^btype|^pbnft|bendis|^hiqual_dv|hcond[0-9]+|^perpolinf|^jbstat|jbiindb_dv|voteintent|polef|^vote|colbens|^istr|^fimngrs_dv|fimnsben_dv|fimnlabgrs_dv|fimnpen|fimnlabnet_dv|fimninvnet_dv|jbseg_dv|^jbnssec5_dv|^jbnssec8_dv|^jbsic07_cc|^jbft_dv|eumem|^jbsec",names(DAT[[i]]),value=TRUE))
OUT[[i]]<-data.table(file=ffs[i], TEMP[, VARS,with=F])
}

INDBEN<-rbindlist(OUT, fill=TRUE)

INDBEN[, wavechar := substr(file,10,10)]
INDBEN <-join(INDBEN,INDBEN[, .N, by=wavechar][order(wavechar), list(wavechar, wave=1:.N)])


nns<-grep("^btype|^pbnft|bendis", names(INDBEN), value=TRUE)

for(vv in nns) {
cat(vv, sep="\n")
setnames(INDBEN, vv, "temp")
INDBEN[, temp := preProcess(as.character(temp))]
INDBEN[temp %in% c("proxy respondent","proxy"), temp := "proxy"]
INDBEN[temp %in% c("refused","missing","don t know","refusal"), temp := NA]
INDBEN[temp %in% c("yes mentioned"), temp := "mentioned"]
setnames(INDBEN, "temp", vv)
}


INDBEN[, bprxy_dla_pip := bendis5]
INDBEN[bendis5=="proxy" & !is.na(pbnft3), bprxy_dla_pip := pbnft3]
INDBEN[!is.na(bprxy_dla_pip), bprxy_dla_pip_dum := as.numeric(bprxy_dla_pip %in% "mentioned")]


INDBEN<-INDBEN[, c("pidp","hidp","wavechar",grep("bprxy",names(INDBEN), value=TRUE)), with=F]



HH.PAN<-rbindlist(OUT, fill=TRUE)

HH.PAN[, year := istrtdaty]
HH.PAN[, month := istrtdatm]


HH.PAN[, wavechar := substr(file,10,10)]
HH.PAN<-join(HH.PAN,HH.PAN[, .N, by=wavechar][, list(wavechar, wave = 1:8)])



HH.PAN[, jbstat := tolower(as.character(jbstat))]

JBSTAT<-data.table(read.csv(file="harmonization mappers/JBSTAT.csv"))
HH.PAN <-join(HH.PAN, JBSTAT)

HH.PAN[, hiqual_dv := as.character(hiqual_dv)]
QUAL<-data.table(read.csv(file="harmonization mappers/HH.QUAL.csv"))

HH.PAN<-join(HH.PAN, QUAL)
#highest qualification prior to most reforms
HH.PAN<-join(HH.PAN, HH.PAN[, .N, by=c("pidp","hiqual_dv_sd","hiqual_dv_sd_num","year")][year<=2011][, list(maxhiqual_dv_sd_num = max(hiqual_dv_sd_num)), by= pidp])

IND<-data.table(read.csv(file="harmonization mappers/INUDSTRY.CLASS.csv"))
HH.PAN[, jbiindb_dv := as.character(jbiindb_dv)]
HH.PAN<-join(HH.PAN, IND[, list(jbiindb_dv, ind_label=unifiedlabel)][!is.na(jbiindb_dv)])

#pre reform industry of employment 
HH.PAN<- join(HH.PAN, join(HH.PAN[, .N, by=c("pidp","ind_label","year")][year<=2011][ind_label!="" & !is.na(ind_label)][, .N, by=c("pidp","ind_label")],HH.PAN[, .N, by=c("pidp","ind_label","year")][year<=2011][ind_label!=""& !is.na(ind_label)][, .N, by=c("pidp","ind_label")][, max(N), by="pidp"])[V1==N][, list(pidp, industry_sector_sd= ind_label)])


#cleaning
HH.PAN[, jbnssec8_dv := preProcess(as.character(jbnssec8_dv))]
HH.PAN[, jbnssec5_dv := preProcess(as.character(jbnssec5_dv))]



#health conditions
for(var in c("hcond1","hcond2","hcond3","hcond4","hcond5","hcond6","hcond7","hcond8","hcond9","hcond10","hcond11","hcond12","hcond13","hcond14","hcond15","hcond16","hcond17")) {

setnames(HH.PAN, var, "temp")
HH.PAN[, temp := preProcess(as.character(temp))]

HH.PAN[temp %in% c("missing","refusal","don't know","don t know","refused","inapplicable", "proxy","proxy respondent","not available for iemb"), temp := NA]

HH.PAN[, temp_num := as.numeric(temp)]

HH.PAN[temp %in% c("mentioned","yes mentioned"), temp_num := 1]
HH.PAN[temp %in% c("not mentioned"), temp_num := 0]

HH.PAN <-join(HH.PAN,HH.PAN[wave==1, list(w1_temp_dum = mean(as.numeric(temp_num))), by=pidp])


setnames(HH.PAN, "temp", var)
setnames(HH.PAN, "temp_num", paste(var,"_dum",sep=""))
setnames(HH.PAN, "w1_temp_dum", paste("w1_",var,"_dum",sep=""))



}



for(var in c("vote1","vote2","vote3","vote4","vote5","vote6", "vote7","vote8")) {

setnames(HH.PAN, var, "temp")
HH.PAN[, temp := tolower(as.character(temp))]
HH.PAN[temp %in% c("proxy","proxy respondent"), temp := "proxy"]
HH.PAN[temp %in% c("refused","refusal"), temp := "refused"]


setnames(HH.PAN, "temp", var)

}



HH.PAN[ , jbsec := preProcess(as.character(jbsec))]

HH.PAN[, jbsec_num := as.numeric(jbsec)]
HH.PAN[jbsec=="very likely", jbsec_num := 1]
HH.PAN[jbsec=="likely", jbsec_num := 2]
HH.PAN[jbsec=="unlikely", jbsec_num := 3]
HH.PAN[jbsec=="very unlikely", jbsec_num := 4]


SIC07<-data.table(data.frame(jbsic07_cc =as.character(OUT[[1]]$jbsic07_cc) , jbsic07_cc_num = as.numeric(OUT[[1]]$jbsic07_cc)))

SIC07 <-DTUniqueBy(SIC07, names(SIC07))[jbsic07_cc_num>2]

SIC07[, SIC2007Section := ""]
SIC07[jbsic07_cc_num > 5 &jbsic07_cc_num<=8,  SIC2007Section := "Agriculture, Forestry and Fishing"]
SIC07[jbsic07_cc_num > 8 &jbsic07_cc_num<=13,  SIC2007Section := "Mining and Quarrying"]
SIC07[jbsic07_cc_num > 13 &jbsic07_cc_num<=37,  SIC2007Section := "Manufacturing"]
SIC07[jbsic07_cc_num > 37 &jbsic07_cc_num<=38,  SIC2007Section := "Electricity, Gas, Steam and Air Conditioning Supply"]
SIC07[jbsic07_cc_num > 38 &jbsic07_cc_num<=42,  SIC2007Section := "Water Supply; Sewerage, Waste Management and Remediation Activities"]
SIC07[jbsic07_cc_num > 42 &jbsic07_cc_num<=45,  SIC2007Section := "Construction"]
SIC07[jbsic07_cc_num > 45 &jbsic07_cc_num<=48,  SIC2007Section := "Wholesale and Retail Trade"]
SIC07[jbsic07_cc_num > 48 &jbsic07_cc_num<=53,  SIC2007Section := "Transportation and Storage"]
SIC07[jbsic07_cc_num > 53 &jbsic07_cc_num<=55,  SIC2007Section := "Accommodation and Food Service Activities"]
SIC07[jbsic07_cc_num > 55 &jbsic07_cc_num<=61,  SIC2007Section := "Information and Communication"]
SIC07[jbsic07_cc_num > 61 &jbsic07_cc_num<=64,  SIC2007Section := "Financial and Insurance Activities"]
SIC07[jbsic07_cc_num > 64 &jbsic07_cc_num<=65,  SIC2007Section := "Real Estate Activities"]
SIC07[jbsic07_cc_num > 65 &jbsic07_cc_num<=72,  SIC2007Section := "Professional, Scientific and Technical Activities"]
SIC07[jbsic07_cc_num > 72 &jbsic07_cc_num<=78,  SIC2007Section := "Administrative and Support Service Activities"]
SIC07[jbsic07_cc_num > 78 &jbsic07_cc_num<=79,  SIC2007Section := "Public Administration and Defence; Compulsory Social Security"]
SIC07[jbsic07_cc_num > 79 &jbsic07_cc_num<=80,  SIC2007Section := "Education"]
SIC07[jbsic07_cc_num > 80 &jbsic07_cc_num<=83,  SIC2007Section := "Human Health and Social Work Activities"]
SIC07[jbsic07_cc_num > 83 &jbsic07_cc_num<=87,  SIC2007Section := "Arts, Entertainment and Recreation"]
SIC07[jbsic07_cc_num > 87 &jbsic07_cc_num<=90,  SIC2007Section := "Other Service Activities"]




SIC07 <-SIC07[SIC2007Section!=""]
HH.PAN[, jbsic07_cc := as.character(jbsic07_cc)]
HH.PAN<-join(HH.PAN,SIC07)

#PRESENT ECONOMIC


for(var in c("votenorm","poleff1","poleff2","poleff3","poleff4")) {

setnames(HH.PAN, var, "temp")
HH.PAN[, temp := as.character(temp)]
HH.PAN[temp %in% c("missing","Not available for IEMB","refusal","don't know","refused","inapplicable", "proxy","proxy respondent","don't know"), temp  := NA]

HH.PAN[temp=="strongly disagree", temp_num := 1]
HH.PAN[temp=="disagree", temp_num := 2]
HH.PAN[temp %in% c("neither agree nor disagree","neither agree/disagree"), temp_num := 3]
HH.PAN[temp=="agree", temp_num := 4]
HH.PAN[temp=="strongly agree", temp_num := 5]


setnames(HH.PAN,  "temp",var)
setnames(HH.PAN,  "temp_num",paste(var,"_num", sep=""))



}



HH.PAN[, wavechar := substr(file,10,10)]


###this loads the LAD identifiers
ffs<-list.files("data files/lad/usoc", include.dirs=TRUE, recursive=TRUE)

LOC<-NULL
for(i in 1:length(ffs)) {

TEMP<-data.table(read.dta(file=paste("data files/lad/usoc/",ffs[i],sep="")))
sub<-substr(ffs[i], 1,1)

setnames(TEMP, names(TEMP), gsub(paste(sub,"_",sep=""),"", names(TEMP)))


LOC[[i]]<-data.table(file=ffs[i], TEMP)

}
LOC<-rbindlist(LOC)
LOC[, wavechar := substr(file,1,1)]


#merge LAD codes
HH.PAN <-join(HH.PAN, LOC[, list(hidp,wavechar,code= oslaua)])

PID<-HH.PAN[, .N, by=c("pidp","wavechar","code")][order(pidp,wavechar)]

#impute missing LAD information for small subset of individuals with missing code
PID[, code := na.locf(code), by=pidp]

PID[, N:= NULL]

HH.PAN[, code := NULL]

HH.PAN<-join(HH.PAN, PID)

HH.PAN <-HH.PAN[!is.na(code)]

##fixes a few LAD codes that have changed since 2011 revision
HH.PAN[code=="E07000104"]$code<-"E07000241"
HH.PAN[code=="E07000100"]$code<-"E07000240"
HH.PAN[code=="E07000101"]$code<-"E07000243"
HH.PAN[code=="E07000097"]$code<-"E07000242"
HH.PAN[code=="E06000048"]$code<-"E06000057"
HH.PAN[code=="E08000020"]$code<-"E08000037"
HH.PAN[code=="S12000009"]$code<-"S12000045"
HH.PAN[code=="S12000043"]$code<-"S12000046"

HH.PAN[, country := substr(code,1,1)]
#drop northern ireland
HH.PAN<-HH.PAN[ country!="N"]

HH.PAN[, wavechar := substr(file,10,10)]

HH.PAN<-HH.PAN[order(pidp,wave)]

HH.PAN<-HH.PAN[!is.na(year) & year>2000]

PARTIES<-data.table(read.csv(file="harmonization mappers/PARTY.CLOSEST.TO.csv"))

HH.PAN<- join(HH.PAN, PARTIES[, list(vote4, partystandardizevote4= X)])

HH.PAN<- join(HH.PAN, PARTIES[, list(vote3=vote4, partystandardizevote3= X)])

HH.PAN<- join(HH.PAN, PARTIES[, list(vote8=vote4, partystandardizevote8= X)])


#a small set of duplicate rows
HH.PAN <- DTUniqueBy(HH.PAN, c("pidp","wave"))


 HH.PAN<- HH.PAN[year>=2000]
 
HH.PAN[, region :=  substr(code,1,3)]

 HH.PAN[, ryr := factor(paste(substr(code,1,3), year,sep="-"))]

 HH.PAN[,tm := factor(paste(year,month,sep="-"))]
HH.PAN[,quarter := 1]
 
HH.PAN[month>3 & month<=6,quarter := 2]
HH.PAN[month>6 & month<=9,quarter := 3]
HH.PAN[month>9 & month<=12,quarter := 4]
  
HH.PAN<-HH.PAN[nchar(code) >3] 
#HH.PAN<-HH.PAN[partystandardizevote4!=""]

HH.PAN[partystandardizevote4!="", ukipother := as.numeric(partystandardizevote4 %in% c("ukipother","other","ukip","bnp"))]
HH.PAN<-join(HH.PAN, DTUniqueBy(HH.PAN[partystandardizevote4!=""][!is.na(partystandardizevote4)][order(year, decreasing=TRUE),list(pidp,year, partystandardizevote4)], c("pidp"))[, list(pidp, mostrecentstatedpreference= partystandardizevote4)])


HH.PAN<-join(HH.PAN, HH)

HH.PAN<-join(HH.PAN, INCOMEALL)

HH.PAN <-join(HH.PAN, BENALL)

HH.PAN <-join(HH.PAN, INDBEN[, c("pidp","hidp","wavechar",grep("bprxy",names(INDBEN), value=TRUE)), with=F])
HH.PAN[, tm := ymd(paste(year,month,"01",sep="-"))]

##create jbstat history

JBSTAT<-HH.PAN[, .N, by=c("pidp","year","jbstat_sd")][, 1:3, with=F]
JBSTAT[, comb := paste(year,jbstat_sd,sep="-")]
JBSTAT <-JBSTAT[, c("pidp","comb"), with=F]

HH.PAN <-join(HH.PAN,JBSTAT[, list(jbstathistory = paste(comb,collapse="__")), by=pidp])


write_dta(HH.PAN, path="data files/INDIVIDUAL.PANEL.dta")







