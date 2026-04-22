
// for tables A15-A17

// first find out outliers
use contridaily_proc, clear

drop if nonblocked == 0 

g id_week = string(id)+"_"+string(week)

egen weekly_Addition = total(Addition), by(id_week)
egen weekly_Deletion = total(Deletion), by(id_week)

duplicates drop id_week, force

gen weekly_Total = weekly_Addition+weekly_Deletion
keep if week < 0
egen average_weekly = mean(weekly_Total), by(id)
keep id average_weekly
duplicates drop id, force
egen average_average = mean(average_weekly)
egen sd_average = sd(average_weekly)
summ average_average sd_average average_weekly
keep if average_weekly > 4*sd_average+ average_average
keep id
count
sort id
save outlier, replace


use contridaily_proc, clear

drop if nonblocked == 0 

g id_week = string(id)+"_"+string(week)

egen weekly_Addition = total(Addition), by(id_week)
egen weekly_Deletion = total(Deletion), by(id_week)

egen min_date = min(date), by(id_week)

duplicates drop id_week, force
replace date = min_date
drop min_date
format joindate %d

sort id
merge id using technicaluser
drop if _merge!=1
drop _merge


sort id
merge id using outlier
drop if _merge==3
drop _merge

gen age = round((date - joindate)/7)

gen agesqr = age^2
gen logAddition = log(weekly_Addition+1)
gen logDeletion = log(weekly_Deletion+1)
gen logTotal = log(weekly_Addition+weekly_Deletion + 1)

gen after = week > 0

// for Table A15
reg logTotal after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logDeletion after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logTotal after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logDeletion after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r


// for Table A16
sort id
merge id using userpagestat2005
drop if _merge==2
drop _merge

sort id
merge id using usertalkstat2005
drop if _merge==2
drop _merge

replace userpage2005_add = 0 if userpage2005_add==.
replace userpage2005_deleted = 0 if userpage2005_deleted ==.
replace usertalk2005_add = 0 if usertalk2005_add ==.
replace usertalk2005_deleted = 0 if usertalk2005_deleted ==.

gen social_participation = userpage2005_add + userpage2005_deleted + usertalk2005_add + usertalk2005_deleted
replace social_participation = 0 if social_participation == .

gen temp = age if week ==0
egen age_to_block = max(temp), by(id)

replace social_participation = social_participation/(age_to_block+1)
replace social_participation = log(social_participation+1)

drop temp age_to_block

gen social_participation_after = social_participation*after 

reg logTotal after social_participation_after social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logAddition after social_participation_after social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logDeletion after social_participation_after social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logTotal after social_participation_after social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logAddition after social_participation_after social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logDeletion after social_participation_after social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r


// for Table A17
sort id 
merge id using percent_blocked
tab _merge
drop if _merge==2
drop _merge

gen percent_blocked_after = percent_blocked*after
count if percent_blocked==.

reg logTotal after percent_blocked_after percent_blocked age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logAddition after percent_blocked_after percent_blocked age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logDeletion after percent_blocked_after percent_blocked age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logTotal after percent_blocked_after percent_blocked age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logAddition after percent_blocked_after percent_blocked age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logDeletion after percent_blocked_after percent_blocked age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r






