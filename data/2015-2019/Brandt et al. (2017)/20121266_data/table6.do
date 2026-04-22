clear
set more off

use "lp analysis 20160228",clear

gsort + firm year
bysort firm LPid (year): gen growth1=2*(routput-routput[_n-1])/(routput+routput[_n-1]) if year==year[_n-1]+1 
bysort firm LPid (year): gen growth2=((routput-routput[_n-1])/(routput+routput[_n-1])+(routput[_n-1]-routput[_n-2])/(routput[_n-1]+routput[_n-2])) if year==year[_n-1]+1 & year==year[_n-2]+2 
bysort firm LPid (year): gen survive=routput[_n+1]~=.

*two types of ownership
gen     SOE=(ownership==1)

*double
gen SOE_t =SOE * tariff_output
bysort firm LPid (year): gen SOE_lt=SOE*tariff_output[_n-1]
gen  SOE_g =   SOE  * growth1
gen nSOE_g =(1-SOE) * growth1
gen t_g   =growth1 * tariff_output

*triple
gen  SOE_t_g=    SOE  * growth1 * tariff_output
gen nSOE_t_g= (1-SOE) * growth1 * tariff_output

*replaced next year
bysort firm (year): gen replacement_f1=replacement[_n+1] if year==year[_n+1]-1

egen ccyy=group(cic_adj year)

bysort firm (year): gen ltar_o = tariff_output[_n-1]
tabulate year, gen(YY)

xi: areg growth1        SOE ltar_o SOE_lt lnk tenure YY*, absorb(cic_adj) cluster(ccyy)
eststo output1
xi: areg survive        SOE ltar_o SOE_lt lnk tenure YY*, absorb(cic_adj) cluster(ccyy)
eststo survive1
xi: areg replacement_f1 SOE               growth1 SOE_g                  lnk tenure YY*, absorb(cic_adj) cluster(ccyy)
eststo rp11
xi: areg replacement_f1 SOE tariff_output SOE_t growth1 SOE_g t_g SOE_t_g lnk tenure YY* if sdown2==0|Mfirstsoe==1, absorb(cic_adj) cluster(ccyy)
eststo rp22
esttab output1 survive1 rp11 rp22, keep(SOE ltar_o tariff_output SOE_lt SOE_t growth1 SOE_g t_g SOE_t_g) b(%6.4f) star(* 0.10 ** 0.05 *** 0.01) se
