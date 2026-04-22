README FILE FOR REPLICATION OF RESULTS IN “HOUSE PRICES, HOME EQUITY-BASED BORROWING, AND THE U.S. HOUSEHOLD LEVERAGE CRISIS,” BY ATIF MIAN AND AMIR SUFI, FORTHCOMING IN THE AMERICAN ECONOMIC REVIEW.

THE STATA DO FILE CONTAINS ALL NECESSARY INFORMATION AND CODE. IT IS CALLED MIANSUFI_AER_HOMEEQUITY.DO. THE BELOW NOTES ON DATA AVAILABILITY ARE ALSO IN THE DO FILE.

ATIF MIAN AND AMIR SUFI, JUNE 2010.

*********************************************
******** REQUIRED DATA FILES          *******
*********************************************

*THE FOLLOWING 8 DATA SETS ARE USED TO CREATE FIGURES AND TABLES
*houseanal_temp_8mv.dta
*houseanal_temp_8ma.dta
*houseanal_temp_8mvCS.dta
*houseanal_temp_8miCS.dta
*houseanal_temp_8maCS.dta
*houseanal_temp_8msvCS.dta
*houseanal_temp_8mmvCS.dta
*houseanal_temp_8mtvCS.dta

*the end of the file names reveal how the data were sorted before grouping into groups of 5.
*_8mv means sorted by 1997 zipcode, whether the individual moved between 1997 and 1999, and then vantage score
*_8ma is same as first two, then age
*_8mi is same as first two, then 2008 estimated income
*_8msv is same as first two, then gender, then vantage score
*_8mmv is same as first two, then year moved, then vantage score
*_8mtv is same as first two, then number of mortgage accounts, then vantage score
*the CS stands for Cross-Sectional, meaning the data have been reshaped from a panel to a cross-section

*PROPRIETARY DATA
*In the construction of the above data sets, three of the data providers
*do not allow sharing of the data for free. We can only provide the above data sets
*to another researcher if we have explicit permission from the following data providers.
*Researchers will likely have to pay the data providers for access.
*
*EQUIFAX
*The individual and zip code level data are from EQUIFAX. Please contact
*Lori Pete at EQUIFAX (lori.pete@equifax.com)
*
*
*FISERV CASE SHILLER WEISS
*The zip code level house price indices are from FCSW. Please contact
*Cameron Rogers FISERV (cameron.rogers@fiserv.com)
*
*
*ZIP-CODES.COM
*Data matching zipcodes to CBSAs are from zip-codes.com. If you show
*proof of purchase of ths standard US Zip Code Database, that will
*be sufficient.
*
*
*We are willing to share the above data sets if researchers obtain explicit
*permission from Equifax and FCSW for the data. As mentioned before, we imagine
*that researchers will have to pay for some or all of these data.
*
*
*Atif Mian and Amir Sufi, June 2010

