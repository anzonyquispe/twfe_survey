libname mar '/data/cpsmar';
libname save '.';

data save.mar_probit ;
 set mar.mar_data;
 keep year state female sex married marstat ernsrc incwag age hrlywg hrslyr wkslyr wgt;
 where 1995 le year le 2008;
run;