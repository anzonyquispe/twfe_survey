#
DTUniqueBy <- function(data, varvec) {
  data <- as.data.table(data)
  data[!duplicated(data.frame(data[, varvec, with=F]))]
}

Setnames <- function(x, old, new, allow.absent.cols=T) {
  if (!allow.absent.cols) {
    setnames(x, old, new)
  } else {
    old.intersect <- intersect(old, names(x))
    common.indices <- old %in% old.intersect
    new.intersect <- new[common.indices]
    setnames(x, old.intersect, new.intersect)
  }
}


options(stringsAsFactors=FALSE)
library(zoo)
library(foreign)
library(lubridate)
library(data.table)
library(plyr)
library(operator.tools)

setwd("/Users/thiemo/Dropbox/Research/Austerity and Brexit/Replication V2/data files/bhps/")

ffsa<-list.files("/Users/thiemo/Dropbox/Research/Austerity and Brexit/Replication V2/data files/bhps/", include.dirs=TRUE, recursive=TRUE)

ffs<-grep("indresp.dta", ffsa, value=TRUE)


OUT<-NULL

for(i in 1:18) {
cat(i, " ")
sub<-gsub("/|_","",str_extract(ffs[i], "/([a-z]{1,2})_")) 

TEMP<-DAT[[i]]
setnames(TEMP, names(TEMP), gsub(paste(sub,"_",sep=""),"", names(TEMP)))

VARS<-c(grep("^pno|^pidp|^pid|^hid|^sex|^istrtdat|istrtdaty|^hiqual_dv$|tenure_dv|jbsic|hlstat|hiqual_dv|fimnlabgrs_dv|fimngrs_dv|fimnb",names(TEMP),value=TRUE))

OUT[[i]]<-data.table(file=ffs[i], TEMP[, VARS,with=F])

}

BHPS<-rbindlist(OUT,fill=TRUE)
BHPS[, jbsic := as.character(jbsic)]

setnames(BHPS, "fimnb", "fimnsben_dv")
BHPS <-BHPS[!is.na(istrtdaty)]

BHPS <-BHPS[order(pidp, istrtdaty)]

##
BHPS[, wavechar := gsub("/|_","",str_extract(file, "/([a-z]{1,2})_")) ]
BHPS<-join(BHPS, BHPS[, .N, by=wavechar][order(wavechar)][, list(wavechar, wavenum=2:18 )])



BHPS[, sex := tolower(sex)]
BHPS[, year := istrtdaty]
BHPS<-BHPS[year>=1995]





MAP<-data.table(read.csv(file="/Users/thiemo/Dropbox/Research/Austerity and Brexit/USOC/comb/SIC2003-SIC2007.csv"))

BHPS[is.na(jbsic92) & !is.na(jbsic), jbsic92  := jbsic]

SIC<-BHPS[, .N, by= jbsic92][order(N,decreasing=TRUE)]



SIC[, SEC := substr(jbsic92,1,2)]

SIC[nchar(jbsic92)==3, SEC := substr(jbsic92,1,1)]

SIC[, ncharSIC := nchar(jbsic92)]
SIC <-SIC[order(jbsic92)]

MAP[nchar(SIC.2003_CODE)==5, SIC2003_SEC := substr(SIC.2003_CODE,1,2)]
MAP[nchar(SIC.2003_CODE)==4, SIC2003_SEC := substr(SIC.2003_CODE,1,1)]

MAP[nchar(SIC.2007_CODE)==5, SIC2007_SEC := substr(SIC.2007_CODE,1,2)]
MAP[nchar(SIC.2007_CODE)==4, SIC2007_SEC := substr(SIC.2007_CODE,1,1)]

MAP.SECTION<-DTUniqueBy(MAP[, .N, by=c("SIC2003_SEC","SIC2007_SEC")][order(N, decreasing=TRUE)],"SIC2003_SEC")

