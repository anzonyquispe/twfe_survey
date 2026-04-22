				




gen	region1=.					
replace region1=	2	if state==	1			
replace region1=	1	if state==	2			
replace region1=	2	if state==	3			
replace region1=	5	if state==	4			
replace region1=	1	if state==	5			
replace region1=	3	if state==	6			
replace region1=	6	if state==	7			
replace region1=	1	if state==	8			
replace region1=	4	if state==	9
replace region1=	2	if state==	10
replace region1=	3	if state==	11
replace region1=	6	if state==	12
replace region1=	3	if state==	13
replace region1=	3	if state==	14
replace region1=	4	if state==	15
replace region1=	3	if state==	16
replace region1=	3	if state==	17
replace region1=	2	if state==	18
replace region1=	1	if state==	19
replace region1=	6	if state==	20
replace region1=	3	if state==	21
replace region1=	3	if state==	22
replace region1=	5	if state==	23
replace region1=	2	if state==	24
replace region1=	2	if state==	25
replace region1=	1	if state==	26
replace region1=	5	if state==	27
replace region1=	1	if state==	28
replace region1=	3	if state==	29
replace region1=	3	if state==	30
replace region1=	5	if state==	31
replace region1=	3	if state==	32

gen	region2=.		
replace region2=	2	if state==	1
replace region2=	2	if state==	2
replace region2=	2	if state==	3
replace region2=	6	if state==	4
replace region2=	2	if state==	5
replace region2=	3	if state==	6
replace region2=	6	if state==	7
replace region2=	2	if state==	8
replace region2=	3	if state==	9
replace region2=	2	if state==	10
replace region2=	3	if state==	11
replace region2=	6	if state==	12
replace region2=	3	if state==	13
replace region2=	3	if state==	14
replace region2=	3	if state==	15
replace region2=	3	if state==	16
replace region2=	3	if state==	17
replace region2=	2	if state==	18
replace region2=	2	if state==	19
replace region2=	6	if state==	20
replace region2=	3	if state==	21
replace region2=	3	if state==	22
replace region2=	6	if state==	23			
replace region2=	2	if state==	24			
replace region2=	2	if state==	25			
replace region2=	2	if state==	26			
replace region2=	6	if state==	27			
replace region2=	2	if state==	28			
replace region2=	3	if state==	29			
replace region2=	3	if state==	30			
replace region2=	6	if state==	31			
replace region2=	3	if state==	32			

cap label define regionlbl 	1 "border"	2 "north"	3 "center"	4 "capital"	5 "yucatan"	6 "south"
cap label values region1 regionlbl						
cap label values region2 regionlbl						


gen	maqshare=.		
replace maqshare=	0.286	if state==	1
replace maqshare=	0.868	if state==	2
replace maqshare=	0.226	if state==	3
replace maqshare=	0	if state==	4
replace maqshare=	0.485	if state==	5
replace maqshare=	0	if state==	6
replace maqshare=	0	if state==	7
replace maqshare=	0.742	if state==	8
replace maqshare=	0.004	if state==	9
replace maqshare=	0.34	if state==	10
replace maqshare=	0.048	if state==	11
replace maqshare=	0.06	if state==	12
replace maqshare=	0.008	if state==	13
replace maqshare=	0.087	if state==	14
replace maqshare=	0.02	if state==	15
replace maqshare=	0	if state==	16
replace maqshare=	0.023	if state==	17
replace maqshare=	0	if state==	18
replace maqshare=	0.142	if state==	19
replace maqshare=	0	if state==	20
replace maqshare=	0.101	if state==	21
replace maqshare=	0.552	if state==	22
replace maqshare=	0	if state==	23
replace maqshare=	0.073	if state==	24
replace maqshare=	0.022	if state==	25
replace maqshare=	0.644	if state==	26
replace maqshare=	0	if state==	27
replace maqshare=	0.769	if state==	28
replace maqshare=	0.103	if state==	29
replace maqshare=	0	if state==	30
replace maqshare=	0.227	if state==	31
replace maqshare=	0.154	if state==	32

gen maqind=0			
replace maqind=1 if maqshare>0.2			

*these value come from "Is Mexico a Lumpy Country" by Bernard, Robertson and Schott. From 1998 Maquiladora figures and industrial census. This is share of total manuf that is maq...