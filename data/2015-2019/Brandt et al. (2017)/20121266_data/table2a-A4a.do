clear
local temp: tempfile

use "../Luhang-trade/table3customs6dupdate_regdata", clear
sort hs_adj y
replace v=. if y<2000|y>2006
sort y hs_adj DF tradefirm
save `temp', replace

use "imp2007_limited", clear
gen y=2007
gen tradefirm=1
rename value v
gen lnim=log(v)
sort y hs_adj DF tradefirm
merge y hs_adj DF tradefirm using `temp', update
drop if _merge==1
drop _merge
sort hs_adj y
save `temp', replace


use "../instrument/tariffIV_hs_adj.dta", clear
keep hs_adj y maxtariff_o
replace maxtariff_o = maxtariff_o/100
drop if maxtariff_o==.
sort hs_adj y
merge hs_adj y using `temp'
replace maxtariff_o=r if _merge==2
drop _merge

drop imt cap mat auto indfb hhfb dconsp ndconsp
*----------------------
*      bec |      Freq.
*----------+-----------
*      111 |      2,232   primary food & bev. for industry  --> mat
*      112 |      8,892   primary food & bev. for househ.   --> mat
*      121 |      3,888   process food & bev. for industry  -->     imt
*      122 |     11,928   process food & bev. for househ.   -->             cons 
*       21 |     13,548   primary indus. supplies           --> mat
*       22 |    103,692   process indus. supplies           -->     imt
*       31 |        444   primary fuel & lubricant          --> mat
*      322 |        744   process fuel & lubricant (oth.)   -->     imt
*       41 |     29,628   capital goods                     -->         cap
*       42 |     12,900   capital goods parts & access.     -->     imt
*       51 |        384   passenger motor cars              -->         cap
*      521 |      2,100   other transport eq. for industry  -->         cap
*      522 |        888   other transport eq. for househ.   -->         cap
*       53 |      4,848   transport eq. parts * access.     -->     imt
*       61 |      7,680   consomer goods: durable           -->             cons
*       62 |     19,692   consomer goods: semi-durable      -->             cons
*       63 |     10,140   consomer goods: non-durable       -->             cons
*        7 |        432   
*      n/a |         24
*----------------------
gen mat = bec=="111" | bec=="112" | bec=="21"  | bec=="31"  
gen imt = bec=="121"              | bec=="22"  | bec=="322" | bec=="42"  | bec=="53"
gen cap = bec=="41"  | bec=="51"  | bec=="521" | bec=="522"
gen cons= bec=="122" | bec=="61"  | bec=="62"  | bec=="63"  
gen all = 1

tabulate y, gen(yy)
egen HS_adj=group(hs_adj)

gen tfTC1= r           * (tradefirm==1)
gen tfDF1= r           * (DF       ==1)
gen IVTC1= maxtariff_o * (tradefirm==1)
gen IVDF1= maxtariff_o * (DF       ==1)

egen Tv=sum(v), by(y hs_adj)
bysort y hs_adj (Tv): gen lnTv=log(Tv) if _n==1
for any all mat imt cap cons: xtreg   lnTv              r                            yy*              if X==1, i(HS_adj) fe robust cluster(HS_adj) \ estimates store C1X
for any all mat imt cap cons: xtreg   lnim  tfTC1 tfDF1 r                            yy* DF tradefirm if X==1, i(HS_adj) fe robust cluster(HS_adj) \ estimates store C2X
for any all mat imt cap cons: xtivreg lnim (tfTC1 tfDF1 r = IVTC1 IVDF1 maxtariff_o) yy* DF tradefirm if X==1, i(HS_adj) fe                        \ estimates store C3X

estimates table C1all C1mat C1imt C1cap C1cons, keep(r) b(%5.3f) star(.01 .05 .1) stats(N r2)
estimates table C1all C1mat C1imt C1cap C1cons, keep(r) b(%5.3f) se(%5.3f) stats(N r2)

estimates table C2all C2mat C2imt C2cap C2cons, keep(r) b(%5.3f) star(.01 .05 .1) stats(N r2)
estimates table C2all C2mat C2imt C2cap C2cons, keep(r) b(%5.3f) se(%5.3f) stats(N r2)

estimates table C3all C3mat C3imt C3cap C3cons, keep(r) b(%5.3f) star(.01 .05 .1) stats(N r2)
estimates table C3all C3mat C3imt C3cap C3cons, keep(r) b(%5.3f) se(%5.3f) stats(N r2)
for any all mat imt cap cons, pause: xi: ivreg lnim (tfTC1 tfDF1 r = IVTC1 IVDF1 maxtariff_o) yy* DF tradefirm i.HS_adj if X==1 , cluster(HS_adj)
