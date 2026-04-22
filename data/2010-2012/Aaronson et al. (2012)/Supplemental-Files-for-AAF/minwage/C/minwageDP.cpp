/*
minwageDP.cpp
Solves decision rules with dynamic programming for a utility function aggregating consumption and 
a durables-stock parameters.

For additional comments/explanations on the model of the program, 
see minwageDP.h, the header file.  The comments that are in this cpp file will be about 
the actual implementation.

Remember to comment/uncomment "NDEBUG" appropriately when you switch from debugging to compiling
a version for use.
*/


#include <time.h>
#include <iostream>
using std::cout;
using std::cerr;
using std::endl;
#include <fstream>
using std::ifstream;
using std::ofstream;
#include <cmath>
using std::sqrt;
using std::floor;	
using std::ceil;
using std::exp;
using std::log;

#include<vector>
using std::vector;

#include <limits>
using std::numeric_limits;

#include <algorithm>
using std::sort;

#include <ctime>
using std::time;

#include "minwageDP.h"
#include "matrix.h"
#include "GAUSS.h"
#include "c_gaussIO.h"
#include "model.h"



#define NDEBUG //turns asserts off.  should be commented when debugging
#include <cassert>


// driver-main.
int main(){

	matrix baseM;
	Array newA, highInds, lowInds, wghtsHigh;
	
	//initialize basematrix
	baseM = matrix(1,1,-3.5);
	baseM &= -2; baseM&=-.4; baseM&=0.2; baseM&=3; baseM&=14; baseM&=100;

	
	unsigned int *arrayDims = new unsigned int;
	*arrayDims = 15;
	newA.allocator(arrayDims,1);
	highInds.allocator(arrayDims,1);
	lowInds.allocator(arrayDims,1);
	wghtsHigh.allocator(arrayDims,1);
	//newA(0)=-30;
	//newA(1)=-25;
	//newA(2)=-20;
	//newA(3)=-18;
	//newA(4)=-10;
	//newA(5)=-4;
	//newA(6)=-3.5;
	//newA(7)=-3;
	//newA(8)=-0;
	//newA(9)=1;
	//newA(10)=10;
	//newA(11)=44;
	//newA(12)=100;
	//newA(13)=115;
	//newA(14)=125;

	newA(14)=-30;
	newA(13)=-25;
	newA(12)=-20;
	newA(11)=-18;
	newA(10)=-10;
	newA(9)=-4;
	newA(8)=-3.5;
	newA(7)=-3;
	newA(6)=-0;
	newA(5)=1;
	newA(4)=10;
	newA(3)=44;
	newA(2)=100;
	newA(1)=115;
	newA(0)=125;

	matchArray(baseM, newA, highInds, lowInds, wghtsHigh);

	cout << "baseM length: " << baseM.length() << endl;
	cout << "baseM is " << baseM << endl;
	cout << "newA.length): " << newA.vecLength() << endl;
	cout << "newA is " << newA << endl;
	cout << "High Inds: " << highInds << endl;
	cout << "low Inds: " << lowInds<< endl;
	cout << "wghtsHigh: " << wghtsHigh<< endl;
	

	return 0;

}



//int main(){
//
//
//	Array newA;
//	matrix dims=matrix(4,1);
//	dims(0)=3; dims(1)=10; dims(2)=101; dims(3)=93;
//	newA.initializer(dims, -.561);
//
//	for (dims(0)=0; dims(0)<3; dims(0)++){
//		for (dims(1)=0; dims(1)<10; dims(1)++){
//			for (dims(2)=0; dims(2)<101; dims(2)++){
//				for (dims(3)=0; dims(3)<93; dims(3)++){
//					newA(dims) = dims(0)*10*101*93 + 
//								 dims(1)*101*93 +
//								 dims(2)*93 + 
//								 dims(3);
//
//				}
//			}
//		}
//	}
//	newA.fixIatM(0,0);
//	newA.fixIatM(1,2);
//	newA.fixIatM(2,3);
//	unsigned int len = newA.vecLength();
//
//	cout << "len is " << len << endl;
//	cout << newA(0) << endl;
//
//	return 0;
//}


