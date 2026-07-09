set more off
cap log using tablea5,t replace
***Source: Nick Bloom, November 2010, nbloom@stanford.edu
*This file investigates the sampling bias in the CEP management survey.
*It tests if multinationals responded differently to the telephone management survey request than other firms. 
*Sample is all eligible (i.e. alive manufacturing) firms with 100 to 5000 employees that were approached for an interview in the European countries analyzed in the Bloom, Sadun and Van Reenen (2010) paper
*The variables "allinterview" is equal to unity if the firm was interviewed, and zero otherwise. Those interviewed firms with suitable accounting data were used in Column (1) of Table 6.
*Note the variables aa1, aa2 etc are analyst interview dummies

u sampling_final_TableA5,replace
lab var allinterview "Firm completed management interview"
lab var labp "Labor productivity = log(sales/employee)"
lab var lemp "Log(employment)"
lab var du_usa_mu "US multinational"
lab var du_oth_mu "Non-US multinational"

set more off

*Column (1)
cap estimates drop *
eststo: areg allinterview du_usa_mu du_oth_mu            cc* aa*,ab(sic) rob
test du_usa_mu du_oth_mu

*Column (2)
eststo: areg allinterview                      lemp      cc* aa*,ab(sic) rob

*Column (3)
eststo: areg allinterview du_usa_mu du_oth_mu  lemp      cc* aa*,ab(sic) rob
test du_usa_mu du_oth_mu

*Column (4)
eststo: areg allinterview du_usa_mu du_oth_mu  lemp labp cc* aa*,ab(sic) rob
test du_usa_mu du_oth_mu
esttab  using TableA5.csv, replace stats(N, fmt(%9.0f %9.0g)) cells(b(star fmt(4)) se(par fmt(4))) starlevels( * 0.10 ** 0.05 *** 0.01) keep(du_usa_mu du_oth_mu lemp labp) nogap
log close



