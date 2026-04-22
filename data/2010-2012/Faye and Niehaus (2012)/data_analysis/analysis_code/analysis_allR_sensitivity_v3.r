

### Setup ##################################################################################################

    rm(list=ls())
    #setwd("C:/Ec Projects/PAC/analysis")
    setwd("~/Ec Projects/completed/PAC/submission/aer/data_analysis/analysis_code")
    output.dir <- c("~/Ec Projects/completed/PAC/submission/aer/data_analysis/output")
    source("[2008.08.01][v4] reg_helper_functions.r")
    source("lib_multiregtable.r")
    source("lib_hacktex.r")
    library(Design)
    library(dummies)
    
    # toggle which check of {nobig3, nobig5, loda} should be run
    check <- "loda"

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
                          "p_unvotes_elecex_noncomp" = "UN * Noncompetitive Election",
                          "i_earlyelec"              = "Early Election",
                          "p_unvotes_earlyelec"      = "UN * Early Election",
                          "i_lateelec"               = "Late Election",
                          "p_unvotes_lateelec"       = "UN * Late Election")
                          
### Load Data ################################################################################################

    # load source file and clean it up
    data <- read.csv("100217_oda_final_data_big5_commit_080107_unvotes_term.csv")
    data$p <- interaction(data$wbcode_donor, data$wbcode_recipient, drop=TRUE)
    names(data)[names(data)=="wbcode_recipient"] <- "r"
    names(data)[names(data)=="wbcode_donor"] <- "d"
    
    # identify biggest recipients
    #rtotals <- tapply(data$oda, data$r, FUN=sum)
    #rtotals[order(rtotals)]
    
    # toggle which check to run
    if (check == "nobig3"){
        data <- data[!is.element(data$r, c("EGY","IDN","IND")),]
    } else if (check == "nobig5"){
        data <- data[!is.element(data$r, c("EGY","IDN","IND","ISR","CHN")),]
    } else if (check == "loda"){
        data$loda <- log(data$oda)
        data$loda[is.na(data$loda)] <- log(1/1000000)
        data$loda[is.infinite(data$loda)] <- log(1/1000000)
        data$oda <- data$loda
        
        data$pop <- log(data$pop)
        data$pop_donor <- log(data$pop_donor)
        data$gdp2000 <- log(data$gdp2000)
        data$gdp2000_donor <- log(data$gdp2000_donor)
    }
    
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
    fm.main.IV <- ols(as.formula(paste("oda ~ unvotes + i_elecex + p_unvotes_elecex", paste(yeardums,collapse="+"), sep="+")), data=data.base,x=T,y=T)
    fm.main.VII <- ols(as.formula(paste("oda ~ unvotes_rt + unvotes_resid + i_elecex + p_unvotes_rt_elecex + p_unvotes_resid_elecex", paste(yeardums,collapse="+"), sep="+")), data=data.base,x=T,y=T)
    
    # adjust variances
    fm.main.I$var <- mwc_3way(fm.main.I, data.base$d, data.base$r, data.base$year)
    fm.main.IV$var <- mwc_3way(fm.main.IV, data.base$d, data.base$r, data.base$year)
    fm.main.VII$var <- mwc_3way(fm.main.VII, data.base$d, data.base$r, data.base$year)
       
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
    
    # adjust variances
    fm.comp.IV$var <- mwc_3way(fm.comp.IV, data.compe$d, data.compe$r, data.compe$year)

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

### Election Timing ###########################################################################################

    data$dateexec[data$dateexec==13] <- NA
    
    data$elecearly4 <- as.numeric(data$dateexec < 4)
    data$i_earlyelec4 <- data$i_elecex * data$elecearly4
    data$i_earlyelec4[data$i_elecex==0] <- 0
    data$i_lateelec4 <- data$i_elecex * (1 - data$elecearly4)
    data$i_lateelec4[data$i_elecex==0] <- 0
    data$p_unvotes_earlyelec4 <- data$i_earlyelec4 * data$unvotes
    data$p_unvotes_lateelec4 <- data$i_lateelec4 * data$unvotes
    
    # flag series that are missing a time for their election
    data$anytimemissing <- ave(as.numeric(is.na(data$dateexec) & data$i_elecex==1), data$p, FUN=max)
    table(data$anytimemissing)
    
    # make an analysis dataset with these series removed
    data.time <- estsample(data[data$anytimemissing==0,], c("unvotes","i_earlyelec4","i_lateelec4","p_unvotes_earlyelec4","p_unvotes_lateelec4","oda","p","d","r","year"))
    data.time$yeardum <- data.time$year
    data.time <- dummy.data.frame(data.time, names="yeardum")
    data.time$d <- as.numeric(factor(data.time$d))
    data.time$r <- as.numeric(factor(data.time$r))
    data.time <- demean(data.time, "p", skip=c("d","r","year"))
    
    # regressions w/ 4 month defn
    data.time$i_earlyelec <- data.time$i_earlyelec4
    data.time$p_unvotes_earlyelec <- data.time$p_unvotes_earlyelec4
    data.time$i_lateelec <- data.time$i_lateelec4
    data.time$p_unvotes_lateelec <- data.time$p_unvotes_lateelec4
    #fm.time4 <- ols(oda ~ unvotes + i_earlyelec + p_unvotes_earlyelec + i_lateelec + p_unvotes_lateelec, data=data.time,x=T,y=T)
    #fm.time4$var <- mwc_3way(fm.time4, data.time$d, data.time$r, data.time$year)

    yeardums <- paste("yeardum",1975:2003,sep="")
    form.time <- as.formula(paste("oda ~ unvotes + i_earlyelec + p_unvotes_earlyelec + i_lateelec + p_unvotes_lateelec",
                                    paste(yeardums,collapse="+"), sep="+"))
    fm.time4 <- ols(form.time, data=data.time,x=T,y=T)
    fm.time4$var <- mwc_3way(fm.time4, data.time$d, data.time$r, data.time$year)



### Format and Output Tables ################################################################################

    # main table
    vars.main <- c("i_elecex","i_elecex_comp","i_elecex_noncomp","i_earlyelec","i_lateelec",
                   "p_unvotes_elecex","p_unvotes_rt_elecex","p_unvotes_resid_elecex","p_unvotes_elecex_comp","p_unvotes_elecex_noncomp","p_unvotes_earlyelec","p_unvotes_lateelec",
                   "unvotes","unvotes_rt","unvotes_resid")
    addrows.main <- rbind(c("Fixed Effects","DR,Y","DR","DR,Y","DR","DR,Y","DR","DR,Y","DR","DR,Y"),
                          c("Macro Controls","N","Y","N","Y","N","Y","N","Y","N"))
    table.main <- multiregtable(vars.main, varlabels, list(fm.main.I,fm.main.III,
                                                           fm.main.IV, fm.main.VI,
                                                           fm.main.VII,  fm.main.IX,
                                                           fm.comp.IV, fm.comp.VI, fm.time4), 3, addrows.main)
    result <- hacktex(table.main, 
                    file=paste(output.dir, "sensitivity_", check, ".tex", sep=""),
                    label="tab:sensitivity",
                    table.env=FALSE,
                    caption.loc="top",
                    rowname=NULL,
                    center="none",
                    colheads=c("Regressor","I","II","III","IV","V","VI","VII","VIII","IX"),
                    collabel.just=c("l","c","c","c","c","c","c","c","c","c"))