//
//int main(){
//
//	time_t seconds1, seconds2;
//	seconds1 = time(NULL);
//
//
//
//
//	/////////////begin what was previously global params ////////////////////////////////////
//
//	const double rho=2;                                          //CRRA. Dont set to 1 or will divide by zero
//	const double beta= .987;                                     //discount rate. == 4th root of .95
//	const double downpaymentR = .7;                              //downpayment rate
//	const double delta= 0.039815410595812191359353485978;        //depreciation rate of durables. ==1 - (4th root of .85)      
//	const double theta=.2;                                       //cobb-douglas exponent   (stock^ theta) (consumpt^(1-theta))
//	const double R = 1.0098534065489688518732777445707;           // 1+ rate of return.  == 4th root 1.04       
//	const double fixedDurableCost = 0.05;                           //multiplier on todays stock to determine fixed cost of buying a car/house (ie I>0)
//	const int AfloorFnVersion = 0;								 // 0 is the paper's model; 1 is analytical model (assets>=0 at death)
//
//	const double PIgrowthR = 0.01; /* Income Growth Rate (per quarter) ;1.024113689084445129404144960023 = 4throot of 1.10 */
//	const int PIgrowthChangeTime = 81;
//
//	/* Parameters for Markov Chain Discretization of Permanent Income (PI) AR(1) process */
//	unsigned int numPIstates; //unsigned const int numPIstates = 5; // This is all done by reading in from GAUSS now
//	const double upper_lev=0.01;		//area left in upper tail after upper bound
//	const double lower_lev=0.01;		//area left in lower tail after lower bound
//
//	const int periods=10;
//
//	const double minAssets = -35;
//	const double maxAssets=10;//const double maxAssets=10; //maxAssets = 25; 
//	const double minStock = 0; //force stock positive (CRRA utility funcn of stock!)
//	const double maxStock=40;//const double maxStock = 40;
//	const double highInvestment = 10; //highInvestment=26;
//	const double highConsumption=20;//highConsumption=25;
//	const double initasset=10; /* initial period assets in simulation */
//	const double initstock=10; /* initial period stock in simulation */
//
//	const double Cfloor = 1;
//	const double Cinc=.5;//Cinc=2;//Cinc=.3;
//	const double Iinc=.5;
//
//
//	const double Aincr = .5;
//	const double Sincr = .5;
//
//
//	// DP uses last periods optimal solution as a guess, and searches through +/- guess % of the arrays. set guess=1 to compare to non-guessing solution.
//	// Will look +- guess% * prevbestIndex.  For example, set guess=1 guarantees you look through whole space.
//	// Setting guess >= .5 then if prevbestIndex was right in the middle, you will still look through the whole space,
//	//but if it's at one end, you will only look through half the space.  guess<.5 you won't look thru whole space.
//	// If this is screwing results up too much, you may want to add more intial periods that search the whole space.
//	// currently the first and last two do this.  
//	const double Iguess = 1.0;  
//	const double Cguess = 1.0;
//
//	const double negInf = -numeric_limits<double>::max(); // -1/0; //-10*getPeriodUtility(Cdecs(0), Sstates(0), simWorld.theta, simWorld.rho);
//	/////////////end what was previously global params ////////////////////////////////////
//
//
//
//	// declarations
//	/* --A sim-person makes (periods-1) decisions in all, and has periods states. 
//	     End of final period is certain death e.g. last decision should be "eat it all" 
//	*/
//	//The comments can be found at the top of this file, but might be more thoroughly done for each variable in minwageDP.gau GAUSS code.
//	unsigned int  numCdecs, numIdecs, numAstates, numSstates, //dims of states&decisions
//		CadjustmentLow, CadjustmentHigh, IadjustmentLow, IadjustmentHigh, //parameters for choosing the "guess window"
//		hikeStart, hikeLength;
//	double wageIncr;
//	matrix transitionM, // PIstates will be numPIstates by 1, transitionM is numPIstates by numPIstates
//		TSprobabilities, //transitory shock probabilities
//		Cdecs, Idecs, //Discretization of consumption/investment for DP. (Sim chooses closest A/S-state grid point.)
//		TSvals, // transitory shocks
//		Astates, Sstates, PIstates, Tstates,//Discretization of asset/stock states for DP. Sim interpolates on grid 
//		wageHike;
//
//	hikeStart = 32;
//	hikeLength= 6;
//	wageIncr = 0.3;
//	wageHike = seqa(wageIncr, -wageIncr/hikeLength, hikeLength); //wageHike will start at hikeStart
//
//
//	// get transitionM, PIstates from GAUSS 
//	getTransM(transMfilename, PIstates, transitionM);
//	numPIstates = PIstates.length();
//	assert(numPIstates == transitionM.cols() && numPIstates == transitionM.rows());
//
//	numCdecs = int((highConsumption-Cfloor)/Cinc + 1);
//	numIdecs = int(highInvestment/Iinc + 1);
//	Cdecs = seqa(Cfloor,Cinc, numCdecs);// MAKE SURE Cfloor IS AN OPTION! or results will be a bit harder to interpret. Also Make sure Cdec stays sorted!
//	Idecs = seqa(0, Iinc, numIdecs);
//	TSvals = matrix(1,1,0); //dummy 
//	TSprobabilities = matrix(1,1,1);
//
//	
//	//NEED _ascending_ (not just monotonic) order for Astates, Sstates
//	numAstates = int((maxAssets-minAssets)/Aincr) + 1;
//	numSstates = int((maxStock-minStock)/Sincr) + 1;
//	Astates = seqa(minAssets, Aincr, numAstates);
//	Sstates = seqa(minStock, Sincr, numSstates);
//	Tstates = seqa(1, 1, periods);
//	assert(    (Cdecs.length() == numCdecs)  &&  (Idecs.length() == numIdecs) 
//		&& (Astates.length() == numAstates)  &&  (Sstates.length() == numSstates) );  //some error checknig
//
//
//	CadjustmentLow = int(floor(Cguess*numCdecs));
//	CadjustmentHigh = int(ceil(Cguess*numCdecs));
//	IadjustmentLow = int(floor(Iguess*numIdecs));
//	IadjustmentHigh = int(ceil(Iguess*numIdecs));
//	
//	universe theSimWorld(Astates, Sstates, PIstates, Tstates, Cdecs, Idecs, TSvals,
//				downpaymentR, delta, R, PIgrowthR, theta, rho, beta, fixedDurableCost, negInf,
//				PIgrowthChangeTime, hikeStart, AfloorFnVersion,
//				transitionM, TSprobabilities, wageHike);
//
//	Array VM, bestCM, bestIM; //results.  Array must be allocated outside of getDecRules call (for GAUSS to interface)
//	unsigned int *arrayOrderDP=new unsigned int[4], //array so length can be "hacked" off for CPrevIndices_Ipos, etc [FIX THIS! use matrix]
//	*arrayOrderResults = new unsigned int[4];
//	arrayOrderDP[0]=numAstates; arrayOrderDP[1]=numSstates; arrayOrderDP[2]=numPIstates; arrayOrderDP[3]=periods;
//	arrayOrderResults[0]=numAstates; arrayOrderResults[1]=numSstates; arrayOrderResults[2]=numPIstates; arrayOrderResults[3]=periods-1;
//	VM.allocator(arrayOrderDP,4); //Just allocate space here.  Let getDecRules do all the rest.
//	bestCM.allocator(arrayOrderResults,4);
//	bestIM.allocator(arrayOrderResults,4);
//
//	cout << "dimensions: periods, numAstates, numSstates, numPIstates: " << periods << "  " << numAstates << "  " << numSstates << "  " << numPIstates << endl;
//	cout << "Order == Approx # operations/loops: " << periods*numAstates*numSstates*numPIstates*Idecs.length()*Cdecs.length()*log( double(numSstates)) << endl;
//	cout << "Cdecs (len: " << Cdecs.length() << " ): " << Cdecs << endl << "Idecs (len: " << Idecs.length() << " ): " << Idecs << endl;
//	cout << "Astates (len: " << Astates.length() << " ): " <<  Astates << endl << "Sstates (len: " << Sstates.length() << " ): " << Sstates << endl << "PIstates (len: " << PIstates.length() << " ): " << PIstates << endl;
//	cout << "TSVals (len: " << TSvals.length() << " ): " << TSvals << endl;
//	cout << "Wage hike is "  << wageHike << endl;	
//	cout << "Cadjustment: low, high " << CadjustmentLow << " " << CadjustmentHigh << endl;; 
//	cout << "Iadjustment: low, high " << IadjustmentLow << " " << IadjustmentHigh << endl;
//
//	cout << "From GAUSS: numPIstates; PIstates; transitionM\n";
//	cout << numPIstates << endl << PIstates << transitionM;
//
//
//	//error checking.  //bad programming practice.  
//	//Should add check for Sstates and Astates, which need to be _increasing_
//	double *copy1, *copy2;
//	long unsigned int len1 = Cdecs.length(), len2=Idecs.length();
//	copy1 = Cdecs.getDataPtr(); 
//	sort(copy1, copy1 + len1); //sort takes one address beyond the end.
//	copy2 = Idecs.getDataPtr(); 
//	sort(copy2, copy2 + len2);
//	for (long unsigned int i=0; i< len1; i++){
//		if (copy1[i] != Cdecs(i)) {cerr << "You've got a world of pain coming." << endl; exit(1);}
//	}
//	for (long unsigned int i=0; i<len2; i++){
//		if (copy2[i] != Idecs(i)) {cerr << "You will meet a violent end." << endl; exit(1);}
//	}
//	delete [] copy1; delete [] copy2;
//	//end error checking
//
//
//
//
//	getDecisionRules(theSimWorld,
//					CadjustmentLow, CadjustmentHigh, IadjustmentLow, IadjustmentHigh,
//					  VM, bestCM, bestIM);
//
//
//	//getDecisionRulesGAUSS(&periods, Astates.data, &numAstates, Sstates.data, numSstates, PIstates.data, numPIstates,
//
//	seconds2 = time(NULL);
//	
//
//	
//	cout << "Time: " << (seconds2-seconds1) << endl;
//	
//	return 0;
//
//}








