/* Important: you need to put the .dat and .do files in one folder/
   directory and then set the working folder to that folder. */

global censodir="C:\Users\pu106334\Desktop\WORK\Mexico\mexico_censo\"

set more off

clear
infix ///
 int     sample                               1-4 ///
 double  serial                               5-14 ///
 int     pernum                              15-17 ///
 float  wtper                               18-25 ///
 int     hrswrk1                             26-28 ///
 byte    hlthcov                             29-30 ///
 byte    mx00a_imss                          31 ///
 byte    mx00a_issste                        32 ///
 byte    mx00a_pemex                         33 ///
 byte    mx05a_insim                         34 ///
 byte    mx00a_noinsr                        35 ///
 byte    mx05a_insis                         36 ///
 byte    mx05a_inspe                         37 ///
 byte    mx05a_insno                         38 ///
 byte    mx00a_incpro                        39 ///
 using "${censodir}ipumsi_00015.dat"

/* Modify weights to reflect customized samples. */
replace wtper = wtper * 1.0 if sample == 4843
replace wtper = wtper * 1.0 if sample == 4844
replace wtper = wtper * 1.0 if sample == 4845
replace wtper = wtper * 1.0 if sample == 4846
replace wtper=wtper/10000

label var sample `"IPUMS sample identifier"'
label var serial `"Serial number"'
label var pernum `"Person number"'
label var wtper `"Person weight"'
label var hrswrk1 `"Hours worked per week"'
label var hlthcov `"Health coverage"'
label var mx00a_imss `"Insured by social security (IMSS)"'
label var mx00a_issste `"Insured by ISSSTE (public employees social security)"'
label var mx00a_pemex `"Insured by Pemex (Mexican oil company), defense, or navy"'
label var mx05a_insim `"IMSS subscriber"'
label var mx00a_noinsr `"No insurance"'
label var mx05a_insis `"ISSSTE subscriber"'
label var mx05a_inspe `"PEMEX, army or navy [insurance] subscriber"'
label var mx05a_insno `"Without health insurance"'
label var mx00a_incpro `"Receives income from Procampo or Progresa"'

label define samplelbl 0321 `"Argentina 1970"'
label define samplelbl 0322 `"Argentina 1980"', add
label define samplelbl 0323 `"Argentina 1991"', add
label define samplelbl 0324 `"Argentina 2001"', add
label define samplelbl 0401 `"Austria 1971"', add
label define samplelbl 0402 `"Austria 1981"', add
label define samplelbl 0403 `"Austria 1991"', add
label define samplelbl 0404 `"Austria 2001"', add
label define samplelbl 0761 `"Brazil 1960"', add
label define samplelbl 0762 `"Brazil 1970"', add
label define samplelbl 0763 `"Brazil 1980"', add
label define samplelbl 0764 `"Brazil 1991"', add
label define samplelbl 0765 `"Brazil 2000"', add
label define samplelbl 1121 `"Belarus 1999"', add
label define samplelbl 1161 `"Cambodia 1998"', add
label define samplelbl 1241 `"Canada 1971"', add
label define samplelbl 1242 `"Canada 1981"', add
label define samplelbl 1243 `"Canada 1991"', add
label define samplelbl 1244 `"Canada 2001"', add
label define samplelbl 1521 `"Chile 1960"', add
label define samplelbl 1522 `"Chile 1970"', add
label define samplelbl 1523 `"Chile 1982"', add
label define samplelbl 1524 `"Chile 1992"', add
label define samplelbl 1525 `"Chile 2002"', add
label define samplelbl 1561 `"China 1982"', add
label define samplelbl 1562 `"China 1990"', add
label define samplelbl 1701 `"Colombia 1964"', add
label define samplelbl 1702 `"Colombia 1973"', add
label define samplelbl 1703 `"Colombia 1985"', add
label define samplelbl 1704 `"Colombia 1993"', add
label define samplelbl 1705 `"Colombia 2005"', add
label define samplelbl 1881 `"Costa Rica 1963"', add
label define samplelbl 1882 `"Costa Rica 1973"', add
label define samplelbl 1883 `"Costa Rica 1984"', add
label define samplelbl 1884 `"Costa Rica 2000"', add
label define samplelbl 2181 `"Ecuador 1962"', add
label define samplelbl 2182 `"Ecuador 1974"', add
label define samplelbl 2183 `"Ecuador 1982"', add
label define samplelbl 2184 `"Ecuador 1990"', add
label define samplelbl 2185 `"Ecuador 2001"', add
label define samplelbl 8181 `"Egypt 1996"', add
label define samplelbl 2501 `"France 1962"', add
label define samplelbl 2502 `"France 1968"', add
label define samplelbl 2503 `"France 1975"', add
label define samplelbl 2504 `"France 1982"', add
label define samplelbl 2505 `"France 1990"', add
label define samplelbl 2881 `"Ghana 2000"', add
label define samplelbl 3001 `"Greece 1971"', add
label define samplelbl 3002 `"Greece 1981"', add
label define samplelbl 3003 `"Greece 1991"', add
label define samplelbl 3004 `"Greece 2001"', add
label define samplelbl 3481 `"Hungary 1970"', add
label define samplelbl 3482 `"Hungary 1980"', add
label define samplelbl 3483 `"Hungary 1990"', add
label define samplelbl 3484 `"Hungary 2001"', add
label define samplelbl 3681 `"Iraq 1997"', add
label define samplelbl 3761 `"Israel 1972"', add
label define samplelbl 3762 `"Israel 1983"', add
label define samplelbl 3763 `"Israel 1995"', add
label define samplelbl 4041 `"Kenya 1989"', add
label define samplelbl 4042 `"Kenya 1999"', add
label define samplelbl 4581 `"Malaysia 1970"', add
label define samplelbl 4582 `"Malaysia 1980"', add
label define samplelbl 4583 `"Malaysia 1991"', add
label define samplelbl 4584 `"Malaysia 2000"', add
label define samplelbl 4841 `"Mexico 1960"', add
label define samplelbl 4842 `"Mexico 1970"', add
label define samplelbl 4843 `"Mexico 1990"', add
label define samplelbl 4844 `"Mexico 1995"', add
label define samplelbl 4845 `"Mexico 2000"', add
label define samplelbl 4846 `"Mexico 2005"', add
label define samplelbl 5281 `"Netherlands 1960"', add
label define samplelbl 5282 `"Netherlands 1971"', add
label define samplelbl 5283 `"Netherlands 2001"', add
label define samplelbl 6021 `"Palestine 1997"', add
label define samplelbl 5911 `"Panama 1960"', add
label define samplelbl 5912 `"Panama 1970"', add
label define samplelbl 5913 `"Panama 1980"', add
label define samplelbl 5914 `"Panama 1990"', add
label define samplelbl 5915 `"Panama 2000"', add
label define samplelbl 6081 `"Philippines 1990"', add
label define samplelbl 6082 `"Philippines 1995"', add
label define samplelbl 6083 `"Philippines 2000"', add
label define samplelbl 6201 `"Portugal 1981"', add
label define samplelbl 6202 `"Portugal 1991"', add
label define samplelbl 6203 `"Portugal 2001"', add
label define samplelbl 6421 `"Romania 1992"', add
label define samplelbl 6422 `"Romania 2002"', add
label define samplelbl 7041 `"Vietnam 1989"', add
label define samplelbl 7042 `"Vietnam 1999"', add
label define samplelbl 6461 `"Rwanda 1991"', add
label define samplelbl 6462 `"Rwanda 2002"', add
label define samplelbl 7241 `"Spain 1981"', add
label define samplelbl 7242 `"Spain 1991"', add
label define samplelbl 7243 `"Spain 2001"', add
label define samplelbl 7101 `"South Africa 1996"', add
label define samplelbl 7102 `"South Africa 2001"', add
label define samplelbl 8001 `"Uganda 1991"', add
label define samplelbl 8002 `"Uganda 2002"', add
label define samplelbl 8261 `"United Kingdom 1991"', add
label define samplelbl 8262 `"United Kingdom 2001"', add
label define samplelbl 8401 `"United States 1960"', add
label define samplelbl 8402 `"United States 1970"', add
label define samplelbl 8403 `"United States 1980"', add
label define samplelbl 8404 `"United States 1990"', add
label define samplelbl 8405 `"United States 2000"', add
label define samplelbl 8406 `"United States 2005"', add
label define samplelbl 8621 `"Venezuela 1971"', add
label define samplelbl 8622 `"Venezuela 1981"', add
label define samplelbl 8623 `"Venezuela 1990"', add
label define samplelbl 8624 `"Venezuela 2001"', add
label values sample samplelbl

