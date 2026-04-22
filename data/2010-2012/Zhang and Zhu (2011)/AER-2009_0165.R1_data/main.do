// for all tables in the paper

use daily_contribution, clear
egen joindate = min(date), by(id)
egen lastdate = max(date) if (date < mdy(10, 10, 2006) | date > mdy(11, 17, 2006)) & Total > 0, by(id)
egen temp = max(lastdate), by(id)
replace lastdate = temp if lastdate==.
drop temp 
format lastdate %d

g contributed_during_1st_block =  Total > 0 & Total!=. & (date >= mdy(6, 2, 2004) & date <= mdy(6, 17, 2004))
egen temp = max(contributed_during_1st_block), by(id)
replace contributed_during_1st_block = temp 
drop temp

count if lastdate==.

g nonblocked = 0 

// joined before the 3rd block and contributed at least once during the 3rd block
replace nonblocked = 1 if joindate < mdy(10, 19, 2005) & lastdate >= mdy(11, 1, 2005)  & lastdate !=. 
// or contributed during the 1st block (even if the contributor didn't contribute during the third block
replace nonblocked = 1 if joindate < mdy(10, 19, 2005) & contributed_during_1st_block == 1 

drop contributed_during_1st_block

sort id
merge id using userlangstat_percentage
tab _merge

drop if _merge == 2
drop _merge

gen overseas = .

replace overseas = percentage > 0.5 & percentage!=.

drop percentage

replace nonblocked = 1 if overseas==1 & joindate < mdy(10, 19, 2005)  

preserve
keep if nonblocked==1
keep id
sort id
save nonblocked, replace
restore

gen week = .

quietly do genweek
save contridaily_proc, replace


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

// for Table 2 of the paper
reg logTotal after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logDeletion after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logTotal after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
matrix list e(V)
xtreg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logDeletion after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r

// for Table 3 of the paper 
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

// for Table 4 of the paper
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


// for summary stats in Table 1
// for panel A
use contridaily_proc, clear
sort id date 

drop if week < -4 | week > 4 | week == 0
// for panel A
egen total_addition_before = total(Addition) if week < 0, by(id)
egen temp = max(total_addition_before), by(id)
replace total_addition_before = temp if total_addition_before==.
drop temp

egen total_addition_after = total(Addition) if week > 0, by(id)
egen temp = max(total_addition_after), by(id)
replace total_addition_after = temp if total_addition_after ==.
drop temp

egen total_deletion_before = total(Deletion) if week < 0, by(id)
egen temp = max(total_deletion_before), by(id)
replace total_deletion_before = temp if total_deletion_before==.
drop temp

egen total_deletion_after = total(Deletion) if week > 0, by(id)
egen temp = max(total_deletion_after), by(id)
replace total_deletion_after = temp if total_deletion_after ==.
drop temp

egen total_total_before = total(Total) if week < 0, by(id)
egen temp = max(total_total_before), by(id)
replace total_total_before = temp if total_total_before==.
drop temp

egen total_total_after = total(Total) if week > 0, by(id)
egen temp = max(total_total_after), by(id)
replace total_total_after = temp if total_total_after ==.
drop temp

duplicates drop id, force
ttest total_addition_before = total_addition_after
ttest total_deletion_before = total_deletion_after
ttest total_total_before = total_total_after

// for panel B
use contridaily_proc, clear
sort id date 
drop if week < -4 | week > 4 | week == 0

drop if nonblocked==0 
egen total_addition_before = total(Addition) if week < 0, by(id)
egen temp = max(total_addition_before), by(id)
replace total_addition_before = temp if total_addition_before==.
drop temp

egen total_addition_after = total(Addition) if week > 0, by(id)
egen temp = max(total_addition_after), by(id)
replace total_addition_after = temp if total_addition_after ==.
drop temp

egen total_deletion_before = total(Deletion) if week < 0, by(id)
egen temp = max(total_deletion_before), by(id)
replace total_deletion_before = temp if total_deletion_before==.
drop temp

egen total_deletion_after = total(Deletion) if week > 0, by(id)
egen temp = max(total_deletion_after), by(id)
replace total_deletion_after = temp if total_deletion_after ==.
drop temp

egen total_total_before = total(Total) if week < 0, by(id)
egen temp = max(total_total_before), by(id)
replace total_total_before = temp if total_total_before==.
drop temp

egen total_total_after = total(Total) if week > 0, by(id)
egen temp = max(total_total_after), by(id)
replace total_total_after = temp if total_total_after ==.
drop temp

duplicates drop id, force
ttest total_addition_before = total_addition_after
ttest total_deletion_before = total_deletion_after
ttest total_total_before = total_total_after
