clear
use table6
bootstrap, rep(200): reg mig pminc jpminc if total>=30 & cvsq<100 & icrisat==1,  cluster(castecode)
bootstrap, rep(200): reg mig pminc jpminc cvsq if total>=30 & cvsq<100 & icrisat==1,  cluster(castecode)
bootstrap, rep(200): areg mig pminc jpminc cvsq vjpminc  if total>=30 & cvsq<100 & icrisat==1, a(village) cluster(castecode)


cgmreg mig pminc jpminc cvsq vpminc if total>=30 & cvsq<100 & icrisat==1,  cluster(village castecode)
cgmreg mig pminc jpminc cvsq vpminc second bank hlthctr bus towndist if total>=30 & cvsq<100 & icrisat==1,  cluster( village castecode)
testparm second bank hlthctr bus towndist
cgmreg mig pminc jpminc cvsq vjpminc second bank hlthctr bus towndist if total>=30 & cvsq<100 & icrisat==1,  cluster( village castecode)
testparm second bank hlthctr bus towndist




