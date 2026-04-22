* Conversion of ASCII data from the India ASI panel datasets to Stata format   ;
* Original Author: Olivier Dupriez, World Bank                                          ;
* Originally Authored: January 29, 2012                                                             ;
* Revised by: Stephen D. O'Connell;
* 23 November 2013 ;

set more off
clear all

if `year'>=2000 {
local yr=`year'-2000+1
}
else {
local yr=`year'-1900
}
tempvar tmpv

#delimit ;

* BLOCK-A (IDENTIFICATION BLOCK FOR OFFICIAL USE);

infix
	str YEAR	1	-	4
	str FACT_ID	5	-	12
	str BLK		13	-	13
	str A3		14	-	14
	str A4		15	-	18
	str A5		19	-	23
	str A9		24	-	24
	str A10		25	-	29
	str A11		30	-	32
	str A12		33	-	34
	str MWDAYS	35	-	37
	str NWDAYS	38	-	40
	str WDAYS	41	-	43
	str COSTOP	44	-	55
	str MULT	56	-	64
using "$data/ASI/raw data//`year'/OASIBLa`yr'.txt";

foreach j in X Y Z { ;
replace A4=subinstr(A4,"`j'","0",.) ;
replace A5=subinstr(A5,"`j'","0",.) ;
} ;

destring *, replace;

la var 	YEAR	"Year";
la var 	FACT_ID	"Factory Code";
la var 	BLK		"Block code";
la var 	A3		"Scheme code";
la var 	A4		"Ind. Code as per Frame (4-digit level of NIC-04/NIC-98)";
la var 	A5		"Ind Code as per Return (5-digit, NIC-04/NIC-98)";
la var 	A9		"Rural/Urban code";
la var 	A10		"RO/SRO code";
la var 	A11		"No. of units";
la var 	A12		"Status of Unit";
la var 	MWDAYS	"Number of working days ( Manufacturing days)";
la var 	NWDAYS	"Number of working days (Non-Manufacturing days)";
la var 	WDAYS	"Number of working days (Total)";
la var 	COSTOP	"Cost of Production";
la var 	MULT	"Inflation/Multiplier factor";

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
saveold "$work/BLA`year'.dta", replace;


* BLOCK-B (TO BE FILLED BY OWNERS);

clear;
infix
	str YEAR	1	-	4
	str FACT_ID	5	-	12
	str BLK		13	-	13
	str B02		14	-	15
	str B03		16	-	16
	str B04		17	-	20
	str B05		21	-	24
	str B06		25	-	28
	str B07F	29	-	37
	str B07T	38	-	46
	str B08		47	-	48
	str B09		49	-	49
	str B10		50	-	50
	str MULT	51	-	59
using "$data/ASI/raw data//`year'/OASIBLb`yr'.txt";

destring *, replace;


la var 	YEAR	"Year";
la var 	FACT_ID	"Factory Code";
la var 	BLK		"Block code";
la var 	B02		"Type of organisation(code)";
la var 	B03		"Type of ownership(code)";
la var 	B04		"Total number of units the company has";
la var 	B05		"How many units located in the same state";
la var 	B06		"Year of initial production";
la var 	B07F	"Accounting year (From)";
la var 	B07T	"Accounting year (To)";
la var 	B08		"Number of months of operation";
la var 	B09		"Does your unit have computerised A/C system?";
la var 	B10		"Can your unit supply ASI data in Computer Floppy";
la var 	MULT	"Inflation/Multiplier factor";

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
la val B09 yesno;
la val B10 yesno;

***concord variable names to the conventions found in 2008;
drop B05;
rename B10 B11;
rename B09 B10;
rename B08 B09;
rename B07T B08T;
rename B07F B08F;
rename B06 B07;

compress;
sort FACT_ID;
saveold "$work/BLB`year'.dta", replace;


* BLOCK-C (FIXED ASSETS);

clear;
infix
	str YEAR	1	-	4
	str FACT_ID	5	-	12
	str BLK		13	-	13
	str C_I1	14	-	15
	str C_I3	16	-	27
	str C_I4	28	-	39
	str C_I5	40	-	51
	str C_I6	52	-	63
	str C_I7	64	-	75
	str C_I8	76	-	87
	str C_I9	88	-	99
	str C_I10	100	-	111
	str C_I11	112	-	123
	str C_I12	124	-	135
	str MULT	136	-	144
using "$data/ASI/raw data//`year'/OASIBLc`yr'.txt";

* Values have leading zeros and some have negative values (e.g. "0000-1234"). We remove the leading zeros. ;
* This will allow us to de-string these variables. ;

local varlst "C_I3 C_I4 C_I5 C_I6 C_I7 C_I8 C_I9 C_I10 C_I11 C_I12";
foreach x of local varlst {;
	gen `tmpv' = substr(`x',strpos(`x',"-"),.);
	replace `x'=`tmpv' if `tmpv'~="";
	drop `tmpv';
};

destring *, replace;

la var 	YEAR	"Year";
la var 	FACT_ID	"Factory Code";
la var 	BLK		"Block code";
la var 	C_I1	"S. No.";
la var 	C_I3	"Opening as on";
la var 	C_I4	"Due to revaluation";
la var 	C_I5	"Actual addition";
la var 	C_I6	"Deduction & adjustment during the year";
la var 	C_I7	"Closing as on";
la var 	C_I8	"Up to year beginning ";
la var 	C_I9	"Provided during the year";
la var 	C_I10	"Up to year end";
la var 	C_I11	"Opening as on";
la var 	C_I12	"Closing as on";
la var 	MULT	"Inflation/Multiplier factor";

if `year' <=2000 { ;
cap lab drop itemC ;
la def itemC
	1	"Land"
	2	"Building"
	3	"Plant & Machinery"
	4	"Transport equipment"
	5	"Computer equipment including software"
	6	"Others"
	7	"Sub-total (2 to 7)"
	8	"Capital work in progress"
	9	"Total (1+8+9)" ;
} ;
else { ;
cap lab drop itemC ;
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
} ;
la val C_I1 itemC;

