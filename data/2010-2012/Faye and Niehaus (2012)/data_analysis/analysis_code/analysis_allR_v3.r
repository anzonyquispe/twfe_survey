
### Setup ##################################################################################################

    rm(list=ls())
    input.dir <- c("~/Ec Projects/completed/PAC/submission/aer/data_analysis/data")
    setwd("~/Ec Projects/completed/PAC/submission/aer/data_analysis/analysis_code")
    output.dir <- c("~/Ec Projects/completed/PAC/submission/aer/data_analysis/output")
    figure.dir <- c("~/Ec Projects/completed/PAC/submission/aer/data_analysis/output")
    source("[2008.08.01][v4] reg_helper_functions.r")
    source("lib_multiregtable.r")
    source("lib_hacktex.r")
    library(Design)
    library(dummies)

### Helper Functions for Constructing Analysis Datasets ######################################################

    # drop observations that are missing vars in varlist
    # note that varlist should include "p" and "year"
    estsample <- function(data, varlist){
    
        # strip out obs with missing values
        missing <- rep(0, nrow(data))
        for (v in varlist){
            missing <- missing + as.numeric(is.na(data[,v]))
        }
        data <- data[missing==0,]
        
        # then strip out any paircode series with gaps
        data$minyear <- ave(data$year, data$p[,drop=TRUE], FUN=min)
        data$maxyear <- ave(data$year, data$p[,drop=TRUE], FUN=max)
        data$pobs <- ave(data$year, data$p[,drop=TRUE], FUN=NROW)
        return(data[(data$maxyear - data$minyear + 1 == data$pobs),varlist])
        data$minyear <- NULL
        data$maxyear <- NULL
        data$pobs <- NULL
    }
    
    # demean a dataset (assumes it has no missing values)
    demean <- function(data, dmfactor, skip=c()){
        skip <- c(skip, dmfactor)
        usenames <- setdiff(names(data), skip)
        for (v in usenames){
            data[,v] <- data[,v] - ave(data[,v], data[,dmfactor], FUN=mean)
        }
        return(data)
    }

#################### Variable Labels #################################################

    varlabels <- pairlist("i_elecex"                 = "Exec. Election",
                          "pop"                      = "Population",
                          "gdp2000"                  = "GDP",
                          "pop_donor"                = "Population (Donor)",
                          "gdp2000_donor"            = "GDP (Donor)",
                          "unvotes"                  = "UN Agreement",
                          "p_unvotes_elecex"         = "UN * Election",
                          "unvotes_rt"               = "UN Donor Avg.",
                          "unvotes_resid"            = "UN Residual",
                          "p_unvotes_rt_elecex"      = "UN Avg. * Election",
                          "p_unvotes_resid_elecex"   = "UN Residual * Election",
                          "noncomp"                  = "Noncompetitive",
                          "p_unvotes_noncomp"        = "UN * Noncompetitive",
                          "i_elecex_comp"            = "Competitive Election",
                          "i_elecex_noncomp"         = "Noncompetitive Election",
                          "p_unvotes_elecex_comp"    = "UN * Competitive Election",
                          "p_unvotes_elecex_noncomp" = "UN * Noncompetitive Election")
                          
### Load Data ################################################################################################

    # load source file and clean it up
    data <- read.csv(paste(input.dir, "111102_oda_final_data_big5_commit_080107_unvotes_term.csv", sep="/"))
    data$p <- interaction(data$wbcode_donor, data$wbcode_recipient, drop=TRUE)
    names(data)[names(data)=="wbcode_recipient"] <- "r"
    names(data)[names(data)=="wbcode_donor"] <- "d"
    
    # toggle use of disbursements rather than commitments
    #data$oda <- data$odaPair_disburse
    #output.dir <- c("C:/Ec Projects/PAC/latex_tables/disburse")

