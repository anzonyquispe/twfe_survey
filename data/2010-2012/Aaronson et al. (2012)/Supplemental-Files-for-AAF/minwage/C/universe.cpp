

#include "universe.h"

//#include <iostream>
#include <fstream>
using std::ofstream;
#include <cmath>
using std::log; //natural log [should switch to log base 2, ]


int universe::print(ofstream &out) const{
    int numCdecs= Cdecs.length(), numIdecs=Idecs.length(), numTSvals=TSvals.length(),
    numAstates=Astates.length(), numSstates=Sstates.length(), numPIstates=PIstates.length(), numTstates=Tstates.length();

    //Logging
//    out << "SettingsSwitch is " << settingsSwitch << endl;
//    out << "Hikeswitch is " << hikeswitch << endl;
    out << "Cdec (length: "  << numCdecs << "): " << Cdecs << endl;
    out << "Idec: (length: " << numIdecs << "): " << Idecs << endl;
    out << "Astates: (length: " << numAstates << "): " << Astates << endl;
    out << "Sstates: (length: " << numSstates << "): " << Sstates << endl;
    out << "PIstates: (length: " << numPIstates << "): " << PIstates << endl;
	out << "TSvals : (length: " << numTSvals << "): " << TSvals << endl;
	out << "TSprobabilities: " << TSprobabilities << endl;
	//out << "I work here" << endl;
    out << "transitionM (rows denote time t values, cols time t+1 values): " << transitionM << endl;
	//out << "but not here" << endl;
    out << "wageHike " << wageHike << endl;
    out << "Hikestart " << hikeStart << endl;
    out << "R, FDC_multiplier, delta, downpaymentR: " << R << "\t" << FDC_multiplier << "\t" << delta << "\t" << downpaymentR << endl;
    out << "PIgrowthR, incomeLevelAtHike , beta, rho, theta " << "\t" << PIgrowthR << "\t" << incomeLevelAtHike << "\t" << beta << "\t" << rho << "\t" << theta << endl;
	out << "Negative infinite Utils: " << negativeInfiniteUtils << endl;
    //"Cfloor, Cinc, Iinc, Aincr, Sincr, Cguess, Iguess: " Cfloor~Cinc~Iinc~Aincr~Sincr~Cguess~Iguess;
//    out << "C: low, high" << CadjustmentLow << CadjustmentHigh << endl; 
//    out << "I: low, high" << IadjustmentLow << IadjustmentHigh << endl;
    
    out << "dimensions: numTstates, numCdecs, numIdecs, numAstates, numSstates, numPIstates, lnnumsstates" << endl;//Iguess, cguess were here.
    out << numTstates << "\t" << numCdecs << "\t" << numIdecs << "\t" << numAstates << "\t" << numSstates << "\t" << numPIstates << "\t" << log(double(numSstates)) << endl; //Iguess, cguess were here.
	if (AfloorFnVersion == 0) {out << "AfloorFnVersion: Standard." << endl; } else {out << "AfloorFnVersion: no liquidity constraints" << endl;}
    
    //format /len 6,2; //e-notation for the order of ops
    //out << "Num operations: " << numTstates*numAstates*numSstates*numPIstates*(IadjustmentHigh+IadjustmentLow)*(CadjustmentHigh+CadjustmentLow)*log(numSstates);
    //out << "Memory required: " << numTstates*numAstates*numSstates*numPIstates*3; // 3 bc VM, CM, IM. // *8bytes per entry for GAUSS
    //format /ldn 10,5; //set back to old format

	return 1;
}

//
//double state::getSval() const{
//	return theUniverse.Sstates(Sidx);
//}
//double state::getAval() const{
//	return theUniverse.Astates(Aidx);
//}
//double state::getPIval() const{
//	return theUniverse.PIstates(PIidx);
//}
//double state::getTval() const{
//	return int(theUniverse.Tstates(Tidx)); //gotta typecast cus i never templated matrix
//}
//
//double decision::getCval() const{
//	return theUniverse.Cdecs(Cidx);
//}
//double decision::getIval() const{
//	return theUniverse.Idecs(Iidx);
//}