SIC<-join(SIC, MAP.SECTION[, list(SEC= SIC2003_SEC, SIC2007_SEC)])
SIC[, SIC2007_SEC := as.numeric(SIC2007_SEC)]

SIC[SIC2007_SEC >= 1 &SIC2007_SEC<=3,  SIC2007Section := "Agriculture, Forestry and Fishing"]
SIC[SIC2007_SEC >= 5 &SIC2007_SEC<=9,  SIC2007Section := "Mining and Quarrying"]
SIC[SIC2007_SEC >= 10 &SIC2007_SEC<=33,  SIC2007Section := "Manufacturing"]
SIC[SIC2007_SEC >= 35 &SIC2007_SEC<=35,  SIC2007Section := "Electricity, Gas, Steam and Air Conditioning Supply"]
SIC[SIC2007_SEC >= 36 &SIC2007_SEC<=39,  SIC2007Section := "Water Supply; Sewerage, Waste Management and Remediation Activities"]
SIC[SIC2007_SEC >= 41 &SIC2007_SEC<=43,  SIC2007Section := "Construction"]
SIC[SIC2007_SEC >= 45 &SIC2007_SEC<=47,  SIC2007Section := "Wholesale and Retail Trade"]
SIC[SIC2007_SEC >= 49 &SIC2007_SEC<=53,  SIC2007Section := "Transportation and Storage"]
SIC[SIC2007_SEC >= 55 &SIC2007_SEC<=56,  SIC2007Section := "Accommodation and Food Service Activities"]
SIC[SIC2007_SEC >= 58 &SIC2007_SEC<=63,  SIC2007Section := "Information and Communication"]
SIC[SIC2007_SEC >= 64 &SIC2007_SEC<=66,  SIC2007Section := "Financial and Insurance Activities"]
SIC[SIC2007_SEC >= 68 &SIC2007_SEC<=68,  SIC2007Section := "Real Estate Activities"]

SIC[SIC2007_SEC >= 69 &SIC2007_SEC<=75,  SIC2007Section := "Professional, Scientific and Technical Activities"]
SIC[SIC2007_SEC >= 77 &SIC2007_SEC<=82,  SIC2007Section := "Administrative and Support Service Activities"]
SIC[SIC2007_SEC >= 84 &SIC2007_SEC<=84,  SIC2007Section := "Public Administration and Defence; Compulsory Social Security"]
SIC[SIC2007_SEC >= 85 &SIC2007_SEC<=85,  SIC2007Section := "Education"]
SIC[SIC2007_SEC >= 86 &SIC2007_SEC<=88,  SIC2007Section := "Human Health and Social Work Activities"]
SIC[SIC2007_SEC >= 90 &SIC2007_SEC<=93,  SIC2007Section := "Arts, Entertainment and Recreation"]
SIC[SIC2007_SEC >= 94 &SIC2007_SEC<=96,  SIC2007Section := "Other Service Activities"]
SIC[SIC2007_SEC >= 97 &SIC2007_SEC<=98,  SIC2007Section := "Activities of Households as Employers"]
SIC[SIC2007_SEC >= 99 &SIC2007_SEC<=99,  SIC2007Section := "Activities of Households as Employers"]

BHPS<-join(BHPS, SIC[, list(jbsic92, SIC2007Section)])



JBSTAT<-data.table(read.csv(file="/JBSTAT.csv"))

BHPS<-join(BHPS, JBSTAT[, list(jbstatl=jbstat, 	jbstat_sd)])



for(var in c("tenure_dv","sex")) {
setnames(BHPS, var, "temp")
BHPS[, temp := tolower(as.character(preProcess(temp)))]
setnames(BHPS, "temp",var)
}

BHPS[tenure_dv =="local authority rented",  tenure_dv := "local authority rent"]
BHPS[tenure_dv =="other rented",  tenure_dv := "other"]
BHPS[tenure_dv =="missing or wild",  tenure_dv := "missing"]


