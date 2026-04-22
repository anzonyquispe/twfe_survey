clear all

local pathcensus "/rdcprojects/la00296/data/csr/Juan/"
local pathpgs    "/rdcprojects/la00296/programs/"

capture log close
log using `pathpgs'lookupconcat.log, replace
use `pathcensus'concat

describe
gen numcfn=real(cfn)
xtdes, i(numcfn) t(year)
sort stgeo msa ctygeo cfn year
gen census_rec=_n
su census_rec, detail
di "Hola"
log close
