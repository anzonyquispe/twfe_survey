*** Inputs: d g t, I am assuming we have three variables called this way below, with d numeric, and t numeric taking strictly positive consecutive values

// filling the panel

fillin g t

// Baseline treatment

*largest value of t
sum t
scalar Tplus1=r(max)+1

*dates at which treatment not missing
gen t_dnotmiss=t*(d!=.)+Tplus1*(d==.)
bys g: egen firstt_donotmiss=min(t_dnotmiss)

*dropping groups whose treatment missing at all dates
drop if firstt_donotmiss==Tplus1

*baseline treatment
gen d_baseline_temp=d if t==firstt_donotmiss
bys g: egen d_baseline=min(d_baseline_temp)

// Date of first treatment change

gen t_d_diff_d_baseline=t*(d!=. & d!=d_baseline)+Tplus1*(d==.|d==d_baseline)
bys g: egen Fg=min(t_d_diff_d_baseline)

// Treatment at first treatment change

gen d_Fg_temp=d if t==Fg
bys g: egen d_Fg=min(d_Fg_temp)

// Treatment change at first change

gen first_change=d_Fg-d_baseline

// Dropping groups whose date of first treatment change is unknown

gen d_missing_atFgminus1_temp=(d==.) if t==Fg-1
bys g: egen d_missing_atFgminus1=min(d_missing_atFgminus1_temp)
drop if d_missing_atFgminus1==1

// Classifying designs

//Staggered first-switch design?
egen sd_Fg=sd(Fg)
sum sd_Fg

if r(mean)==0{

sum Fg
di "Your design is not a Staggered First Switch Design: all groups experience their first treatment change at period " r(mean) ". You cannot use the did_multiplegt_dyn package to estimate the treatment's effect."

egen sd_first_change=sd(first_change)
sum sd_first_change

if r(mean)>0{
	
di "All groups experience their first treatment change at period " r(mean) ", but the magnitude of that change varies across groups. Then, your design is an Heterogeneous Adoption Design. You may be able to use the did_had package to estimate the treatment's effect, see Chapter 7 of the DID textbook of de Chaisemartin and D'Haultfoeuille for further details."

}

if r(mean)==0{
	
di "All groups experience their first treatment change at period " r(mean) ", and the magnitude of that change does not vary across groups. Then, your design is not an Heterogeneous Adoption Design, so you cannot use the did_had package to estimate the treatment's effect."

}

xtset g t
gen fd_d=d.d
replace fd_d=abs(fd_d)
bys t: egen min_switch=min(fd_d)
bys t: egen max_switch=max(fd_d)
gen switchers_and_stayers=(max_switch>0&min_switch==0)
sum switchers_and_stayers
 	
if r(max)==1{
	
di "Your design is a Switchers and Stayers Design: there is at least one pair of consecutive time periods (t − 1, t) between which there is at least one switcher, whose treatment changes, and one stayer, whose treatment does not change. Then, if you are ready to assume that lagged treatments do not affect the current outcome beyond a pre-determined lag, you can use the did_multiplegt_stat package to estimate the treatment's effect. See Section 8.4 of the DID textbook of de Chaisemartin and D'Haultfoeuille for further details."

}

if r(max)==0{
	
di "Your design is not a Switchers and Stayers Design: there is no pair of consecutive time periods (t − 1, t) between which there is at least one switcher, whose treatment changes, and one stayer, whose treatment does not change. Then, you cannot use the did_multiplegt_stat package to estimate the treatment's effect."

}

}

if r(mean)>0{

// Is the treatment binary?
sum d
scalar d_max=r(max)
scalar d_min=r(min)
gen binary_check=(d==d_max|d==d_min)
sum binary_check
scalar binary=(r(mean)==1)

// Is the treatment absorbing?	
gen absorbing=(d==d_Fg) if t>Fg

sum absorbing

if r(min)==1&binary==1{
	
egen sd_Fg_among_switchers=sd(Fg) if Fg<Tplus1
sum sd_Fg_among_switchers

if r(mean)==0{

di "Your design is a Classical DID Design, with an absorbing and binary treatment, and no variation in treatment timing. You can use a static TWFE regression and/or an event-study TWFE regression to estimate the treatment's effect, see Chapter 3 of the DID textbook of de Chaisemartin and D'Haultfoeuille for further details."

}

if r(mean)>0{

di "Your design is a Staggered Adoption Design, with an absorbing and binary treatment, and variation in treatment timing. You can for instance use the csdid, did_multiplegt_dyn, or did2s package to estimate the treatment's effect, see Chapter 6 of the DID textbook of de Chaisemartin and D'Haultfoeuille for further details."

}

	
}

if r(min)!=1|binary!=1{
	
di "Your design is a Staggered First Switch Design, where groups experience their first treatment change at different points in time. You can use the did_multiplegt_dyn package to estimate the treatment's effect, see Section 8.3 of the DID textbook of de Chaisemartin and D'Haultfoeuille for further details. If you are ready to assume that lagged treatments do not affect the current outcome beyond a pre-determined lag, you can also use the did_multiplegt_stat package, see Section 8.4 of the DID textbook for further details."

bys d_baseline: egen sd_Fg_by_d_baseline=sd(Fg)
sum sd_Fg_by_d_baseline
if r(mean)==0{
di "While your design is a Staggered First Switch Design, where groups experience their first treatment change at different points in time, groups with the same period-one treatment all experience their first treatment change at the same date, perhaps because the period-one treatment is a continuously distributed variable (groups all have different period-one treatments). Then, you can still use the did_multiplegt_dyn package to estimate the treatment's effect, but you need to specify the continuous option, see Section 8.3.5.1 of the DID textbook of de Chaisemartin and D'Haultfoeuille for further details."	
}



}

}

	


 
