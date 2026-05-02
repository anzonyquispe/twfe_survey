********************************************************************
* Program to create dataset of state minimum wages from 1980-2009  *
* Minimum Wage Data is From January Issues of Monthly Labor Review *
* and www.dol.gov/whd/state/stateminwagehis.htm                    *
********************************************************************

clear all
set more off
set obs 18972
local i=1

gen state = .
gen year = .
gen month = .

local states 1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56
foreach state of local states   {
 forv year = 1979/2009 {
  forv month = 1/12 {
   qui replace state = `state' in `i'
   qui replace year = `year' in `i'
   qui replace month = `month' in `i'
   local i=`i'+1
  }
 }
}
sort state year month
******************************************
* minimum wage history, 1981-2008
*  note for lags -- 1981 all states are at the federal level of $3.35
******************************************

* federal level
gen minwage = 2.90
 replace minwage = 3.10 if (year==1980)
 replace minwage = 3.35 if (year>1980)
 replace minwage = 3.80 if (year>1990 | (year==1990 & month>3))
 replace minwage = 4.25 if (year>1991 | (year==1991 & month>3))
 replace minwage = 4.75 if (year>1996 | (year==1996 & month>9))
 replace minwage = 5.15 if (year>1997 | (year==1997 & month>8))
 replace minwage = 5.85 if (year==2007 & month>7) | (year==2008 & month<8) 
 replace minwage = 6.55 if (year==2008 & month>7) | (year==2009 & month<8) 
 replace minwage = 7.25 if (year==2009 & month>7) 


gen usmin = minwage

* states -- check codes are right on states . ie same in ce as in cps
* alaska
 replace minwage = minwage+0.50 if state==2 
 replace minwage = 7.15 if (state==2 & year>2002)
 replace minwage = 7.75 if (state==2 & year>2009)

* arizona
 replace minwage = 6.75 if state==4 & year>2006
  * cpi adjustment
 replace minwage = 6.90 if state==4 & year==2008
 replace minwage = 7.25 if state==4 & year==2009

* arkansas
 replace minwage =6.25 if state==5 & year==2006 & month>9
 replace minwage =6.25 if state==5 & year>2006 
 replace minwage = 6.55 if state==5 & ((year==2008 & month>7) | (year==2009 & month<8))
 replace minwage = 7.25 if state==5 & (year==2009 & month>7) 

* calif
 replace minwage =4.25 if state==6 & (year>1988 | (year==1988 & month>6))
 replace minwage =4.75 if state==6 & (year>1996 | (year==1996 & month>9))
 replace minwage =5.00 if state==6 & year==1997 & (month>2 & month<9)
 replace minwage =5.15 if state==6 & ((year==1997 & month>8) | (year==1998 & month<3))
 replace minwage =5.75 if state==6 & year==1998 & month>2
 replace minwage =5.75 if state==6 & year>1998 & year<2001
 replace minwage =6.25 if state==6 & year==2001
 replace minwage =6.75 if state==6 & year>2001
 replace minwage =7.50 if state==6 & year==2007
 replace minwage =8.00 if state==6 & year>2007

* colorado
 replace minwage =6.85 if state==8 & year==2007
 * cpi adjustment
 replace minwage =7.02 if state==8 & year==2008
 replace minwage = 7.28 if state==8 & year==2009


* connecticut
 replace minwage=2.92 if state==9 & year==1979
 replace minwage=3.12 if state==9 & year==1980
 replace minwage=3.37 if state==9 & (year>1980 & year<1987 | (year==1987 & month<10)) //fixed a typo here
 replace minwage=3.75 if state==9 & ((year==1987 & month>9 ) | (year==1988 & month<10))
 replace minwage=4.25 if state==9 & (year>1988 | (year==1988 & month>9))
 replace minwage=4.27 if state==9 & (year>1991 | (year==1991 & month>3))
 replace minwage=4.77 if state==9 & year==1996 & month>9
 replace minwage=4.77 if state==9 & year==1997 & month<3
 replace minwage=5.00 if state==9 & year==1997 & (month>2 & month<9)
 replace minwage=5.18 if state==9 & year==1997 & month>8
 replace minwage=5.18 if state==9 & year==1998
 replace minwage=5.65 if state==9 & year==1999
 replace minwage=6.15 if state==9 & year==2000
 replace minwage=6.40 if state==9 & year==2001
 replace minwage=6.70 if state==9 & year==2002
 replace minwage=6.90 if state==9 & year==2003
 replace minwage=7.10 if state==9 & year>2003 & year<2006
 replace minwage=7.40 if state==9 & year==2006
 replace minwage=7.65 if state==9 & year==2007
 replace minwage=7.65 if state==9 & year==2008
 replace minwage=8.00 if state==9 & year==2009

* delaware
 replace minwage=5.65 if state==10 & year==1999 & month>4
 replace minwage=5.65 if state==10 & year==2000 & month<10
 replace minwage=6.15 if state==10 & year==2000 & month>9
 replace minwage=6.15 if state==10 & year>2000
 replace minwage=6.65 if state==10 & year==2007
 replace minwage=7.15 if state==10 & (year==2008 | (year==2009 & month<8))
 replace minwage = 7.25 if state==10 & (year==2009 & month>7) 

* florida
  * cpi adjustment
 replace minwage=6.40 if state==12 & year==2006
 replace minwage=6.67 if state==12 & year==2007
 replace minwage=6.79 if state==12 & year==2008
 replace minwage=7.21 if state==12 & year==2009 & month<8
 replace minwage = 7.25 if state==12 & (year==2009 & month>7) 

* hawaii
 replace minwage=3.85 if state==15 & year>1987
 replace minwage=4.25 if state==15 & ((year==1992 & month<4) | (year==1991 & month>3))
 replace minwage=4.75 if state==15 & (year==1992 & month>3)
 replace minwage=5.25 if state==15 & year>1992
 replace minwage=5.75 if state==15 & year==2002
 replace minwage=6.25 if state==15 & year>2002 & year<2006
 replace minwage=6.75 if state==15 & year==2006
 replace minwage=7.25 if state==15 & year==2007 & month<7
 replace minwage=7.25 if state==15 & year>2006

* Illinois 
 replace minwage=5.5 if state==17 & year==2004
 replace minwage=6.5 if state==17 & year>=2005 & year<2007
 replace minwage=6.5 if state==17 & year==2007 & month<7
 replace minwage=7.5 if state==17 & ((year==2007 & month>6) | (year==2008 &  month<7)) 
 replace minwage=7.75 if state==17 & ((year==2008 & month>6) | (year==2009 & month<7))
 replace minwage=8 if state==17 & year==2009 & month>6

* Iowa
 replace minwage=3.85 if state==19 & year==1990
 replace minwage=4.25 if state==19 & year==1991
 replace minwage=4.65 if state==19 & (year>1991 & year<1996)
 replace minwage=4.65 if state==19 & year==1996 & month<10
 replace minwage=6.20 if state==19 & (year==2007 & month>3) 
 replace minwage = 7.25 if state==19 & year>2007

* kentucky
 replace minwage=5.85 if state==21 & year==2007 & month>5
 replace minwage=5.85 if state==21 & year==2008 & month<8
 replace minwage = 6.55 if state==21 & ((year==2008 & month>7) | (year==2009 & month<8)) 
 replace minwage = 7.25 if state==21 & (year==2009 & month>7) 

* Maine
 replace minwage=3.45 if state==23 & year==1985
 replace minwage=3.55 if state==23 & year==1986
 replace minwage=3.65 if state==23 & (year==1987 | year==1988)
 replace minwage=3.75 if state==23 & year==1989
 replace minwage=3.85 if state==23 & year==1990
 replace minwage=3.85 if state==23 & (year==1991 & month<4)
 replace minwage=5.75 if state==23 & year==2002
 replace minwage=6.25 if state==23 & year==2003
 replace minwage=6.25 if state==23 & year==2004
 replace minwage=6.35 if state==23 & year==2005
 replace minwage=6.50 if state==23 & year==2006 & month<10
 replace minwage=6.75 if state==23 & year==2006 & month>9
 replace minwage=6.75 if state==23 & year==2007 & month<10
 replace minwage=7 if state==23 & ((year==2007 & month>9) | (year==2008 & month<10))
 replace minwage = 7.25 if state==23 & ((year==2008 & month>9) | year==2009)
 replace minwage = 7.5 if state==23 & (year==2009 & month>9)
* cpi adjustments at least starting in 2009, probably earlier


* maryland
 replace minwage=6.15 if state==24 & (year==2007 | (year==2008 & month<8))
 replace minwage = 6.55 if state==24 & ((year==2008 & month>7) | (year==2009 & month<8)) 
 replace minwage = 7.25 if state==24 & (year==2009 & month>7) 


* Massachusetts
 replace minwage=3.55 if state==25 & ((year==1986 & month>6) | (year==1987 & month<7))
 replace minwage=3.65 if state==25 & ((year==1987 & month>6) | (year==1988 & month<7))
 replace minwage=3.75 if state==25 & ((year==1988 & month>6) | (year==1989) | (year==1990 & month<4))
 replace minwage=4.75 if state==25 & year==1996
 replace minwage=5.25 if state==25 & (year>1996 & year<2000)
 replace minwage=6.00 if state==25 & year==2000
 replace minwage=6.75 if state==25 & year>2000 & year<2007
 replace minwage=7.50 if state==25 & year==2007
 replace minwage=8.00 if state==25 & year>2007


* michigan
 replace minwage=6.95 if state==26 & year==2006 & month>9
 replace minwage=6.95 if state==26 & year==2007 & month<7
 replace minwage=7.15 if state==26 & year==2007 & month>6
 replace minwage=7.15 if state==26 & year==2008 & month<7
 replace minwage=7.40 if state==26 & ((year==2008 & month>6) | year==2009)


* Minnesota
 replace minwage=3.55 if state==27 & year==1988
 replace minwage=3.85 if state==27 & year==1989
 replace minwage=3.95 if state==27 & year==1990
 replace minwage=4.25 if state==27 & year==1991
 replace minwage=6.15 if state==27 & year==2005 & month>7
 replace minwage=6.15 if state==27 & year>2005 & year<2008
 replace minwage=6.15 if state==27 & year==2008 & month<8
 replace minwage = 6.55 if state==27 & ((year==2008 & month>7) | (year==2009 & month<8)) 
 replace minwage = 7.25 if state==27 & (year==2009 & month>7) 


* missouri
 replace minwage=6.5 if state==29 & year==2007
   * cpi adjustment
 replace minwage = 6.65 if state==29 & year==2008
 replace minwage= 7.05 if state==29 & (year==2009 & month<8)
 replace minwage = 7.25 if state==29 & (year==2009 & month>7) 


* montana
 replace minwage=6.15 if state==30 & (year==2007 | (year==2008 & month<8))
 replace minwage = 6.55 if state==30 & ((year==2008 & month>7) | (year==2009 & month<8)) 
 * cpi adjustment
 replace minwage = 6.90 if state==30 & (year==2009 & month<8) 
 replace minwage = 7.25 if state==30 & (year==2009 & month>7) 

* nevada
  * cpi adjustment
 replace minwage=6.15 if state==32 & year==2006 & month>10
 replace minwage=6.33 if state==32 & (year==2007 | (year==2008 & month<8))
 replace minwage = 6.55 if state==32 & ((year==2008 & month>7) | (year==2009 & month<8)) 
 replace minwage = 7.25 if state==32 & (year==2009 & month>7) 


* New Hampshire 
 replace minwage=3.45 if state==33 & year==1987
 replace minwage=3.55 if state==33 & year==1988
 replace minwage=3.65 if state==33 & year==1989
 replace minwage=3.75 if state==33 & year==1990 & month<4
 replace minwage=3.85 if state==33 & year==1991 & month<4
 replace minwage=6.5 if state==33 & ((year==2007 & month>8) | (year==2008 & month<8))
 replace minwage = 7.25 if state==33 & ((year==2008 & month>8) | year==2009) 
* note --- increased to $7.55 if do not receive paid health benefits.


* New Jersey
 replace minwage=5.05 if state==34 & ((year>1992 & year<1997) | (year==1992 & month>3))
 replace minwage=5.05 if state==34 & (year==1997 & month<9)
 replace minwage=6.15 if state==34 & ((year==2005 & month>9) | (year==2006 & month<10))
 replace minwage=7.15 if state==34 & (year==2006 & month>9)
 replace minwage=7.15 if state==34 & (year==2007 | year==2008 | (year==2009 & month<8))
 replace minwage = 7.25 if state==34 & (year==2009 & month>7) 


* New Mexico
 replace minwage = 6.5 if state==35 & year==2008 & month<8
 replace minwage = 6.55 if state==35 & year==2008 & month>7
 replace minwage = 7.5 if state==35 & year==2009


* New York
 replace minwage=6.00 if state==36 & year==2005
 replace minwage=6.75 if state==36 & year==2006
 replace minwage=7.15 if state==36 & (year==2007 | year==2008 | (year==2009 & month<8))
 replace minwage = 7.25 if state==36 & (year==2009 & month>7) 


* north carolina
 replace minwage=6.15 if state==37 & (year==2007 | (year==2008 & month<8))
 replace minwage = 6.55 if state==37 & ((year==2008 & month>7) | (year==2009 & month<8)) 
 replace minwage = 7.25 if state==37 & (year==2009 & month>7) 


* north dakota
 replace minwage=5.85 if state==38 & ((year==2007 & month>6) | (year==2008 & month<8)) 
 replace minwage = 6.55 if state==38 & ((year==2008 & month>7) | (year==2009 & month<8)) 
 replace minwage = 7.25 if state==38 & (year==2009 & month>7) 


* ohio
 replace minwage=6.85 if state==39 & year>2006 & year<2008
  * cpi adjustment
 replace minwage=7.00 if state==39 & year==2008
 replace minwage=7.30 if state==39 & year==2009


* Oregon 
 replace minwage=3.85 if state==41 & (year==1989 & month>8)
 replace minwage=4.25 if state==41 & year==1990
 replace minwage=4.75 if state==41 & (year>1990 & year<1997)
 replace minwage=5.50 if state==41 & year==1997
 replace minwage=6.00 if state==41 & year==1998
 replace minwage=6.50 if state==41 & year>1998 & year<2003
 replace minwage=6.90 if state==41 & year==2003
 replace minwage=7.05 if state==41 & year==2004
 replace minwage=7.25 if state==41 & year==2005
 replace minwage=7.50 if state==41 & year==2006
 replace minwage=7.80 if state==41 & year==2007
 replace minwage=7.95 if state==41 & year==2008
 replace minwage=8.40 if state==41 & year==2009


* Pennsylvania 
 replace minwage=3.70 if state==42 & ((year==1989 & month>1) | (year==1990 &  month<4))
 replace minwage=6.25 if state==42 & year==2007 & month<7
 replace minwage=7.15 if state==42 & year==2007 & month>6
 replace minwage=7.15 if state==42 & (year==2008 | (year==2009 & month<8))
 replace minwage = 7.25 if state==42 & (year==2009 & month>7) 

* Rhode Island 
 replace minwage=3.55 if state==44 & ((year==1986 & month>6) | (year==1987 & month<7))
 replace minwage=3.65 if state==44 & ((year==1987 & month>6) | (year==1988 & month<7))
 replace minwage=4.00 if state==44 & ((year==1988 & month>6) | (year==1989 & month<8))
 replace minwage=4.25 if state==44 & ((year==1989 & month>7) | (year==1990) | (year==1991 & month<4))
 replace minwage=4.45 if state==44 & ((year==1991 & month>3) | (year>1991 & year<1996))
 replace minwage=4.45 if state==44 & year==1996 & month<10
 replace minwage=5.65 if state==44 & year==1999 & month>6
 replace minwage=5.65 if state==44 & year==2000 & month<9
 replace minwage=6.15 if state==44 & year==2000 & month>8
 replace minwage=6.15 if state==44 & year>2000 & year<2004
 replace minwage=6.75 if state==44 & year>2003 & year<2007
 replace minwage=6.75 if state==44 & year==2006 & month<3
 replace minwage=7.10 if state==44 & year==2006 & month>2
 replace minwage=7.40 if state==44 & year>2006


* south dakota
 replace minwage = 5.85 if state==46 & ((year==2007 & month>6) | (year==2008 & month<8)) 
 replace minwage = 6.55 if state==46 & ((year==2008 & month>7) | (year==2009 & month<8)) 
 replace minwage = 7.25 if state==46 & (year==2009 & month>7) 


* Vermont 
 replace minwage=3.45 if state==50 & ((year==1986 & month>6) | (year==1987 & month<7))
 replace minwage=3.55 if state==50 & ((year==1987 & month>6) | (year==1988 & month<7))
 replace minwage=3.65 if state==50 & ((year==1988 & month>6) | (year==1989 & month<7))
 replace minwage=3.75 if state==50 & ((year==1989 & month>6) | (year==1990 & month<4))
 replace minwage=3.85 if state==50 & ((year==1990 & month>3) | (year==1991 & month<4))
 replace minwage=4.50 if state==50 & year==1995
 replace minwage=4.75 if state==50 & year==1996
 replace minwage=5.15 if state==50 & year==1997 & month>6 & month<10
 replace minwage=5.25 if state==50 & year==1997 & month>9
 replace minwage=5.25 if state==50 & year==1998
 replace minwage=5.25 if state==50 & year==1999 & month<10
 replace minwage=5.75 if state==50 & year==1999 & month>9
 replace minwage=5.75 if state==50 & year==2000
 replace minwage=6.25 if state==50 & year==2001
 replace minwage=6.25 if state==50 & year==2002
 replace minwage=6.25 if state==50 & year==2003
 replace minwage=6.75 if state==50 & year==2004
 replace minwage=7.00 if state==50 & year==2005
 replace minwage=7.25 if state==50 & year==2006
 replace minwage=7.53 if state==50 & year==2007
 replace minwage=7.68 if state==50 & year==2008
 replace minwage=8.06 if state==50 & year==2009

* Washington 
 replace minwage=3.85  if state==53 & year==1989
 replace minwage=4.25  if state==53 & (year==1990 | year==1991)
 replace minwage=4.90  if state==53 & (year>1993 & year<1997)
 replace minwage=4.90  if state==53 & year==1997 & month<9
 replace minwage=5.70  if state==53 & year==1999
 replace minwage=6.50  if state==53 & year==2000
* cpi adjusted from here on out
 replace minwage=6.72  if state==53 & year==2001
 replace minwage=6.90  if state==53 & year==2002
 replace minwage=7.01  if state==53 & year==2003
 replace minwage=7.16  if state==53 & year==2004
 replace minwage=7.35  if state==53 & year==2005
 replace minwage=7.63  if state==53 & year==2006
 replace minwage=7.93  if state==53 & year==2007
 replace minwage=8.07  if state==53 & year==2008
 replace minwage=8.55  if state==53 & year==2009


* west virginia
 replace minwage=5.85  if state==54 & year==2006 & month>6
 replace minwage=5.85  if state==54 & year==2007 & month<7
 replace minwage=6.55  if state==54 & ((year==2007 & month>6) | (year==2008 & month<7))
 replace minwage = 7.25 if state==54 & ((year==2008 & month>6) | year==2009)


* wisconsin
 replace minwage=5.70 if state==55 & year==2005 & month>5
 replace minwage=5.70 if state==55 & year==2006 & month<6
 replace minwage=6.50 if state==55 & ((year==2006 & month>5) | year==2007)
 replace minwage=6.50 if state==55 & year==2008 & month<8
 replace minwage = 6.55 if state==55 & ((year==2008 & month>7) | (year==2009 & month<8))
 replace minwage = 7.25 if state==55 & (year==2009 & month>7) 


* states that are indexing (as of 2008): arizona (but not binding), colorado, florida, missouri,
*  montana, ohio, oregon, vermont, washington.  


* global check on state vs federal

gen lagst = state[_n-1] 
gen lagmw = minwage[_n-1] 
 replace lagmw=. if year==1982 & month==1
 replace lagmw=. if state~=lagst

gen check = minwage - usmin
gen check2 = minwage - lagmw
 replace check2=. if state~=lagst


summarize minwage usmin check check2
summ


*************************************************************
*  compute quarterly and annual changes in the minimum wage *
*************************************************************

keep state year month minwage usmin

gen st1 = state[_n-1]
gen st2 = state[_n-2]
gen st3 = state[_n-3]
gen st4 = state[_n-4]
gen st5 = state[_n-5]
gen st6 = state[_n-6]
gen st7 = state[_n-7]
gen st8 = state[_n-8]
gen st9 = state[_n-9]
gen st10 = state[_n-10]
gen st11 = state[_n-11]
gen st12 = state[_n-12]
gen st13 = state[_n-13]
gen st14 = state[_n-14]
gen st15 = state[_n-15]
gen st16 = state[_n-16]
gen st17 = state[_n-17]
gen st18 = state[_n-18]
gen st19 = state[_n-19]
gen st20 = state[_n-20]
gen st21 = state[_n-21]
gen st22 = state[_n-22]
gen st23 = state[_n-23]
gen st24 = state[_n-24]
gen st25 = state[_n-25]
gen st26 = state[_n-26]
gen st27 = state[_n-27]
gen st28 = state[_n-28]
gen st29 = state[_n-29]

gen st1ld = state[_n+1]
gen st2ld = state[_n+2]
gen st3ld = state[_n+3]
gen st4ld = state[_n+4]
gen st5ld = state[_n+5]
gen st6ld = state[_n+6]
gen st7ld = state[_n+7]
gen st8ld = state[_n+8]
gen st9ld = state[_n+9]
gen st10ld = state[_n+10]
gen st11ld = state[_n+11]
gen st12ld = state[_n+12]
gen st13ld = state[_n+13]
gen st14ld = state[_n+14]
gen st15ld = state[_n+15]

forv x=1/29 {
 gen mw`x' = minwage[_n-`x']
  replace mw`x' = . if state~=st`x'
}

forv x=1/15 {
gen mw`x'ld = minwage[_n+`x']
 replace mw`x'ld=. if state~=st`x'ld
}

gen dminwage3 = minwage - mw3
gen dminwage6 = minwage - mw6
gen dminwage9 = minwage - mw9
gen dminwage12 = minwage - mw12
gen dminwage15 = minwage - mw15

gen dlminwage3 = log(minwage) - log(mw3)
gen dlminwage6 = log(minwage) - log(mw6)
gen dlminwage9 = log(minwage) - log(mw9)
gen dlminwage12 = log(minwage) - log(mw12)
gen dlminwage15 = log(minwage) - log(mw15)

* generate lags of minimum wage
gen dlminwage3l1 = dlminwage3[_n-3]
 replace dlminwage3l1=. if state~=st3

gen dlminwage3l2 = dlminwage3[_n-6]
 replace dlminwage3l2=. if state~=st6

gen dlminwage3l3 = dlminwage3[_n-9]
 replace dlminwage3l3=. if state~=st9

gen dlminwage3l4 = dlminwage3[_n-12]
 replace dlminwage3l4=. if state~=st12

gen dlminwage3l5 = dlminwage3[_n-15]
 replace dlminwage3l5=. if state~=st15

drop if year<1979

summarize

drop st1-st15 st1ld st2ld st3ld st4ld st5ld st6ld st7ld st8ld st9ld st10ld st11ld st12ld st13ld st14ld st15ld

* drop DC which I really don't have a good series for
drop if state==11

* thru 2008
* drop if year>2008


sort state year month

save mw7909, replace

* Make a few adjustments for credit card data version

ren state stfips

* Make nominal copies of a few measures we will use later.
ren minwage mw
gen mw_nominal = mw
gen mw5_nominal = mw5
gen mw6_nominal = mw6
 

* Now make everything else real
gen pce = 0
 replace pce=0.7695 if year == 1992
 replace pce=0.7864 if year == 1993
 replace pce=0.8027 if year == 1994
 replace pce=0.8204 if year == 1995
 replace pce=0.8383 if year == 1996
 replace pce=0.8539 if year == 1997
 replace pce=0.8621 if year == 1998
 replace pce=0.8760 if year == 1999
 replace pce=0.8978 if year == 2000
 replace pce=0.9149 if year == 2001
 replace pce=0.9274 if year == 2002
 replace pce=0.9462 if year == 2003
 replace pce=0.9710 if year == 2004
 replace pce=1.0000 if year == 2005
 replace pce=1.0275 if year == 2006
 replace pce=1.0550 if year == 2007
 replace pce=1.0903 if year == 2008

sort stfips year month
 
replace mw = mw / pce
forv x=1/29 {
 by stfips: replace mw`x' = mw`x' / pce[_n-`x']
}
forv x=1/15 {
 by stfips: replace mw`x' = mw`x'ld / pce[_n+`x']
}

keep if year>=1995 & year<=2008
ren year year_num

sort stfips year_num month

save mw9508.dta, replace
 
exit, clear