/************************** some functions ******************************/

//double getSnext(const state &todaysState, const decision &todaysDecision, const universe &simWorld){
//	return (1-simWorld.delta)*todaysState.S + todaysDecision.I;
//}

// S, I are values not indices
double getSnext(const double Sval, const double Ival, const universe &simWorld){
	return (1-simWorld.delta)*Sval + Ival;
}


//"tomAindexLow" is tomorrow's lower asset index, for interpolation.  Similarly for rest.
//cons,inv, timeIdx,permIncome,sIdx are all indices (should change names)
void getBetter_V_Decs(const universe &simWorld, int cons, int inv, 
		 Array &VM,  //can't be const if i wanna use fixIatM ...
		 int timeIdx, int permIncome, int sIdx, 
		 //const unsigned int &tomAindexLow, const unsigned int &tomAindexHigh, const double &tomAwght,
		 const Array &tomAindicesLow, const Array &tomAindicesHigh, const Array &tomAwghts, //"assetts" means "COH" now, of course! names should be changed.
		 const unsigned int &tomSindexLow, const unsigned int &tomSindexHigh, const double &tomSwght,
		 double &bestVal, int &bestCidx, int &bestIidx /* , bool &gotNewBest */) //values passed in and returned by ref
{
	assert(tomAindicesLow.isVector() && tomAindicesHigh.isVector() && tomAwghts.isVector());

	double val=0,  C=simWorld.Cdecs(cons), I=simWorld.Idecs(inv);
	VM.fixIatM(3,timeIdx+1); //compute tomorrow's val func first; timeIdx runs from periods- _2_ 
	for (int PIidx=0; PIidx<simWorld.PIstates.length(); PIidx++){
		VM.fixIatM(2,PIidx);
		//val_TS=0;
		for (int TSidx=0; TSidx<simWorld.TSvals.length(); TSidx++){
			//val_TS += VM.linearInterpolation2D(tomAindexLow[TSidx], tomAindexHigh[TSidx],
			//		tomSindexLow, tomSindexHigh, tomAwght[TSidx], tomSwght)   
			//		 * simWorld.TSprobabilities[TSidx];
			val += VM.linearInterpolation2D(tomAindicesLow(TSidx), tomAindicesHigh(TSidx),
				tomSindexLow, tomSindexHigh, tomAwghts(TSidx), tomSwght)   
				 * simWorld.transitionM(permIncome,PIidx) * simWorld.TSprobabilities(TSidx);
		}
		//val += val_TS * simWorld.transitionM(permIncome,PIidx);
	}							
	VM.freeAll();
	val = simWorld.beta*val + getPeriodUtility(C, simWorld.Sstates(sIdx), simWorld); //compute total value function for today
//	assert( C == (expendituresDec(cons)-I-simWorld.fixedDurableCost));

	//gotNewBest = false;
	if (bestVal < val) { //bestVal_Ipos is initialized to be -infinite (==min possible value for double) //use "<" (not "<=") for identical results with GAUSS (shouldnt be any real diff between the two) 
		bestVal	= val;
		bestCidx	= cons; //cons should index cdecs correctly.
		bestIidx	= inv;  //indexes Idecs
		//gotNewBest = true;
	}
}