label define hrswrk1lbl 000 `"0 hours"'
label define hrswrk1lbl 001 `"1 hour"', add
label define hrswrk1lbl 002 `"2 hours"', add
label define hrswrk1lbl 003 `"3 hours"', add
label define hrswrk1lbl 004 `"4 hours"', add
label define hrswrk1lbl 005 `"5 hours"', add
label define hrswrk1lbl 006 `"6 hours"', add
label define hrswrk1lbl 007 `"7 hours"', add
label define hrswrk1lbl 008 `"8 hours"', add
label define hrswrk1lbl 009 `"9 hours"', add
label define hrswrk1lbl 010 `"10 hours"', add
label define hrswrk1lbl 011 `"11 hours"', add
label define hrswrk1lbl 012 `"12 hours"', add
label define hrswrk1lbl 013 `"13 hours"', add
label define hrswrk1lbl 014 `"14 hours"', add
label define hrswrk1lbl 015 `"15 hours"', add
label define hrswrk1lbl 016 `"16 hours"', add
label define hrswrk1lbl 017 `"17 hours"', add
label define hrswrk1lbl 018 `"18 hours"', add
label define hrswrk1lbl 019 `"19 hours"', add
label define hrswrk1lbl 020 `"20 hours"', add
label define hrswrk1lbl 021 `"21 hours"', add
label define hrswrk1lbl 022 `"22 hours"', add
label define hrswrk1lbl 023 `"23 hours"', add
label define hrswrk1lbl 024 `"24 hours"', add
label define hrswrk1lbl 025 `"25 hours"', add
label define hrswrk1lbl 026 `"26 hours"', add
label define hrswrk1lbl 027 `"27 hours"', add
label define hrswrk1lbl 028 `"28 hours"', add
label define hrswrk1lbl 029 `"29 hours"', add
label define hrswrk1lbl 030 `"30 hours"', add
label define hrswrk1lbl 031 `"31 hours"', add
label define hrswrk1lbl 032 `"32 hours"', add
label define hrswrk1lbl 033 `"33 hours"', add
label define hrswrk1lbl 034 `"34 hours"', add
label define hrswrk1lbl 035 `"35 hours"', add
label define hrswrk1lbl 036 `"36 hours"', add
label define hrswrk1lbl 037 `"37 hours"', add
label define hrswrk1lbl 038 `"38 hours"', add
label define hrswrk1lbl 039 `"39 hours"', add
label define hrswrk1lbl 040 `"40 hours"', add
label define hrswrk1lbl 041 `"41 hours"', add
label define hrswrk1lbl 042 `"42 hours"', add
label define hrswrk1lbl 043 `"43 hours"', add
label define hrswrk1lbl 044 `"44 hours"', add
label define hrswrk1lbl 045 `"45 hours"', add
label define hrswrk1lbl 046 `"46 hours"', add
label define hrswrk1lbl 047 `"47 hours"', add
label define hrswrk1lbl 048 `"48 hours"', add
label define hrswrk1lbl 049 `"49 hours"', add
label define hrswrk1lbl 050 `"50 hours"', add
label define hrswrk1lbl 051 `"51 hours"', add
label define hrswrk1lbl 052 `"52 hours"', add
label define hrswrk1lbl 053 `"53 hours"', add
label define hrswrk1lbl 054 `"54 hours"', add
label define hrswrk1lbl 055 `"55 hours"', add
label define hrswrk1lbl 056 `"56 hours"', add
label define hrswrk1lbl 057 `"57 hours"', add
label define hrswrk1lbl 058 `"58 hours"', add
label define hrswrk1lbl 059 `"59 hours"', add
label define hrswrk1lbl 060 `"60 hours"', add
label define hrswrk1lbl 061 `"61 hours"', add
label define hrswrk1lbl 062 `"62 hours"', add
label define hrswrk1lbl 063 `"63 hours"', add
label define hrswrk1lbl 064 `"64 hours"', add
label define hrswrk1lbl 065 `"65 hours"', add
label define hrswrk1lbl 066 `"66 hours"', add
label define hrswrk1lbl 067 `"67 hours"', add
label define hrswrk1lbl 068 `"68 hours"', add
label define hrswrk1lbl 069 `"69 hours"', add
label define hrswrk1lbl 070 `"70 hours"', add
label define hrswrk1lbl 071 `"71 hours"', add
label define hrswrk1lbl 072 `"72 hours"', add
label define hrswrk1lbl 073 `"73 hours"', add
label define hrswrk1lbl 074 `"74 hours"', add
label define hrswrk1lbl 075 `"75 hours"', add
label define hrswrk1lbl 076 `"76 hours"', add
label define hrswrk1lbl 077 `"77 hours"', add
label define hrswrk1lbl 078 `"78 hours"', add
label define hrswrk1lbl 079 `"79 hours"', add
label define hrswrk1lbl 080 `"80 hours"', add
label define hrswrk1lbl 081 `"81 hours"', add
label define hrswrk1lbl 082 `"82 hours"', add
label define hrswrk1lbl 083 `"83 hours"', add
label define hrswrk1lbl 084 `"84 hours"', add
label define hrswrk1lbl 085 `"85 hours"', add
label define hrswrk1lbl 086 `"86 hours"', add
label define hrswrk1lbl 087 `"87 hours"', add
label define hrswrk1lbl 088 `"88 hours"', add
label define hrswrk1lbl 089 `"89 hours"', add
label define hrswrk1lbl 090 `"90 hours"', add
label define hrswrk1lbl 091 `"91 hours"', add
label define hrswrk1lbl 092 `"92 hours"', add
label define hrswrk1lbl 093 `"93 hours"', add
label define hrswrk1lbl 094 `"94 hours"', add
label define hrswrk1lbl 095 `"95 hours"', add
label define hrswrk1lbl 096 `"96 hours"', add
label define hrswrk1lbl 097 `"97 hours"', add
label define hrswrk1lbl 098 `"98 hours"', add
label define hrswrk1lbl 099 `"99 hours"', add
label define hrswrk1lbl 100 `"100 hours"', add
label define hrswrk1lbl 101 `"101 hours"', add
label define hrswrk1lbl 102 `"102 hours"', add
label define hrswrk1lbl 103 `"103 hours"', add
label define hrswrk1lbl 104 `"104 hours"', add
label define hrswrk1lbl 105 `"105 hours"', add
label define hrswrk1lbl 106 `"106 hours"', add
label define hrswrk1lbl 107 `"107 hours"', add
label define hrswrk1lbl 108 `"108 hours"', add
label define hrswrk1lbl 109 `"109 hours"', add
label define hrswrk1lbl 110 `"110 hours"', add
label define hrswrk1lbl 111 `"111 hours"', add
label define hrswrk1lbl 112 `"112 hours"', add
label define hrswrk1lbl 113 `"113 hours"', add
label define hrswrk1lbl 114 `"114 hours"', add
label define hrswrk1lbl 115 `"115 hours"', add
label define hrswrk1lbl 116 `"116 hours"', add
label define hrswrk1lbl 117 `"117 hours"', add
label define hrswrk1lbl 118 `"118 hours"', add
label define hrswrk1lbl 119 `"119 hours"', add
label define hrswrk1lbl 120 `"120 hours"', add
label define hrswrk1lbl 121 `"121 hours"', add
label define hrswrk1lbl 122 `"122 hours"', add
label define hrswrk1lbl 123 `"123 hours"', add
label define hrswrk1lbl 124 `"124 hours"', add
label define hrswrk1lbl 125 `"125 hours"', add
label define hrswrk1lbl 126 `"126 hours"', add
label define hrswrk1lbl 127 `"127 hours"', add
label define hrswrk1lbl 128 `"128 hours"', add
label define hrswrk1lbl 129 `"129 hours"', add
label define hrswrk1lbl 130 `"130 hours"', add
label define hrswrk1lbl 131 `"131 hours"', add
label define hrswrk1lbl 132 `"132 hours"', add
label define hrswrk1lbl 133 `"133 hours"', add
label define hrswrk1lbl 134 `"134 hours"', add
label define hrswrk1lbl 135 `"135 hours"', add
label define hrswrk1lbl 136 `"136 hours"', add
label define hrswrk1lbl 137 `"137 hours"', add
label define hrswrk1lbl 138 `"138 hours"', add
label define hrswrk1lbl 139 `"139 hours"', add
label define hrswrk1lbl 140 `"140+ hours"', add
label define hrswrk1lbl 998 `"Unknown"', add
label define hrswrk1lbl 999 `"NIU (not in universe)"', add
label values hrswrk1 hrswrk1lbl

label define hlthcovlbl 10 `"IMSS only"'
label define hlthcovlbl 20 `"ISSSTE only"', add
label define hlthcovlbl 30 `"Pemex, military, or naval coverage only"', add
label define hlthcovlbl 40 `"Other coverage only"', add
label define hlthcovlbl 50 `"Multiple sources of coverage"', add
label define hlthcovlbl 51 `"IMSS and ISSSTE"', add
label define hlthcovlbl 52 `"IMSS and Pemex, military, or naval"', add
label define hlthcovlbl 53 `"IMSS and other"', add
label define hlthcovlbl 54 `"ISSSTE and Pemex, military, or naval"', add
label define hlthcovlbl 55 `"ISSSTE and other"', add
label define hlthcovlbl 56 `"Pemex, military, or naval, and other"', add
label define hlthcovlbl 57 `"IMSS, ISSSTE, and Pemex, military, or naval"', add
label define hlthcovlbl 58 `"IMSS, ISSSTE, and other"', add
label define hlthcovlbl 59 `"IMSS, ISSSTE, Pemex, military, or naval, and other"', add
label define hlthcovlbl 60 `"No coverage"', add
label define hlthcovlbl 99 `"Unknown"', add
label values hlthcov hlthcovlbl

label define mx00a_imsslbl 1 `"Yes"'
label define mx00a_imsslbl 2 `"No"', add
label define mx00a_imsslbl 9 `"Unknown"', add
label values mx00a_imss mx00a_imsslbl

