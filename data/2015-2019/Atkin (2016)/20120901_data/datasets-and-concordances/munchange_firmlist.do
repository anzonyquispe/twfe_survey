*this gets a list of firms that were in changing municipalities so changed firmid
*by looking at munchange.smcl we can say when muni names changed and then if there 
*seems to be two very similar firms in the two years I will mark them and change the firmid 
*to the original firmid.

*this file is old and has not been updated with new post 2000 municipalities


gen munchange=1 if muncenso==	26071
replace munchange=1 if muncenso==	29045
replace munchange=1 if muncenso==	4010
replace munchange=1 if muncenso==	4011
replace munchange=1 if muncenso==	30208
replace munchange=1 if muncenso==	1010
replace munchange=1 if muncenso==	24058
replace munchange=1 if muncenso==	29048
replace munchange=1 if muncenso==	3009
replace munchange=1 if muncenso==	24057
replace munchange=1 if muncenso==	2005
replace munchange=1 if muncenso==	29049
replace munchange=1 if muncenso==	1011
replace munchange=1 if muncenso==	29050
replace munchange=1 if muncenso==	26072
replace munchange=1 if muncenso==	29051
replace munchange=1 if muncenso==	29052
replace munchange=1 if muncenso==	29053
replace munchange=1 if muncenso==	29054
replace munchange=1 if muncenso==	29055
replace munchange=1 if muncenso==	29056
replace munchange=1 if muncenso==	29057
replace munchange=1 if muncenso==	29058
replace munchange=1 if muncenso==	29059
replace munchange=1 if muncenso==	29060
replace munchange=1 if muncenso==	23008
replace munchange=1 if muncenso==	15122

replace munchange=1 if muncenso==	7112
replace munchange=1 if muncenso==	10039
replace munchange=1 if muncenso==	18020
replace munchange=1 if muncenso==	26070
replace munchange=1 if muncenso==	30204
replace munchange=1 if muncenso==	30205
replace munchange=1 if muncenso==	30206
replace munchange=1 if muncenso==	30207
replace munchange=0 if muncenso==	7059
replace munchange=0 if muncenso==	10001
replace munchange=0 if muncenso==	18004
replace munchange=0 if muncenso==	26048
replace munchange=0 if muncenso==	30039
replace munchange=0 if muncenso==	30161
replace munchange=0 if muncenso==	30082
replace munchange=0 if muncenso==	30045


	
replace munchange=0 if muncenso==	26026
replace munchange=0 if muncenso==	29030
replace munchange=0 if muncenso==	4003
replace munchange=0 if muncenso==	30045
replace munchange=0 if muncenso==	1001
replace munchange=0 if muncenso==	24010
replace munchange=0 if muncenso==	29010
replace munchange=0 if muncenso==	3001
replace munchange=0 if muncenso==	24037
replace munchange=0 if muncenso==	2004
replace munchange=0 if muncenso==	29032
replace munchange=0 if muncenso==	1001
replace munchange=0 if muncenso==	29010
replace munchange=0 if muncenso==	26029
replace munchange=0 if muncenso==	29032
replace munchange=0 if muncenso==	29038
replace munchange=0 if muncenso==	29029
replace munchange=0 if muncenso==	29044
replace munchange=0 if muncenso==	29040
replace munchange=0 if muncenso==	29015
replace munchange=0 if muncenso==	29023
replace munchange=0 if muncenso==	29044
replace munchange=0 if muncenso==	29022
replace munchange=0 if muncenso==	29029
replace munchange=0 if muncenso==	23001

drop if munchange==.


gen muncenso2=muncenso
replace muncenso2=	1001	if muncenso2==	1010
replace muncenso2=	1001	if muncenso2==	1011
replace muncenso2=	2004	if muncenso2==	2005
replace muncenso2=	3001	if muncenso2==	3009
replace muncenso2=	4003	if muncenso2==	4011
replace muncenso2=	7008	if muncenso2==	7117
replace muncenso2=	7026	if muncenso2==	7113
replace muncenso2=	7049	if muncenso2==	7119
replace muncenso2=	7052	if muncenso2==	7115
replace muncenso2=	7059	if muncenso2==	7114
replace muncenso2=	7059	if muncenso2==	7116
replace muncenso2=	7081	if muncenso2==	7118
replace muncenso2=	12072	if muncenso2==	12076
replace muncenso2=	23001	if muncenso2==	23008
replace muncenso2=	24010	if muncenso2==	24058
replace muncenso2=	24037	if muncenso2==	24057
replace muncenso2=	26026	if muncenso2==	26071
replace muncenso2=	26029	if muncenso2==	26072
replace muncenso2=	29010	if muncenso2==	29048
replace muncenso2=	29010	if muncenso2==	29050
replace muncenso2=	29015	if muncenso2==	29056
replace muncenso2=	29022	if muncenso2==	29059
replace muncenso2=	29023	if muncenso2==	29057
replace muncenso2=	29029	if muncenso2==	29053
replace muncenso2=	29029	if muncenso2==	29060
replace muncenso2=	29030	if muncenso2==	29045
replace muncenso2=	29030	if muncenso2==	29046
replace muncenso2=	29030	if muncenso2==	29047
replace muncenso2=	29032	if muncenso2==	29049
replace muncenso2=	29032	if muncenso2==	29051
replace muncenso2=	29038	if muncenso2==	29052
replace muncenso2=	29040	if muncenso2==	29055
replace muncenso2=	29044	if muncenso2==	29054
replace muncenso2=	29044	if muncenso2==	29058
replace muncenso2=	30045	if muncenso2==	30208
replace muncenso2=	32017	if muncenso2==	32057
replace muncenso2=	7059	if muncenso==	7112
replace muncenso2=	10001	if muncenso==	10039
replace muncenso2=	18004	if muncenso==	18020
replace muncenso2=	26048	if muncenso==	26070
replace muncenso2=	30039	if muncenso==	30204
replace muncenso2=	30161	if muncenso==	30205
replace muncenso2=	30082	if muncenso==	30206
replace muncenso2=	30045	if muncenso==	30207

sort year
egen newfirm=tag(firmid)
replace newfirm=0 if year==1985
gsort -year
egen closefirm=tag(firmid)
replace closefirm=0 if year==2000


drop if munchange==0 & closefirm==0
drop if munchange==1 & newfirm==0

replace year=year+1 if munchange==0
egen concat=concat(muncenso2 grupo year)

keep if maxemploy>49
*only larger firms dealt with here

egen count=count(year), by(concat)

drop if count==1

egen summunchange=total(munchange), by(concat)

drop if summunchange==0
drop if summunchange==count

order employ munchange concat firmid count

sort concat