//backup copy JIC while im makign TS (and veector?) changes
//void getBetter_V_Decs(const universe &simWorld, int cons, int inv, 
//		 Array &VM,  //can't be const if i wanna use fixIatM ...
//		 int timeIdx, int permIncome, int sIdx, 
//		 const unsigned int &tomAindexLow, const unsigned int &tomAindexHigh, const double &tomAwght,
//		 const unsigned int &tomSindexLow, const unsigned int &tomSindexHigh, const double &tomSwght,
//		 double &bestVal, int &bestCidx, int &bestIidx /* , bool &gotNewBest */) //values passed in and returned by ref
//{
//	double val=0, C=simWorld.Cdecs(cons), I=simWorld.Idecs(inv);
//	VM.fixIatM(3,timeIdx+1); //compute tomorrow's val func first; timeIdx runs from periods- _2_ 
//	for (int PIidx=0; PIidx<simWorld.PIstates.length(); PIidx++){
//		VM.fixIatM(2,PIidx);
//		val += VM.linearInterpolation2D(tomAindexLow, tomAindexHigh,
//				tomSindexLow, tomSindexHigh, tomAwght, tomSwght)   *   simWorld.transitionM(permIncome,PIidx);
//	}							
//	VM.freeAll();
//	val = simWorld.beta*val + getPeriodUtility(C, simWorld.Sstates(sIdx), simWorld); //compute total value function for today
////	assert( C == (expendituresDec(cons)-I-simWorld.fixedDurableCost  note fixedDurCost may be deprecated..));
//
//	//gotNewBest = false;
//	if (bestVal < val) { //bestVal_Ipos is initialized to be -infinite (==min possible value for double) //use "<" (not "<=") for identical results with GAUSS (shouldnt be any real diff between the two) 
//		bestVal	= val;
//		bestCidx	= cons; //cons should index cdecs correctly.
//		bestIidx	= inv;  //indexes Idecs
//		//gotNewBest = true;
//	}
//}


//dims[] and indices[] have numDims elements; dims[n] is the size of the nth dimension of 
//the (multi-dimensional) array, data.  Indices should have same order as [][]...[]!
// e.g. indices=1|2|3 for indices [1][2][3]
//getIndex looks up data[indices[0]][indices[1]]...[indices[numDims-1]].
//I Think this follows C's conventions, so getIndex should coincide with  [][]...[].

//unsigned int getIndex(int numDims, unsigned int *dims, unsigned int* indices){
//	register unsigned int subMatSizes=1, // "scale" of an index, to move past the subarrays
//		index=0;
//
//	for (int dim=numDims-1; dim>=0; dim--){//start with fastest moving index. careful with -- on unsigned int.
//		index += indices[dim] * subMatSizes;
//		subMatSizes *= dims[dim];
//	}
//	return index;
//}


//uses exp() function from cmath
//permIncome will be gauss.permincome-1 since its an idx
//theTIme should be the __STATE__ variable, not the index.
/*
    New intercept adjustment: ignoring randomness (pistates) and adjustment (wagehike), 
i.e. letting lnY = b + PIgrowthR*T          let b = fixedValue -PIgrowthR*timeBeforeStart
==> lnY(timeBeforeStart) = b + PIgrowthR*timeBeforeStart= fixedValue 
i.e. after timeBeforeStart periods, lnY is fixedvalue.  
*/
// at theTime==PIgrowthChangeTime, PIgrowth stops.  i.e. it is same as what it was previous period.
double getIncome(int theTime, int permIncome,
				 double PIgrowthR, const matrix &PIstates, const matrix &wageHike, int hikeStart, double incomeLevelAtHike, int PIgrowthChangeTime, double initialPI){
    double income, logIncome, adjustment;
	double timeBeforeStart, b, fixedValue; // for adjusting the intercept 
	int hikeIndex, hikeLength;

    /* Calculate "minimum wage hike" adjustment using global wageHike[]*/  

	timeBeforeStart = hikeStart; //1; //recall the theTime state var goes from 1 to periods (or periods-1)
	fixedValue = log(incomeLevelAtHike); //income at timeBeforeStart is exp(fixedValue ) 
	b = initialPI; //e.g y=mx+b
	hikeLength = wageHike.length();
    hikeIndex = theTime - hikeStart;
	
	if ((0<=hikeIndex) && (hikeIndex < hikeLength))		{adjustment = wageHike(hikeIndex);}  //theTime is _state_; must line up with GAUSS
	else												{adjustment = 0;}

	//interest = (R-1) * assets; // note assets can be negative

	if (theTime < PIgrowthChangeTime)		{logIncome = b + PIstates(permIncome) + PIgrowthR*theTime + adjustment;}
	else									{logIncome = b + PIstates(permIncome) + PIgrowthR*(PIgrowthChangeTime-1) + adjustment;}
	
    //income = interest + exp(logIncome);
	income = exp(logIncome);
    return income;    
}


