
// for Table A18

// need to run main.do before running this program
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

gen age = round((date - joindate)/7)
gen agesqr = age^2
gen logAddition = log(weekly_Addition + 1)
gen logDeletion = log(weekly_Deletion + 1)
gen logTotal = log(weekly_Addition + weekly_Deletion + 1)

gen after = week > 0

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

sort id
merge id using revealinfo
tab _merge
keep if _merge==3
drop _merge

gen revealamount = ifname  + iflocation + ifurl + iftalk

gen revealamount_after = revealamount*after


reg logTotal after revealamount_after revealamount social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logAddition after revealamount_after revealamount social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logDeletion after revealamount_after revealamount social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logTotal after revealamount_after revealamount social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logAddition after revealamount_after revealamount social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logDeletion after revealamount_after revealamount social_participation age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r

