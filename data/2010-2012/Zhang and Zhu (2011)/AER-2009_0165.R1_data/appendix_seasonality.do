// for tables A1-A2

// Table A1 
use daily_contribution, clear

egen joindate = min(date), by(id)

sort id

merge id using nonblocked

gen nonblocked = _merge==3
drop _merge

gen week = .

replace week = 4 if date >= mdy(11, 22, 2003) & date < mdy(11, 29, 2003)
replace week = 3 if date >= mdy(11, 15, 2003) & date < mdy(11, 22, 2003)
replace week = 2 if date >= mdy(11, 8, 2003) & date < mdy(11, 15, 2003)
replace week = 1 if date >= mdy(11, 1, 2003) & date < mdy(11, 8, 2003)
replace week = 0 if date >= mdy(10, 19, 2003) & date < mdy(11, 1, 2003)
replace week = -1 if date >= mdy(10, 12, 2003) & date < mdy(10, 19, 2003)
replace week = -2 if date >= mdy(10, 5, 2003) & date < mdy(10, 12, 2003)
replace week = -3 if date >= mdy(9, 28, 2003) & date < mdy(10, 5, 2003)
replace week = -4 if date >= mdy(9, 21, 2003) & date < mdy(9, 28, 2003)

drop if week==.

g id_week = string(id)+"_"+string(week)

drop if nonblocked == 0 

egen weekly_Addition = total(Addition), by(id_week)
egen weekly_Deletion = total(Deletion), by(id_week)

// keep if joindate < mdy(1,1,2005)
egen min_date = min(date), by(id_week)

duplicates drop id_week, force
replace date = min_date
drop min_date

format joindate %d

gen age = round((date - joindate)/7)

gen agesqr = age^2
gen logAddition = log(weekly_Addition+1)
gen logDeletion = log(weekly_Deletion+1)
gen logTotal = log(weekly_Addition+ weekly_Deletion + 1)

gen after = week > 0

reg logTotal after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logDeletion after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logTotal after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logDeletion after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r



// Table A2
use daily_contribution, clear

egen joindate = min(date), by(id)

sort id

merge id using nonblocked

gen nonblocked = _merge==3
drop _merge

gen week = .

replace week = 4 if date >= mdy(11, 22, 2004) & date < mdy(11, 29, 2004)
replace week = 3 if date >= mdy(11, 15, 2004) & date < mdy(11, 22, 2004)
replace week = 2 if date >= mdy(11, 8, 2004) & date < mdy(11, 15, 2004)
replace week = 1 if date >= mdy(11, 1, 2004) & date < mdy(11, 8, 2004)
replace week = 0 if date >= mdy(10, 19, 2004) & date < mdy(11, 1, 2004)
replace week = -1 if date >= mdy(10, 12, 2004) & date < mdy(10, 19, 2004)
replace week = -2 if date >= mdy(10, 5, 2004) & date < mdy(10, 12, 2004)
replace week = -3 if date >= mdy(9, 28, 2004) & date < mdy(10, 5, 2004)
replace week = -4 if date >= mdy(9, 21, 2004) & date < mdy(9, 28, 2004)

drop if week==.

g id_week = string(id)+"_"+string(week)


drop if nonblocked == 0 

egen weekly_Addition = total(Addition), by(id_week)
egen weekly_Deletion = total(Deletion), by(id_week)

// keep if joindate < mdy(1,1,2005)
egen min_date = min(date), by(id_week)

duplicates drop id_week, force
replace date = min_date
drop min_date

format joindate %d

gen age = round((date - joindate)/7)

gen agesqr = age^2
gen logAddition = log(weekly_Addition+1)
gen logDeletion = log(weekly_Deletion+1)
gen logTotal = log(weekly_Addition+ weekly_Deletion + 1)

gen after = week > 0

reg logTotal after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logDeletion after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logTotal after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logAddition after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logDeletion after age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r