BHPS[hiqual_dv %in% c("Other higher degree","Degree"), hiqual_sd := "level4"]
BHPS[hiqual_dv %in% c("A-level etc"), hiqual_sd := "level3"]
BHPS[hiqual_dv %in% c("A-level etc"), hiqual_sd := "level3"]

QUAL<-data.table(read.csv(file="/Users/thiemo/Dropbox/Research/Austerity and Brexit/USOC/stata11_se/HH.QUAL.csv"))

BHPS<-join(BHPS, QUAL)

BHPS[istrtdatm=="December", month := 12]
BHPS[istrtdatm=="November", month := 11]
BHPS[istrtdatm=="October", month := 10]
BHPS[istrtdatm=="September", month := 9]
BHPS[istrtdatm=="August", month := 8]
BHPS[istrtdatm=="July", month := 7]
BHPS[istrtdatm=="June", month := 6]
BHPS[istrtdatm=="May", month := 5]
BHPS[istrtdatm=="April", month := 4]
BHPS[istrtdatm=="March", month := 3]
BHPS[istrtdatm=="February", month := 2]
BHPS[istrtdatm=="January", month := 1]


BHPS <-BHPS[order(pidp, wavenum)]


BHPS[,quarter := 1]
BHPS[month>3 & month<=6,quarter := 2]
BHPS[month>6 & month<=9,quarter := 3]
BHPS[month>9 & month<=12,quarter := 4]
  

BHPS<-BHPS[, c("file","wavechar","wavenum","pidp","hidp","pid","hid","pno","year","quarter","month","sex","fimnlabgrs_dv","fimngrs_dv","fimnsben_dv","finnow_sd","vote1","vote2","vote3","vote4","opeur1","opeur2","opeur3","jbnssec8_dv","jbstat_sd","hiqual_dv","hiqual_dv_sd","hiqual_dv_sd_num","SIC2007Section","tenure_dv","bprxy_cb","bprxy_ctc","bprxy_dla_pip","bprxy_hbcbrr","bprxy_housingben","bprxy_incap","bprxy_incomesupport","bprxy_unemploy","bprxy_wtc"),with=F]
BHPS<-BHPS[wavenum>=11]

#LOCAL AHTORITIES
LAD<-readFiles("/Users/thiemo/Dropbox/Research/Austerity and Brexit/USOC/UKDA-6027-stata11/stata11/", ftype="dta", collate="list")
LAD<-lapply(LAD, function(x) x[, wave:= paste("b",substr(names(x)[1],1,1),sep="")])
LAD<-lapply(LAD, function(x) setnames(x,names(x), c("hid","oslaua","wavechar")))

LAD<-rbindlist(LAD)
BHPS <-join(BHPS, LAD)

setnames(BHPS, "oslaua","code")



#write.dta(BHPS, file="../../BHPS.dta")

load("/Users/thiemo/Dropbox/Research/Austerity and Brexit/USOC/stata11_se/HH.PAN.USOC.rdata")

TEMP<-rbind(HH.PAN[, intersect(names(HH.PAN),names(BHPS)), with=F], BHPS[, intersect(names(HH.PAN),names(BHPS)), with=F])


PARTIES<-data.table(read.csv(file="/Users/thiemo/Dropbox/Research/Austerity and Brexit/USOC/stata11_se/PARTY.CLOSEST.TO.csv"))

TEMP<- join(TEMP, PARTIES[, list(vote4, partystandardizevote4= X)])

TEMP<- join(TEMP, PARTIES[, list(vote3=vote4, partystandardizevote3= X)])


for(var in c("bprxy_cb","bprxy_ctc","bprxy_dla_pip","bprxy_hbcbrr","bprxy_housingben","bprxy_incap","bprxy_incomesupport","bprxy_unemploy","bprxy_wtc")) {

setnames(TEMP, var, "temp")
TEMP[temp %in% c("mentioned","yes"), temp := 1]
TEMP[temp %in% c("not mentioned","inapplicable","no"), temp := 0]

TEMP[, temp := as.numeric(temp)]

setnames(TEMP,  "temp",var)

}


