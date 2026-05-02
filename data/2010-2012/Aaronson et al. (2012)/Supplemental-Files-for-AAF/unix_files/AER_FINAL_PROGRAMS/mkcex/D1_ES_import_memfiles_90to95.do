#delimit;

local syr: piece 2 2 of "${passthru_lyr}";

infix

	newid 1-8
	str cu_code 75-75
	str cu_code_ 76-76
	age 9-11
	str age_ 12-12
	str educa 83-84
	str educa_ 85-85
	incweekq 137-138
	str incw_ekq 139-139
	inc_hrsq 123-125
	str inc__rsq 126-126
	incnonwk 129-129
	salaryx 217-226
		
using ${syf_root}\\${passthru_lyr}\\Rawdata\cdrom\\membi`syr'${passthru_qtr}.txt, clear;

exit;