### Basic Facts about the Data ################################################################################

    # panel dimensions
    nrow(table(data$year))
    nrow(table(data$r))
    nrow(data) / nrow(table(interaction(data$d, data$year)))

    # 116 recipients, of which 71 had at least one executive election
    table(tapply(data$i_elecex, data$r, max))
    
    # 64 of the 71 countries holding at least one election have voting results for at least one
    table(tapply(data$i_elecex[!is.na(data$i_far_pct)], data$r[!is.na(data$i_far_pct)], max))
    
    # trend
    mean(data$i_elecex[!duplicated(data[,c("r","year")])])
    robcov(ols(i_elecex ~ year + as.factor(r), data=data[!duplicated(data[,c("r","year")]),],x=T,y=T), data$r[!duplicated(data[,c("r","year")])])
    0.002219 / 0.08945
    
    # 274 elections
    # 105 of 274 are competitive by the EIEC measure
    # 73 of 225 are competitive by the percent measure
    # correlation between the measures is 0.50
    NROW(unique(data[data$i_elecex==1, c("r","year")]))
    table(data$i_far_eiec[!duplicated(data[,c("r","year")]) & data$i_elecex==1])
    table(data$i_far_pct[!duplicated(data[,c("r","year")]) & data$i_elecex==1])
    with(data[!duplicated(data[,c("r","year")]) & data$i_elecex==1,],{
        print(cor(i_far_eiec, i_far_pct, use="complete.obs"))
    })

### Summary Statistics ########################################################################################

    # function
    sstats <- function(vec){
        return(c(sum(as.numeric(!is.na(vec))), roundsig(mean(vec, na.rm=TRUE),2),roundsig(sd(vec, na.rm=TRUE),2)))
    }

    # DYR level
    sstab <- matrix(nrow=7, ncol=4)
    sstab[1,] <- c("ODA", sstats(data$oda))
    sstab[2,] <- c("UN Alignment", sstats(data$unvotes))
    
    # RY level
    sstab[3,] <- c("Election", sstats(data$i_elecex[!duplicated(data[,c("r","year")])]))
    sstab[4,] <- c("GDP", sstats(data$gdp2000[!duplicated(data[,c("r","year")])]))
    sstab[5,] <- c("Population", sstats(data$pop[!duplicated(data[,c("r","year")])]))
    
    # DY level
    sstab[6,] <- c("GDP (Donor)", sstats(data$gdp2000_donor[!duplicated(data[,c("d","year")])]))
    sstab[7,] <- c("Population (Donor)", sstats(data$pop_donor[!duplicated(data[,c("d","year")])]))
    
    # output
    result <- hacktex(sstab, 
                    file=paste(output.dir, "sumstats_new.tex", sep="/"),
                    label="tab:sumstats_new",
                    table.env=FALSE,
                    caption.loc="top",
                    center="none",
                    rowlabel="",
                    rowname=rep("",7),
                    rgroup=c("Donor/Recipient/Year Level","Recipient/Year Level","Donor/Year Level"),
                    n.rgroup=c(2,3,2),
                    colheads=c("Variable","$N$","Mean","Standard Deviation"),
                    collabel.just=c("l","c","c","c"))
                    
### Mean ODA by Recipient #####################################################################################
    
    odameans <- tapply(data$oda, data$r, FUN=mean)
    odameans <- data.frame(odamean=as.numeric(odameans), r=names(odameans))
    odatotals <- tapply(data$oda, data$r, FUN=sum)
    odatotals <- data.frame(odatotal=as.numeric(odatotals), r=names(odatotals))
    odastats <- merge(odatotals, odameans, by=c("r"))
    odastats <- odastats[order(odastats$odatotal, decreasing = TRUE),]
    odastats$r <- as.character(odastats$r)
    odastats$odatotal <- format(round(odastats$odatotal), big.mark=",", big.interval=3)
    odastats$odamean <- format(round(odastats$odamean), big.mark=",", big.interval=3)
    
    odastatsflat <- cbind(odastats[1:39,], odastats[40:78,], rbind(odastats[79:116,], c("","","")))
    
    # output
    result <- hacktex(odastatsflat, 
                    file=paste(output.dir, "odastats_recipient.tex", sep="/"),
                    label="tab:odastats_recipient",
                    table.env=FALSE,
                    caption.loc="top",
                    center="none",
                    rowlabel="",
                    rowname=NULL,
                    col.just=c("|l","r","r|","l","r","r|","l","r","r|"),
                    colheads=c("Recip.","Total ODA","Mean ODA","Recip.","Total ODA","Mean ODA","Recip.","Total ODA","Mean ODA"),
                    collabel.just=c("l","c","c","l","c","c","l","c","c"))
    
