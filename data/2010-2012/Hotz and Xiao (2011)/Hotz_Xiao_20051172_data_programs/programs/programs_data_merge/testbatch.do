qui clear all
qui capture log close
qui log using /rdcprojects/la00296/programs/testbatch.log, replace
di "This is to test how to use batch mode in CCRDC Lab"
di "Hol! Now it is working!"
di " Hi Mo !!!!!"
qui log close