TEMP[, region := substr(code, 1,2)]
TEMP<-TEMP[nchar(code)>4] 
TEMP[, BHPSSAMPLE := as.numeric(pidp %in% BHPS[,.N, by=pidp]$pidp)]

TEMP[, partystandardizevote3 := as.character(partystandardizevote3)]
TEMP[, partystandardizevote4 := as.character(partystandardizevote4)]

write_dta(TEMP, path="../USOCBHPSCOMB.dta")



HH.PAN<- join(HH.PAN, PARTIES[, list(vote8=vote4, partystandardizevote8= X)])




DTUniqueBy(BHPS,c("pidp","istrtdaty"))[, list(min(istrtdaty), max(istrtdaty), yrsbet= max(istrtdaty)-min(istrtdaty),.N), by=c("pidp")][N==yrsbet]


OUT<-NULL

for(i in 19:length(DAT)) {
cat(i, " ")
sub<-gsub("/|_","",str_extract(ffs[i], "/([a-z]{1,2})_")) 

TEMP<-DAT[[i]]
setnames(TEMP, names(TEMP), gsub(paste(sub,"_",sep=""),"", names(TEMP)))

VARS<-c(grep("^pno|^pidp|^pid|^hid|^sex|^istrtdat|^hiqual_dv$|^fimnb$|^fimngrs_dv|^vote1$|^vote2$|^vote3$|^vote4$|tenure_dv|jbstatl|mrjrgsc|mlstat_bh|jbsic|hlstat",names(TEMP),value=TRUE))

OUT[[i]]<-data.table(file=ffs[i], TEMP[, VARS,with=F])

}
USOC<-rbindlist(OUT,fill=TRUE)


PARTIES<-data.table(read.csv(file="~/Dropbox/Research/Austerity and Brexit/USOC/stata11_se/PARTY.CLOSEST.TO.csv"))
USOC <-join(USOC, PARTIES[, list(vote4=vote4, vote4_sd=X)])

USOC[vote4_sd=="", vote4_sd:=NA]
USOC[!is.na(vote4_sd), ukipother := as.numeric(vote4_sd %in% c("ukip","bnp","other"))]
USOC <-join(USOC, PARTIES[, list(vote3=vote4, vote3_sd=X)])

USOC[vote3_sd=="", vote3_sd:=NA]
USOC[!is.na(vote3_sd), ukipothervote := as.numeric(vote3_sd %in% c("ukip","bnp","other"))]

USOC[!is.na(vote4_sd), vote34_sd_comb := vote4_sd]
USOC[!is.na(vote3_sd), vote34_sd_comb := vote3_sd]

USOC[, ukipeither := as.numeric(vote34_sd_comb %in% c("ukip","bnp","other"))]

UKIPSUPPORTER<-DTUniqueBy(USOC[ukipeither==1][order(pidp, istrtdaty)],"pidp")
NONUKIPSUPPORTER<-DTUniqueBy(USOC[ukipeither==0][order(pidp, istrtdaty)],"pidp")[pidp %!in% UKIPSUPPORTER$pidp]


BOTH<-rbind(UKIPSUPPORTER, NONUKIPSUPPORTER)

BOTH<-BOTH[, list(pidp, ukipeither)]

BHPS.USOC<-join(BHPS, BOTH)[!is.na(ukipeither)]

DTUniqueBy(BHPS.USOC,c("pidp","istrtdaty"))[, list(min(istrtdaty), max(istrtdaty), yrsbet= max(istrtdaty)-min(istrtdaty),.N), by=c("pidp")][N==yrsbet]



#^btype|perpolinf|perbfts|grpbfts|voteintent|polef|^btype|^f1|

OUT <-lapply(OUT, function(x) Setnames(x, c("fimngrs_dv","fimnb","jbsec_bh","jbft","njusp","njisp","fisitx","jbsic92"), c("fimngrs_dv","fimnsben_dv","jbnssec8_dv","jbft_dv","nunmpsp_dv","nnmpsp_dv","finfut","jbsic"), allow.absent.cols=TRUE))