### Regressions with Base Data ################################################################################

    # construct the base dataset
    data.base <- estsample(data, c("unvotes","i_elecex","p_unvotes_elecex","unvotes_rt","unvotes_resid","p_unvotes_rt_elecex","p_unvotes_resid_elecex","oda","p","d","r","year"))
    data.base$d <- as.numeric(factor(data.base$d))
    data.base$r <- as.numeric(factor(data.base$r))
    data.base$yeardum <- data.base$year
    data.base <- dummy.data.frame(data.base, names="yeardum")
    data.base$donoryeardum <- as.numeric(interaction(data.base$d, data.base$year, drop=TRUE))
    data.base <- dummy.data.frame(data.base, names="donoryeardum")
    data.base <- demean(data.base, "p", skip=c("d","r","year"))
    
    # identify the range of years and recipients to use
    yeardums <- paste("yeardum",1975:2003,sep="")
    donoryeardums <- paste("donoryeardum",1:145,sep="")
    
    # run the regressions
    fm.main.I <- ols(as.formula(paste("oda ~ i_elecex", paste(yeardums,collapse="+"), sep="+")), data=data.base,x=T,y=T)
    fm.main.II <- ols(as.formula(paste("oda ~ i_elecex", paste(donoryeardums,collapse="+"), sep="+")), data=data.base,x=T,y=T)
    fm.main.IV <- ols(as.formula(paste("oda ~ unvotes + i_elecex + p_unvotes_elecex", paste(yeardums,collapse="+"), sep="+")), data=data.base,x=T,y=T)
    fm.main.V <- ols(as.formula(paste("oda ~ unvotes + i_elecex + p_unvotes_elecex", paste(donoryeardums,collapse="+"), sep="+")), data=data.base,x=T,y=T)
    fm.main.VII <- ols(as.formula(paste("oda ~ unvotes_rt + unvotes_resid + i_elecex + p_unvotes_rt_elecex + p_unvotes_resid_elecex", paste(yeardums,collapse="+"), sep="+")), data=data.base,x=T,y=T)
    fm.main.VIII <- ols(as.formula(paste("oda ~ unvotes_rt + unvotes_resid + i_elecex + p_unvotes_rt_elecex + p_unvotes_resid_elecex", paste(donoryeardums,collapse="+"), sep="+")), data=data.base,x=T,y=T)
    
    # adjust variances
    fm.main.I$var <- mwc_3way(fm.main.I, data.base$d, data.base$r, data.base$year)
    fm.main.II$var <- mwc_3way(fm.main.II, data.base$d, data.base$r, data.base$year)
    fm.main.IV$var <- mwc_3way(fm.main.IV, data.base$d, data.base$r, data.base$year)
    fm.main.V$var <- mwc_3way(fm.main.V, data.base$d, data.base$r, data.base$year)
    fm.main.VII$var <- mwc_3way(fm.main.VII, data.base$d, data.base$r, data.base$year)
    fm.main.VIII$var <- mwc_3way(fm.main.VIII, data.base$d, data.base$r, data.base$year)
    
    # standardized effect sizes
    2 * sd(data$unvotes) * coefficients(fm.main.IV)["p_unvotes_elecex"]
    2 * sd(data$unvotes) * coefficients(fm.main.IV)["p_unvotes_elecex"] / mean(data$oda)
    coefficients(fm.main.IV)["i_elecex"] + (mean(data$unvotes) - sd(data$unvotes)) * coefficients(fm.main.IV)["p_unvotes_elecex"]
    coefficients(fm.main.IV)["i_elecex"] + (mean(data$unvotes) + sd(data$unvotes)) * coefficients(fm.main.IV)["p_unvotes_elecex"]
        