rename C_I12 C_I13;
rename C_I11 C_I12;
rename C_I10 C_I11;


compress;
sort FACT_ID;
saveold "$work/BLC`year'.dta", replace;


* BLOCK-D (WORKING CAPITAL AND LOANS);

clear;
infix
	str YEAR	1	-	4
	str FACT_ID	5	-	12
	str BLK		13	-	13
	str D_I1	14	-	15
	str D_I3	16	-	27
	str D_I4	28	-	39
	str MULT	40	-	48
using "$data/ASI/raw data//`year'/OASIBLd`yr'.txt";

local varlst "D_I3 D_I4";
foreach x of local varlst {;
	gen `tmpv' = substr(`x',strpos(`x',"-"),.);
	replace `x'=`tmpv' if `tmpv'~="";
	drop `tmpv';
};
destring *, replace;

la var 	YEAR	"Year";
la var 	FACT_ID	"Factory Code";
la var 	BLK		"Block code";
la var 	D_I1	"S. No.";
la var 	D_I3	"Opening (Rs.)";
la var 	D_I4	"Closing (Rs.)";
la var 	MULT	"Inflation/Multiplier factor";

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
saveold "$work/BLD`year'.dta", replace;


* BLOCK-E (EMPLOYMENT AND LABOUR COST);

clear;
infix
	str YEAR	1	-	4
	str FACT_ID	5	-	12
	str BLK		13	-	13
	str E_I1	14	-	15
	str E_I3	16	-	23
	str E_I4	24	-	31
	str E_I5	32	-	41
	str E_I6	42	-	49
	str E_I7	50	-	59
	str E_I8	60	-	71
	str E_I9	72	-	83
	str E_I10	84	-	95
	str E_I11	96	-	107
	str MULT	108	-	116
using "$data/ASI/raw data//`year'/OASIBLe`yr'.txt";

destring *, replace;

la var 	YEAR	"Year";
la var 	FACT_ID	"Factory Code";
la var 	BLK		"Block code";
la var 	E_I1	"S. No.";
la var 	E_I3	"Mandays Worked (Manufacturing)";
la var 	E_I4	"Mandays Worked (Non Manufacturing)";
la var 	E_I5	"Mandays Worked (Total)";
la var 	E_I6	"Average Number of persons worked";
la var 	E_I7	"No. of mandays paid for";
la var 	E_I8	"Wages/salaries (in Rs.)";
la var 	E_I9	"Bonus (in Rs.)";
la var 	E_I10	"Contribution to Provident Fund and other funds";
la var 	E_I11	"Workmen & Staff Welfare Expenses";
la var 	MULT	"Inflation/Multiplier factor";

la def itemE
	1 "Male Workers employed directly"
	2 "Female Workers employed directly"
	3 "Child Workers employed directly"
	4 "Sub-total (1+2+3)"
	5 "Workers employed through contractors"
	6 "Total Workers (4+5)"
	7 "Supervisory & managerial staff"
	8 "Other employees"
	9 "Unpaid family members/proprietor/Coop. members"
	10 "Total employees (6+7+8+9)";
la val E_I1 itemE;



rename E_I11 E_I12;
rename E_I10 E_I11;
rename E_I9 E_I10;

compress;
sort FACT_ID;
saveold "$work/BLE`year'.dta", replace;


* BLOCK-F (OTHER EXPENSES);