//Old version of matcharray  (pre vector)
////matchArray takes care of allocation; references can be empty
//void matchArray(const matrix &baseArray, const matrix &newArray, //should both be vectors
//				matrix &indicesLow, matrix &indicesHigh, matrix &weightsHigh){ //results go in the last three elements
//DONT FORGET:  basearray must be INCREASINng and newArray DECREASING
void matchArray(const matrix &baseArray, const Array &newArray, //should both be vectors
				Array &indicesLow, Array &indicesHigh, Array &weightsHigh){ //results go in the last three elements
    //Base case: all elts less than baseArray[1] 
	assert(baseArray.isVector() && newArray.isVector());
	int N, M, i, j;
    //N=baseArray.length(); M=newArray.length();
	N=baseArray.length(); M=newArray.vecLength();

	//No longer allocate space in this function.
    //indicesHigh = matrix(M,1,0);
    //indicesLow =  matrix(M,1,0);
    //weightsHigh = matrix(M,1,0);

	/*WITH Iterators, code loosk something like : 
	if (increasing) { forwarditer; set firstVal = lowval (-1). etc.
	*/


    i=M-1;// i>=0
	while ((newArray(i) < baseArray(0))){
        indicesLow(i)=0;
        indicesHigh(i)=0;
        weightsHigh(i)=-1; //Code for "Off the grid; below"
        i--;
		if (i<0) {break;} //no short-circuit eval in GAUSS..
	}
	//while (newArray(i) <= baseArray(0)){
 //       indicesLow(i)=0;
 //       indicesHigh(i)=0;
 //       weightsHigh(i)=0;
 //       i--;
	//	if (i<0) {break;} //no short-circuit eval in GAUSS..
	//}

    
    /*walk through newArray comparing to base, using fact that both arrays are monotonically ordered (asc, desc here)*/
    /*newArray[i] >= baseArray[j-1] always */
    j=1;// j<=N; j==0 is done above.
	while (i>=0 && j<=(N-1)){
		while (newArray(i)>=baseArray(j)){ // ">=" moves through baseArray quickest (and makes code below nicer). ">" moves through newArray quickest ; 
            j=j+1;
			if (j>(N-1)){//no shortcircuit eval in GAUSS; allows us to use ">=" too.
				if (newArray(i)==baseArray(j-1)){ //this if-block lets use use the ">=" above
					indicesLow(i) = j-2; //could set this to j-1.
					indicesHigh(i)= j-1;
					weightsHigh(i)=1;
					i--;
				}
				break;
			}
		}
		if (j>(N-1)) {break;} //"want" to iterate once more; can't; so go to final-case loop.
        indicesLow(i) = j-1;
        indicesHigh(i) = j;
//        if (baseArray[j] == baseArray[j-1]); //This test is only useful if baseArray[0]==baseArray[1], b/c
		//i believe that using ">=" above makes this test useless
		//print "should never land here";
//            weightsHigh[i] = 0; 
//        else;
        weightsHigh(i) = (newArray(i) - baseArray(j-1)) / (baseArray(j) - baseArray(j-1));
//        endif;
		i=i-1;
	}

    // final cases
	while (i>=0){ //if you enter this then j>(N-1)
        indicesLow(i)=N-1;
        indicesHigh(i)=N-1;
        weightsHigh(i)=-2;
        i=i-1;
	}
	//while (i>=0){
 //       indicesLow(i)=N-1;
 //       indicesHigh(i)=N-1;
 //       weightsHigh(i)=1;
 //       i=i-1;
	//}
}




//   needs to be modified for when matrix is templated (e.g. matrix<T> Xarray, T x,  and the rest)
void binaryLocate( const matrix &Xarray, double x, 
				  int &j_L, int &j_U, double &wghtHigh){ //results go in the last three values
   int j_M, dif, DIM;
   bool ascending;
   DIM = Xarray.length();
   ascending = true; //1
   if ( Xarray(DIM-1)<Xarray(0) ) ascending=false;

   j_L = 0;
   j_U = DIM-1;
   dif = j_U-j_L;

   if (Xarray(j_U) < x)					{wghtHigh=-2; j_L=j_U-1; return;}
   else if (Xarray(j_L) > x)			{wghtHigh=-1; j_U=j_L+1; return;}

   if (ascending){
	   while (dif>1){
         j_M = floor((j_U+j_L)/2.0); //should be same as just (j_U+j_L)/2 C-integral division
		 if (x>Xarray(j_M))		{j_L = j_M;}
		 else		            {j_U = j_M;}
         dif = j_U-j_L;
	   }
      //j_Star = j_L;
   }
   else{
	   while (dif>1){
         j_M = floor((j_U+j_L)/2.0);
		 if (x<Xarray(j_M))		{j_L = j_M;}
		 else					{j_U = j_M;}
         dif = j_U-j_L;
	   }
      //j_Star = j_L;
   }
    
   //Can't guarantee Xarray[j_U] != Xarray[j_L] even if j_U>j_L always
   //if ( (Xarray(j_U) == Xarray(j_L)) || (Xarray(j_U) < x) )		{wghtHigh=1;} 
   //else if (Xarray(j_L) > x)									{wghtHigh = 0;}
   //else		       {wghtHigh = (x - Xarray(j_L)) / (Xarray(j_U) - Xarray(j_L));}
   if (Xarray(j_U) == Xarray(j_L))			{wghtHigh=1;} 
   else		       {wghtHigh = (x - Xarray(j_L)) / (Xarray(j_U) - Xarray(j_L));}
}



void getTransM(char* filename, matrix &PIstates, matrix &transitionM){
	ifstream fin;
	fin.open(filename);
	double numPIstatesDouble;
	int numPIstates;
	fin >> numPIstatesDouble;  //careful: GAUSS writes this to ascii funny
	numPIstates = int(numPIstatesDouble); 
	PIstates = matrix(numPIstates, 1, 0);
	transitionM = matrix(numPIstates, numPIstates, 0);

	for (unsigned int i=0; i<numPIstates; i++){
		fin >> PIstates(i,0);
		if (!fin.good()) {cerr << "Error inputting TransitionM\n"; exit(1);}
	} cout << endl;
	for (unsigned int i=0; i<numPIstates; i++){
		for (unsigned int j=0; j<numPIstates; j++){
			fin >> transitionM(i,j);
			if (!fin.good()) {cerr << "Error inputting TransitionM\n"; exit(1);}
		}
	}
	fin.close();
}



double getFDC(const double &Sval, const double &FDC_multiplier){
	return (FDC_multiplier*Sval);
}




