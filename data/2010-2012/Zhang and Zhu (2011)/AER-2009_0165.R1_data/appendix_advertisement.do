// for Tables A9-A11

// The program requires an intermediary output contridaily_proc from main.do
// So need to run main.do at least once to have its output

use contridaily_proc, clear

drop if nonblocked == 0 

sort id
merge id using banned_id
keep if _merge==1 
drop _merge

g id_week = string(id)+"_"+string(week)

egen weekly_Addition = total(Addition), by(id_week)
egen weekly_Deletion = total(Deletion), by(id_week)

egen min_date = min(date), by(id_week)

duplicates drop id_week, force
replace date = min_date
drop min_date
format joindate %d

gen age = round((date - joindate)/7)
gen agesqr = age^2
gen logAddition = log(weekly_Addition + 1)
gen logDeletion = log(weekly_Deletion + 1)
gen logTotal = log(weekly_Addition + weekly_Deletion + 1)

gen after = week > 0

// for Table A9
reg logTotal after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logDeletion after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logTotal after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logDeletion after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r

// for Table A10
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

// for Table A11
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

