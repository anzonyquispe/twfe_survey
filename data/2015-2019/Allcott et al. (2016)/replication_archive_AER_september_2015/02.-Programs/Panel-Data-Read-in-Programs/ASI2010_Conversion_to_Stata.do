* Conversion of ASCII data from the India ASI panel datasets to Stata format   ;
* 27 September 2013                                                             ;

set more off
clear all
local yr=11
tempvar tmpv

#delimit ;

* BLOCK-A (IDENTIFICATION BLOCK FOR OFFICIAL USE);

infix
str YEAR	1-4
str FACT_ID	5-12
str BLK	13-13
str A3	14-14
str A4	15-18
str A5	19-23
str A9	24-24
str A10	25-29
str A11	30-32
str A12	33-34
str MWDAYS	35-37
str NWDAYS	38-40
str WDAYS	41-43
str COSTOP	44-57
str EXPORTSHARE	58-60
str MULT	61-69
using "$data/ASI/raw data//`year'/OASA`yr'.txt";

destring *, replace;

la var YEAR "2011";
la var FACT_ID "Factory Code";
la var BLK "Block code, Always 'A'";
la var A3 "Scheme code";
la var A4 "Ind. Code as per Frame (4-digit level of NIC-04/NIC-98)";
la var A5 "Ind Code as per Return (5-digit, NIC-04/NIC-98)";
la var A9 "Rural/Urban code";
la var A10 "RO/SRO code";
la var A11 "No. of units";
la var A12 "Status of Unit ";
la var MWDAYS "Number of working days ( Manufacturing days)";
la var NWDAYS "Number of working days (Non-Manufacturing days)";
la var WDAYS "Number of working days ( Total)";
la var COSTOP "Cost of Production";
la var EXPORTSHARE "Share % of products/by-products directly exported.";
la var MULT "Inflation/Multiplier factor (in 9999.9999 format)";



la def scheme 1 "Census" 2 "Sample";
la val A3 scheme;

la def sector 1 "Rural" 2 "Urban";
la val A9 sector;

la def status
	1  "Open"
	2  "Closed"
	3  "NOP"
	4  "Deleted (found non-existent within 3 years)"
	5  "Non-response due to closure but in existence and owner/occupier is not traceable"
	6  "Non-response due to non existence now& owner not traceable"
	7  "Non-response due to relevant records are with court/Income tax department etc."
	8  "Non-response due to recalcitrant/refuse to submit the return"
	9  "Non-response due to factory under prosecution in respect of earlier ASI"
	10 "Non-response due to other reasons"
	11 "Deleted (found non-existent after more than 3 years)"
	12 "Deleted due to deregistration"
	13 "Deleted due to out of coverage i.e. Defence,Oil Storage, Technical"
	14 "Deleted due to identical with PSL. No."
	15 "Deleted due to any other reason (Specify)";
la val A12 status;

compress;
sort FACT_ID;
save "$work/BLA`year'.dta", replace;


* BLOCK-B (TO BE FILLED BY OWNERS);

clear;
infix
str YEAR	1-4
str FACT_ID	5-12
str BLK	13-13
str B02	14-15
str B03	16-16
str B05	17-20
str B06F	21-29
str B06T	30-38
str B07	39-40
str B08	41-41
str B09	42-42
str B04	43-43
str MULT	44-52
using "$data/ASI/raw data//`year'/OASB`yr'.txt";

destring *, replace;

la var YEAR "2011";
la var FACT_ID "Factory Code";
la var BLK "Block code, Always 'B'";
la var B02 "Type of organisation(code)";
la var B03 "Type of ownership(code)";
la var B05 "Year of initial production";
la var B06F "Accounting year (From)";
la var B06T "Accounting year (To)";
la var B07 "Number of months of operation";
la var B08 "Does your unit have computerised A/C system? (Yes-1, No-2)";
la var B09 "Can your unit supply ASI data in Computer Floppy(Yes-1,No-2)";
la var B04 "Whether the unit has ISO Certification, 14000 series";
la var MULT "Inflation/Multiplier factor (in 9999.9999 format)";

la def org
	1 "Individual Proprietorship"
	2 "Joint Family (HUF)"
	3 "Partnership"
	4 "Public Limited Company"
	5 "Private Limited Company"
	6 "Government Departmental Enterprise (excluding Khadi,Handloom)"
	7 "Public Corporation by Special Act of Parliament or State Legislature Of PSU"
	8 "Khadi and Village Industries Commission"
	9 "Handlooms"
	10 "Co-operative Society"
	19 "Others (including Trusts, Wakf Boards etc.)";
