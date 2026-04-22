
*** ownership

*** use "type" variable, classify ownership into four types: 1=state, 2=collective, 3=private, 4=foreign, 5=Hong Kong, Macau and Taiwan (4 and 5 can be combined into a single "foreign" category
*** The key is "159" and "160", which are joint stock and stock shareholding. We identify these firms' ownership using the information of other variables about firm equity structure
forvalues i = 1998/2007 {
	gen ownership`i' = real(type`i')
	recode ownership`i' 110 141 143 151=1 120 130 142 149=2 171 172 173 174 190=3 210 220 230 240=4 310 320 330 340=5 
	for any HMT`i' collective`i' foreign`i' state`i' individual`i' legal_person`i': replace e_X=0 if e_X<0
	egen e_total`i'=rsum(e_*`i')
	replace e_state`i' = e_state`i' + e_legal_person`i'
	for any state`i' collective`i' individual`i' \ num 1/3: replace ownership`i'=Y if (e_X>=e_state`i'&e_X>=e_collective`i'&e_X>=e_individual`i')&(ownership`i'==159|ownership`i'==160)
}