### Regressions with Controls ###################################################################################

    # keep variable set; drop series with gaps in their controls
    data.cont <- estsample(data, c("unvotes","i_elecex","p_unvotes_elecex","unvotes_rt","unvotes_resid","p_unvotes_rt_elecex","p_unvotes_resid_elecex","oda","p","d","r","year","gdp2000","pop","gdp2000_donor","pop_donor"))
    data.cont <- demean(data.cont, "p", skip=c("d","r","year")) 
    
    # regressions
    fm.main.III <- ols(oda ~ i_elecex + pop + gdp2000 + pop_donor + gdp2000_donor, data=data.cont,x=T,y=T)
    fm.main.VI <- ols(oda ~ unvotes + i_elecex + p_unvotes_elecex + pop + gdp2000 + pop_donor + gdp2000_donor, data=data.cont,x=T,y=T)
    fm.main.IX <- ols(oda ~ unvotes_rt + unvotes_resid + i_elecex + p_unvotes_rt_elecex + p_unvotes_resid_elecex + pop + gdp2000 + pop_donor + gdp2000_donor, data=data.cont,x=T,y=T)
    
    # adjust variances
    fm.main.III$var <- mwc_3way(fm.main.III, data.cont$d, data.cont$r, data.cont$year)
    fm.main.VI$var <- mwc_3way(fm.main.VI, data.cont$d, data.cont$r, data.cont$year)
    fm.main.IX$var <- mwc_3way(fm.main.IX, data.cont$d, data.cont$r, data.cont$year)
    
### Voting Competitiveness Regressions #######################################################################

    # construct the dataset (drop pairs with only one observation)
    data.compv <- estsample(data, c("unvotes","i_elecex","p_unvotes_elecex","oda","i_far_pct","p","d","r","year"))
    data.compv <- data.compv[!ave(data.compv$year, data.compv$p, FUN=NROW)==1,]
    data.compv$d <- as.numeric(factor(data.compv$d))
    data.compv$r <- as.numeric(factor(data.compv$r))
    
    # create new interactions
    data.compv$noncomp <- data.compv$i_far_pct
    data.compv$i_elecex_comp <- data.compv$i_elecex * (1 - data.compv$noncomp)
    data.compv$i_elecex_noncomp <- data.compv$i_elecex * data.compv$noncomp
    data.compv$p_unvotes_elecex_comp <- data.compv$unvotes * data.compv$i_elecex_comp
    data.compv$p_unvotes_elecex_noncomp <- data.compv$unvotes * data.compv$i_elecex_noncomp
    data.compv$p_unvotes_noncomp <- data.compv$unvotes * data.compv$noncomp
    
    # dummies and de-meaning
    data.compv$yeardum <- data.compv$year
    data.compv <- dummy.data.frame(data.compv, names="yeardum")
    data.compv$donoryeardum <- as.numeric(interaction(data.compv$d, data.compv$year, drop=TRUE))
    data.compv <- dummy.data.frame(data.compv, names="donoryeardum")
    data.compv <- demean(data.compv, "p", skip=c("d","r","year")) 
    
    # identify the range of years and recipients to use
    yeardums <- paste("yeardum",1975:2002,sep="")
    donoryeardums <- paste("donoryeardum",1:140,sep="")
    
    # regressions
    fm.comp.I <- ols(as.formula(paste("oda ~ unvotes + noncomp + p_unvotes_noncomp + i_elecex_comp + p_unvotes_elecex_comp + i_elecex_noncomp + p_unvotes_elecex_noncomp",
                                    paste(yeardums,collapse="+"), sep="+")), data=data.compv,x=T,y=T)
    fm.comp.II <- ols(as.formula(paste("oda ~ unvotes + noncomp + p_unvotes_noncomp + i_elecex_comp + p_unvotes_elecex_comp + i_elecex_noncomp + p_unvotes_elecex_noncomp",
                                    paste(donoryeardums,collapse="+"), sep="+")), data=data.compv,x=T,y=T)
    
    # adjust variances
    fm.comp.I$var <- mwc_3way(fm.comp.I, data.compv$d, data.compv$r, data.compv$year)
    fm.comp.II$var <- mwc_3way(fm.comp.II, data.compv$d, data.compv$r, data.compv$year)

