// for generating tables A3-A5

use daily_newpost_addition, clear

egen joindate = min(date), by(id)

gen week = .

quietly do genweek

g id_week = string(id)+"_"+string(week)

sort id

merge id using nonblocked

gen nonblocked = _merge==3
drop _merge


drop if nonblocked == 0 


egen weekly_Addition = total(newpost_Addition), by(id_week)


egen min_date = min(date), by(id_week)

duplicates drop id_week, force
replace date = min_date
drop min_date
format joindate %d

gen age = round((date - joindate)/7)


gen agesqr = age^2
gen logAddition = log(weekly_Addition + 1)

gen after = week > 0

// for Table A3

reg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r

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

// for Table A4
reg logAddition after social_participation_after social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logAddition after social_participation_after social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r

sort id 
merge id using percent_blocked
tab _merge
drop if _merge==2
drop _merge

gen percent_blocked_after = percent_blocked*after
count if percent_blocked==.

// for Table A5
reg logAddition after percent_blocked_after percent_blocked age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logAddition after percent_blocked_after percent_blocked age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r