label define mx00a_issstelbl 1 `"No and unknown"'
label define mx00a_issstelbl 2 `"Yes"', add
label values mx00a_issste mx00a_issstelbl

label define mx00a_pemexlbl 1 `"No and unknown"'
label define mx00a_pemexlbl 2 `"Yes"', add
label values mx00a_pemex mx00a_pemexlbl

label define mx05a_insimlbl 1 `"IMSS subscriber"'
label define mx05a_insimlbl 2 `"Not an IMSS subscriber"', add
label define mx05a_insimlbl 9 `"NIU (not in universe)"', add
label values mx05a_insim mx05a_insimlbl

label define mx00a_noinsrlbl 1 `"Yes, has insurance"'
label define mx00a_noinsrlbl 2 `"Does not have health coverage"', add
label values mx00a_noinsr mx00a_noinsrlbl

label define mx05a_insislbl 1 `"ISSSTE subscriber"'
label define mx05a_insislbl 2 `"Not an ISSSTE subscriber"', add
label define mx05a_insislbl 9 `"NIU (not in universe)"', add
label values mx05a_insis mx05a_insislbl

label define mx05a_inspelbl 1 `"PEMEX, army or navy (insurance) subscriber"'
label define mx05a_inspelbl 2 `"Not a PEMEX subscriber"', add
label define mx05a_inspelbl 9 `"NIU (not in universe)"', add
label values mx05a_inspe mx05a_inspelbl

label define mx05a_insnolbl 1 `"Without health insurance"'
label define mx05a_insnolbl 2 `"With health insurance"', add
label define mx05a_insnolbl 8 `"Unknown"', add
label values mx05a_insno mx05a_insnolbl

label define mx00a_incprolbl 0 `"NIU (not in universe)"'
label define mx00a_incprolbl 1 `"Yes, receives other income from Procampo or Progresa"', add
label define mx00a_incprolbl 2 `"No, does not receive other income from Procampo or Progresa"', add
label define mx00a_incprolbl 9 `"Not specified"', add
label values mx00a_incpro mx00a_incprolbl


rename wtper wtper15
rename mx00a_imss mx00a_imss_15

sort  sample serial pernum

save ${censodir}mexico_censo_15.dta, replace