//Astates, Sstates, Cdecs, Idecs, must all be increasing.
//getDecRules SHOULDNT change where VM,bestCM,bestIM point to !!!!!!
//backup is below
int getDecisionRules(const universe &simWorld,   
					 int CadjustmentLow, int CadjustmentHigh, int IadjustmentLow, int IadjustmentHigh, int IzeroIdx,
					 Array &VM, Array &bestCM, Array &bestIM){

	char timeStr [9];
    _strtime( timeStr );
	extern ofstream errorOut;
	errorOut.open("C:\\Temp\\minwageDP.log", ios::out|ios::app);
	errorOut << "getDecisionRules is beginning now\n";
	errorOut << timeStr;
	errorOut << "\n";
	errorOut.close();

						  //add tests for astates, sstates, cdecs, idecs to see that they are increasing

	///////////////////Declarations;

	// "Re-Declare" parameters
	int numAstates = simWorld.Astates.length(), numSstates = simWorld.Sstates.length(), 
		numPIstates = simWorld.PIstates.length(), periods = simWorld.Tstates.length(),
		numCdecs = simWorld.Cdecs.length(), numIdecs = simWorld.Idecs.length();
	int bestIidx_Ipos, bestCidx_Ipos,//store where last periods best was, conditional on I>0 (temp vars)
		bestCidx_Izero, //bestIidx_Izero, //initialize at 0 in case 
		fillerInt;

	int lowCidx_Inonzero, highCidx_Inonzero, lowIidx_Inonzero, highIidx_Inonzero, lowCidx_Izero, highCidx_Izero;


	// Declarations //in my VC++ long double is same as double.  Had a few issues with precision errors causing trivial differences bt GAUSS and C++
	bool betterThanNegInfUtils_Ipos,betterThanNegInfUtils_Izero,
		betterThanNegInfUtils_floor;
	int T;
	double	A, S, PInc, Y, 
			bestVal_Izero, bestVal_Ipos, bestVal_floor;

	matrix	expendituresDec, Anext, 
		AindicesLow, AindicesHigh, Awghts, //AindicesLow/high should be <int>
		vals_PI,//Tomorrows value _conditional_ on PI
		indexer; //used to index arrays
	Array	CprevIndices_Ipos, IprevIndices_Ipos, CprevIndices_Izero;
	
	unsigned int *arrayOrder=new unsigned int[3]; // Array for matrix allocations
	arrayOrder[0]=numAstates; arrayOrder[1]=numSstates; arrayOrder[2]=numPIstates;
	CprevIndices_Ipos.allocator(arrayOrder, 3);
	IprevIndices_Ipos.allocator(arrayOrder, 3);
	CprevIndices_Izero.allocator(arrayOrder, 3);

	// set the slice of VM corresponding to the final state (after the last decision) to constant/0 
	//so that the solver eats everything in the period before the end.
	matrix t2;
	VM.fixIatM(3,periods-1);
	t2 = matrix(3,1);
	for (t2(0)=0; t2(0)<numAstates; t2(0)++){
		for (t2(1)=0; t2(1)<numSstates; t2(1)++){
			for (t2(2)=0; t2(2)<numPIstates; t2(2)++){
				VM(t2) = 0;
			}
		}
	}
	VM.freeAll();
	//allocate for Consumption/investment with 1 less time dimension


	//////////End Declarations
	
	// Start Solving the Decision Rules.
	for (int timeIdx=periods-2; timeIdx>=0; timeIdx--){//timeIdx like assets, stock, permIncome, below; T is state variable, e.g. like A, S, PI below.
		T=simWorld.Tstates(timeIdx); //Tstates should be sequential integers (3,4,5, etc).
		//T = timeIdx+1;
        _strtime( timeStr );
	    errorOut.open("C:\\Temp\\minwageDP.log", ios::out|ios::app);
	    errorOut << "Time index ";
    	errorOut << timeIdx;
	    errorOut << "\n";
		errorOut << "At time ";
		errorOut << timeStr;
		errorOut << "\n";
	    errorOut.close();
		for (int assets=0; assets<numAstates; assets++){
			A = simWorld.Astates(assets);
			for (int stock=0; stock<numSstates; stock++){
				S = simWorld.Sstates(stock);
				for (int permIncome=0; permIncome<numPIstates; permIncome++){//State is now fixed
					PInc = simWorld.PIstates(permIncome);

//Probably DO want to do the following code at some point, although .00001 should probably be massively changed.
//Actually I think we want to use indices as in:  if one simworld.astates(assets+1) > (downpaymentr-1)*simworld.ssstates(stoc-1) continue
					//[maybe replace 1 by 2, to be super safe?.]
//here were first thoughts:
//Or rather, 10 should be something like simWorld.maxIncomePossible so that we basically test all states that aren't bad {where i use the below def'n of bad}
//Which leads to new question: do we want to test all states that aren't bad?  I guess they dont' have negative inf utils.
//And definition of "bad" state should be redone; [is a state bad if it is infeasible?  Or _just_ if: either tomorrow 
//is bad _OR_ tomorrow is infeasible!
					//We do compute fudge cases where A,S are infeasible because of interpolation approximation
					// dont do: {if (A <= ((downpaymentR-1)*S + .000001)) break;} //Sstates is increasing 
					// (downpaymentR-1)*S is deprecated: use getAfloor()

//want to test this for speed compared to without it.
//This says: if the "most feasible" state that is within x diagonal jumps from current state is still infeasible, then skip this state; (x is the +/-)
					//if ((assets<numAstates-10 ) && (stock>9)){ // can't i combine the two ifs? ( at some point i got errors that magically disappeared ... )
					//	if (simWorld.Astates(assets+10) < getAfloor(simWorld.Sstates(stock+10), T, simWorld)){
					//		indexer = matrix(4,1);
					//		indexer(0)=assets; indexer(1)=stock; indexer(2)=permIncome; indexer(3)=timeIdx;
					//		VM(indexer)		= simWorld.negativeInfiniteUtils;
					//		bestCM(indexer)	= -1;
					//		bestIM(indexer)	= -1;
					//		IprevIndices_Ipos(indexer) = 1; //need to store a dummy index for next period's guessing; 0,1 seem best.
					//		CprevIndices_Ipos(indexer) = 0;// "raw" value for indexing Idecs/Cdecs
					//		continue; //"continue", not "break", so as to hit this block and set VM,CM,IM values for other PIstates.
					//	}
					//}

					//some initializations to negative infinite so i can compare for greater
					//bestVal_Ipos		= -numeric_limits<double>::max();
					//bestVal_Izero		= -numeric_limits<double>::max();
					//bestVal_Ifloor	= -numeric_limits<double>::max();
					bestVal_Ipos	= simWorld.negativeInfiniteUtils;
					bestVal_Izero	= simWorld.negativeInfiniteUtils;
					bestVal_floor  = simWorld.negativeInfiniteUtils;

					
					indexer = matrix(3,1);
					indexer(0)=assets; indexer(1)=stock; indexer(2)=permIncome; //indexer(3)=timeIdx;


					//note on guessing: prevIndices are junk the first time; this is because for endoftime, getGuessingRange ignores their values.
					//also the code for guessing for _Izero relies on getGuessingRange to NOT change the guess for C based on what is passed in for Iprev!!
					getGuessingRange(simWorld, timeIdx, int(CprevIndices_Ipos(indexer)), int(IprevIndices_Ipos(indexer)),
						CadjustmentLow, CadjustmentHigh, IadjustmentLow, IadjustmentHigh, IzeroIdx,
						lowCidx_Inonzero, highCidx_Inonzero, lowIidx_Inonzero, highIidx_Inonzero);
					getGuessingRange(simWorld, timeIdx, int(CprevIndices_Izero(indexer)), IzeroIdx,
						CadjustmentLow, CadjustmentHigh, IadjustmentLow, IadjustmentHigh, IzeroIdx, 
						lowCidx_Izero, highCidx_Izero, fillerInt, fillerInt);

					//This is income for calculating COH _tomorrow_; this is consistent with A_t+1 = f(a_t, y_t, -c_t, -i_t)
					Y = getIncome(T+1, permIncome, simWorld.PIgrowthR, simWorld.PIstates, simWorld.wageHike, 
						simWorld.hikeStart, simWorld.incomeLevelAtHike, simWorld.PIgrowthChangeTime, simWorld.initialPI);
						    
					//case for the expenditure floor
					getBestDecision(simWorld, VM, timeIdx, stock, assets, permIncome, Y,
						0, 0, IzeroIdx, IzeroIdx, //indices for cdecs,idecs
						IzeroIdx,
						false, //decides whether to payFDC 
						fillerInt, fillerInt, bestVal_floor, //results here
						betterThanNegInfUtils_floor);//results here


					//case for I==Ifloor and C>=Cfloor (C will equal cfloor only if its included twice in cdecs ...)
					getBestDecision(simWorld, VM, timeIdx, stock, assets, permIncome, Y,
						lowCidx_Izero, highCidx_Izero, IzeroIdx, IzeroIdx, //indices for cdecs,idecs; could add guessing if we want.
						IzeroIdx,
						false, //decides whether to payFDC
						bestCidx_Izero, fillerInt, bestVal_Izero, //results here
						betterThanNegInfUtils_Izero);//results here
					

					betterThanNegInfUtils_Izero = betterThanNegInfUtils_Izero || betterThanNegInfUtils_floor;
					if (bestVal_Izero < bestVal_floor){ // note: "<="  ==>  in case of negInfUtils for both, this evaluates true
						bestVal_Izero	= bestVal_floor;
						bestCidx_Izero	= 0;
					}	//else keep Izero values.

					//start I>idecs(0) section
					getBestDecision(simWorld, VM, timeIdx, stock, assets, permIncome,Y,
						lowCidx_Inonzero, highCidx_Inonzero, lowIidx_Inonzero, highIidx_Inonzero, 
						IzeroIdx,
						true, //must pay FDC
						bestCidx_Ipos, bestIidx_Ipos, bestVal_Ipos, betterThanNegInfUtils_Ipos);

					indexer = matrix(4,1);
					indexer(0)=assets; indexer(1)=stock; indexer(2)=permIncome; indexer(3)=timeIdx;

					//Never have to test Ipos case for betterThanNegInfUtils
					// which is why we only fill bestC_Ipos if it is > _Izero, ie > -INF
					indexer = matrix(4,1);
					indexer(0)=assets; indexer(1)=stock; indexer(2)=permIncome; indexer(3)=timeIdx;
					if (bestVal_Ipos > bestVal_Izero){ // which guarantees: (betterThanNegInfUtils for ipos)
						VM(indexer)		= bestVal_Ipos;
						bestCM(indexer)	= simWorld.Cdecs(bestCidx_Ipos); //bestC_Ipos; // should be bestCM(indexer) = cons(bestCidx_Ipos); etc.
						bestIM(indexer)	= simWorld.Idecs(bestIidx_Ipos); //bestI_Ipos;
					}
					else if (betterThanNegInfUtils_Izero){//recall, we set betterThanNegInfUtils_Izero = better..._Izero || better..._Ifloor;
						//so can index using bestCidx_Izero, etc. bc they are defined 
						VM(indexer)		= bestVal_Izero;
						bestCM(indexer)	= simWorld.Cdecs(bestCidx_Izero);
						//bestIM(indexer)	= simWorld.Idecs(bestIidx_Izero);
						bestIM(indexer) = simWorld.Idecs(IzeroIdx);
					}
					else{//here we know both paths have negative infinite utils. we lose.
						//keep a counter here?
						VM(indexer) = bestVal_Izero;
						VM(indexer)		= simWorld.negativeInfiniteUtils; //this DOESNT MAKE SENSE if negativeInfiniteUtils is allowed to be > -INF.
						//VM(indexer) = -numeric_limits<double>::max(); //  use this once code is switched
						// search: negInf
						bestCM(indexer) = -1;
						bestIM(indexer) = -1;
					}

				
					//Regardless of whether we did I==0 or I>0, need to keep track of what best option _would_ have been for each case
					indexer = matrix(3,1);
					indexer(0)=assets; indexer(1)=stock; indexer(2)=permIncome;
					IprevIndices_Ipos(indexer) = bestIidx_Ipos; // "raw" value for indexing Idecs/Cdecs
					CprevIndices_Ipos(indexer) = bestCidx_Ipos;
					CprevIndices_Izero(indexer)= bestCidx_Izero;

				}// end PI loop
			}// end stock loop
		}// end assets loop
	}//end time loop	

	errorOut.open("C:\\Temp\\minwageDP.log", ios::out|ios::app);
	errorOut << "getDecisionRules is returning now\n";
	errorOut.close();
	return 0;
}