clear;
infix
	str YEAR	1	-	4
	str FACT_ID	5	-	12
	str BLK		13	-	13
	str F1		14	-	25
	str F2A		26	-	37
	str F2B		38	-	49
	str F2C		50	-	61
	str F2D		62	-	73
	str F3		74	-	85
	str F4		86	-	97
	str F5		98	-	109
	str F6		110	-	121
	str F7		122	-	133
	str F8		134	-	145
	str F9		146	-	157
	str F10		158	-	169
	str F11		170	-	181
	str MULT	182	-	190
using "$data/ASI/raw data//`year'/OASIBLf`yr'.txt";

destring *, replace;

la var 	YEAR	"Year";
la var 	FACT_ID	"Factory Code";
la var 	BLK		"Block code";
la var 	F1		"Work done by others ";
la var 	F2A		"Repair & maintenance of Building";
la var 	F2B		"Repair & maintenance of Plant & Machinery";
la var 	F2C		"Repair & maintenance of Pollution control equipment";
la var 	F2D		"Repair & maintenance of Other fixed assets";
la var 	F3		"Operating expenses";
la var 	F4		"Non-operating expenses";
la var 	F5		"Insurance Charges";
la var 	F6		"Rent paid for Plant & Machinery and other Fixed assets";
la var 	F7		"Total expenses (1 to 6)";
la var 	F8		"Rent paid for Buildings";
la var 	F9		"Rent paid for land on lease or royalties on mines, quarries etc.";
la var 	F10		"Interest paid ";
la var 	F11		"Purchase value of goods sold in the same condition as purchased";
la var 	MULT	"Inflation/Multiplier factor";

drop F2C F2D;

compress;
sort FACT_ID;
saveold "$work/BLF`year'.dta", replace;


* BLOCK-G (OTHER OUTPUT/RECEIPTS);

clear;
infix
	str YEAR	1	-	4
	str FACT_ID	5	-	12
	str BLK		13	-	13
	str G1		14	-	25
	str G2		26	-	37
	str G3		38	-	49
	str G4		50	-	61
	str G5		62	-	73
	str G6		74	-	85
	str G7		86	-	97
	str G8		98	-	109
	str G9		110	-	121
	str G10		122	-	133
	str G11		134	-	145
	str	MULT	146	-	154
using "$data/ASI/raw data//`year'/OASIBLg`yr'.txt";

destring *, replace;

la var 	YEAR	"Year";
la var 	FACT_ID	"Factory Code";
la var 	BLK		"Block code";
la var 	G1		"Income from services";
la var 	G2		"Variation in stock of semi-finished goods";
la var 	G3		"Value in electricity generated and sold.";
la var 	G4		"Value of own construction";
la var 	G5		"Net balance of goods sold in the same condition as purchased";
la var 	G6		"Rent received for Plant & Machinery and other fixed assets";
la var 	G7		"Total receipts (1 to 6)";
la var 	G8		"Rent received for building";
la var 	G9		"Rent received for land on lease or royalties on mines, quarries etc.";
la var 	G10		"Interest received";
la var 	G11		"Sale value of goods sold in the same condition as purchased";
la var 	MULT	"Inflation/Multiplier factor";

***concord variable names to the conventions found in 2008;
rename G11 G12;
rename G10 G11;
rename G9 G10;
rename G8 G9;
rename G7 G8;


compress;
sort FACT_ID;
saveold "$work/BLG`year'.dta", replace;


* BLOCK-H (INPUT ITEMS - Indigenous items consumed);

clear;
infix
	str YEAR	1	-	4
	str FACT_ID	5	-	12
	str BLK		13	-	13
	str H_I1	14	-	15
	str H_I3	16	-	20
	str H_I4	21	-	23
	str H_I5	24	-	39
	str H_I6	40	-	51
	str H_I7	52	-	66
	str MULT	67	-	75
using "$data/ASI/raw data//`year'/OASIBLh`yr'.txt";

destring *, replace;

la var 	YEAR	"Year";
la var 	FACT_ID	"Factory Code";
la var 	BLK		"Block code";
la var 	H_I1	"Sl. No.";
la var 	H_I3	"Item code (ASICC)";
la var 	H_I4	"Unit of quantity (code)";
la var 	H_I5	"Quantity consumed";
la var 	H_I6	"Purchase value (in Rs.)";
la var 	H_I7	"Rate per unit (in Rs.0.00)";
la var 	MULT	"Inflation/Multiplier factor";

