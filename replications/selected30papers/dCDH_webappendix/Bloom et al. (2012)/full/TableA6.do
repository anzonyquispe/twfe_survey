set more off
cap log using tablea6,t replace
***Source: Nick Bloom, November 2010, nbloom@stanford.edu
*This file investigates the sampling bias in the HH IT survey
*It tests if our sample of management firms with accounting data (those for which we use in Table 6) has differential HH matching. 


u replicate,replace
qui tab cty,gen(cc)
*Matched are the sites which are in HH (single or one of multi-matches)
gen matched=(s_c~=.)
so company_code year
gen labp=ly-le
*Collapse for the cross-sectional matching regression
collapse lemp peeps matched du_usa_mu du_oth_mu cc* labp ldegree_t* public* sic,by(company_code)
cap estimates drop *
 
*Column (1)
eststo: areg matched du_usa_mu du_oth_mu             cc* ,ab(sic) rob
test du_usa_mu du_oth_mu

*Column (2)
eststo: areg matched                      lemp       cc* ,ab(sic) rob

*Column (3)
eststo: areg matched du_usa_mu du_oth_mu  lemp       cc* ,ab(sic) rob
test du_usa_mu du_oth_mu

*Column (4)
eststo: areg matched du_usa_mu du_oth_mu  lemp peeps cc*,ab(sic) rob
test du_usa_mu du_oth_mu


*Column (5)
eststo: areg matched du_usa_mu du_oth_mu  lemp peeps labp cc*,ab(sic) rob
test du_usa_mu du_oth_mu

esttab  using TableA6.csv, replace stats(N, fmt(%9.0f %9.0g)) cells(b(star fmt(4)) se(par fmt(4))) starlevels( * 0.10 ** 0.05 *** 0.01) keep(du_usa_mu du_oth_mu lemp labp peeps) nogap
log close

