capture program drop postmoments

program postmoments3, eclass 

//syntax  N(scalar) name(string) 

local M = N
local name = name

quietly{
di "`name'"

di `M'

scalar gamma = e(gamma)
scalar epsilon = e(epsilon)

scalar Chi = e(Q)
scalar ChiPval = e(pval)

mat mt = e(moments) 
mat mtV = e(moments_V) 

mat mt2 = e(moments_pred) 
mat mtV2 = e(moments_V)*0

mat colnames mt = Pop_Tax Pop_Bartik Pop_Pers Wage_Tax Wage_Bartik Wage_Pers Rent_Tax Rent_Bartik Rent_Pers Est_Tax Est_Bartik Est_Pers
mat colnames mtV = Pop_Tax Pop_Bartik Pop_Pers Wage_Tax Wage_Bartik Wage_Pers Rent_Tax Rent_Bartik Rent_Pers Est_Tax Est_Bartik Est_Pers
mat rownames mtV = Pop_Tax Pop_Bartik Pop_Pers  Wage_Tax Wage_Bartik Wage_Pers Rent_Tax Rent_Bartik Rent_Pers Est_Tax Est_Bartik Est_Pers

ereturn post mt mtV, obs(`M')
ereturn local title "structural estimates"
ereturn local cmd "postmat2"

lincom _b[Est_Tax] - _b[Pop_Tax] +(gamma*(epsilon+1)-1)*_b[Wage_Tax]
ereturn scalar ATest_TStat = r(estimate)/r(se)
ereturn scalar ATest_pval = 2*ttail(1398,abs(r(estimate)/r(se)))

ereturn scalar Chi = Chi
ereturn scalar ChiPval = ChiPval

est sto moment_1_`name'

mat colnames mt2 = Pop_Tax Pop_Bartik Pop_Pers Wage_Tax Wage_Bartik Wage_Pers Rent_Tax Rent_Bartik Rent_Pers Est_Tax Est_Bartik Est_Pers
mat colnames mtV2 = Pop_Tax Pop_Bartik Pop_Pers Wage_Tax Wage_Bartik Wage_Pers Rent_Tax Rent_Bartik Rent_Pers Est_Tax Est_Bartik Est_Pers
mat rownames mtV2 = Pop_Tax Pop_Bartik Pop_Pers Wage_Tax Wage_Bartik Wage_Pers Rent_Tax Rent_Bartik Rent_Pers Est_Tax Est_Bartik Est_Pers

ereturn post mt2 mtV2, obs(`M')
ereturn local title "structural estimates"
ereturn local cmd "postmat2"

est sto moment_2_`name'

}

*esttab moment* , stat(Chi ChiPval) star(* 0.10 ** 0.05 *** 0.01)  mtitles("Empirical" "Predicted")

esttab moment* , se stat(Chi ChiPval ATest_TStat ATest_pval) star(* 0.10 ** 0.05 *** 0.01)  mtitles("Empirical" "Predicted")

end 
