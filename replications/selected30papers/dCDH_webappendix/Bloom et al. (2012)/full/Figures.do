clear
use Figures,clear
*Figure 3A
graph hbar peeps,over(country,sort(1) reverse)
*Figure 3B
graph hbar peeps if MNE_tot>=25&MNE_o==1&europe==1,over(MNE_cty,sort(1) reverse)


