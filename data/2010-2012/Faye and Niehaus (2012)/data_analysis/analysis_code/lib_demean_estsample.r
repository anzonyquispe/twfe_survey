### helper function to demean datasets
### NB: this version demeans every variable in the dataset (other than the factor)

    demean_estsample <- function(data, dmfactor){

        varlist <- names(data)[names(data)!=dmfactor]
    
        # isolate observations that are missing vars in varlist
        missing <- rep(0, nrow(data))
        for (v in varlist){
            missing <- missing + as.numeric(is.na(data[,v]))
        }
        missing <- missing + as.numeric(is.na(data[,dmfactor]))
        retdata <- data[missing==0,c(varlist, dmfactor)]

        # demean the remaining observation by dmfactor
        for (v in varlist){
            retdata[,v] <- retdata[,v] - ave(retdata[,v], retdata[,dmfactor], FUN=mean)
        }

        return(retdata)
    }
