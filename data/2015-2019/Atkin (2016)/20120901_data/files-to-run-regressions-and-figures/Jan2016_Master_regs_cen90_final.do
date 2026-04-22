*This do file generates all the key tables:
qui {
clear
cap clear matrix
set mem 1000m
set matsize 10000
set maxvar 10000
set  more off

if "`c(os)'"=="Unix" {
global scratch="/home/fac/da334/Data/Mexico/Stata10/"
global dirnet="/home/fac/da334/Work/Mexico/regout/"
}

if "`c(os)'"=="Windows" {
global dirnet="C:/Work/Mexico/regout/"
global scratch="C:/Data/Mexico/Stata10/"
global dirtemp="C:/Scratch/"
global dir="C:/Work/Mexico/"
global dirrev="C:/Work/Mexico/Revision/New_code/"
global dirsub "C:/Work/Mexico/Revision/New_code/Code_submit/files to run regressions and figures/"
}

*First I set up the basic globals:
/**=============================================================**/
*Sexes, Industries, Ages
/**=============================================================**/
/**SEXES**/
global sexx "emp" 
global sexinteract=0
*if this takes the value 1, and sexx is emp and interactions are femaale, i do sex interactions with mun-fem fixed effects and i.year-sex*state FE
global indlist  `" "19" "' 
/**AGES OF EXPOSURES**/
global aget  "16"   
/**MPOP TYPE**/
global mpop "mp"  // this takes mp if used interpolated populations and cp if use basleine populations.
/**=============================================================**/
*File Names
/**=============================================================**/
/**File Used**/
global file "_skillcharbytype"
/**Regression File Name**/
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_MainXXX_\`indlist'"'
/**Do I want multiple seperate age regs in same table**/
global allages=0
/**=============================================================**/
*Variables
/**=============================================================**/
/**LHS Variables**/
global reglist   `"\`lgender3'clyrschl"'     
/**Weights**/
global weightyrschl=0
*takes the value 1 if want \`lgender3'clyrschl as weights even if LHS is different
/**RHS Variables**/
global shocker `" "delta\`lgender'50" "'  
global interactlist `""""'
global laglevelinteract=0
*this is the type of lag used for the interaction. 0=no lag, 1=2 year lag, 2=initial level
global controlinteract `""""'
global controlinsert ""
global codeinsert1 ""
global codeinsert2 ""
global codeinsert3 ""
global codeinsert4 ""
global laganything ""
*if i want to stick some lag or intial value or mean into the controls, stick it in both laganything and then controlinsert 
*inserts code or extra control just before regs are run
/**=============================================================**/
*Specification Options
/**=============================================================**/
/**RHS Remainder**/
global remainder=13 // this is the variant of how I calculate the remainder jobs term
global sexremainder=1
*this takes the value 1 if the remainder term is uses sex specific jobs or all jobs
global remainderon "0" 
*this includes a remainder of jobs term. these can be 50 or 00 jobs
/**Regression Sample**/
global iflist `" "if muncenso!=12" "'  //  "if muncenso!=12 & yobexp<=\`yobmin1990'" 
global mexicocity=0
global weightsquare=0
/**Estimates Include Municiplaity Linear Time Trend or No State Fixed Effects**/
global lineartrendon=1
*this tunrs on the linear municipality time trend
global nostatefe=0
*this tunrs on the "no state-time fixed effects" specification
global lineartrendstatefeon=0
*this removes the state-time fixed effects everywhere and replaces them with time fixed effects and runs linear trend
global firstdif=0
*this turns on Arrelano Bond with first dif. For this to work need inston=0.
global noyearfe=0
*this tunrs on the "no state-time fixed effects" specification with not even any year fixed effects
global catchupon=1
global catchlag=2
global catchlist="" //  "\`lgender3'clyrschl" 
*this turns on catchup specifications. With lags this includes the l.`catchlist'*yobexp*i.state. Without lages this includes l.`catchlist'(avreage over `catchlag' years before sample)*yobexp*i.state. Defaults to lag of two for dependent variable.
global finalrfspec=1
*this only runs the final reduced form specs for every regression (currently fe catchup or linear)
global nofeatall=0
*if this is one, then i run 5 alterante specifications sequentially dropping fixed effects. Only works with finalrfspec==_linear and no interactions and statefe on
global manual=0
global linear="_linear"
*this is _linear for rf linear specification, and blank for catchup
global residualreg=0
*if this is 1-run residual graph but need only one rhs...
/**Estimates Include IV Estimate, and Instrument Choice**/
global inston=0 
*this turns on IV regression (=1)
global ivonly=0
*this means that only the IV regs are reported if=1 (not OLS and RF as well)
global bartikon=0
*this turns on bartik. 0=off, 1=on, 2=both bartik and large expansion instruments, 3=bartik for levels, delta 50 for changes, 4=Export style bartik
global bartype="bar5rg"
*type of bartik instrument  LI0 is  initial state level growth, LI0R is with your mun removed
*global bartype bar0Rst bar0st  bar0Rrg bar0rg  bar0R bar0 
global exptype="dr2expm_"
*this is the type of export data used in in the hanson style iv
/**Additional Controls**/
global control = ""
global control2 = ""
*control 2 is not loaded from data so can stick in complicated interactions of variables loaded elsewhere
/**=============================================================**/
/**=============================================================**/
local seed = clock( c(current_time), "hms" )
set seed `seed'
local rnum=floor(runiform()*1000)
copy "${dirrev}Mregs_March13_global.do" "${dirtemp}temp`rnum'Mregs_March13_global.do", replace
if ${finalrfspec}==1 {
local rfname=""
}




*here I loop over the population measure, the trends, the weights and the lag on the catchup trend

foreach looper1 in cp {  // this takes mp if used interpolated populations and cp if use basleine populations.
foreach looper2 in "_linear"  {  //  this determines how stringent the fixed effects and time trends are: options: "_catchup" "_linear" "_notrend"  "_pretrend"
foreach looper3 in 1 {  // this is how cohorts are weighted 1 for wtyrschl, 0 for standard weight which is equal to wt`lhs'
foreach looper4 in 2 {  // for catchup spec, how big lag is: catchlag-2 is standard (means previous two period averages used)

global mpop "`looper1'"
global linear "`looper2'"
global weightyrschl=`looper3'
global catchlag=`looper4'

foreach export in 26  { //   the code used for jobs in the export classification

local exportp1=`export'+1

local namer "Jan2016_cen90_final_`export'"
local middle "_none"


local filend "_1yrexp"   




***********************************************************************************************
*Table 1 Generates summary stats in third panel of Table 1
***********************************************************************************************


/**
*==========================================================================================*
*Table 1: Summary Stats
global sexx "emp" 
global indlist   `" "`export' 13 27" "'  
global iflist `" "if muncenso!=12"   "' 
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global reglist   `"\`lgender3'clyrschl "' 
global regname=`"`namer'_Table_0_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"d\`lgender'50 d\`lgender'00 \`lgender'00"
"' ; 
#delimit cr
global manual=1
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
***********************************************************************************************

*then type:
gen q16demp5026cp_pos=q16demp5026cp if q16demp5026cp>0 & q16demp5026cp!=.
gen q16demp5026cp_neg=q16demp5026cp if q16demp5026cp<0 & q16demp5026cp!=.
gen q16demp5026cp_non0=q16demp5026cp if q16demp5026cp!=0 & q16demp5026cp!=.
egen Xq16demp5026cp_dm=wtmean(q16demp5026cp),by(muncenso) weight(eclwtyrschl)
gen q16demp5026cp_dm=q16demp5026cp-Xq16demp5026cp_dm
drop Xq16demp5026cp_dm
tabstat q16emp0013cp q16emp0026cp q16demp0013cp q16demp0026cp q16demp5013cp q16demp5026cp q16demp5026cp_pos q16demp5026cp_neg q16demp5026cp_non0 q16demp5026cp_dm if yobexp>=1970 & yobexp<=1983 [aw=eclwtyrschl] ,  stat(mean sd n) columns(statistics) varwidth(16) format(%7.0gc)

**/



***********************************************************************************************
*Table 2 Basic results
***********************************************************************************************

/**
*==========================================================================================*
*Table 2: Export  jobs on education (all)
global sexx "emp" 
global indlist   `" "`export'" "'  
global iflist `" "if muncenso!=12"   "' 
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_Table_1_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"d\`lgender'50"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
***********************************************************************************************

**/

/**
*==========================================================================================*
*Table 1: Export  jobs on education (other columns)
global sexx "emp" 
global indlist   `" "`export'" "'  
global iflist `" "if muncenso!=12"    "' 
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_Table_1_ols_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"d\`lgender'00"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"


global finalrfspec=0
global inston=0
global ivonly=0
global bartikon=0
global finalrfspec=0
global lineartrendon=0
global catchupon=1
global sexx "emp" 
global indlist   `" "`export'" "'  
global iflist `" "if muncenso!=12"    "' 
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_Table_1_ldv_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"d\`lgender'50"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
global finalrfspec=1
global inston=0
global ivonly=0
global bartikon=0
global finalrfspec=1
global lineartrendon=1
global catchupon=1


foreach rem in 13  {
global remainder=`rem' 
global sexremainder=0
global remainderon "1 2"  // this is 50 jobs
global sexx "emp" 
global indlist   `" "`export'" "'  
global iflist `" "if muncenso!=12"   "' 
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_Table_1_rem`rem'_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"d\`lgender'50"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
}
global remainderon "0" 


global finalrfspec=0
global inston=1
global ivonly=1
global bartikon=0
global lineartrendon=1
global catchupon=0
global sexx "emp" 
global indlist   `" "`export'" "'  
global iflist `" "if muncenso!=12"    "' 
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_Table_1_iv_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"d\`lgender'00"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
global finalrfspec=1
global inston=0
global ivonly=0
global bartikon=0
global finalrfspec=1
global lineartrendon=1
global catchupon=1
***********************************************************************************************


*==========================================================================================*
*Run residual regs to generate Figure C.3
global sexx "emp" 
global residualreg=1
global indlist  `" "`export'"  "'  
global reglist   `"\`lgender3'clyrschl"' 
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_XgraphX_\`indlist'"'
global shocker `"  "d\`lgender'00"  "d\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
global residualreg=0
***********************************************************************************************

**/


***********************************************************************************************
*Table 3 Long changes
***********************************************************************************************

/**
do "${dirrev}Jan2016_LongChange_1990_2000.do"
**/

***********************************************************************************************
*Table 4 Other Export measures
***********************************************************************************************

/**
*these are export data from feenstra divided by employment data from IMSS to get exports per worker.
*==========================================================================================*
*Table 4: Export  jobs on education (top quartile of exports per worker)
global sexx "emp" 
global indlist   `" "x5x36" "'  
global iflist `" "if muncenso!=12"   "' 
global aget  "16"   
global file "_genericskill_feenstra4exppworker_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_Table_3_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"d\`lgender'50"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
***********************************************************************************************

*these are year by year export measures
*==========================================================================================*
*Table 4: Export  jobs on education (all and post90)
global sexx "emp" 
global indlist   `" "`export'"  "'  
global iflist `" "if muncenso!=12"   "' 
global aget  "16"   
global file "_genericskill_expyrbyyr_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_Table_3_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"d\`lgender'50"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
***********************************************************************************************

**/


/**
use yobexp muncenso  q16delta2*pop  using "${scratch}reg2year_mwyes_2000_july11_exporters_new_1516_16.dta", clear
*keep yobexp muncenso q1516*
renvars q*pop , postsub(pop p)
renvars q*p , sub(delta d)
*gen q1516dmaqinegi0011cp = q1516dmaq0011cp+ q1516dall0011cp
*gen q1516dmaqinegi0011mp = q1516dmaq0011mp+ q1516dall0011mp
*gen q1516dmaqinegi0011gp = q1516dmaq0011gp+ q1516dall0011gp
*gen q16dmaqinegi0011cp = q16dmaq0011cp+ q16dall0011cp
*gen q16dmaqinegi0011gp = q16dmaq0011gp+ q16dall0011gp
*gen q16dmaqinegi0011mp = q16dmaq0011mp+ q16dall0011mp
sort yobexp muncenso
save "${scratch}mergesubset_exporters_ericpanel_1516.dta", replace
use "${scratch}reg2year_mwyes_2000_july11_genericskill_none_cen90_1yrexp.dta"
drop if muncenso==. | yobexp==.
merge 1:1 yobexp muncenso using "${scratch}mergesubset_exporters_ericpanel_1516.dta", generate(_merge99)

foreach ends in 20 21 22 23 24 {
foreach type in a b {
gen q16d2exp`type'm00`ends'cp=q16d2nmq`type'00`ends'cp+q16maqemp0011cp
gen q16d2exp`type'me00`ends'cp=q16d2nmq`type'00`ends'cp+q16maqeemp0011cp
gen q16d2exp`type'mec00`ends'cp=q16d2nmq`type'00`ends'cp+q16maqecemp0011cp
}
gen q16dmaqm00`ends'cp=q16maqemp0011cp
gen q16dmaqme00`ends'cp=q16maqeemp0011cp
gen q16dmaqmec00`ends'cp=q16maqecemp0011cp
gen q16dmaqm50`ends'cp=q16maqemp5011cp
gen q16dmaqme50`ends'cp=q16maqeemp5011cp
gen q16dmaqmec50`ends'cp=q16maqecemp5011cp
}

save "${scratch}reg2year_mwyes_2000_july11_exporter_new_1516_16.dta", replace
cap erase "${scratch}mergesubset_exporters_ericpanel_1516.dta"


*Linear OLS and Reduced Form
global mpop "cp"
global sexx "emp" 
global indlist  `" "22"  "'  // 
global linear="_linear"
global iflist `" "if muncenso!=12 & yobexp>1969"  "' 
global aget  "16"   
global file "_exporter_new_1516_16"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_3_combo_\`indlist'"'
#delimit ;

global shocker `"   
"dmaqm50" 
"dmaqme50" 
"d2nmqb00"
"d2nmqb00 dmaqm50"
"d2nmqb00 dmaqme50"
"d2uskb00 d2skib00"


"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"




*==========================================================================================*
**/








***********************************************************************************************
*Table 5 Gender
***********************************************************************************************
/**
*==========================================================================================*
*Table 5: Male female (cols 1/2)
global sexx "male fem" 
global indlist   `" "`export'" "'  
global iflist `" "if muncenso!=12"  "' 
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_Table_4a1_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"demp50"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
***********************************************************************************************

**/



/**
*==========================================================================================*
*Table 5: Male female placebo (using imss sex data initial) (cols 9/10)
global sexx "male female"  
global indlist   `" "`export'" "'   
global iflist `" "if muncenso!=12"    "' 
global aget  "16"  
global file "_genericskill_skillsexinitial86_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_Table_4b4_`rfname'_\`sexx'_\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"' 
#delimit ;
global shocker `"   
"dempm86i1ra00_50 dempf86i1ra00_50"
"' ; 
global randomuse "";
global controlinteract   `"  
""
"';
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
global randomuse ""
global controlinteract   `"  "" "'

***also dabbled with "dempm86i2ra00_50 dempf86i2ra00_50"

***********************************************************************************************

*==========================================================================================*
*Table 5: Male female placebo (using imss sex data initial)  (cols 7/8)
global sexx "male female" 
global indlist   `" "`export'" "'   
global iflist `""if muncenso!=12 & yobexp>=\`yobmin1990'"    "' 
global aget  "16"  
global file "_genericskill_skillsexinitial86_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_Table_4b3_`rfname'_\`sexx'_\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"' 
#delimit ;
global shocker `"   
"demptdm9i1ra50_50 demptdf9i1ra50_50"
"' ; 
global randomuse "";
global controlinteract   `"  
""
"';
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
global randomuse ""
global controlinteract   `"  "" "'

***********************************************************************************************
**/

/**
*==========================================================================================*
*Table 5: Male female placebo first stage
global sexx "emp"  
global indlist   `" "`export'" "'   
global iflist `" "if muncenso!=12"    "' 
global aget  "16"  
global file "_genericskill_skillsexinitial86_cen90`filend'"
global reglist   `"q${aget}dmale50\`indlist'`looper1' q${aget}dfem50\`indlist'`looper1'"' 
global regname=`"`namer'_Table_4b4fs_`rfname'_\`sexx'_\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"' 
#delimit ;
global shocker `"   
"dempm86i1ra00_50 dempf86i1ra00_50"
"' ; 
global randomuse "";
global controlinteract   `"  
""
"';
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
global randomuse ""
global controlinteract   `"  "" "'
***********************************************************************************************

*==========================================================================================*
*Table 5: Male female placebo first stage
global sexx "emp" 
global indlist   `" "`export'" "'   
global iflist `" "if muncenso!=12 & yobexp>=\`yobmin1990'" "' 
global aget  "16"  
global file "_genericskill_skillsexinitial86_cen90`filend'"
global reglist   `"q${aget}dmale50\`indlist'`looper1' q${aget}dfem50\`indlist'`looper1'"' 
global regname=`"`namer'_Table_4b3fs_`rfname'_\`sexx'_\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"' 
#delimit ;
global shocker `"
"demptdm9i1ra50_50 demptdf9i1ra50_50"
"' ; 
global randomuse "";
global controlinteract   `"  
""
"';
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
*global randomuse "q${aget}dmale????cp q${aget}dfem????cp"
global controlinteract   `"  "" "'
***********************************************************************************************
**/




*==========================================================================================*
*Table 6: Later life incomes
/**

global sexx "emp" 
global indlist   `" "`export'" "'  
global iflist `" "if muncenso!=12"   "' 
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'_Table_7a_`rfname'_\`sexx'_\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global reglist `"
eclxtinctot 
eclxtincearn 
eclxtincearnlnwage 
eclxtincearnlnhrs
eclrsincearnlnhrs612
"' ;  
global shocker `"  
"d\`lgender'50" 
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
**/
*==========================================================================================*






















***********************************************************************************************
*Figures 4 and 5 (effects at many ages)
***********************************************************************************************


/**
*==========================================================================================*
*Figures 4 and 5: other ages
global sexx "emp" 
global indlist   `" "`export'" "'  
global iflist `" "if muncenso!=12" "'   
global allages=1
global aget  "6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23"   
global file "_genericskill`middle'_cen90_allyear`filend'"
global reglist   `"\`lgender3'clyrschl \`lgender3'clyrschlprop08 \`lgender3'cldropq10 "'   
global regname=`"`namer'_Table_5_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"d\`lgender'50"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
***********************************************************************************************

*these coefficient are then used by the following file: ageofexposure_regs.do
*to generate Figures 4 and 5

**/




/**


*==========================================================================================*
*Table C.1: Multiple Ages in Same Reg
global sexx "emp" 
global indlist   `" "`export'" "'  
global iflist `" "if muncenso!=12"  "' 
global aget  "16"   
global allages=1
global file "_genericskill`middle'_cen90_allyear`filend'"
global reglist   `"\`lgender3'clyrschl \`lgender3'cldropq10 \`lgender3'clyrschlprop08"' 
global regname=`"`namer'_Table_5b1_`rfname'_\`sexx'_\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"  
"d\`lgender'50" 
"' ; 
global controlinteract   `"
"q14demp50\`indlist'`looper1' q15demp50\`indlist'`looper1' q16demp50\`indlist'`looper1' q17demp50\`indlist'`looper1' q18demp50\`indlist'`looper1'"
"';
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"

*==========================================================================================*

*==========================================================================================*
*Table C.1: Multiple Ages in Same Reg
global sexx "emp" 
global indlist   `" "`export'" "'  
global iflist `" "if muncenso!=12"  "' 
global aget  "13"   
global allages=1
global file "_genericskill`middle'_cen90_allyear`filend'"
global reglist   `"\`lgender3'clyrschl \`lgender3'cldropq10 \`lgender3'clyrschlprop08"' 
global regname=`"`namer'_Table_5b2_`rfname'_\`sexx'_\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"  
"d\`lgender'50" 
"' ; 
global controlinteract   `"
"q11demp50\`indlist'`looper1' q12demp50\`indlist'`looper1' q13demp50\`indlist'`looper1' q14demp50\`indlist'`looper1' q15demp50\`indlist'`looper1'"
"';
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"

*==========================================================================================*
**/












***********************************************************************************************
*Figure 7 Are exports different?
***********************************************************************************************

local namez "`namer'"

foreach nonexport in 27     {    

local namer "`namez'"

/**
***********************************************************************************************
*Figure 7: Export and non export  jobs on education at many ages
global sexx "emp" 
global indlist   `" "`nonexport' `export'" "'  
global iflist `" "if muncenso!=12"   "'  
global allages=1
global aget  "6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23"  
global file "_genericskill_none_cen90_allyear`filend'"
global reglist   `"\`lgender3'clyrschl"'  
global regname=`"`namer'_Table_11x_nx`nonexport'_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"d\`lgender'50"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
***********************************************************************************************
**/

*these coefficient are then used by the following file: ageofexposure_regs.do
*to generate Figure 7



}


***********************************************************************************************
*Table 7 Heterogeneity
***********************************************************************************************

/**
winexec "C:\My Dropbox\Stata13\StataMP-64" do "${dirsub}Jan2016_Heterogeneity_regs_cen90_final.do"
sleep 15000
winexec "C:\My Dropbox\Stata13\StataMP-64" do "${dirsub}Jan2016_Heterogeneity_regs_cen90_final_altdelta.do"
sleep 15000
winexec "C:\My Dropbox\Stata13\StataMP-64" do "${dirsub}Jan2016_Heterogeneity_regs_cen90_final_herfa.do"
sleep 15000
**/

***********************************************************************************************






*==========================================================================================*


***********************************************************************************************
*Figures 6, C.4, C.5, C.6, C.7, Table C.2, C.3, C.4 Cross Section analysis
***********************************************************************************************
/*
do "${dirrev}MDiff_in_diff_setup.do"
do "${dirrev}MDiff_in_diff_otheroutcomes_individual.do"
do "${dirrev}MDiff_in_diff_otheroutcomes_individual_munfe.do"
*this generates Ishort and Iparents graphs and tables for schatt etc....
*/


*==========================================================================================*














*==========================================================================================*
*Table B.1: Migration
/**

*Log Cohort Size (col 1)
global sexx "emp" 
global reglist   `"\`lgender3'clyrschl"' 
global indlist   `" "`export'" "'  // 
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_7b1_\`indlist'"'
#delimit ;
global shocker `"  
"d\`lgender'50"
"' ; 
#delimit cr
global codeinsert1 "cap gen \`lgender3'clyrschllnn=log(\`lgender3'clwtyrschl)"
global codeinsert2 "cap drop \`lgender3'clyrschl"
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"





*Cohort Size/Working Population (col 2)
global sexx "emp" 
global reglist   `"\`lgender3'clyrschl"' 
global indlist   `" "`export'"  "'  
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_7b3_\`indlist'"'
#delimit ;
global shocker `"  
"d\`lgender'50"
"' ; 
#delimit cr
global randomuse "q\`aget'\`lgender'munpop"
global codeinsert1 "cap drop \`lgender3'clyrschlmp"
global codeinsert2 "gen \`lgender3'clyrschlmp=\`lgender3'clwtyrschl/q\`aget'\`lgender'munpop"
global codeinsert3 "cap drop \`lgender3'clyrschl"
global codeinsert4 ""
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"





*MigrantPropInteraction
global sexx "emp" 
global reglist   `"\`lgender3'clyrschl"' 
global indlist   `" "`export'" "' //  
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global interactlist   `" "migpropform_2000_`export'"  "migprop_2000_13"  "' 
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_7b5_\`indlist'"'
*global manual=1
#delimit ;
global shocker `"  
"d\`lgender'50"
"' ; 
#delimit cr
*global testes=1
global codeinsert1 "cap mvencode migprop*, mv(0) override"
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
*global testes=0
global codeinsert1 ""





***code from Mcohort_avg_firm_prepare_mig_Aug2014.do to get leavestay regs
*this file takes
*cohortmeans_mwyes_2000migwide.dta
*merges in the ratio of leavers and stayers, and then regresses on the sume of shocks 1995-1999

use "${scratch}reg2year_mwyes_2000_july11_genericskill_none_cen90_1yrexp.dta"
gen year=yobexp+16
drop if year<1995
drop if year>=2000
foreach type of var q16demp???6cp {
egen tot`type'=total(`type'), by(muncenso)
}

egen tagmun=tag(muncenso)
keep if tagmun==1
merge 1:1 muncenso using "${scratch}cohortmeans_mwyes_2000migwide.dta",  generate(_mergecen) keep(match master) keepusing(eclyrschlr eclwtyrschlr)
xi: reg  eclyrschlr  totq16demp5026cp  i.state [aweight= eclwtyrschlr], robust
outreg2 totq16demp5026cp using "${dirrev}`namer'_Table_7b7_leavestay3", ctitle("eclyrschlr  demp26")    nonotes  excel nocons 
*this is the basic reg - just adding up all the deltaperworkers and anyone who was 15-20 in 1995-1999

**/

*==========================================================================================*









*==========================================================================================*
*Appendix Tables: Robustness



/**




*P/D, Hire/Fire/Expan
global sexx "emp" 
global indlist   `" "`export'" "'
global iflist `" "if muncenso!=12"   "'  
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15a_\`indlist'"'
global shocker `"  "pod\`lgender'50 ned\`lgender'50"  "hire\`lgender'50 fire\`lgender'50" "exp\`lgender'50 new\`lgender'50 fire\`lgender'50" "new\`lgender'50" "dx\`lgender'50" "exp\`lgender'50 new\`lgender'50 fire\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
*dx is hire+fire


*P/D, Hire/Fire/Expan
global sexx "emp" 
global indlist   `" "`export'" "'
global iflist `" "if muncenso!=12"   "'  
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15a2_\`indlist'"'
global shocker `" "hire\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
 

**/

/**

*Other LHS
global sexx "emp" 
global indlist   `" "`export'" "'
global iflist `" "if muncenso!=12"   "'   
global reglist   `"\`lgender3'clyrschl2  \`lgender3'clyrschl2fin"'  
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15b_\`indlist'"'
global shocker `"  "d\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"

**/



/**
*100 thresh
global sexx "emp" 
global indlist   `" "`export'" "'
global iflist `" "if muncenso!=12"   "'   
global reglist   `"\`lgender3'clyrschl"'
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15d_\`indlist'"'
global shocker `"  "d\`lgender'100" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"


**/

/**
*if lists
global sexx "emp" 
global indlist   `" "`export'" "'  
global reglist   `"\`lgender3'clyrschl"' 
global iflist `"  "if munmatch==1 & muncenso!=12" "if muncenso!=20 & muncenso!=30 & muncenso!=12" "'
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15e1_\`indlist'"'
global shocker `"  "d\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"


*if lists
global sexx "emp" 
global indlist   `" "`export'" "'  
global reglist   `"\`lgender3'clyrschl"' 
global iflist `" "if muncenso!=12 & region2==2" "if muncenso!=12 & region2==3" "if muncenso!=12 & region2==6" "if muncenso!=12 & rhhincomepc2000>904" "if muncenso!=12 & rhhincomepc2000<=904"  "'
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15e2_\`indlist'"'
global shocker `"  "d\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"

* met zones and not
global sexx "emp" 
global indlist   `" "`export'" "'  
global reglist   `"\`lgender3'clyrschl"' 
global iflist `"  "if muncenso<=99 & muncenso!=12" "if muncenso>99 & muncenso!=12" "'
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15e3_\`indlist'"'
global shocker `"  "d\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"

*progressa
global sexx "emp" 
global indlist   `" "`export'" "'  
global reglist   `"\`lgender3'clyrschl"'
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15f_\`indlist'"'
global iflist `"  "if muncenso!=12" "'
global shocker `"  "d\`lgender'50" "'  
global control2   `"i.progexpose"'
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"


**/
 



/**
*muni/non muni with (3) region dummies
global sexx "emp" 
global indlist   `" "`export'" "'  
global reglist   `"\`lgender3'clyrschl"'
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15g1_\`indlist'"'
global iflist `"  "if muncenso!=12"  "if muncenso<=99 & muncenso!=12" "if muncenso>99 & muncenso!=12" "'
global nostatefe=1
global control2   `"i.region2*i.yobexp"'
global shocker `"  "d\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"



*region with (3) region dummies
global sexx "emp" 
global indlist   `" "`export'" "'  
global reglist   `"\`lgender3'clyrschl"'
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15g2_\`indlist'"'
global iflist `"  "if muncenso!=12 & region2==2" "if muncenso!=12 & region2==3" "if muncenso!=12 & region2==6" "'
global nostatefe=1
global control2   `"i.region2*i.yobexp"'
global shocker `"  "d\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"




*mexico city with (3) region dummies
global sexx "emp" 
global indlist   `" "`export'" "'  
global reglist   `"\`lgender3'clyrschl"'
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15h_\`indlist'"'
global mexicocity=1
global iflist `"  "if muncenso>0" "'
global nostatefe=1
global control2   `"i.region2*i.yobexp"'
global shocker `"  "d\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
global nostatefe=0
global control2   `""'




*no fixed effects
global sexx "emp" 
global indlist   `" "`export'" "'  
global reglist   `"\`lgender3'clyrschl"'
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15i_\`indlist'"'
global iflist `"  "if muncenso!=12"  "'
global nofeatall=1
global shocker `"  "d\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
global nofeatall=0





*Spillovers
global sexx "emp" 
global indlist   `" "`export'" "'
global iflist `" "if muncenso!=12"   "'  
global aget  "16"   
global file "_genericskill`middle'_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15j_\`indlist'"'
global nostatefe=1
global lineartrendstatefeon=1
global noyearfe=1
#delimit ;
global shocker `"   
"d\`lgender'50 ssd\`lgender'50"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
global nostatefe=0
global lineartrendstatefeon=0
global noyearfe=0






*Dev, rfif (these are changes that are abnormal at frim level)
global sexx "emp" 
global indlist   `" "`export'" "'
global iflist `" "if muncenso!=12"   "'  
global aget  "16"   
global reglist   `"\`lgender3'clyrschl"' 
global file "_genericskill`middle'_cen90`filend'"
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_Table_15l_\`indlist'"'
global shocker `"  "dev\`lgender'50" "rfif\`lgender'50" "'  
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"


**/


********************************************************
*Differentiated industries (Figure D.1)

/**
*Herfindahl other ages
global sexx "emp" 
global indlist   `" "`export' `exportp1'" "`export'" "'  
global iflist `" "if muncenso!=12" "'    
global allages=1
global aget  "7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23"   
global file "_genericskill_nowage_many_alt16_allyear"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_Table_15k2_manyage_`rfname'_\`sexx'_\`aget'\`file'_`looper1'`looper2'`looper3'`looper4'_\`indlist'"'
#delimit ;
global shocker `"   
"dha\`lgender'50"
"' ; 
#delimit cr
noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
***********************************************************************************************
**/











} // *export

}
}
}
}
*end of looper


exit, STATA clear



break here





