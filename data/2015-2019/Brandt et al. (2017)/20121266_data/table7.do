clear
set more off

use firm-level-ready, clear
keep  cic_adj year firm tfp* mum1 ltar* lmaxt_* outputr

drop if tfpA==.
bysort firm (year): gen entry=1 if tfpA[_n-1]==.
bysort firm (year): gen exit =1 if tfpA[_n+1]==.
for var entry exit \ any 1998 2007: replace X=. if year==Y
bysort firm (year): gen Entry=(entry[_n-1]==1)
bysort firm (year): gen Exit =( exit[_n+1]==1)
for var entry exit: replace tfpA=. if X==1
drop if tfpA==.
egen sdcic4=sd(cic_adj), by(firm)

drop if Entry==1 & Exit==1
egen sdcic=sd(cic_adj), by(firm)
keep if sdcic==0

for any o i: egen Mltar_X=mean(ltar_X), by(cic_adj)
for any o i: egen Mlmax_X=mean(lmaxt_X), by(cic_adj)
for any o i:  gen Dltar_X=ltar_X  - Mltar_X
for any o i:  gen Dlmax_X=lmaxt_X - Mlmax_X

tabulate year, gen(YY)
egen ccyy=group(cic_adj year)

for any O I \ any o i: gen TXinc  =Dltar_Y*(1-Entry)*(1-Exit)
for any O I \ any o i: gen TXentry=Dltar_Y*Entry
for any O I \ any o i: gen TXexit =Dltar_Y*Exit
for any O I \ any o i: gen TmXinc  =Dlmax_Y*(1-Entry)*(1-Exit)
for any O I \ any o i: gen TmXentry=Dlmax_Y*Entry
for any O I \ any o i: gen TmXexit =Dlmax_Y*Exit

for var tfpA mum1 Entry Exit TOinc TIinc TOentry TIentry TOexit TIexit TmO* TmI*: egen MX=mean(X), by(cic_adj)
for var tfpA mum1 Entry Exit TOinc TIinc TOentry TIentry TOexit TIexit TmO* TmI*:  gen DX=X-MX

for num 1/10: gen YnX=YYX*Entry
for num 1/10: gen YxX=YYX*Exit
for var YY* Yn* Yx*:  egen MX=mean(X), by(cic_adj)
for var YY* Yn* Yx*:   gen DX=X-MX

for var tfpA mum1: regress DX DTOinc DTOentry DTOexit DTIinc DTIentry DTIexit DYY* DYn* DYx*, cluster(ccyy) noconst \ estimates store X1
for var tfpA mum1: ivreg   DX (DTO* DTI* = DTmO* DTmI*) DYY* DYn* DYx*, cluster(ccyy) noconst \ estimates store X2
	
estimates table mum11 mum12 tfpA1 tfpA2 , keep(DTOinc DTOentry DTOexit DTIinc DTIentry DTIexit) b(%5.3f) star(.1 .05 .01) stats(N)
estimates table mum11 mum12 tfpA1 tfpA2 , keep(DTOinc DTOentry DTOexit DTIinc DTIentry DTIexit) b(%5.3f) se(%5.3f) stats(N)

