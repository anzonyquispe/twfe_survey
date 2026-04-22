LIBNAME NEW 'C:\research\minwage';
LIBNAME TRANS XPORT 'C:\research\minwage\scf2007x'; 
PROC COPY IN=TRANS OUT=NEW;
RUN; 
ENDSAS;
