*********************************************************************************************************
*This do file replicates results in Americans Do It Better by Bloom, Sadun and Van Reenen, Table 6 and Appendix Table C2
*Programmed up by Nick Bloom, September 2010. For queries contact nbloom@stanford.edu
*********************************************************************************************************
version 9.0
clear all
set memory 100m
set matsize 2000
set more off
cap log using table6_c2,t replace

**********************************
*RUNS THE REGRESSIONS IN TABLE 6
**********************************
u replicate
cap estimates drop *
*Generating country by year dummies to control for national business cycles
egen cyear=group(cty year)
tab cyear,gen(cy)
*Generating quartic in coverage ratio as non-linear control for any sampling biases
gen c2=cover^2
gen c3=cover^3
gen c4=cover^4
gen c5=cover^5


*Col 1: US firms higher returns in levels - larger sample
eststo:areg ly lcap lemp                                              du_usa_mu du_oth_mu cy*              public*             ,cluster(company_code) ab(sic)
test du_oth_mu=du_usa_mu

*Col 2: US firms higher returns - SAMPLE WITH PEEPS DATA
eststo:areg ly lcap lemp           lpcemp lpcemp_du_usa_mu lpcemp_du_oth_mu du_usa_mu du_oth_mu cy* cover c2-c5   public* ldegree_t*  if peeps~=. [aw=cover],cluster(company_code) ab(sic)
test lpcemp_du_oth_mu=lpcemp_du_usa_mu
test du_oth_mu=du_usa_mu

*Col 3: People flexibility & IT interaction
eststo:areg ly lcap lemp           lpcemp peeps lpcemp_peeps du_usa_mu du_oth_mu cy* cover c2-c5   public* ldegree_t*   [aw=cover],cluster(company_code) ab(sic)
test du_oth_mu=du_usa_mu

*Col 4: Zorg, people management and both in with the US interaction
eststo:areg ly lcap lemp           lpcemp peeps lpcemp_peeps du_usa_mu du_oth_mu lpcemp_du_usa_mu lpcemp_du_oth_mu cy* cover c2-c5  public* ldegree_t*  if peeps~=. [aw=cover],cluster(company_code) ab(sic)
test lpcemp_du_oth_mu=lpcemp_du_usa_mu
test du_oth_mu=du_usa_mu

*Col 5: Fixed effects + peeps
eststo:areg ly lcap lemp lpcemp lpcemp_du_usa_mu lpcemp_du_oth_mu peeps lpcemp_peeps cy* cover c2-c5  public* ldegree_t*  if peeps~=. [aw=cover],cluster(company_code) ab(interview)
test lpcemp_du_oth_mu=lpcemp_du_usa_mu

*Col 6: Fixed effects + peeps + plus skills
eststo:areg ly lcap lemp lpcemp lpcemp_du_usa_mu lpcemp_du_oth_mu peeps lpcemp_peeps lpcemp_ldegree_t* cy* cover c2-c5  public* ldegree_t*  if peeps~=. [aw=cover],cluster(company_code) ab(interview)
test lpcemp_du_oth_mu=lpcemp_du_usa_mu

*Col 7: Intensity without peeps
eststo:areg  lpcemp du_usa_mu du_oth_mu ldegree_t* cy* cover c2-c5   if peeps~=. [aw=cover],cluster(company_code) ab(sic)
test du_oth_mu=du_usa_mu

*Col 8: Intensity with peeps
eststo:areg  lpcemp du_usa_mu du_oth_mu peeps ldegree_t* cy* cover c2-c5   if peeps~=. [aw=cover],cluster(company_code) ab(sic)
test du_oth_mu=du_usa_mu

esttab  using Table6.csv, replace stats(N, fmt(%9.0f %9.0g)) cells(b(star fmt(4)) se(par fmt(4))) starlevels( * 0.10 ** 0.05 *** 0.01) keep(lpcemp_du_usa_mu lpcemp_du_oth_mu peeps lpcemp_peeps lcap lemp lpcemp du_usa_mu du_oth_mu ldegree_t lpcemp_ldegree_t) nogap

**********************************
*APPENDIX TABLE C2
**********************************
cap estimates drop *

