*** tableA1.do

clear
set mem 100m

capture log close
log using tableA1.log, replace text


use ../data/dis70panx.dta

gen menroll = (mpublicelemt+mpublichst+mprivatelemt+mprivatehst)/1000
gen enroll = (publicelemt+publichst+privatelemt+privatehst)/1000
replace publicelemhst = (publicelemt+publichst)/1000 if year<1990
gen frblack = (publicelemb+publichsb)/(1000*publicelemhst)

gen STU69 = stu/1000 if year==1970
egen stu69 = max(STU69), by(msa)

gen PUB70 = publicelemhst if year==1970
egen public70 = max(PUB70), by(msa)

sort leaid areaname
by leaid: replace areaname = areaname[1]
sort areaname

*** Panel A
l areaname menroll enroll publicelemhst frblack imp cntydis if year==1970 & stu69>50 & major==1, separator(0)

*** Panel B
l mname state menroll enroll publicelemhst frblack imp cntydis if year==1970 & public70>50 & major~=1, separator(0)

*** Panel C
l areaname menroll enroll publicelemhst frblack imp cntydis if year==1970 & stu69<50 & major==1, separator(0)

log close

