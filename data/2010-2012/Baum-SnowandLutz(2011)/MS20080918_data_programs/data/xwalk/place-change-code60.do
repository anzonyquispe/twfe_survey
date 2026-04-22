/*
This program changes place codes
to match place-codes.dta based
on discrepancies found in 1960 only.  
This program is intended to be called
in order to make place codes consistent 
between the 1960 census and place-codes.dta.
*/


*CA
*La Habra 
replace place = 1428 if place==1425 & statefips==6

*CT
*Bridgeport
replace place = 200 if place==110 & statefips==9
*New Britain
replace place = 1390 if place==705 & statefips==9
*Hartford
replace place = 970 if place==485 & statefips==9
*New Haven
replace place = 1450 if place==735 & statefips==9
*West Haven
replace place = 2535 if place==1270 & statefips==9
*Milford
replace place = 1270 if place==645 & statefips==9
*Norwalk
replace place = 1630 if place==825 & statefips==9
*Stamford
replace place = 2180 if place==1100 & statefips==9
*Waterbury
replace place = 2460 if place==1240 & statefips==9

*FL
*Jacksonville, FL
replace place = 1003 if place==1000 & statefips==12
*Miami Beach, FL
replace place = 1375 if place==1369 & statefips==12
*North Miami, FL
replace place = 1498 if place==1502 & statefips==12
replace place = 1498 if place==1495 & statefips==12
*Lakeland
replace place = 1136 if place==1140 & statefips==12

*IL
*Alton
replace place = 115 if place==105 & statefips==17
*Morton Grove, IL
replace place = 3873 if place==3870 & statefips==17

*ME
*Portland, ME
replace place = 3750 if place==2095 & statefips==23

*MD
*Annapolis
replace place = 11 if place==15 & statefips==24

*MA
*Attleboro
replace place = 210 if place==105 & statefips==25
*Boston
replace place = 440 if place==220 & statefips==25
*Brockton
replace place = 540 if place==270 & statefips==25
*Cambridge
replace place = 610 if place==302 & statefips==25
*Fall River
replace place = 1220 if place==605 & statefips==25
*Lowell
replace place = 2180 if place==1085 & statefips==25
*Lynn
replace place = 2210 if place==1100 & statefips==25
*New Bedford
replace place = 2770 if place==1380 & statefips==25
*Pittsfield
replace place = 3370 if place==1680 & statefips==25
*Waltham
replace place = 4440 if place==2205 & statefips==25
*Worcester
replace place = 5030 if place==2500 & statefips==25
*Springfield
replace place = 4090 if place==2030 & statefips==25
*Lawrence
replace place = 2030 if place==1010 & statefips==25
*Melrose
replace place = 2430 if place==1215 & statefips==25
*Woburn
replace place = 5010 if place==2490 & statefips==25
*Peabody
replace place = 3260 if place==1625 & statefips==25
replace place = 700 if place==345 & statefips==25
*Beverly
replace place = 390 if place==195 & statefips==25
*Revere
replace place = 3510 if place==1750 & statefips==25
*Medford
replace place = 2400 if place==1200 & statefips==25
*Everett
replace place = 1200 if place==595 & statefips==25
*Salem
replace place = 3670 if place==1830 & statefips==25
*Holyoke
replace place = 1830 if place==910 & statefips==25
replace place = 2230 if place==1110 & statefips==25
replace place = 760 if place==375 & statefips==25
replace place = 3460 if place==1725 & statefips==25
replace place = 2830 if place==1410 & statefips==25
*Somerville
replace place = 3920 if place==1945 & statefips==25

*MI

replace place = 1185 if place==1205 & statefips==26
*Sterling Heights, MI
replace place = 2583 if place==2578 & statefips==26

*NH
*Manchester
replace place = 1610 if place==875 & statefips==33

*NM
*Roswell
replace place = 334  if place==330 & statefips==35

*PA
*Aliquippa, PA
replace place = 115 if place==100 & statefips==42
*Monroeville, PA
replace place = 6564 if place==6578 & statefips==42
*Sharon
replace place = 7738 if place==7700 & statefips==42

*RI
replace place = 90 if place==50 & statefips==44
replace place = 120 if place==65 & statefips==44
*Pawtucket
replace place = 380 if place==195 & statefips==44
*Providence
replace place = 400 if place==205 & statefips==44
*Warwick
replace place = 500 if place==260 & statefips==44

*TN
*Nashville
replace place = 1016 if place==1015 & statefips==47

*VA
*Arlington CDP
replace place = 56 if place==55 & statefips==51





