*this programme creates table 3, except for column (7). 
*first sort the data, and tell STATA about the panel structure
*in order to create the excel tables you need to install outreg2 in STATA

sort region time
tsset region time, quarterly

*l1wtotalpv5 is the generated present value variable at 5 percent devided by the SD of the orignial PV seriesvariable
*l1wtotalpv1 is the generated present value variable at 1 percent devided by the SD of the orignial PV seriesvariable
*generally the letter w refers to weighting by the standard deviation and l1 to lags by one quarter



*note that not all time dummies are included due to missing values
xtreg   lnhouseprice  l1wtotalpv5  time9 time10 time12 time13 time14 time15 time16 time17 time18 time19 time21 time22 time23 time24 time25 time26 time27 time28 time29 time30 time31 time32 time33 time34 time35 time36 time37 time38 time39 time40 time41 time42 time43 time44 time45 time46 time47 time48 time49 time50 time51 time52 time53 time54 time55 time56 time57 time58 time59 time60 time61 time62 time63 time64 time65 time66 time67 time68 time69 time70 time71 time72 time73 time74 time75 time76 time77 time78 time79 time80 time81 time82 time83 time84 time85 time86 time87 time88 time89 time90 time91 time92 time93 time94 time95 time96 time97 time98 time99 time100 time101 time102 time103 time104 time105 , fe cluster (region)
outreg2 using myfile
xtreg   lnhouseprice  l1wtotalpv1  time9 time10 time12 time13 time14 time15 time16 time17 time18 time19 time21 time22 time23 time24 time25 time26 time27 time28 time29 time30 time31 time32 time33 time34 time35 time36 time37 time38 time39 time40 time41 time42 time43 time44 time45 time46 time47 time48 time49 time50 time51 time52 time53 time54 time55 time56 time57 time58 time59 time60 time61 time62 time63 time64 time65 time66 time67 time68 time69 time70 time71 time72 time73 time74 time75 time76 time77 time78 time79 time80 time81 time82 time83 time84 time85 time86 time87 time88 time89 time90 time91 time92 time93 time94 time95 time96 time97 time98 time99 time100 time101 time102 time103 time104 time105 , fe cluster (region)
outreg2 using myfile
xtreg   lnhouseprice  L1.l1wtotalpv5  time9 time10 time12 time13 time14 time15 time16 time17 time18 time19 time21 time22 time23 time24 time25 time26 time27 time28 time29 time30 time31 time32 time33 time34 time35 time36 time37 time38 time39 time40 time41 time42 time43 time44 time45 time46 time47 time48 time49 time50 time51 time52 time53 time54 time55 time56 time57 time58 time59 time60 time61 time62 time63 time64 time65 time66 time67 time68 time69 time70 time71 time72 time73 time74 time75 time76 time77 time78 time79 time80 time81 time82 time83 time84 time85 time86 time87 time88 time89 time90 time91 time92 time93 time94 time95 time96 time97 time98 time99 time100 time101 time102 time103 time104 time105 , fe cluster (region)
outreg2 using myfile
xtreg   lnhouseprice  l1wtotalpv5   l1unempl time22 time23 time24 time25 time26 time27 time28 time29 time30 time31 time32 time33 time34 time35 time36 time37 time38 time39 time40 time41 time42 time43 time44 time45 time46 time47 time48 time49 time50 time51 time52 time53 time54 time55 time56 time57 time58 time59 time60 time61 time62 time63 time64 time65 time66 time67 time68 time69 time70 time71 time72 time73 time74 time75 time76 time77 time78 time79 time80 time81 time82 time83 time84 time85 time86 time87 time88 time89 time90 time91 time92 time93 time94 time95 time96 time97 time98 time99 time100 time101 time102 time103 time104 time105, fe cluster (region)
outreg2 using myfile
xtreg   lnhouseprice  l1wtotalpv5  l1wprivatstarts time23 time24 time25 time26 time27 time28 time29 time30 time31 time32 time33 time34 time35 time36 time37 time38 time39 time40 time41 time42 time43 time44 time45 time46 time47 time48 time49 time50 time51 time52 time53 time54 time55 time56 time57 time58 time59 time60 time61 time62 time63 time64 time65 time66 time67 time68 time69 time70 time71 time72 time73 time74 time75 time76 time77 time78 time79 time80 time81 time82 time83 time84 time85 time86 time87 time88 time89 time90 time91 time92 time93 time94 time95 time96 time97 time98 time99 time100 time101 time102 time103 time104 time105 , fe cluster (region)
outreg2 using myfile
xtreg   lnhouseprice  l1wtotalpv5  tt1 tt2 tt3 tt4 tt5 tt6 tt7 tt8 tt9 tt10 tt11 time10 time12 time13 time14 time15 time16 time17 time18 time19 time21 time22 time23 time24 time25 time26 time27 time28 time29 time30 time31 time32 time33 time34 time35 time36 time37 time38 time39 time40 time41 time42 time43 time44 time45 time46 time47 time48 time49 time50 time51 time52 time53 time54 time55 time56 time57 time58 time59 time60 time61 time62 time63 time64 time65 time66 time67 time68 time69 time70 time71 time72 time73 time74 time75 time76 time77 time78 time79 time80 time81 time82 time83 time84 time85 time86 time87 time88 time89 time90 time91 time92 time93 time94 time95 time96 time97 time98 time99 time100 time101 time102 time103 time104 time105, fe cluster (region)
outreg2 using myfile
*this regression is run adding 4 UK regions - note that we have now to use all time dummies
xtreg   uklnhouseprice  ukl1wtotalpv5  time9 time10 time11 time12 time13 time14 time15 time16 time17 time18 time19 time20 time21 time22 time23 time24 time25 time26 time27 time28 time29 time30 time31 time32 time33 time34 time35 time36 time37 time38 time39 time40 time41 time42 time43 time44 time45 time46 time47 time48 time49 time50 time51 time52 time53 time54 time55 time56 time57 time58 time59 time60 time61 time62 time63 time64 time65 time66 time67 time68 time69 time70 time71 time72 time73 time74 time75 time76 time77 time78 time79 time80 time81 time82 time83 time84 time85 time86 time87 time88 time89 time90 time91 time92 time93 time94 time95 time96 time97 time98 time99 time100 time101 time102 time103 time104 time105 , fe cluster (region)
outreg2 using myfile, excel