la val B02 org;

la def own
	1 "Wholly Central Government"
	2 "Wholly State and/or Local Govt."
	3 "Central Government and State and/or Local Government jointly"
	4 "Joint Sector Public"
	5 "Joint Sector Private"
	6 "Wholly Private Ownership";
la val B03 own;

la def yesno 1 "Yes" 2 "No";
la val B08 yesno;
la val B09 yesno;

***concord variable names to the conventions found in the prior two years;
rename B09 B11;
rename B07 B09;
rename B05 B07;
rename B04 B06;
rename B06F B08F;
rename B06T B08T;
rename B08 B10;

compress;
sort FACT_ID;
save "$work/BLB`year'.dta", replace;


* BLOCK-C (FIXED ASSETS);

clear;
infix
str YEAR	1-4
str FACT_ID	5-12
str BLK	13-13
str C_I1	14-15
str C_I3	16-29
str C_I4	30-43
str C_I5	44-57
str C_I6	58-71
str C_I7	72-85
str C_I8	86-99
str C_I9	100-113
str C_I10	114-127
str C_I11	128-141
str C_I12	142-155
str C_I13	156-169
str MULT	170-178
using "$data/ASI/raw data//`year'/OASC`yr'.txt";

* Values have leading zeros and some have negative values (e.g. "0000-1234"). We remove the leading zeros. ;
* This will allow us to de-string these variables. ;

local varlst "C_I3 C_I4 C_I5 C_I6 C_I7 C_I8 C_I9 C_I10 C_I11 C_I12 C_I13";
foreach x of local varlst {;
	gen `tmpv' = substr(`x',strpos(`x',"-"),.);
	replace `x'=`tmpv' if `tmpv'~="";
	drop `tmpv';
};

destring *, replace;

la var YEAR "2011";
la var FACT_ID "Factory Code";
la var BLK "Block code, Always 'C'";
la var C_I1 "S. No. (to be entered as printed in the schedule)";
la var C_I3 "Opening as on ";
la var C_I4 "Due to revaluation";
la var C_I5 "Actual addition";
la var C_I6 "Deduction & adjustment during the year";
la var C_I7 "Closing as on";
la var C_I8 "Up to year beginning ";
la var C_I9 "Provided during the year";
la var C_I10 "Adjustment during the year for sold/ discarded.";
la var C_I11 "Up to year end";
la var C_I12 "Opening as on ";
la var C_I13 "Closing as on";
la var MULT "Inflation/Multiplier factor (in 9999.9999 format)";



la def itemC
	1 "Land"
	2 "Building"
	3 "Plant & Machinery"
	4 "Transport equipment" 
	5 "Computer equipment including software"
	6 "Pollution Control Equipment"
	7 "Others"
	8 "Sub-total (2 to 7)"
	9 "Capital work in progress"
	10 "Total (1+8+9)";
la val C_I1 itemC;

compress;
sort FACT_ID;
save "$work/BLC`year'.dta", replace;


* BLOCK-D (WORKING CAPITAL AND LOANS);

clear;
infix
str YEAR	1-4
str FACT_ID	5-12
str BLK	13-13
str D_I1	14-15
str D_I3	16-29
str D_I4	30-43
str MULT	44-52
using "$data/ASI/raw data//`year'/OASD`yr'.txt";

local varlst "D_I3 D_I4";
foreach x of local varlst {;
	gen `tmpv' = substr(`x',strpos(`x',"-"),.);
	replace `x'=`tmpv' if `tmpv'~="";
	drop `tmpv';
};
destring *, replace;

la var YEAR "2011";
la var FACT_ID "Factory Code";
la var BLK "Block code, Always 'D'";
la var D_I1 "S. No. (to be entered as printed in the schedule)";
la var D_I3 "Opening (Rs.)";
la var D_I4 "Closing (Rs.)";
la var MULT "Inflation/Multiplier factor (in 9999.9999 format)";



la def itemD
	1 "Raw Materials & Components and Packing materials"
	2 "Fuels & Lubricants"
	3 "Spares, Stores & Others"
	4 "Sub-total (1 to 3)"
	5 "Semi-finished goods/work in progress"
	6 "Finished goods"
	7 "Total inventory ( 4 to 6)"
	8 "Cash in Hand in Hand & at Bank"
	9 "Sundry Debtors"
	10 "Other current assets"
	11 "Total current assets (7 to 10)"
	12 "Sundry Creditors"
	13 "Over draft, cash credit, other short Terms loan from Banks & other financial Institutions"
	14 "Other current liabilities"
	15 "Total current liabilities (12 to 14)"
	16 "Working capital (11 minus 15)"
	17 "Outstanding loans (excluding Interest but including deposits)";
la val D_I1 itemD;

compress;
sort FACT_ID;
save "$work/BLD`year'.dta", replace;