### Voting Competitiveness Regressions w/ Controls ##############################################################

    # construct the dataset (drop pairs with only one observation)
    data.compvc <- estsample(data, c("unvotes","i_elecex","p_unvotes_elecex","oda","i_far_pct","p","d","r","year","gdp2000","pop","gdp2000_donor","pop_donor"))
    data.compvc <- data.compvc[!ave(data.compvc$year, data.compvc$p, FUN=NROW)==1,]
    data.compvc$d <- as.numeric(factor(data.compvc$d))
    data.compvc$r <- as.numeric(factor(data.compvc$r))
    
    # create new interactions
    data.compvc$noncomp <- data.compvc$i_far_pct
    data.compvc$i_elecex_comp <- data.compvc$i_elecex * (1 - data.compvc$noncomp)
    data.compvc$i_elecex_noncomp <- data.compvc$i_elecex * data.compvc$noncomp
    data.compvc$p_unvotes_elecex_comp <- data.compvc$unvotes * data.compvc$i_elecex_comp
    data.compvc$p_unvotes_elecex_noncomp <- data.compvc$unvotes * data.compvc$i_elecex_noncomp
    data.compvc$p_unvotes_noncomp <- data.compvc$unvotes * data.compvc$noncomp
    
    # de-meaning
    data.compvc <- demean(data.compvc, "p", skip=c("d","r","year")) 
 
    # regressions
    fm.comp.III <- ols(oda ~ unvotes + noncomp + p_unvotes_noncomp + i_elecex_comp + p_unvotes_elecex_comp + i_elecex_noncomp + p_unvotes_elecex_noncomp
                                + gdp2000 + pop + gdp2000_donor + pop_donor, data=data.compvc,x=T,y=T)
    
    # adjust variances
    fm.comp.III$var <- mwc_3way(fm.comp.III, data.compvc$d, data.compvc$r, data.compvc$year)

### EIEC Competitiveness Regressions #########################################################################

    # construct the dataset (drop pairs with only one observation)
    data.compe <- estsample(data, c("unvotes","i_elecex","p_unvotes_elecex","oda","i_far_eiec","p","d","r","year"))
    data.compe <- data.compe[!ave(data.compe$year, data.compe$p, FUN=NROW)==1,]
    data.compe$wbcode_r <- data.compe$r
    data.compe$d <- as.numeric(factor(data.compe$d))
    data.compe$r <- as.numeric(factor(data.compe$r))
    
    # create new interactions
    data.compe$noncomp <- data.compe$i_far_eiec
    data.compe$i_elecex_comp <- data.compe$i_elecex * (1 - data.compe$noncomp)
    data.compe$i_elecex_noncomp <- data.compe$i_elecex * data.compe$noncomp
    data.compe$p_unvotes_elecex_comp <- data.compe$unvotes * data.compe$i_elecex_comp
    data.compe$p_unvotes_elecex_noncomp <- data.compe$unvotes * data.compe$i_elecex_noncomp
    data.compe$p_unvotes_noncomp <- data.compe$unvotes * data.compe$noncomp
    
    # dummies and de-meaning
    data.compe$yeardum <- data.compe$year
    data.compe <- dummy.data.frame(data.compe, names="yeardum")
    data.compe$donoryeardum <- as.numeric(interaction(data.compe$d, data.compe$year, drop=TRUE))
    data.compe <- dummy.data.frame(data.compe, names="donoryeardum")
    data.compe <- demean(data.compe, "p", skip=c("d","r","wbcode_r","year")) 
    
    # identify the range of years and recipients to use
    yeardums <- paste("yeardum",1975:2003,sep="")
    donoryeardums <- paste("donoryeardum",1:145,sep="")
    
    # regressions
    fm.comp.IV <- ols(as.formula(paste("oda ~ unvotes + noncomp + p_unvotes_noncomp + i_elecex_comp + p_unvotes_elecex_comp + i_elecex_noncomp + p_unvotes_elecex_noncomp",
                                    paste(yeardums,collapse="+"), sep="+")), data=data.compe,x=T,y=T)
    fm.comp.V <- ols(as.formula(paste("oda ~ unvotes + noncomp + p_unvotes_noncomp + i_elecex_comp + p_unvotes_elecex_comp + i_elecex_noncomp + p_unvotes_elecex_noncomp",
                                    paste(donoryeardums,collapse="+"), sep="+")), data=data.compe,x=T,y=T)
    
    # adjust variances
    fm.comp.IV$var <- mwc_3way(fm.comp.IV, data.compe$d, data.compe$r, data.compe$year)
    fm.comp.V$var <- mwc_3way(fm.comp.V, data.compe$d, data.compe$r, data.compe$year)

