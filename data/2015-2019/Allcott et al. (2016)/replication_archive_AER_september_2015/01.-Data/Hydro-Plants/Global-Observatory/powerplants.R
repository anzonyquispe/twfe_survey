######################################################
#you input your information for the following section
setwd( "" )
######################################################
require(RCurl)
require(XML)
require(cwhmisc)
require(plyr)
require(stringr)
require(data.table)

options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))
agent="Firefox/23.0" 
curl = getCurlHandle()
curlSetOpt(
  cookiejar = 'cookies.txt' ,
  useragent = agent,
  followlocation = TRUE ,
  autoreferer = TRUE ,
  httpauth = 1L, # "basic" 
  curl = curl
)


plants <- read.csv('powerplants.csv',stringsAsFactors=F, header=T)  

indiaplants <- plants[plants$Country=='India',]

#set up
indiaplants$abstract<-''
indiaplants$lat<-NA
indiaplants$lon<-NA
indiaplants$type<-''

#loop over rows
for ( i in seq( nrow(indiaplants) ) ){
#  i <- 155
url <-indiaplants$url[i]

html<-try(getURL(
  url,
  maxredirs = as.integer(20),
  followlocation = TRUE,
  curl = curl
), TRUE)
if(class(html)=="try-error") {
  print(paste('link read error:',url))
  next
}

work <-htmlTreeParse(html,useInternal = TRUE)

indiaplants$abstract[i] <-unlist(xpathApply(work, "//div[@id='Abstract_Block']/table/tr/td", xmlValue))
indiaplants$lat[i] <- unlist(xpathApply(work, "//td/span/input[@id = 'Latitude_Start']", xmlGetAttr,"value") )
indiaplants$lon[i] <-unlist(xpathApply(work, "//td/span/input[@id = 'Longitude_Start']", xmlGetAttr,"value") )
type <-unlist(xpathApply(work, "//select[@id = 'Type_of_Plant_enumfield_rng1']/option[@selected='selected']", xmlGetAttr,"value"))
if (length(type)==0) {
  indiaplants$type[i]<-'missing'  
} else {
  indiaplants$type[i]<-type
}
rm(type) 
print(i)
}


write.table(indiaplants, 'indiaplants.csv',sep = ",", append = FALSE, qmethod = c("d"), row.names=FALSE, col.names=TRUE)    
