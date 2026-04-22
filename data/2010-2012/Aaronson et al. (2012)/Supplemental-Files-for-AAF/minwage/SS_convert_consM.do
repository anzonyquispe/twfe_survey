/*  convert_consM.do   */

** converts consM.txt (output from printmatrix NEW.gau) to consM.dta
** insheeted data is read in inconsistently: data ometimes read in as string, sometimes as number. 
** this program takes care of that.

program check
   clear
   cd "C:\Research\minwage\results\Results_`1'_`2'hike\sims"
   *cd "D:\RESULTS_minwage\Results_`1'_`2'hike\sims"
   insheet sim_id period cons y investm using consM.txt, comma
   describe
end

*****************

program long
   gen sim_id2 = real(substr(sim_id,1,5))
   drop sim_id
   rename sim_id2 sim_id

   gen period2 = real(substr(period,1,5))
   drop period
   rename period2 period

   gen cons2 = real(substr(cons,1,5))
   drop cons
   rename cons2 cons

   gen investm2 = real(substr(investm,1,5))
   drop investm
   rename investm2 investm

   gen y2 = real(substr(y,1,10))
   drop y
   rename y2 y
   save consM, replace
end
*****************

program short
   save consM, replace
end

*****************

program convert
 check `1' `2'
 capture confirm numeric variable period
 if _rc {
   long
 }
 else {
   short
 }
 sort period sim_id, stable
 save consM, replace
end

************

/*
convert 591 no
convert 591 
convert 592
convert 593
*/