### Voting Competitiveness Regressions w/ Controls ##############################################################

    # construct the dataset (drop pairs with only one observation)
    data.compec <- estsample(data, c("unvotes","i_elecex","p_unvotes_elecex","oda","i_far_eiec","p","d","r","year","gdp2000","pop","gdp2000_donor","pop_donor"))
    data.compec <- data.compec[!ave(data.compec$year, data.compec$p, FUN=NROW)==1,]
    data.compec$d <- as.numeric(factor(data.compec$d))
    data.compec$r <- as.numeric(factor(data.compec$r))
    
    # create new interactions
    data.compec$noncomp <- data.compec$i_far_eiec
    data.compec$i_elecex_comp <- data.compec$i_elecex * (1 - data.compec$noncomp)
    data.compec$i_elecex_noncomp <- data.compec$i_elecex * data.compec$noncomp
    data.compec$p_unvotes_elecex_comp <- data.compec$unvotes * data.compec$i_elecex_comp
    data.compec$p_unvotes_elecex_noncomp <- data.compec$unvotes * data.compec$i_elecex_noncomp
    data.compec$p_unvotes_noncomp <- data.compec$unvotes * data.compec$noncomp
    
    # de-meaning
    data.compec <- demean(data.compec, "p", skip=c("d","r","year")) 
 
    # regressions
    fm.comp.VI <- ols(oda ~ unvotes + noncomp + p_unvotes_noncomp + i_elecex_comp + p_unvotes_elecex_comp + i_elecex_noncomp + p_unvotes_elecex_noncomp
                                + gdp2000 + pop + gdp2000_donor + pop_donor, data=data.compec,x=T,y=T)
    
    # adjust variances
    fm.comp.VI$var <- mwc_3way(fm.comp.VI, data.compec$d, data.compec$r, data.compec$year)
        
### NED Regressions w/out Controls ##########################################################################

    # construct the base dataset
    data.nedb <- estsample(data, c("unvotes","i_elecex","p_unvotes_elecex","NEDtotal","NEDODA","p","r","year"))
    data.nedb$r <- as.numeric(factor(data.nedb$r))
    data.nedb$rcode <- data.nedb$r
    data.nedb$yeardum <- data.nedb$year
    data.nedb <- dummy.data.frame(data.nedb, names="yeardum")
    data.nedb <- demean(data.nedb, "p", skip=c("r","year"))
    
    # identify the range of years and recipients to use
    yeardums <- paste("yeardum",1990:2003,sep="")
    #ryears <- paste("ryear",1:116,sep="")

    # regressions
    fm.6.I <- ols(NEDtotal ~ unvotes + i_elecex + p_unvotes_elecex, data=data.nedb,x=T,y=T)
    fm.6.II <- ols(as.formula(paste("NEDtotal ~ unvotes + i_elecex + p_unvotes_elecex", paste(yeardums,collapse="+"), sep="+")), data=data.nedb,x=T,y=T)
    #fm.6.III <- ols(as.formula(paste("NEDtotal ~ unvotes + i_elecex + p_unvotes_elecex", paste(ryears,collapse="+"), sep="+")), data=data.nedb,x=T,y=T)
    fm.6.IV <- ols(NEDODA ~ unvotes + i_elecex + p_unvotes_elecex, data=data.nedb,x=T,y=T)

    # adjust variances
    fm.6.I$var <- mwc_2way(fm.6.I, data.nedb$r, data.nedb$year)
    fm.6.II$var <- mwc_2way(fm.6.II, data.nedb$r, data.nedb$year)
    #fm.6.III$var <- mwc_2way(fm.6.III, data.nedb$r, data.nedb$year)
    fm.6.IV$var <- mwc_2way(fm.6.IV, data.nedb$r, data.nedb$year)
    
