set mem 500m
local pathcensus "/rdcprojects/la00296/data/csr/Juan/"
use `pathcensus'census_naeyc.dta, replace
keep if contrib_by==6
list name1 name2 