
// for Table A19

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

rename overseas traditional_chinese
g traditional_chinese_after = traditional_chinese*after

reg logTotal after traditional_chinese_after traditional_chinese age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logAddition after traditional_chinese_after traditional_chinese age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
reg logDeletion after traditional_chinese_after traditional_chinese age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), r
xtreg logTotal after traditional_chinese_after traditional_chinese age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logAddition after traditional_chinese_after traditional_chinese age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r
xtreg logDeletion after traditional_chinese_after traditional_chinese age agesqr if ((week >= -4 & week < 0) | (week >0 & week <= 4)), i(id) fe r