### NED Regressions with Controls ###########################################################################

    # keep variable set; drop series with gaps in their controls
    data.nedc <- estsample(data, c("unvotes","i_elecex","p_unvotes_elecex","NEDtotal","p","r","year","gdp2000","pop","gdp2000_donor","pop_donor"))
    data.nedc <- demean(data.nedc, "p", skip=c("r","year"))
    
    # regressions
    fm.6.III <- ols(NEDtotal ~ unvotes + i_elecex + p_unvotes_elecex + pop + gdp2000 + pop_donor + gdp2000_donor, data=data.nedc,x=T,y=T)
    
    # adjust variance
    fm.6.III$var <- mwc_2way(fm.6.III, data.nedc$r, data.nedc$year)

### Format and Output Tables ################################################################################

    # main table
    vars.main <- c("i_elecex","p_unvotes_elecex","p_unvotes_rt_elecex","p_unvotes_resid_elecex","unvotes","unvotes_rt","unvotes_resid","pop","gdp2000","pop_donor","gdp2000_donor")
    addrows.main <- rbind(c("Fixed Effects","DR,Y","DR,DY","DR","DR,Y","DR,DY","DR","DR,Y","DR,DY","DR"))
    table.main <- multiregtable(vars.main, varlabels, list(fm.main.I, fm.main.II, fm.main.III,
                                                           fm.main.IV, fm.main.V, fm.main.VI,
                                                           fm.main.VII, fm.main.VIII, fm.main.IX), 3, addrows.main)
    result <- hacktex(table.main, 
                    file=paste(output.dir, "main.tex", sep="/"),
                    label="tab:main",
                    table.env=FALSE,
                    caption.loc="top",
                    rowname=NULL,
                    center="none",
                    colheads=c("Regressor","1","2","3","4","5","6","7","8","9"),
                    collabel.just=c("l","c","c","c","c","c","c","c","c","c"))
                    
    # competitiveness table
    vars.comp <- c("unvotes","noncomp","p_unvotes_noncomp","i_elecex_comp","p_unvotes_elecex_comp","i_elecex_noncomp","p_unvotes_elecex_noncomp")
    addrows.comp <- rbind(c("FEs","DR,Y","DR,DY","DR","DR,Y","DR,DY","DR"), c("Controls","-","-","Yes","-","-","Yes"))
    table.comp <- multiregtable(vars.comp, varlabels, list(fm.comp.I, fm.comp.II, fm.comp.III,fm.comp.IV,fm.comp.V,fm.comp.VI), 3, addrows.comp)
    result <- hacktex(table.comp, 
                    file=paste(output.dir, "competition_revised.tex", sep="/"),
                    label="tab:competition_revised",
                    table.env=FALSE,
                    caption.loc="top",
                    rowname=NULL,
                    center="none",
                    colheads=c("Regressor","1","2","3","4","5","6"),
                    collabel.just=c("l","c","c","c","c","c","c"))

    # NED table          
    vars.ned <- c("i_elecex","p_unvotes_elecex","unvotes","pop","gdp2000","pop_donor","gdp2000_donor")
    addrows.ned <- rbind(c("Fixed Effects","R","R,Y","R","R"))
                          
    table.ned <- multiregtable(vars.ned, varlabels, list(fm.6.I,fm.6.II,fm.6.III,fm.6.IV), 3, addrows.ned)
    result <- hacktex(table.ned, 
                    file=paste(output.dir, "ned.tex", sep="/"),
                    label="tab:ned",
                    table.env=FALSE,
                    caption.loc="top",
                    rowname=NULL,
                    center="none",
                    colheads=c("Regressor","1","2","3","4"),
                    collabel.just=c("l","c","c","c","c"))
    

