####################################################################################
# mwc_2way(fit, v1, v2)
#
# Description
# -----------
# Take a fitted model and two panel dimensions, and return a revised estimate of
# the parameter covariance matrix clustered on each of the dimensions, as in 
# Cameron, Gelbach & Miller 2006
#
# Arguments
# ---------
#       fit             Fitted model
#       v1,2            Panel dimensions on which to cluster
#
####################################################################################

mwc_2way <- function(fit, v1, v2){

    # give proper names, attributes etc. to return matrix
    retvar <- robcov(fit, v1)$var
    retvar[,] <- 0

    # list factors and interactions to cluster on and the corresponding signs
    clustervars <- list(v1, 
                        v2, 
                        interaction(v1,v2))             
    signs <- c(1,1,-1)
    ret <- robcov
    for(i in 1:NROW(signs)){
    
        curclusvar <- clustervars[[i]]
        cursign <- signs[i]
        
        # calculate a finite-clusters inflation factor
        D <- NROW(unique(curclusvar))
        inflator <- D/(D-1)
        
        retvar <- retvar + cursign*inflator*robcov(fit, curclusvar)$var
    
    }
    
    # fix any negative variances that arise
    for (v in row.names(retvar)){
    
        if (diag(retvar)[v] < 0){
            print(paste("Warning: negative variance for ", v, sep=""))
            retvar[v,v] <- 0
        }
    
    }
    return(retvar)
}

####################################################################################
# mwc_3way(fit, v1, v2, v3)
#
# Description
# -----------
# Take a fitted model and three panel dimensions, and return a revised estimate of
# the parameter covariance matrix clustered on each of the dimensions, as in 
# Cameron, Gelbach & Miller 2006
#
# Arguments
# ---------
#       fit             Fitted model
#       v1,2,3          Panel dimensions on which to cluster
#
####################################################################################

mwc_3way <- function(fit, v1, v2, v3){

    # give proper names, attributes etc. to return matrix
    retvar <- robcov(fit, v1)$var
    retvar[,] <- 0

    # list factors and interactions to cluster on and the corresponding signs
    clustervars <- list(v1, 
                        v2, 
                        v3, 
                        interaction(v1,v2),
                        interaction(v2,v3),
                        interaction(v1,v3),
                        interaction(v1,v2,v3))              
    signs <- c(1,1,1,-1,-1,-1,1)
    
    for(i in 1:NROW(signs)){
    
        curclusvar <- clustervars[[i]]
        cursign <- signs[i]
        
        # calculate a finite-clusters inflation factor
        D <- NROW(unique(curclusvar))
        inflator <- D/(D-1)
        
        retvar <- retvar + cursign*inflator*robcov(fit, curclusvar)$var
    
    }
    
    # fix any negative variances that arise
    for (v in row.names(retvar)){
    
        if (diag(retvar)[v] < 0){
            print(paste("Warning: negative variance for ", v, sep=""))
            retvar[v,v] <- 0
        }
    
    }

    return(retvar)
}

####################################################################################
# fixvar(fit, problemvar, v1, v2, v3)
#
# Description
# -----------
# Fix problem with negative variances arising from multi-way clustering
#
# Arguments
# ---------
#       fit             Fitted model
#       problemvar      Variable to fix
#       v1,2,3          Panel dimensions on which to cluster
#
####################################################################################

fixvar3 <- function(fit, problemvar, v1, v2, v3){

    # disable fixing for certain vars we don't care about
    if (any(grep("ryear", problemvar, fixed=TRUE)) | any(grep("yeardum", problemvar, fixed=TRUE))){ 
        return(0)
    }
  
    tv12 <- diag(mwc_2way(fit, v1, v2))[problemvar]
    tv13 <- diag(mwc_2way(fit, v1, v3))[problemvar]
    tv23 <- diag(mwc_2way(fit, v2, v3))[problemvar]
    
    return(max(tv12, tv13, tv23))
}

####################################################################################

fixvar2 <- function(fit, problemvar, v1, v2){
  
    tv1 <- diag(robcov(fit, v1)$var)[problemvar]
    tv2 <- diag(robcov(fit, v2)$var)[problemvar]
    return(max(tv1, tv2))
}