*Note the hiring, firing, promotions and rewards questions in people management particularly associated with higher returns to IT
gen lpcemp_operations=lpcemp*operations
gen lpcemp_monitoring=lpcemp*monitoring
gen lpcemp_targets=lpcemp*targets
gen lpcemp_management=lpcemp*management

*Baseline peeps
eststo: areg ly lcap lemp           lpcemp peeps lpcemp_peeps du_usa_mu du_oth_mu cy* cover c2-c5   public* ldegree_t*   [aw=cover],cluster(company_code) ab(sic)
test du_oth_mu=du_usa_mu

*Shopfloor operations 
eststo:areg ly lcap lemp           lpcemp operations lpcemp_operations du_usa_mu du_oth_mu cy* cover c2-c5   public* ldegree_t*   [aw=cover],cluster(company_code) ab(sic)

*Monitoring 
eststo:areg ly lcap lemp           lpcemp monitoring lpcemp_monitoring du_usa_mu du_oth_mu cy* cover c2-c5   public* ldegree_t*   [aw=cover],cluster(company_code) ab(sic)

*Targets 
eststo:areg ly lcap lemp           lpcemp targets lpcemp_targets du_usa_mu du_oth_mu cy* cover c2-c5   public* ldegree_t*   [aw=cover],cluster(company_code) ab(sic)

*Total management 
eststo:areg ly lcap lemp           lpcemp management lpcemp_management du_usa_mu du_oth_mu cy* cover c2-c5   public* ldegree_t*   [aw=cover],cluster(company_code) ab(sic)

esttab  using tablec2.csv, replace stats(N, fmt(%9.0f %9.0g)) cells(b(star fmt(4)) se(par fmt(4))) starlevels( * 0.10 ** 0.05 *** 0.01) keep(peeps lpcemp_peeps operations lpcemp_operations monitoring lpcemp_monitoring targets lpcemp_targets management lpcemp_management lcap lemp lpcemp du_usa_mu du_oth_mu ldegree_t) nogap


**************************************
*ADDITIONAL TESTS MENTIONED IN THE TEXT
**************************************
*Add materials to Column (1) specification
areg ly lcap lemp                                           lmat   du_usa_mu du_oth_mu cy*              public*             ,cluster(company_code) ab(sic)

****NEED TO EDIT THIS IN THE TEXT TO MATCH - FOOTNOTE 48
*Add materials and PCS to Column (1) specification
areg ly lcap lemp lpcemp                                          lmat   du_usa_mu du_oth_mu cy*              public*             ,cluster(company_code) ab(sic)

*Drop people management interactions and ownership variables
areg ly lcap lemp           lpcemp peeps cy* cover c2-c5  public* ldegree_t*  if peeps~=. [aw=cover],cluster(company_code) ab(sic)

*Hours interaction
gen lpcemp_hours_t=lpcemp*hours_t
areg ly lcap lemp lpcemp  peeps lpcemp_peeps lpcemp_hours_t lpcemp_du_usa_mu lpcemp_du_oth_mu  cy* cover c2-c5  public* ldegree_t*  if peeps~=. [aw=cover],cluster(company_code) ab(interview)

*Unions
replace uni=. if uni<0
gen lpcemp_uni=lpcemp*uni
areg ly lcap lemp lpcemp  peeps lpcemp_peeps uni lpcemp_uni lpcemp_du_usa_mu lpcemp_du_oth_mu  cy* cover c2-c5  public* ldegree_t*  if peeps~=. [aw=cover],cluster(company_code) ab(interview)

*Servers
gen ltotserver=log(totserver)
gen lpcemp_ltotserver=lpcemp*ltotserver
areg ly lcap lemp lpcemp  peeps lpcemp_peeps ltotserver lpcemp_ltotserver lpcemp_du_usa_mu lpcemp_du_oth_mu  cy* cover c2-c5  public* ldegree_t*  if peeps~=. [aw=cover],cluster(company_code) ab(interview)

*Networks
gen lpcemp_net=lpcemp*net
areg ly lcap lemp lpcemp  peeps lpcemp_peeps net lpcemp_net lpcemp_du_usa_mu lpcemp_du_oth_mu  cy* cover c2-c5  public* ldegree_t*  if peeps~=. [aw=cover],cluster(company_code) ab(interview)
log close



