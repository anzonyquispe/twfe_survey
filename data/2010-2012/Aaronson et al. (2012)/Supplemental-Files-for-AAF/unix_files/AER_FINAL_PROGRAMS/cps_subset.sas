options nofmterr;
libname cpsogr '/data/cpsout';
libname here '.';

data here.ogr_select;
     set cpsogr.ogr_data;
     keep year age female hhid hhid2 hhnum lineno serial mis month nonwhite relhd stname wgt hhwgt 
	_ernwk edgrp ernhr ernush ernwgt faminc hours1 hoursu1 selfemp mlr chld chldnm relhd ;
run;

*nonwhite
