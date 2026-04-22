set mem 500m
cd "C:\research\minwage\SCF"

local years = "89 92 95 98 01 04 07"
foreach year of local years  {
 insheet using scfregdata`year'.csv
 tempfile scfregdata`year'
 save `scfregdata`year'',replace
 clear
}


use `scfregdata89'

append using `scfregdata92'
append using `scfregdata95'
append using `scfregdata98'
append using `scfregdata01'
append using `scfregdata04'
append using `scfregdata07'

save scfregdata8907,replace
