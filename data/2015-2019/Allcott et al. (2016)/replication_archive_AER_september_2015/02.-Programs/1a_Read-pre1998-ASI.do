************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

************************************************************************
************************************************************************
cd "$data/ASI/raw data"

# delim ;	cap log close; cap erase "$work/infiling log.txt";	 
qui infile using "$do/Dictionaries/in9293.dic" ;	save "$work/in9293.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_011.dic" ;	keep if recordcat==11;	save "$work/in9394_011.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_040.dic" ;	keep if recordcat==40;	save "$work/in9394_040.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_053.dic" ;	keep if recordcat==53 | recordcat==51;	save "$work/in9394_053.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_074.dic" ;	keep if recordcat==74;	save "$work/in9394_074.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_081.dic" ;	keep if recordcat==81;	save "$work/in9394_081.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_082.dic" ;	keep if recordcat==82;	save "$work/in9394_082.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_091.dic" ;	keep if recordcat==91;	save "$work/in9394_091.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_101.dic" ;	keep if recordcat==101;	save "$work/in9394_101.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_102.dic" ;	keep if recordcat==102;	save "$work/in9394_102.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_111.dic" ;	keep if recordcat==111;	save "$work/in9394_111.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_121.dic" ;	keep if recordcat==121;	save "$work/in9394_121.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_131.dic" ;	keep if recordcat==131;	save "$work/in9394_131.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_132.dic" ;	keep if recordcat==132;	save "$work/in9394_132.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_133.dic" ;	keep if recordcat==133;	save "$work/in9394_133.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9394_141.dic" ;	keep if recordcat==141;	save "$work/in9394_141.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_011.dic" ;	keep if recordcat==11;	save "$work/in9495_011.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_040.dic" ;	keep if recordcat==40;	save "$work/in9495_040.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_053.dic" ;	keep if recordcat==53 | recordcat==51;	save "$work/in9495_053.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_074.dic" ;	keep if recordcat==74;	save "$work/in9495_074.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_081.dic" ;	keep if recordcat==81;	save "$work/in9495_081.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_082.dic" ;	keep if recordcat==82;	save "$work/in9495_082.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_091.dic" ;	keep if recordcat==91;	save "$work/in9495_091.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_101.dic" ;	keep if recordcat==101;	save "$work/in9495_101.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_102.dic" ;	keep if recordcat==102;	save "$work/in9495_102.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_111.dic" ;	keep if recordcat==111;	save "$work/in9495_111.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_121.dic" ;	keep if recordcat==121;	save "$work/in9495_121.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_131.dic" ;	keep if recordcat==131;	save "$work/in9495_131.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_132.dic" ;	keep if recordcat==132;	save "$work/in9495_132.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_133.dic" ;	keep if recordcat==133;	save "$work/in9495_133.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9495_141.dic" ;	keep if recordcat==141;	save "$work/in9495_141.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_011.dic" ;	save "$work/in9596_011.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_040.dic" ;	save "$work/in9596_040.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_053.dic" ;	save "$work/in9596_053.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_074.dic" ;	save "$work/in9596_074.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_081.dic" ;	save "$work/in9596_081.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_082.dic" ;	save "$work/in9596_082.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_091.dic" ;	save "$work/in9596_091.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_101.dic" ;	save "$work/in9596_101.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_102.dic" ;	save "$work/in9596_102.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_111.dic" ;	save "$work/in9596_111.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_121.dic" ;	save "$work/in9596_121.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_131.dic" ;	save "$work/in9596_131.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_132.dic" ;	save "$work/in9596_132.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_133.dic" ;	save "$work/in9596_133.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9596_141.dic" ;	save "$work/in9596_141.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_011.dic" ;	save "$work/in9697_011.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_040.dic" ;	save "$work/in9697_040.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_053.dic" ;	save "$work/in9697_053.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_074.dic" ;	save "$work/in9697_074.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_081.dic" ;	save "$work/in9697_081.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_082.dic" ;	save "$work/in9697_082.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_091.dic" ;	save "$work/in9697_091.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_102.dic" ;	save "$work/in9697_102.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_111.dic" ;	save "$work/in9697_111.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_121.dic" ;	save "$work/in9697_121.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_131.dic" ;	save "$work/in9697_131.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_132.dic" ;	save "$work/in9697_132.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_133.dic" ;	save "$work/in9697_133.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9697_141.dic" ;	save "$work/in9697_141.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
# delim ;
qui infile using "$do/Dictionaries/in9798_11.dic" ;	save "$work/in9798_11.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_21.dic" ;	save "$work/in9798_21.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_23.dic" ;	save "$work/in9798_23.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_31.dic" ;	save "$work/in9798_31.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_32.dic" ;	save "$work/in9798_32.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_33.dic" ;	save "$work/in9798_33.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_41.dic" ;	save "$work/in9798_41.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_42.dic" ;	save "$work/in9798_42.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_51.dic" ;	save "$work/in9798_51.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_52.dic" ;	save "$work/in9798_52.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_61.dic" ;	save "$work/in9798_61.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_81.dic" ;	save "$work/in9798_81.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;
qui infile using "$do/Dictionaries/in9798_91.dic" ;	save "$work/in9798_91.dta" , replace ;	qui log using "$work/infiling log.txt", t append; desc; qui log c; clear ;

# delim ; 
clear;
qui infile using "$do/Dictionaries/in9899_a.dic" ;	save "$work/in9899_a.dta" , replace ; clear ;
qui infile using "$do/Dictionaries/in9899_b.dic" ;	save "$work/in9899_b.dta" , replace ; clear ;
qui infile using "$do/Dictionaries/in9899_c.dic" ;	save "$work/in9899_c.dta" , replace ; clear ;
qui infile using "$do/Dictionaries/in9899_d.dic" ;	save "$work/in9899_d.dta" , replace ; clear ;
qui infile using "$do/Dictionaries/in9899_e.dic" ;	save "$work/in9899_e.dta" , replace ; clear ;
qui infile using "$do/Dictionaries/in9899_f.dic" ;	save "$work/in9899_f.dta" , replace ; clear ;
qui infile using "$do/Dictionaries/in9899_g.dic" ;	save "$work/in9899_g.dta" , replace ; clear ;
qui infile using "$do/Dictionaries/in9899_h.dic" ;	save "$work/in9899_h.dta" , replace ; clear ;
qui infile using "$do/Dictionaries/in9899_i.dic" ;	save "$work/in9899_i.dta" , replace ; clear ;
qui infile using "$do/Dictionaries/in9899_j.dic" ;	save "$work/in9899_j.dta" , replace ; clear ;

#delim cr		