####################################################################################
# multiregtable(varnames, varlabels, models, roundparam, addrows)
#
# Description
# -----------
# Take a list of fitted models and organize the results into a data frame
# with each model in a separate column.
#
# Arguments
# ---------
#       varnames        List of the variables to be included as rows
#       varlabels       Hash mapping variable names into labels for printing
#       models          List of fitted models
#       roundparam      Number of decimal places to round to
#       addrows         Any extra rows to insert in between the usual coef
#                       estimates and the N/R^2; for example, a row of Y/Ns
#                       indicating whether time FEs were included.
# Notes
# -----
# Calls helper functions multiregtable_addons(), multiregtable_sigsymbol().
#
####################################################################################

multiregtable <- function(varnames, varlabels, models, roundparam, addrows){

    rows <- NROW(varnames)
    cols <- NROW(models) + 1
    rettab <- as.data.frame(matrix(NA, nrow=rows*2, ncol=cols))

    # print row names
    for (v in 1:rows){
        rettab[v*2 - 1, 1] <- varlabels[varnames[v]]
        rettab[v*2, 1] <- c("")
    }

    # fill in numeric quantities
    for (m in 1:(cols-1)){
        for (v in 1:rows){
            if (varnames[v] %in% names(models[[m]]$coefficients)) {
                rettab[v*2 - 1, m+1] <- round(models[[m]]$coefficients[varnames[v]], roundparam)
                t.ratio <- models[[m]]$coefficients[varnames[v]]/sqrt(models[[m]]$var[varnames[v],varnames[v]])
                rettab[v*2, m+1] <- paste("{\\scriptsize (", round(sqrt(models[[m]]$var[varnames[v],varnames[v]]), roundparam), ")", "$^{", multiregtable_sigsymbol(t.ratio) ,"}$}", sep="")
            }
            else {
                rettab[v*2 - 1, m+1] <- c("")
                rettab[v*2, m+1] <- c("")
            }
        }
    }

    # tack on any extra rows handed to us
    startrow <- rows*2+1
    endrow <- rows*2+nrow(addrows)
    rettab[startrow:endrow,] <- addrows

    # add final summary stats
    startrow <- rows*2+nrow(addrows)+1
    endrow <- rows*2+nrow(addrows)+2
    rettab[startrow:endrow,] <- multiregtable_addons(models, roundparam)

    # return
    return(rettab)
}

multiregtable_sigsymbol <- function(t.ratio){

    if(is.na(t.ratio)){ return(c("")) }

    if (pnorm(abs(t.ratio)) > 0.995){ return(c("***")) }
    else if (pnorm(abs(t.ratio)) > 0.975){ return(c("**")) }
    else if (pnorm(abs(t.ratio)) > 0.95){ return(c("*")) }
    else { return(c("")) }

}

means_sigsymbol <- function(p.value){

    if(is.na(p.value)){ return(c("")) }

    if (p.value < 0.01){ return(c("***")) }
    else if (p.value < 0.05){ return(c("**")) }
    else if (p.value < 0.1){ return(c("*")) }
    else { return(c("")) }

}


p_sigsymbol <- function(p.value){

    if(is.na(p.value)){ return(c("")) }

    if (p.value < 0.01){ return(c("***")) }
    else if (p.value < 0.05){ return(c("**")) }
    else if (p.value < 0.1){ return(c("*")) }
    else { return(c("")) }

}

multiregtable_addons <- function(models, roundparam){

    cols <- NROW(models) + 1
    rettab <- as.data.frame(matrix(NA, nrow=2, ncol=cols))
    rettab[1,1] <- c("N")
    rettab[2,1] <- c("$R^2$")

    for (m in 1:(cols-1)){
        rettab[1,m+1] <- NROW(models[[m]]$y)
        rettab[2,m+1] <- round(summary.lm(models[[m]])$r.squared, roundparam)
    }

    return(rettab)

}

#######################################################################################