OUT<-data.table(rbindlist(OUT,fill=TRUE))
OUT <-OUT[order(pidp, istrtdaty)]


OUT[, finnow := tolower(as.character(finnow))]
FIN<-data.table(read.csv(file="~/Dropbox/Research/Sascha and Thiemo/Austerity and Migration/USOC/comb/FINNOW.csv"))
OUT <-join(OUT, FIN)
OUT[finnow_sd=="", finnow_sd :=NA]
OUT[, finnow := NULL]

OUT[, finfut := tolower(as.character(finfut))]
FINFUT<-data.table(read.csv(file="~/Dropbox/Research/Sascha and Thiemo/Austerity and Migration/USOC/comb/FINFUT.csv"))

OUT <-join(OUT, FINFUT)
OUT[finfut_sd=="", finfut_sd :=NA]
OUT[finfut_num=="", finfut_num :=NA]
OUT[, finfut_num := as.numeric(finfut_num)]
OUT[, finfut := NULL]


QUAL<-data.table(read.csv(file="~/Dropbox/Research/Sascha and Thiemo/Austerity and Migration/USOC/comb/HH.QUAL.csv"))

OUT<-join(OUT, QUAL)
OUT[hiqual_dv_sd=="", hiqual_dv_sd :=NA]
OUT[hiqual_dv_sd_num=="", hiqual_dv_sd_num :=NA]
OUT[, hiqual_dv_sd_num := as.numeric(hiqual_dv_sd_num)]
OUT[, hiqual_dv := NULL]


OUT[, vote3 := tolower(as.character(vote3))]
OUT[, vote4 := tolower(as.character(vote4))]

PARTIES<-data.table(read.csv(file="~/Dropbox/Research/Sascha and Thiemo/Austerity and Migration/USOC/comb/PARTY.CLOSEST.TO.csv"))

OUT <-join(OUT, PARTIES[, list(vote4=vote, vote4_sd=sd_vote)])
OUT[vote4_sd=="", vote4_sd:=NA]
OUT[!is.na(vote4_sd), ukipother := as.numeric(vote4_sd %in% c("ukip","bnp","other"))]

OUT <-join(OUT, PARTIES[, list(vote3=vote, vote3_sd=sd_vote)])
OUT[vote3_sd=="", vote3_sd:=NA]

OUT[!is.na(vote3_sd), ukipother_vote3 := as.numeric(vote3_sd %in% c("ukip","bnp","other"))]

OUT[, sex := tolower(as.character(sex))]

OUT[, istrtdatm := tolower(as.character(istrtdatm))]
OUT[istrtdatm %in% c("january","1"), month:= 1]
OUT[istrtdatm %in% c("february","2"), month:= 2]
OUT[istrtdatm %in% c("march","3"), month:= 3]
OUT[istrtdatm %in% c("april","4"), month:= 4]
OUT[istrtdatm %in% c("may","5"), month:= 5]
OUT[istrtdatm %in% c("june","6"), month:= 6]
OUT[istrtdatm %in% c("july","7"), month:= 7]
OUT[istrtdatm %in% c("august","8"), month:= 8]
OUT[istrtdatm %in% c("september","9"), month:= 9]
OUT[istrtdatm %in% c("october","10"), month:= 10]
OUT[istrtdatm %in% c("november","11"), month:= 11]
OUT[istrtdatm %in% c("december","12"), month:= 12]

OUT[ , istrtdatm := NULL]

setnames(OUT, "istrtdaty", "year")
OUT[, year := as.numeric(as.character(year))]
OUT[year<0, year := NA]
OUT<-OUT[!is.na(year)]


##GHQ


