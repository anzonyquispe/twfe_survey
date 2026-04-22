*program name: poboxer.do

replace trimadd=subinstr(trimadd,"p.o.box","pobox",1)
replace trimadd=subinstr(trimadd,"p.obox","pobox",1)
replace trimadd=subinstr(trimadd,"po.box","pobox",1)
replace trimadd=subinstr(trimadd,"r.d.box","rdbox",1)
replace trimadd=subinstr(trimadd,"r.dbox","rdbox",1)
replace trimadd=subinstr(trimadd,"rd.box","rdbox",1)