* BLOCK-E (EMPLOYMENT AND LABOUR COST);

clear;
infix
str YEAR	1-4
str FACT_ID	5-12
str BLK	13-13
str E_I1	14-15
str E_I3	16-23
str E_I4	24-31
str E_I5	32-41
str E_I6	42-49
str E_I7	50-59
str E_I8	60-73
str E_I10	74-87
str E_I11	88-101
str E_I12	102-115
str MULT	116-124
using "$data/ASI/raw data//`year'/OASE`yr'.txt";

destring *, replace;

la var YEAR "2011";
la var FACT_ID "Factory Code";
la var BLK "Block code, Always 'E'";
la var E_I1 "S. No. (to be entered as printed in the schedule)";
la var E_I3 "Mandays Worked (Manufacturing)";
la var E_I4 "Mandays Worked (Non Manufacturing)";
la var E_I5 "Mandays Worked (Total)";
la var E_I6 "Average Number of persons worked";
la var E_I7 "No. of mandays paid for";
la var E_I8 "Wages/salaries (in Rs.)";
la var E_I10 "Bonus (in Rs.)";
la var E_I11 "Contribution to Provident Fund and other funds";
la var E_I12 "Workmen & Staff Welfare Expenses";
la var MULT "Inflation/Multiplier factor (in 9999.9999 format)";




la def itemE
	1 "Male Workers employed directly"
	2 "Female Workers employed directly"
	3 "Sub-total (1+2)"
	4 "Workers employed through contractors"
	5 "Total Workers (3+4)"
	6 "Supervisory & managerial staff"
	7 "Other employees"
	8 "Unpaid family members/proprietor/Coop. members"
	9 "Total employees (5+6+7+8)";
la val E_I1 itemE;

compress;
sort FACT_ID;
save "$work/BLE`year'.dta", replace;


* BLOCK-F (OTHER EXPENSES);

clear;
infix
str YEAR	1-4
str FACT_ID	5-12
str BLK	13-13
str F1	14-27
str F2A	28-41
str F2B	42-55
str F3	56-69
str F4	70-83
str F5	84-97
str F6	98-111
str F7	112-125
str F8	126-139
str F9	140-153
str F10	154-167
str F11	168-181
str MULT	182-190
using "$data/ASI/raw data//`year'/OASF`yr'.txt";

destring *, replace;

la var YEAR "2011";
la var FACT_ID "Factory Code";
la var BLK "Block code, Always 'F'";
la var F1 "Work done by others ";
la var F2A "Repair & maintenance of Building";
la var F2B "Repair & maintenance of Other fixed assets";
la var F3 "Operating expenses";
la var F4 "Non-operating expenses ";
la var F5 "Insurance Charges";
la var F6 "Rent paid for Plant & Machinery and other Fixed assets ";
la var F7 "Total expenses (1 to 6)";
la var F8 "Rent paid for Buildings";
la var F9 "Rent paid for land on lease or royalties on mines, quarries etc.";
la var F10 "Interest paid ";
la var F11 "Purchase value of goods sold in the same condition as purchased";
la var MULT "Inflation/Multiplier factor (in 9999.9999 format)";


compress;
sort FACT_ID;
save "$work/BLF`year'.dta", replace;


* BLOCK-G (OTHER OUTPUT/RECEIPTS);

clear;
infix
str YEAR	1-4
str FACT_ID	5-12
str BLK	13-13
str G1	14-27
str G2	28-41
str G3	42-55
str G4	56-69
str G5	70-83
str G6	84-97
str G7	98-111
str G8	112-125
str G9	126-139
str G10	140-153
str G11	154-167
str G12	168-181
str MULT	182-190
using "$data/ASI/raw data//`year'/OASG`yr'.txt";

destring *, replace;

la var YEAR "2011";
la var FACT_ID "Factory Code";
la var BLK "Block code, Always 'G'";
la var G1 "Income from services";
la var G2 "Variation in stock of semi-finished goods";
la var G3 "Value in electricity generated and sold.";
la var G4 "Value of own construction";
la var G5 "Net balance of goods sold in the same condition as purchased";
la var G6 "Rent received for Plant & Machinery and other fixed assets";
la var G7 "Total receipts (1 to 6)";
la var G8 "Rent received for building";
la var G9 "Rent received for land on lease or royalties on mines, quarries etc.";
la var G10 "Interest received";
la var G11 "Sale value of goods sold in the same condition as purchased";
la var G12 "Total Subsidies";
la var MULT "Inflation/Multiplier factor (in 9999.9999 format)";