for(var in c("scghqa","scghqb","scghqc","scghqd","scghqe","scghqf","scghqg","scghqh","scghqi","scghqj","scghqk","scghql")) {

setnames(OUT, var, "temp")
OUT[, temp := tolower(as.character(temp))]

OUT[temp %in% c("missing or wild","not answered","proxy and or phone","missing","refusal","don't know","refused","inapplicable", "proxy","proxy respondent"), temp := NA]

setnames(OUT, "temp", var)

}

for(var in c("scghqb","scghqe","scghqf","scghqi","scghqj","scghqk")) {

setnames(OUT, var, "temp")
OUT[, temp := tolower(as.character(temp))]
OUT[, temp_num := temp]
OUT[temp_num =="not at all", temp_num := 1]
OUT[temp_num =="no more than usual", temp_num := 2]
OUT[temp_num =="no more thn usual", temp_num := 2]
OUT[temp_num =="rather more", temp_num := 3]
OUT[temp_num =="rather more thn usul", temp_num := 3]
OUT[temp_num =="rather more than usual", temp_num := 3]
OUT[temp_num =="much more than usual", temp_num := 4]
OUT[temp_num =="much more", temp_num := 4]

setnames(OUT, "temp", var)

setnames(OUT, "temp_num", paste(var,"_num",sep=""))

}


OUT<-OUT[year>=2000]








##measure type of benefit receipts

ffs<-grep("income.dta", ffsa, value=TRUE)


if(!file.exists("INC.rdata")) {
INC<-lapply(ffs, function(x) data.table(read.dta(file=x)))
} else {
load('~/Dropbox/Research/Sascha and Thiemo/Austerity and Migration/USOC/comb/INC.rdata')
}

OUI<-NULL

for(i in 1:length(INC)) {
cat(i, " ")
sub<-gsub("/|_","",str_extract(ffs[i], "/([a-z]{1,2})_")) 

TEMP<-INC[[i]]
setnames(TEMP, names(TEMP), gsub(paste(sub,"_",sep=""),"", names(TEMP)))

VARS<-c(grep("^pno|^pidp|^pid|^hid|hidp|^fim05t|^ficode|^frmnth_dv",names(TEMP),value=TRUE))

OUI[[i]]<-data.table(file=ffs[i], TEMP[, VARS,with=F])

}


OUI <-lapply(OUI, function(x) Setnames(x, c("fim05t","ficode_bh"), c("frmnth_dv","ficode"), allow.absent.cols=TRUE))

OUI<-data.table(rbindlist(OUI,fill=TRUE))

OUI[, ficode := tolower(as.character(ficode))]

FICODES<-data.table(read.csv(file="~/Dropbox/Research/Sascha and Thiemo/Austerity and Migration/USOC/comb/FICODES.csv"))
OUI<-join(OUI, FICODES)

OUI[, wave := gsub("_income.dta", "", file)]
OUI[frmnth_dv>=0 & frmnth_dv<100000][, list(frmnth_dv=sum(frmnth_dv, na.rm=TRUE)), by=c("pidp","hidp", "pno","ficodes_sd_coarse","wave")][pidp=="341684365"][ficodes_sd_coarse=="housing benefit"]



FICODE<-data.table(read.csv(file="~/Dropbox/Research/Sascha and Thiemo/Austerity and Migration/USOC/stata11_se/FICODE.csv"))
FICODE<-FICODE[!is.na(ficode_num)]

FICODE.POP<-OUI[, .N, by=ficode]
FICODE.POP1<-FICODE.POP[nchar(ficode)>3]

FICODE.POP2<-FICODE.POP[nchar(ficode)<3]
FICODE.POP2 <-join(FICODE.POP2[, list(ficode_num= ficode)], FICODE)[!is.na(ficode)]

FICODES<-rbind(FICODE.POP1[, list(ficode, ficodesd=ficode)], FICODE.POP2[, list(ficode=ficode_num, ficodesd=ficode)])
FICODES[, ficodes_sd := str_trim(tolower(ficodesd))]
FICODES[, ficodesd := NULL]