getrecs <- function(maxrecs, data){

    userecs <- 1:maxrecs
    for (r in 1:maxrecs){
        rtrend <- data[,paste("dm_ryear", r, sep="")]
        if (min(rtrend)==0 & max(rtrend)==0){
            userecs <- userecs[userecs!=r]
        }
    }
    return(userecs)

}

getyears <- function(maxyears, data){

    useyears <- 1:maxyears
    for (y in 1:maxyears){
        ydum <- data[,paste("dm_yeardum", y, sep="")]
        if (min(ydum)==0 & max(ydum)==0){
            useyears <- useyears[useyears!=y]
        }
    }
    return(useyears)

}

####################################################################################

longtable <- function(outcomes, labels, models, roundparam){
    
    rows <- NROW(outcomes)
    cols <- 4
    rettab <- as.data.frame(matrix(NA, nrow=rows*2, ncol=cols))
    
    #print row names
    for (v in 1:rows){
        rettab[v*2 - 1, 1] <- labels[outcomes[v]]
        rettab[v*2,1] <- c("")
    }

    #fill in reg coefficients
    for (v in 1:rows){
        rettab [v*2-1,4] = round(models[[v]]$coefficients["i_extra"], roundparam)
        t.ratio <- models[[v]]$coefficients["i_extra"]/sqrt(models[[v]]$var["i_extra", "i_extra"])
        rettab[v*2,4] <- paste("{\\scriptsize (", round(sqrt(models[[v]]$var["i_extra", "i_extra"]), roundparam), ")", "$^{", multiregtable_sigsymbol(t.ratio) ,"}$}", sep="")
    }

    #fill in meansmean
    for (v in 1:rows){
        rettab[v*2-1,3] = round(mean(data[,outcomes[[v]]], trim=0, na.rm=TRUE), roundparam)
        rettab[v*2,3] = paste("\\scriptsize (",round(sd(data[,outcomes[[v]]], na.rm=TRUE), roundparam),")",  sep="")
    }
    
    #fill in number of obs
    for (v in 1:rows){
        rettab[v*2-1,2] = NROW(models[[v]]$y)
        rettab[v*2,2] = c("")
    }
    return(rettab)
}


####################################################################################

meantable <- function(outcomes, labels, splitvar, roundparam){
  
      
    rows <- NROW(outcomes)
    cols <- 4
    rettab <- as.data.frame(matrix(NA, nrow=rows*2, ncol=cols))
    
    #print row names
    for (v in 1:rows){
        rettab[v*2 - 1, 1] <- labels[outcomes[v]]
        rettab[v*2,1] <- c("")
    }

    #print means by group
    for (v in 1:rows){
        rettab[v*2-1,2] = round(tapply(data[,outcomes[[v]]], data[,splitvar], mean, na.rm=TRUE)[["1"]], roundparam)
        rettab[v*2,2] = round(tapply(data[,outcomes[[v]]], data[,splitvar], sd, na.rm=TRUE)[["1"]], roundparam)
    }

    for (v in 1:rows){
        rettab[v*2-1,3] = round(tapply(data[,outcomes[[v]]], data[,splitvar], mean, na.rm=TRUE)[["0"]], roundparam)
        rettab[v*2,3] = round(tapply(data[,outcomes[[v]]], data[,splitvar], sd, na.rm=TRUE)[["0"]], roundparam)
    }
    
#print t stats

    for (v in 1:rows){
        rettab[v*2-1,4] = round(t.test(data[,outcomes[[v]]] ~ data[,splitvar], data=data)$p.value, roundparam)
        rettab[v*2,4] = c("") 
    }
    return(rettab)
}

####################################################################################
# linear(varnames, varlabels, models, roundparam, addrows)
#
# Description
# -----------
# Test linear hypotheses: return p-value of test
# 
#
# Arguments
# ---------
#       varnames        List of the variables to be included as rows
#       varlabels       Hash mapping variable names into labels for printing
#       models          List of fitted models
#       roundparam      Number of decimal places to round to
#       addrows         Any extra rows to insert in between the usual coef
#                       estimates and the N/R^2; for example, a row of Y/Ns
#                       indicating whether time FEs were included.
# Notes
# -----
# Calls helper functions multiregtable_addons(), multiregtable_sigsymbol().
#
####################################################################################
