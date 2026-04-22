/*
This program changes place codes
to match place-codes.dta based
on discrepancies found in 1970.
This program is intended to be called
in order to make 1970 census place codes 
consistent with place-codes.dta.

NOTE: This code applies to the 1940 to 1977
CCDB Data.
*/

***1960 Problems***

*CA
*East Bakersfield - NIL
drop if place==820 & statefips==6
*La Habra 
replace place = 1428 if place==1425 & statefips==6
** Lancaster, CA
replace place = 1476 if place==1475 & statefips==6
** Napa, CA
replace place = 1884 if place==1880 & statefips==6
** San Buenaventura/Ventura CA
replace place = 2460 if place==3004 & statefips==6

*CT
/*** A bunch of the old NE Town codes have census records,
but the census duplicates those records with the newer
place codes that match ***/

*FL
*Jacksonville, FL
replace place = 1003 if place==1000 & statefips==12
*Miami Beach, FL
replace place = 1375 if place==1369 & statefips==12
*North Miami, FL
replace place = 1498 if place==1502 & statefips==12
** Lakeland, FL
replace place = 1136 if place==1140 & statefips==12

*IL
*Morton Grove, IL
replace place = 3873 if place==3870 & statefips==17

*MD
*Annapolis
replace place = 11 if place==15 & statefips==24

*MA

replace place = 5010 if place==2490 & statefips==25

*MI

replace place = 1185 if place==1205 & statefips==26
*Sterling Heights, MI
replace place = 2583 if place==2578 & statefips==26

*NC
*Kannapolis, NC
replace place = 1320 if place==1500 & statefips==37

*NM
*Roswell
replace place = 334  if place==330 & statefips==35

*PA
*Aliquippa
replace place = 115 if place==100 & statefips==42
*Monroeville, PA
replace place = 6564 if place==6578 & statefips==42
*New Kensington
replace place = 6776 if place==6790 & statefips==42
*Sharon
replace place = 7738 if place==7700 & statefips==42
*Washington
replace place = 8590 if place==8400 & statefips==42

*Clarksburg, WV
replace place = 310 if place==380 & statefips==54