***the following incorporates changes to the underlying serial numbering in the questionnaires across years;
if `year' <=2000 { ;
	cap lab drop slnoH ;
	lab def slnoH
	6	"Other"
	7	"TotalBasic"
	8	"Chemicals"
	9	"Packing"
	10	"ElecGen"
	11	"ElecPurchase"
	12	"OilConsumed"
	13	"CoalConsumed"
	14	"OtherConsumed"
	15	"ConsumableStore"
	16	"TotalNonBasic"
	17	"Total"
	;
	lab values H_I1 slnoH;
} ;
else if `year' >2000 & `year' <=2002 { ;
	cap lab drop slnoH ;
	lab def slnoH
	6	"Other"
	7	"TotalBasic"
	8	"Chemicals"
	9	"Packing"
	10	"ElecGen"
	11	"ElecPurchase"
	12	"OilConsumed"
	13	"CoalConsumed"
	14	"OtherConsumed"
	15	"ConsumableStore"
	16	"TotalNonBasic"
	17	"Total"
	18	"UnmetElec"
	;
	lab values H_I1 slnoH;
	drop if H_I1>18 ;
} ;
else if `year' >2002 & `year' <=2007 { ;
	cap lab drop slnoH ;
	lab def slnoH
	11	"Other"
	12	"TotalBasic"
	13	"Chemicals"
	14	"Packing"
	15	"ElecGen"
	16	"ElecPurchase"
	17	"OilConsumed"
	18	"CoalConsumed"
	19	"OtherConsumed"
	20	"ConsumableStore"
	21	"TotalNonBasic"
	22	"Total"
	23	"UnmetElec"
	;
	lab values H_I1 slnoH;
	drop if H_I1>23 ;
} ;

compress;
sort FACT_ID;
saveold "$work/BLH`year'.dta", replace;


* BLOCK-I (INPUT ITEMS - Directly imported items only (consumed));

clear;
infix
	str YEAR	1	-	4
	str FACT_ID	5	-	12
	str BLK		13	-	13
	str I_I1	14	-	15
	str I_I3	16	-	20
	str I_I4	21	-	23
	str I_I5	24	-	39
	str I_I6	40	-	51
	str I_I7	52	-	66
	str MULT	67	-	75
using "$data/ASI/raw data//`year'/OASIBLi`yr'.txt";

destring *, replace;

la var 	YEAR	"Year";
la var 	FACT_ID	"Factory Code";
la var 	BLK		"Block code";
la var 	I_I1	"Sl. No.";
la var 	I_I3	"Item code (ASICC)";
la var 	I_I4	"Unit of quantity (code)";
la var 	I_I5	"Quantity consumed";
la var 	I_I6	"Purchase value at delivery (in Rs.)";
la var 	I_I7	"Rate per unit (in Rs.0.00)";
la var 	MULT	"Inflation/Multiplier factor";

compress;
sort FACT_ID;
saveold "$work/BLI`year'.dta", replace;


* BLOCK-J (PRODUCTS AND BY-PRODUCTS (Manufactured by the unit));
clear;
infix
	str YEAR	1	-	4
	str FACT_ID	5	-	12
	str BLK		13	-	13
	str J_I1	14	-	15
	str J_I3	16	-	20
	str J_I4	21	-	23
	str J_I5	24	-	39
	str J_I6	40	-	55
	str J_I7	56	-	67
	str J_I8	68	-	79
	str J_I9	80	-	91
	str J_I10	92	-	103
	str J_I11	104	-	115
	str J_I12	116	-	130
	str J_I13	131	-	142
	str MULT	143	-	151
using "$data/ASI/raw data//`year'/OASIBLj`yr'.txt";

destring *, replace;

la var 	YEAR	"Year";
la var 	FACT_ID	"Factory Code";
la var 	BLK		"Block code";
la var 	J_I1	"Sl.No.";
la var 	J_I3	"Item code (ASICC)";
la var 	J_I4	"Unit of quantity (code)";
la var 	J_I5	"Quantity manufactured";
la var 	J_I6	"Quantity sold";
la var 	J_I7	"Gross sale value (Rs.)";
la var 	J_I8	"Excise duty";
la var 	J_I9	"Sales Tax";
la var 	J_I10	"Others";
la var 	J_I11	"Total";
la var 	J_I12	"Per unit net sale value  (Rs.) [7-11]/6";
la var 	J_I13	"Ex-factory value of output (Rs.) (12 x 5)";
la var 	MULT	"Inflation/Multiplier factor";

compress;
sort FACT_ID;
saveold "$work/BLJ`year'.dta", replace;


/* Notes on use of ASI read-in programs downloaded from IHSN:
For years 1998-99 and 99-00 "Total employees" figures from Block E are recorded as 
"Unpaid family members/proprietor/Coop. members". This is because the category 
"Unpaid family members/proprietor/Coop. members"  did not exist in the 98-99 
and 99-00 surveys. This was likely an unintentional oversight in the original 
code downloaded from IHSN and is corrected in cleaning processes in later programs.
*/;