// nomenclature: *D means * should be an integer, but is of type double for GAUSS [where "*" means 
//"wildcard" and has nothing to do with either pointers or multiplication, here]. 
int getDecisionRulesGAUSS(double *TstatesPtr, double *periodsD, double *AstatesPtr, double *numAstatesD, double *SstatesPtr, double *numSstatesD,
						   double *PIstatesPtr, double *numPIstatesD, double *CdecsPtr, double *numCdecsD, double *IdecsPtr, 
						   double *numIdecsD, double *TSvalsPtr, double *numTSvalsD,
						   double *CadjustmentLowD, double *CadjustmentHighD, double *IadjustmentLowD, double *IadjustmentHighD, double *IzeroIdxGAUSSD,
						   double *downpaymentR, double *delta, double *R, double *PIgrowthR, double *PIgrowthChangeTimeD, double *wageHikePtr, 
						   double *lengthWageHikeD, double *hikeStartD, double *incomeLevelAtHike, double *theta, double *rho, double *beta, 
						   double *FDC_multiplier, double *transitionMPtr,  double *TSprobabilitiesPtr, double *AfloorFnVersionD,//r,c==numPIstates
						   double *VMPtr, double *bestCMPtr, double *bestIMPtr, double *initialPI){

	int periods=int(*periodsD), numAstates=int(*numAstatesD), numSstates=int(*numSstatesD), numPIstates=int(*numPIstatesD), 
		numCdecs=int(*numCdecsD), numIdecs=int(*numIdecsD), numTSvals=int(*numTSvalsD),
		CadjustmentLow=int(*CadjustmentLowD), CadjustmentHigh=int(*CadjustmentHighD), IadjustmentLow=int(*IadjustmentLowD), IadjustmentHigh=int(*IadjustmentHighD), IzeroIdx=int(*IzeroIdxGAUSSD-1),
		hikeLength=int(*lengthWageHikeD), hikeStart=int(*hikeStartD), PIgrowthChangeTime=int(*PIgrowthChangeTimeD),
		AfloorFnVersion=int(*AfloorFnVersionD), retval(0);
	matrix	Astates(numAstates, 1, AstatesPtr, numAstates),
			Sstates(numSstates, 1, SstatesPtr, numSstates),
			PIstates(numPIstates, 1, PIstatesPtr, numPIstates),
			Tstates(periods, 1, TstatesPtr, periods),
			Cdecs(numCdecs, 1, CdecsPtr, numCdecs),
			Idecs(numIdecs, 1, IdecsPtr, numIdecs),
			TSvals(numTSvals, 1, TSvalsPtr, numTSvals),
			wageHike(hikeLength, 1, wageHikePtr, hikeLength),
			transitionM(numPIstates,numPIstates,transitionMPtr, numPIstates*numPIstates),
			TSprobabilities(numTSvals, 1, TSprobabilitiesPtr, numTSvals);

	//This is the only "parameter" that is defined in C (since it can't possibly be set in gauss).
	double negInf;
	negInf = -numeric_limits<double>::max(); 
	//negInf = -1/0; 
	//negInf = 10*getPeriodUtility(Cdecs(0), Sstates(0), simWorld.theta, simWorld.rho);

	universe theSimWorld(Astates, Sstates, PIstates, Tstates, Cdecs, Idecs, TSvals,
				*downpaymentR, *delta, *R, *PIgrowthR, *incomeLevelAtHike, *theta, *rho, *beta, *FDC_multiplier, negInf,
				PIgrowthChangeTime, hikeStart, AfloorFnVersion,
				transitionM, TSprobabilities, wageHike, *initialPI);

	Array VM, bestCM, bestIM;
	matrix DPorder(4,1), resultsOrder(4,1);

	DPorder(0)=numAstates; DPorder(1)=numSstates; DPorder(2)=numPIstates; DPorder(3)=periods;
	resultsOrder=DPorder; resultsOrder(3)=periods-1;
	VM.initializer(VMPtr,DPorder); 	bestCM.initializer(bestCMPtr,resultsOrder);	bestIM.initializer(bestIMPtr, resultsOrder);
	//cout << "arrayinitializer: make sure dataPtrs are allocated ahead of time.\n";

	ofstream fileout;
	fileout.open("simworld.log");
	theSimWorld.print(fileout);
	fileout.close();


	retval =	getDecisionRules(theSimWorld,	
				CadjustmentLow, CadjustmentHigh, IadjustmentLow, IadjustmentHigh, IzeroIdx,
				VM, bestCM, bestIM);

	
	return retval;
}







