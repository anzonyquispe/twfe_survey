*this file will convert all municipalities to their 1990 names.
*any firms with maxemploy>49 that seem to have been reclassified during muncipality changes
*have been fixed.
*there are four municipalities that have been created out of several old munis.
*for these I have moved the two firms to their original locations.
*should probably population weight the census data for 2000 that will be for the new district.

*this will work for both firm and census data
			




			
cap replace firmid=	A0833446_10	if firmid==	Y9410159_10
cap replace firmid=	E2811309_10	if firmid==	Y7210012_10
cap replace firmid=	E3310012_10	if firmid==	Y7510026_10
cap replace firmid=	F1111751_10	if firmid==	Y8310009_10
cap replace firmid=	L0910079_10	if firmid==	Y8510001_10
cap replace firmid=	L0910134_10	if firmid==	Y8510018_10
cap replace firmid=	L0910049_10	if firmid==	Y8510010_10
cap replace firmid=	M4711418_10	if firmid==	Y7110559_10
cap replace firmid=	A0815906_10	if firmid==	Y9410054_10
cap replace firmid=	A0851052_10	if firmid==	Y9410379_10
cap replace firmid=	A0814544_10	if firmid==	Y9410048_10
cap replace firmid=	E2812712_10	if firmid==	Y7210367_19
			
			
cap replace muncenso=	15070	if firmid==	Y7410120_10
cap replace muncenso=	15025	if firmid==	Y7410058_10
			
cap replace firmid=	C3911192_10	if firmid==	Y7410120_10
cap replace firmid=	C2912183_10	if firmid==	Y7410058_10


	
replace muncenso=	1001	if muncenso==	1010
replace muncenso=	1001	if muncenso==	1011
replace muncenso=	2004	if muncenso==	2005
replace muncenso=	3001	if muncenso==	3009
replace muncenso=	4003	if muncenso==	4011
replace muncenso=	7008	if muncenso==	7117
replace muncenso=	7026	if muncenso==	7113
replace muncenso=	7049	if muncenso==	7119
replace muncenso=	7052	if muncenso==	7115
replace muncenso=	7059	if muncenso==	7114
replace muncenso=	7059	if muncenso==	7116
replace muncenso=	7081	if muncenso==	7118
replace muncenso=	12072	if muncenso==	12076
replace muncenso=	23001	if muncenso==	23008
replace muncenso=	24010	if muncenso==	24058
replace muncenso=	24037	if muncenso==	24057
replace muncenso=	26026	if muncenso==	26071
replace muncenso=	26029	if muncenso==	26072
replace muncenso=	29010	if muncenso==	29048
replace muncenso=	29010	if muncenso==	29050
replace muncenso=	29015	if muncenso==	29056
replace muncenso=	29022	if muncenso==	29059
replace muncenso=	29023	if muncenso==	29057
replace muncenso=	29029	if muncenso==	29053
replace muncenso=	29029	if muncenso==	29060
replace muncenso=	29030	if muncenso==	29045
replace muncenso=	29030	if muncenso==	29046
replace muncenso=	29030	if muncenso==	29047
replace muncenso=	29032	if muncenso==	29049
replace muncenso=	29032	if muncenso==	29051
replace muncenso=	29038	if muncenso==	29052
replace muncenso=	29040	if muncenso==	29055
replace muncenso=	29044	if muncenso==	29054
replace muncenso=	29044	if muncenso==	29058
replace muncenso=	30045	if muncenso==	30208
replace muncenso=	32017	if muncenso==	32057
			
replace muncenso=	7059	if muncenso==	7112
replace muncenso=	10001	if muncenso==	10039
replace muncenso=	18004	if muncenso==	18020
replace muncenso=	26048	if muncenso==	26070
replace muncenso=	30039	if muncenso==	30204
replace muncenso=	30161	if muncenso==	30205
replace muncenso=	30082	if muncenso==	30206
replace muncenso=	30045	if muncenso==	30207
			
			
replace muncenso=	12043	if muncenso==	12078
replace muncenso=	12028	if muncenso==	12079
replace muncenso=	12013	if muncenso==	12080
replace muncenso=	15082	if muncenso==	15123
replace muncenso=	15074	if muncenso==	15124
replace muncenso=	15044	if muncenso==	15125
replace muncenso=	30102	if muncenso==	30211
replace muncenso=	30130	if muncenso==	30212
replace muncenso=	32047	if muncenso==	32058
			
			
*here for multi merges, I create synthetic larger municipality			
replace muncenso=	4004	if muncenso==	4006
replace muncenso=	30104	if muncenso==	30149
replace muncenso=	12013	if muncenso==	12023
replace muncenso=	12052	if muncenso==	12041
			
replace muncenso=	4004	if muncenso==	4010
replace muncenso=	30104	if muncenso==	30209
replace muncenso=	12013	if muncenso==	12077
replace muncenso=	12052	if muncenso==	12081
			
			
*for the merges with 4 I have split muni into for in censo create file			