***concord variable names to the conventions found in the prior two years;
rename G12 G7_;
rename G11 G12;
rename G10 G11;
rename G9 G10;
rename G8 G9;
rename G7 G8;
rename G7_ G7;


compress;
sort FACT_ID;
save "$work/BLG`year'.dta", replace;


* BLOCK-H (INPUT ITEMS - Indigenous items consumed);

clear;
infix
str YEAR	1-4
str FACT_ID	5-12
str BLK	13-13
str H_I1	14-15
str H_I3	16-22
str H_I4	23-25
str H_I5	26-39
str H_I6	40-53
str H_I7	54-67
str MULT	68-76
using "$data/ASI/raw data//`year'/OASH`yr'.txt";

destring *, replace;

la var YEAR "2011";
la var FACT_ID "Factory Code";
la var BLK "Block code, Always 'H'";
la var H_I1 "Sl. No.";
la var H_I3 "Item code (NPCMS)";
la var H_I4 "Unit of quantity (code)";
la var H_I5 "Quantity consumed ";
la var H_I6 "Purchase value (in Rs.)";
la var H_I7 "Rate per unit (in Rs.)";
la var MULT "Inflation/Multiplier factor (in 9999.9999 format)";

***code the itemcodes into strings directly so that the encoding doesnt get messed up between years ;
lab def slnoH
11	"Other"
12	"TotalBasic"
13	"Chemicals"
14	"Packing"
15	"ElecGen"
16	"ElecPurchase"
17	"OilConsumed"
18	"CoalConsumed"
19	"GasConsumed"
20	"OtherConsumed"
21	"ConsumableStore"
22	"TotalNonBasic"
23	"Total"
24	"UnmetElec"
;
lab values H_I1 slnoH;
drop if H_I1 > 24 ;

compress;
sort FACT_ID;
save "$work/BLH`year'.dta", replace;


* BLOCK-I (INPUT ITEMS - Directly imported items only (consumed));

clear;
infix
str YEAR	1-4
str FACT_ID	5-12
str BLK	13-13
str I_I1	14-15
str I_I3	16-22
str I_I4	23-25
str I_I5	26-39
str I_I6	40-53
str I_I7	54-67
str MULT	68-76
using "$data/ASI/raw data//`year'/OASI`yr'.txt";

destring *, replace;

la var YEAR "2011";
la var FACT_ID "Factory Code";
la var BLK "Block code, Always 'I'";
la var I_I1 "Sl. No.";
la var I_I3 "Item code (NPCMS)";
la var I_I4 "Unit of quantity (code)";
la var I_I5 "Quantity consumed ";
la var I_I6 "Purchase value at delivery (in Rs.)";
la var I_I7 "Rate per unit (in Rs.) ";
la var MULT "Inflation/Multiplier factor (in 9999.9999 format)";


compress;
sort FACT_ID;
save "$work/BLI`year'.dta", replace;


* BLOCK-J (PRODUCTS AND BY-PRODUCTS (Manufactured by the unit));
clear;
infix
str YEAR	1-4
str FACT_ID	5-12
str BLK	13-13
str J_I1	14-15
str J_I3	16-22
str J_I4	23-25
str J_I5	26-39
str J_I6	40-53
str J_I7	54-67
str J_I8	68-81
str J_I9	82-95
str J_I10	96-109
str J_I11	110-123
str J_I12	124-137
str J_I13	138-151
str MULT	152-160
using "$data/ASI/raw data//`year'/OASJ`yr'.txt";

destring *, replace;

la var YEAR "2011";
la var FACT_ID "Factory Code";
la var BLK "Block code, Always 'J'";
la var J_I1 "Sl.No.";
la var J_I3 "Item code (NPCMS)";
la var J_I4 "Unit of quantity (code)";
la var J_I5 "Quantity manufactured";
la var J_I6 "Quantity sold ";
la var J_I7 "Gross sale value (Rs.)";
la var J_I8 "Excise duty (Rs.) ";
la var J_I9 "Sales Tax (Rs.) ";
la var J_I10 "Others  (Rs.) ";
la var J_I11 "Total (Rs.) ";
la var J_I12 "Per unit net sale value  (Rs.) ";
la var J_I13 "Ex-factory value of output (Rs.) (12 x 5)";
la var MULT "Inflation/Multiplier factor (in 9999.9999 format)";


compress;
sort FACT_ID;
save "$work/BLJ`year'.dta", replace;
