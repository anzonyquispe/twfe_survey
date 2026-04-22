//--Grid-OKnes should be removed.  it is useless. Require S==0 on grid.
//--Should remove negativeInfiniteUtils and hard code it back to -INF as discussed
//--Can take care of permeation of negative infinite easily.  Same as forcing
// income to be positive, which we require anyway so we don't have to check the
//Agrid.  If minimumincome is positive [rerquires checks on R and on Amin ...
//Amin is a  problem because you might want -300 on there just to scare people
// (so consider using Astates[numastates/2]*2 ie double the median) ].
//  if minimum income is positive, call it ymin, then if you put ...
// err this doesn't quite work bc of Cons.  might not afford Cfloor and might not want to change
//the c, i floor.  ie bad scenario is the frequent one, of Cfloor=1 and ifloor==0.
//so you can set idecs[2] = ymin/2 but you can't set cdecs[2] = ymin/2.
//so can't afford that.  so can only afford floor, which has i==0.

//Solution : Change definition of "floor" from a grid pair to a dollar-value given
//by govt.  
//Not sure what test to use.  I would presume the govt doesnt use tomorrows borrowing power
// in its metric?  but it might? 
//So "A_t - afloor_t  + Y_t < eFloor ==> govt brings you up to efloor."
//is what i'd presume. .  Note, as minimum asset value you can also use -(1-downpyamentR)*maxSvalue
// And end program if that value isn't >0 (don't have code to deal with negative income now.).

/*
minwageDP.h.  
This is a program to use dynamic programming to solve the decision rules
for a model, where utility is an aggregate of non-durable consumption
and durable consumption (called "investment").
Some Definitions:
[Note: Grid-OK ness is useless now.  There is no need to test it, it just
gives -infinite utils.  In the particular case of stock, the government
keeps you at the minimum stock level, anyway].
--"Grid-OK" Decision, given a state : means you will land on
the state grids next period.  [Technically we don't check Grid-OKness for
assets, because you would have to have negative income for that to be a problem
ie large interest rate, tiny income].
--"Feasible" decision / State : Means that (either next period's state, given todays state
and todays decision, or just the current state) follows the model's constraints (ie A>=(downpaymentR-1)*S).
--"Allowable" decision / state : Means either the dec/state is a) feasible, or b) it is the floor [seebelow];
in either case, it must not be c==0 and the corresponding state must not have s==0; and it must be Grid-OK.  
That is, the government/rules-of-the-program allow you to eat the floor, even
if you are infeasible and will remain so after you eat the floor. this never actually happens.  It just
means I can be confident that, ignoring grid problems, everyone has at least one OK decision, all the time.
--"Bad" states: Any state that has no allowable decision OR Any state such that ALL
allowable decisions __MIGHT__ lead to a Bad state tomorrow [recursive def'n ...] [ OR
any state that is infeasible].
--"Good" states: Every state that's not bad [has at least one allowable decision].
[Note that this makes all feasible states at end of time "Good" so the recursive def'n is ok :]
OK. There are two ways these things affect the program: a) today, and b) tomorrow. 
a) Given todays state, a given fixed decision is either allowable or not.  If it's not
allowable, well, the DP doesn't allow it, meaning, it doesn't consider it in any way,
and there will be no value associated with it.
b) Given todays state, a given fixed _allowable_ decision can lead to a state tomorrow
that is Bad.  Or, even worse: given todays state, _all_ _allowable_ decisions __might__ lead
to a state tomorrow that is Bad.  That qualifies today as Bad given the above def'n. 
What should i do here?

OK. The state variables are:
Time [T], Assets [A] , (durable) stock [S], Permanent Income [PI] (see "stochastic elements" for this last one);
Note that the value and decision arrays are _not_ indexed by assets, per se.  Rather, a "cash on hand"
value is what actually indexes them.  COH = At+ Yt*TSt
These grids are stored in an object of type
"universe."  Astates, Sstates, PIstates are each arrays that define the possibilities. Tstates 
 should be composed of successive integers; it's current purpose is just to make the time states
clear between GAUSS and C, which have different indexing schemes, so indices and values are very, very 
easily confused.  I am considering code to allow it to be a 
grid of any real numbers, like the others (Astates,etc).  eg, now, in each loop, durables-stock
only depreciates by delta, as opposed to by delta^(todaysperiod - previousperiod). (1/22/08).
(I think it won't be worth the effort to add the stuff for new Tstates, it would have been useful
for debugging so that i could run a 140/4=35  year model without having 140 time states, but now
we mostly want results, so want a quarterly model, so the feature would be useless).  Use "periods"
instead of "numTstates" to indicate the difference between the time grid and the others (sequentialness and
discreteness).
The stochastic elements are:
Permanent Income [Abbreviated: PI] is a state variable; we use Tauchens Markov Chain discretization of an AR(1)
to model it.
Transtitory Shocks [Abbreviated: TS] occur; modelled by ??.
Note on units: PIstates stores _log_ units (think: log dollars) (it is used by getIncome, which exponentiates), whereas
TSvals stores raw units (think: dollars).
The decision choices are:
(Non-Durables) Consumption [C] and (Durables) Investment [I].

Additional elements: 
--"consumption floor" or "expenditure floor" is the pair (Cdecs[0], Idecs[0]),
also referred to as (Cfloor,Ifloor), implicitly defined by the  
Cdecs and Idecs vectors.  Cdecs & Idecs, must be increasingly sorted.
The government pays  for the expenditure floor ifandonlyif the sim can't afford to pay itself.  
The rules allow the floor to be chosen, even when it doesnt give you a feasible state
next period, as long as it places you on the grids [ie the stock grid, since we don't 
technically test the Agrid, since you could only go off by having too high an interest rate
and too low an income, since govt pays for the c and i at the floor].
This might cause errors! because of discretization.  If you are close to being unable to 
pay for the floor you might eat it only because you think it's free, even though you 
can actually eat a little more.  Also, if Idecs[0]<=0 you don't pay Fixed Durable Cost;
in fact, if you have Idecs[0]<0, functionality is not guaranteed if fixedDurableCost>0.
--There is a fixed cost for buying durables (e.g. if investment>0 you pay it).
Make sure to have zero as part of the Igrid, or else you always have to pay the
fixed cost. (So, again: the Igrid does not necessarily have to have zero on it,
ie the Ifloor might be >0. However, the fixed durable cost is hard coded such that
you pay it ifandonlyif I>0 ( _not_ if I>Ifloor)).
--The code uses a Guessing technique since choices shouldnt vary much;
so it keeps track of what was optimal previously and only looks close to that.
[Note: In the simulations, sims should start with positive stock. That way
your stock never provides you with -INF utils for all time, since depreciation
never reaches zero. Otherwise you start with -INF utils, anyway, of course.]
--A value for "Negative Infinite" is needed throughout the program.  If stock or consumption
are zero, current-period utility should be -Infinite.  Also, as part of the definition of
the universe, Eric decided that going off the bottom of the grid should yield -infinite utils.
There are a few possibilities for -infinite: -1/0, called "-INF" which the floating point
operators can deal with correctly in terms of both relations and operations (-INF < x if 
x is a double and x !=-INF, -INF==-INF, -INF+x=-INF if x!=INF, etc).  However, this doesn't
allow for interpolation, so a return value of -INF would basically break the program,
and it will also give -INF utils for all values between Sstates(0) and Sstates(1) if
Sstates(0) is 0, and similarly for Cdecs.  Using values such as -numeric_limits<double>::max()
or 10*getPeriodUtility(cfloor,Sfloor,...) don't have the interpolation problems.  So
we are currently using those.  Note this may make debugging harder, since the program will 
give more reasonable results than if we use -INF.  
usage of -infinite is defined by the universe structure.  "negativeInfinite" is a member,
and it should be set to the appropriate value.  This is generally done in getDecisionRulesGAUSS,
i.e. always it is done right before defining the universe.  Since -INF is basically
what is needed the simWorld element should be removed.

Requirements:
THE FOLLOWING ARE DEPRECATED.
???: make sure that Y is never negative (requires checking getIncome (pigrowthR), Astates, and R).
--Tentatively: Sstates[0] == 0. consider it a strong recommendation, for now, although the "grid0K" code is still 
in place.  Currently, the code is set to quit if ___ANY___ state has no decision that is gridOK, 
so if Sstates[0] >0, you are guaranteed to have states that quit.  This is easy to change, if you want
to.  Just change the if (!anySnextOnGrid) to not exit but to give -inf utils and move on.
--

--Adding code for lettting Investment be <0.  The rule is if I!= 0 (so I<0 or I>0) you pay a fixed durable
 cost (if the parameter is set to be nonzero) in the model. 

Updates: Give -numeric_limits<double>::max utils if you go off grid.

Debugging Notes:
When debugging, make sure to comment out #NDEBUG in all the files in which it appears (ie, turn asserts on).
To speed up the code, you can uncomment it, after you are done debugging.

Also, an odd but very important note: My results for the VM array are occasionally different on/after
the 5th decimal point between a DLL compiled in Debug mode and a DLL compiled in Release mode.
So, if the debug mode VM is bad but very close to matching old results, and the CM and IM match 
old results, keep this in mind.

*/

////Additional comments, originally from minwageDP.cpp:
/*some nomenclature rules:
    --variables beginning with "C" or "I" refer to consumption or investment, respectively 
    --variables beginning with "S" or "A" or "PI" refer to durable stock or assets or permanent income status, respectively.
    --Note pi=3.14 is declare'd already.
    --variables ending with "M" simply mean matrix [note that many variables of type "Array" have this ending since I didn't differentiate
		conceptually between arrays and matrices]
	--variables ending with "V" should be (conceptually) vectors (or nx1 matrices).
    --variables ending with "R" refer to rate
	--State Variables ending with idx are indices, those ending with val are values (not indices).
    --Underscore indicates that what follows the underscore can be thought of as a subscript
*/

/*Due to floating point considerations, be careful in assuming that something is 
always bounded as it should be conceptually. I usually add on an arbitrary constant (0.000001, or something to that effect)
to be sure.*/

/* Global variables such as maxAssets are relatively unreliable. It is uniformly better to just use
Astates[rows(Astates)] instead of maxAssets.  For instance: 
if an increment is a decimal and maxAssets is
divided by the increment in calculating Astates, then depending on the way the division goes and on
the approximation of the decimal, Astates[rows(Astates)] (the effective maximum asset level) may be
slightly different than maxAssets, and comparisons to determine boundaries may fail.
*/

/*
careful allowing sstates[0]>0.  then the grid makes you think you're doing better than you are.
should add -inf utility for going off grid.
*/

//some new comments that should be added / fixed with above:
//-Timing: [Sim loops start here] start with assets; get Y*TS+interest*assets = COH, which indexes
//VM [DP/C-code starts here]; agent then makes decision; 
//whatever is leftover is tomorrows assets [which
// must thus satisfy the liquidity constraint]
//- Also, govt pays for you to stay at Afloor if you can't afford it.  
//  So if you can't afford expFloor (including if you start in an infeasible state)
//    you get floor for free and get Afloor assets for next period (at the start
// of which you get hit with TS). If St drops below Sstates(0) govt tops you off
//  to keep you at that minimum level.  If idecs(0)>0 (which would be odd..) then
//  idecs(0) is still the I floor govt pays for, as well as keeping you at sstates(0).
//  If sstates(0)=0 i should add a check to gauss to make sure sstates(1) is appropriately
// small, based on income and (downpaymentR-1)*maxSval.  The difference would be
//that in the latter case you pay, in the former the govt pays.  Shouldn't matter much
// either way for this model.

// (Note, A>=afloor always, but you might have A+TS <Afloor.)
// if buying the expFloor puts you below afloor, you get 
// a govt-transfer to make the difference.  If buying the expFloor means
// you have Snext<sstates(0), you get a transfer to make up the difference.
// [in practice, if any I decision puts you at Snext < Sstaets(0) you get
// a transfer; but this just means your best bet in that case is to have 
// I be low].  If you are in the sim, and you 
//  make a feasibility error bc of discretization, you lessen C and then I 
//  until you are feasible. if that takes you to expfloor and assets
// are sttill less than Afloor, ie you can't afford the expfloor, 
// then govt pays for you to get to the Afloor and you
// eat the expfloor.  Then repeat.


#ifndef MINWAGEDP_H
#define MINWAGEDP_H


#include <cmath>
using std::pow;
#include <limits>
using std::numeric_limits;
#include <fstream>
using std::ofstream;


//probably this can be moved once getBestDec is moved to the .cpp file
#include <vector>
using std::vector;


#include "matrix.h"
#include "universe.h"

#define user 2 /* doss==0; french==1; doctor==2 */

// Keep char* instead of string, since Ken's functions work on char*
#if user == 0
	char *filename2 = "C:\\Temp\\tmp.fmt";
//	char *filename2 ="\"C:\\Documents and Settings\\g1crd01\\My Documents\\minwage\\C_results\\tmp.fmt\""; // \" places a " in the string, to make spaces ok.
	char *filename  = "\"c:\\Documents and Settings\\g1crd01\\My Documents\\minwage\\minwageDPsims.out\""; // \" places a " in the string, to make spaces ok.
	char *outpath = "C:\\Documents and Settings\\g1crd01\\My Documents\\minwage\\results\\"; // no extra quotes .. b/C it concatenates names at the end anyway?
	char *transMfilename = "C:\\Documents and Settings\\g1crd01\\My Documents\\minwage\\C\\minwageDP\\minwageDP\\transitionM.data";
#elif user==1
	char *filename = "\"c:\\research\\gauss\\wlthep\\sims.out\"";
#elif user==2
    char *filename2 = "C:\\Temp\\tmp.fmt";
	char *filename  = "\"c:\\Documents and Settings\\g1psd00\\My Documents\\minwage\\minwageDPsims.out\""; // \" places a " in the string, to make spaces ok.
	char *outpath = "C:\\Documents and Settings\\g1psd00\\My Documents\\minwage\\results\\"; // no extra quotes .. b/C it concatenates names at the end anyway?
	char *transMfilename = "C:\\Documents and Settings\\g1psd00\\My Documents\\minwage\\C\\minwageDP\\minwageDP\\transitionM.data";
#endif

ofstream errorOut;



/********************** (inline) function declarations & definitions *********************/

//Can't move defn of an inline func from the .h file.
//standard Afloor function for the borrowing limits model
//stock, t, periods are all state values (not indices)
//getAfloor(t, ...) gets floor for time t (often will call getAfloor(...,t+1, ...) )
//fnVersion chooses which Afloor function you want.  Usually a global will be passed.
inline double getAfloor(double stock, double downpaymentR, int time, int periods, int fnVersion){

	if (fnVersion == 0){			//Standard function version

		return (downpaymentR-1)*stock;

	}
	else if (fnVersion == 1){		//function version for no liquidity constraints except positive assets at death

		if (time < (periods) )			return -numeric_limits<double>::max();
		else								return 0;

	}
}

inline double getAfloor(double Sval, int Tval, const universe &univ){

	if (univ.AfloorFnVersion == 0){			//Standard function version

		return (univ.downpaymentR-1)*Sval;

	}
	else if (univ.AfloorFnVersion == 1){		//function version for no liquidity constraints except positive assets at death

		if (Tval < (univ.Tstates.length()) )	return -numeric_limits<double>::max(); //DO NOT USE NEG INFINITE UTILS here!! this is dollars.
		else								return 0;

	}
}

//Can't move defn of an inline func from the .h file.
//standard Afloor function for the borrowing limits model
//getAfloor(t, ...) gets floor for time t (often will call getAfloor(...,t+1, ...) )
//fnVersion chooses which Afloor function you want.
//uses the universe of the given state
//inline double getAfloor(const state &theState, const universe &univ){
//
//	if (univ.AfloorFnVersion == 0){			//Standard function version
//
//		return (univ.downpaymentR-1)*theState.S;
//
//	}
//	else if (univ.AfloorFnVersion == 1){		//function version for no liquidity constraints except positive assets at death
//
//		if (theState.T < (univ.Tstates.length()) )			return univ.negativeInfinite;
//		else								return 0;
//
//	}
//}



//Uses globals: theta=Cobb-Douglas; rho=CRRA;  
// Returns the utility FOR JUST THIS PERIOD (e.g., this does NOT need the discount parameter)
//inline ==> whole _definition_ is here 
//uses <cmath>::std::pow
//consumption, stock are not indices but actual values
inline double getPeriodUtility(double consumption, double stock, const universe &univ){
	assert( (0<univ.theta) && (univ.theta<1) && (univ.rho!=1) ); 

	//float operators handle c,s==0 intelligently, but don't want interpolation over 
	//-INF which is why "universe.negativeInfinite" was introduced.
	if ((stock==0) || (consumption==0)) return univ.negativeInfiniteUtils;
    else 
		return pow( pow(consumption, 1-univ.theta) * pow(stock, univ.theta) , (1-univ.rho) ) / (1-univ.rho);
}

//c and i guesses are independent of each other. this important for now. 
//at endoftime the value of prevBest (CbestIndex,IbestIndex) is irrelevant.
inline void getGuessingRange(const universe &simWorld, int timeIdx, 
							 int CbestIndex, int IbestIndex, 
							 int CadjustmentLow, int CadjustmentHigh, int IadjustmentLow, int IadjustmentHigh, int IzeroIdx,
							 int &lowCidx, int &highCidx, int &lowIidx, int &highIidx){ //return vals here.
	int periods = simWorld.Tstates.length(), 
		numCdecs = simWorld.Cdecs.length(), numIdecs = simWorld.Idecs.length();

	if (timeIdx==(periods-2)){
		lowCidx = 0;
		highCidx = numCdecs-1;
		lowIidx = 0;
		highIidx = IzeroIdx; //look over all I<=0.
	}
	else if (timeIdx==(periods-3)){  //end of time case;//At end of time, want to not search over I.  The I==0 case will be optimal, the other just needs to set a precedent for next round's guess.
		lowCidx = 0;
		highCidx = numCdecs-1;
		lowIidx = 0; //Iidx==0 is not necessarily I==0.
		highIidx = numIdecs-1; //look over all I<=0. ?  consider a person that is super low on S; they can get a govt transfer or buy; probably prefer buy; given that they buy, they want to buy a fair amount?
	}
	else{ // Guess using last periods solution __for positive I__ by adding +/- a % of total space
		lowCidx = CbestIndex - CadjustmentLow;
		highCidx = CbestIndex + CadjustmentHigh;
		if (lowCidx < 0) {lowCidx=0;}
		if (highCidx > (numCdecs-1)) {highCidx=numCdecs-1;}
		lowIidx = IbestIndex - IadjustmentLow;
		highIidx = IbestIndex + IadjustmentHigh;
		if (lowIidx < 0) {lowIidx =0;} // need 0 here if I<0
		if (highIidx > (numIdecs-1)) {highIidx = numIdecs-1;}
	}
}


 /*********************** function declarations *********************/

//Gets todays state and only investmentDec, not a "decision" because
// in the code that uses this, the cons dec isn't yet decided
//double getSnext(const state &todaysState, const decision &todaysDecision, const universe &simWorld);
//sval, ival are values not indices
double getSnext(const double Sval, const double Ival, const universe &simWorld);




//getBetter_V_Decs : get the best value and decisions (out of those that have been examined thus far).
//Specifically, todays state , and a "new" decision (cons, inv) , and and "old" decision,
// with the associated value (bestVal, bestCidx, bestIidx) are all passed, and the better of
//the two decisions is chosen.
//Compared inline'd v non-inline'd and they were effectively the same (like 6:14 to 6:13, inline by a sec).
// State AND decision should be fixed
// cons and inv should be _raw_ indices; they should index idex and cdecs correctly.
// VM should be in it's standard (4-dim) form.  
//Recall order of VM indices is assets, stock, PI, then time. [careful, assets dont index VM exactly, see comments at top]
//Last 5 values are the return values
// bestVal, bestCidx, bestIidx should be passed in as the current best
//  val/consIdx/invIdx, respectively, and they will be returned updated.  
// bestC and bestI must be passed in and determined by the function because it can
//be the case that there are _no_ best options (i.e. consider S_today = 0 and I fixed at 0).
// so if you try to grab the indices, they will be _undefined_.
// if necessary, so that they will still be the best indices (over the space
// checked so far).
// can't make VM const because then you can't use fixIatM
//PASS IN CONS+LOWCIDX, AND PASS IN INVESTMENT_RAW! ! !  ! 
//timeIdx, permIncome, sIdx are for todays state
//gotNewBest is true if the value from this decision is the current best.
//tomAindicesLow, etc, are Arrays now, instead of unsigned ints, because of the transit shocks,
//which require that vectors of indices of length numTSvals be passed instead of single indices.
void getBetter_V_Decs(const universe &simWorld, int cons, int inv,
		  Array &VM, 
		 int timeIdx, int permIncome, int sIdx, 
		 //const unsigned int &AindexLow, const unsigned int &AindexHigh, const double &Awght,
		 const Array &tomAindicesLow, const Array &tomAindicesHigh, const Array &tomAwghts,
		 const unsigned int &SindexLow, const unsigned int &SindexHigh, const double &Swght,
		 double &bestVal, int &bestCidx, int &bestIidx /* , bool &gotNewBest */ ); //values passed in and returned by ref


//n-dim array indexer
unsigned int getIndex(int numDims, unsigned int *dims, unsigned int* indices);

//getIncome should take the state variables as args and return a scalar
//Note: it needs to take the actual values, not just indices, since it must off the chart.
//getIncome uses global R and global PIgrowthR and PIstates vector and wageHike
/*right now, permIncome should be a nonnegative integer, an index for PIstates */
//Uses exp function 
double getIncome(int theTime, int permIncome, double PIgrowthR, const matrix &PIstates, 
				 const matrix &wageHike, int hikeStart, double incomeLevelAtHike, int PIgrowthChangeTime);




/*requires: This version of  requires baseArray INCR and newArray DECR */
/* matchArray: Nx1 baseArray, Mx1 newArray.  Returns: 
1) Mx1 vector, indicesHigh. 0<=indicesHigh[i]<=N-1. 
2) Mx1 vector, indicesLow. 0<=indicesLow[i]<=N-1.
3) Mx1 vector, weightsHigh. 0<=weights<=1.
--matchArray _NO LONGER_ takes care of space allocation. the references (indicesHigh,Low,and weights)
should be allocated before being passed in
--It will be true that baseArray[indicesLow[m]]<=newArray[m]<=baseArray[indicesHigh[m]]
for baseArray[0]<newArray[m]<baseArray[N-1].  Any values of newArray outside the range
of baseArray will have both indices values set to the max/min.
The third vector, weights, will have weights for linear interpolation such that
 (1- weightsHigh[m]) * baseArray[indicesLow[m]] + (weightsHigh[m]) * baseArray[indicesHigh[m]] == newArray[m]
as long as, again, newArray falls within the range of baseArray. Otherwise it will be "set" to the max/min 
of baseArray.
--Big-O order of matchArray=M+N.
--Requires both baseArray and newArray to be sorted (see above).
--indicesHigh[m] might equal indicesLow[m]. (so careful of dividing by indicesHigh-IndicesLow. Rather,
use weightsHigh).  If there are multiple indices in baseArray with the same value, behavior
is not well-defined.  The current rule (2/25) is that two indices are only equal if the value
is off the grid.  Subject to change.
--Coding	weightsHigh[i] == -1  then  newArray[i] < baseArray[0].
--Coding	weightsHigh[i] == -2  then  newArray[i] > baseArray[baseArray.length()].
*/
//
//void matchArray(const matrix &baseArray, const vector<double> &newArray, //should both be vectors
//				vector<unsigned int> &indicesLow, vector<unsigned int> &indicesHigh, vector<double> &weightsHigh); //results go in the last three elements
//
//void matchArray(const matrix &baseArray, const matrix &newArray, //should both be vectors
//				matrix &indicesLow, matrix &indicesHigh, matrix &weightsHigh); //results go in the last three elements

void matchArray(const matrix &baseArray, const Array &newArray, //should both be vectors
				Array &indicesLow, Array &indicesHigh, Array &weightsHigh); //results go in the last three elements

/*  Locates nearest points in an array
   (mostly) From Numerical Recipes in C, p. 117
Weight returned is for the higher index.
*/
//   needs to be modified for when matrix is templated (e.g. matrix<T> Xarray, T x,  and the rest)
//prefer to use the weight to code extra information (ie, if x is off the grid), not the indices.
// Coding	wghtHigh == -1  then  x < Xarray[0].
//			wghtHigh == -2  then  x > Xarray[Xarray.length()]
void binaryLocate( const matrix &Xarray, double x, int 
				  &j_L, int &j_U, double &wghtHigh); //Results returned in last three variables.

/* get transitionM, PIstates from GAUSS */
void getTransM(char* filename, matrix &PIstates, matrix &transitionM); 


/*getFDC: (get Fixed Durable Cost)
--note, i started off using "FDC" as an abbreviation for fixed durable cost.
Since it's not a flat rate any more, i donno if  "fixed" is still appropriate. 
Maybe it is, since the amount paid has nothing to do with how much you buy.
--the function Takes a state and the DC multiplier, and returns the FDC,
ie what must be paid on top of the cost of the durable goods, if a sim decides to have I>0.
*/
//probably should be in "model.h"
double getFDC(const double &Sval, const double &FDC_multiplier);


//The workhorse
//Comments:
//If Idecs includes values < 0, fixed Durable Cost is never paid, i believe.
int getDecisionRules(const universe &simWorld,	  
					 int CadjustmentLow, int CadjustmentHigh, int IadjustmentLow, int IadjustmentHigh,
					 Array &VM, Array &bestCM, Array &bestIM);


/* interface with GAUSS.  Essentially just calls getDecisionRules.
 nomenclature: *D means * is an int, but is of type double for GAUSS.
I think that pointers passed from GAUSS should be treated like const by ref.  (Reference says to allocate space 
 in GAUSS).  Changing the address pointed to doesn't seem to work.
 The returned values, VMptr, bestCMptr, bestIMptr (the best utility, and the decision rules' grids) 
 must be _allocated_ in GAUSS.
*/
extern "C" _declspec(dllexport) int getDecisionRulesGAUSS(double *TstatesPtr, double *periodsD, double *AstatesPtr, double *numAstatesD, double *SstatesPtr, double *numSstatesD,
						   double *PIstatesPtr, double *numPIstatesD, double *CdecsPtr, double *numCdecsD, double *IdecsPtr, 
						   double *numIdecsD,double *TSvalsPtr, double *numTSvalsD,
						   double *CadjustmentLowD, double *CadjustmentHighD, double *IadjustmentLowD, double *IadjustmentHighD, double *IzeroIdxGAUSSD,
						   double *downpaymentR, double *delta, double *R, double *PIgrowthR, double *PIgrowthChangeTimeD, double *wageHikePtr,
						   double *lengthWageHikeD, double *hikeStartD, double *incomeLevelAtHike, double *theta, double *rho, double *beta, 
						   double *FDC_multiplier, double *transitionMPtr, double *TSprobabilitiesPtr, double *AfloorFnVersionD,//r,c==numPIstates
						   double *VMPtr, double *bestCMPtr, double *bestIMPtr, double *initialPI);



//getBestDecision:Takes the range of possible decisions (passed as if they were indices...), as well 
//as the VM matrix up to this point and returns the highest value function on
//those possible decisions, as well as the associated consumption and investment decisions.
//Usage: 
// --pass in highIidx,lowIidx,highCidx,lowCidx all at zero and you will run the
// "atFloor" version; otherwise, pass in a range, and you get the "notAtFloor" version.
// By "range," i mean inclusive [ie idecs[highIidx] shouldn't error, etc].
//--State should be fixed.  If T is todays time, then VM[T+1] should be filled in with 
//tomorrow's value function.
//--The state passed in is the state in which the decision should be calculated (of course).
//Comments:
//--The suffix "Val" on a state variable indicates the variable is a value, not an index.
// Idx means it's an index.
//--We pass in income so as to not recompute it excessively.  Must pass in TOMORROW'S
// income.  Income does NOT include interest. or anything dependent on state variables (
//  which might change for tomorrow's value, based on today's decision).
//--VM, of type Array, can't be const if you want to be able to use fixIatM, etc. ...
//--The "No Decision Options" case [no decisions that are feasible&&onGrid] 
//  can return any indices and returns simWorld.negativeInfiniteUtils value.
//  [Of course, even if its a feasible option, the Floor can still return negInfUtils, if cfloor==0]
//This case can arise when you're at the floor, since it's possible the Ifloor doesn't get you on
//the S-grid (only if you are foolish and leave 0 off the S grid, though).
//--payFDC indicates whether all decisions passed in have to pay the Fixed Durable Cost.
// again, this is done since the calling function already knows the answer.
//--Allows I<0; at least in the snext/grid checking code.  probably whole code needs a going-over, for i<0, tho.
//--anySnextOnGrid will be returned true if there exists at least one allowable decision
// [allowable == feasible or allowed-by-govt (ie the floor)] that keeps your stock on the stock grid.
// Otherwise it's false.
//--BetterThanNegInfutils will be returned true if there exists at least one allowable 
// [allowable == feasible or allowed-by-govt (ie the floor)] decision that places Snext on the Sgrid.
//   Otherwise its false
//.... CAREFUL HERE
//   note that interpolation will give LESS than negative infutils because the values are all negative;
//so you get choice between different decisions, but the actual value is lower. so the variable is 
//NOT based on the actual value.
// NOTE: if betterThanNegInfUtils is returned false, then the values for bestCidx and bestIidx are undefined
// and should be considered invalid.  [this may be modified once betterThanNegInfUtils is modified, but
//presumably then if bestVal is -inf, the same statement wwill hold.]
//So, betterThanNegInfUtils is broken now.  ! i think it works if neginf==-INF or -max. o/w, dont think so.
//

inline void getBestDecision(const universe &simWorld, Array &VM, 
					 const int Tidx, const int Sidx, const int Aidx, const int PIidx,
					 const double incomeValTomorrow,
					 int lowCidx, int highCidx, int lowIidx, int highIidx, int IzeroIdx, //Index management
					 const bool payFDC, 
					 int &bestCidx, int &bestIidx, double &bestVal, //results here
					 bool &betterThanNegInfUtils){ //results here
	double Ival, Snext, expenditureCap,  Afloor,  Swght,
			Icost, FDC(0); //COH = cash-on-hand; FDC = fixedDurableCost*indicator-for-whether-FDC-isPaid;
	
	int SindexLow, SindexHigh, cons_raw,
		lowIidx2(lowIidx), highCidx2;
	int numTSvals=simWorld.TSvals.length();
	bool atFloor; //atFloor indicates the fn was passed exactly 1 decision, and it is the floor.
	int Tval;
	double COHval, Sval;
	matrix	expendituresDec, Anext;
	Array	Anext_TS, AindicesLow_TS, AindicesHigh_TS, Awghts_TS;

	//inits
	betterThanNegInfUtils = false;
	Tval = int(simWorld.Tstates(Tidx));
	COHval = simWorld.Astates(Aidx);
	Sval = simWorld.Sstates(Sidx);

	//initial case to check a) if there are any feasible possibilities,
	//b) check if govt is covering the tab (ie at the floor)
	//and c) check if fixedDurCost applies
 
	if (payFDC) {FDC = getFDC(Sval, simWorld.FDC_multiplier);} //else, FDC=0, from initialization.	

	//calculate atFloor in this function although it technically wastes time, since the calling function knows already; insignificant
	//if ((lowIidx==0)&&(highIidx==0)&&(lowCidx==0)&&(highCidx==0))	atFloor = true;
	if ((lowIidx==IzeroIdx)&&(highIidx==IzeroIdx)&&(lowCidx==0)&&(highCidx==0))	atFloor = true;
	else																		atFloor = false;	

	// This is far from optimal if you allow I<0 (should binary search).  Since this is very very rarely the case,
	//i haven't even clogged the code with anything extra to take care of that option; I<0
	//will just run a bit slower.  who knows, might not even be noticeable [easy to test].
	//for I>=0, dont even need to do this test if (1-delta)*S > Sstates(0); but, again, 99% of time this is as good
	Snext = getSnext(Sval, simWorld.Idecs(lowIidx2), simWorld); //lowIidx2==lowIidx here
	Afloor = getAfloor(Snext, Tval+1,simWorld); //Afloor gets floor for minimum I val
	expenditureCap = COHval - Afloor; //This is the cap associated with the MIN I value; Afloor set above.
	//this is Lowindices AND Floor testS for feasibility [not Grid-OKness!]
	if ((simWorld.Cdecs(lowCidx) + simWorld.Idecs(lowIidx) > expenditureCap) && !atFloor){ //Then NO Decision is feasible
		//gameover. no feasible decisions have been passed, and govt isnt helping
			bestVal = simWorld.negativeInfiniteUtils; //redundant.
			bestCidx = lowCidx;
			bestIidx = lowIidx;
			betterThanNegInfUtils = false;
			return;
	}
	expendituresDec	= matrix(highCidx-lowCidx+1,1); //this might be allocating too much space for now; don't count on expDec to have the right length

	//Main loop; lowIidx2 was adjusted and tested to guarantee this loops is entered if we get here.
	for (int investment_raw = lowIidx; investment_raw<=highIidx; investment_raw++){
		Ival = simWorld.Idecs(investment_raw);  //only grab Idecs once for whole loop.
		Snext = getSnext(Sval,Ival,simWorld);
		if (Snext < simWorld.Sstates(0)) {
			if (Ival < 0)	continue; //Not allowed to sell off too much stock.
			else			Snext = simWorld.Sstates(0); //Govt pays to keep you at minimum stock level; // for quickest code, should quit this loop if not at I==idecs(0), but meh
		} //do we really want govt to pay for minstock under any circumstances (ie you are a millionaire)
		Afloor = getAfloor(Snext,Tval+1,simWorld);
		//expenditureCap = R*Aval-Afloor+incomeValTomorrow;
		expenditureCap = COHval - Afloor; 
		Icost = Ival + FDC; //recall: the function is built with payFDC as a parameter!
		
		//Consumption-GUESSING happens here:
		//expendituresDec.resize(numCdecs_guessing); //First go to max size, so can count number feasible decs.
		for (highCidx2=0; highCidx2<=highCidx-lowCidx; highCidx2++){ // use <= not < , see range of highCidx above.
			expendituresDec(highCidx2) = simWorld.Cdecs(highCidx2+lowCidx) + Icost; //expendituresDec[0:High-Low] ~~~~ Cdecs[low:high]
			if (expendituresDec(highCidx2) > expenditureCap) break; //Attention::: all j>=highCidx2 are illegal; [lowCidx, highCidx2-1] are OK!
		}
		//note: highCidx2 is initially one larger than biggest index (either test failing ==> highCidx2 is too large)
		//expendituresDec.resize(highCidx2); //e.g.: highCidx2 is 1 if 0 is the highest feasible index
		highCidx2 += lowCidx;  //transform highCidx2 from being normalized to being raw.
		
		//dont have to check if there are _zero_ choices for this whole state since
		//we guaranteed existence of choices before entering; just check if there are no decisions for this I != Ifloor
		if (highCidx2 == lowCidx){ //high-low is the # of feasible decisions; if high==low, then we have Zero.
			if (atFloor){ //If floor is infeasible, govt pays for enough to get you to Afloor.  TShock may make you infeasible, later, but that's ok.
				Anext	= matrix(1,1,Afloor);
				highCidx2++; //this isn't used after this point...
			}
			else{ //if ( !atFloor){ //if there are _no_ possible decisions for  all Cdecs and for this fixed I> Idecs(0)  
				break; // then break out of investment loop since Idecs is increasing
			}
		} else{
			Anext				= matrix(highCidx2-lowCidx,1); //Govt does or doesnt pay; anext starts at expDec(0) or at 0, resp.
			for (int j=0; j<highCidx2-lowCidx; j++){ //separate loop because need anext to be the right lenght for passing it to matcharay
				Anext(j) = COHval - expendituresDec(j);  //>=afloor; 
			}
		}

		matrix dims = matrix(2,1); dims(0) = Anext.length(); dims(1) = numTSvals;
		Anext_TS.allocator(dims);
		AindicesLow_TS.allocator(dims); //prefer unsigned ints
		AindicesHigh_TS.allocator(dims);
		Awghts_TS.allocator(dims);
		
		//note we never test afloor constraint after adding interest + Y_(t+1)*TS, since that will be COH_(T+1)
		for (dims(0)=0; dims(0)<Anext.length(); dims(0)++){
			for (dims(1)=0; dims(1)<numTSvals; dims(1)++){
				//see comments at top for timing info.
				//This is poorly named now! should be COHnext_TS ! 
				Anext_TS(dims) = simWorld.R*Anext(dims(0)) + incomeValTomorrow*simWorld.TSvals(dims(1)); //possibly less than afloor

			}
		}

		//This is technically not the limiting part of the code: ln(numCdecs) for binaryLocate vs. numCdecs*numPI for getBest_V_Decs.
		//So it might be better to just scrap matchArray and simplify the code vastly.  it might not even be slower.
		//Given that numI,numC are much smaller than numA, this might be inefficient.  maybe IClnA < I(A+C)
		//However, i think that matchArray probably operatoes more like O(i*(2c)) than O(i*(a+c)) because the reason
		// that ln(A) is better is bc the A and C grids are fairly comparable but the guessing code effectively reduces
		// the C grid so that it is much smaller than the A grid, and simultaneously makes it so that it's not as spread out as the A grid
		// as the A grid so the matchArray will basically walk through the cgrid and finish.
		binaryLocate(simWorld.Sstates, Snext,	SindexLow, SindexHigh, Swght);		//this gives  O(a*s*t*pi* (i*(lnS)))
		//old, pre-vector code:
		//matchArray(simWorld.Astates, Anext,		AindicesLow, AindicesHigh, Awghts);	// this gives O(a*s*t*pi* (i*(a+c)))		
		//new vector code:
		for (int j=0; j<numTSvals; j++){
			AindicesLow_TS.fixIatM(1,j);
			AindicesHigh_TS.fixIatM(1,j);
			Awghts_TS.fixIatM(1,j);
			Anext_TS.fixIatM(1,j);
			matchArray(simWorld.Astates, Anext_TS,		AindicesLow_TS, AindicesHigh_TS, Awghts_TS);	// this gives O(a*s*t*pi* (i*(a+c)))
			//AindicesLow.freeAll(); //No need to free index inside loop; a fixed index can be "re-fixed" without being freed.
		}
		Anext_TS.freeAll();
		AindicesLow_TS.freeAll();
		AindicesHigh_TS.freeAll();
		Awghts_TS.freeAll();


//vector here
		for (int cons=0; cons<Anext.length(); cons++){//Now do rest of consumption loop, cutting off the tail
		//for (int cons=0; cons<Anext.size(); cons++){//Now do rest of consumption loop, cutting off the tail
			cons_raw = cons+lowCidx;
			AindicesLow_TS.fixIatM(0,cons);
			AindicesHigh_TS.fixIatM(0,cons);
			Awghts_TS.fixIatM(0,cons);
			getBetter_V_Decs(simWorld, cons_raw, investment_raw, VM, Tidx, PIidx, Sidx,
//vector here
//			AindicesLow[cons], AindicesHigh[cons], Awghts[cons], SindexLow, SindexHigh, Swght,
//				(unsigned int)AindicesLow(cons), (unsigned int)AindicesHigh(cons), Awghts(cons), SindexLow, SindexHigh, Swght,
				AindicesLow_TS, AindicesHigh_TS, Awghts_TS, SindexLow, SindexHigh, Swght,
				bestVal, bestCidx, bestIidx);
		} //end consumption loop
		AindicesLow_TS.freeAll();
		AindicesHigh_TS.freeAll();
		Awghts_TS.freeAll();
	}//end investment loop (I not fixed at 0)

	if (bestVal > simWorld.negativeInfiniteUtils) 
		{betterThanNegInfUtils = true;}
	else { // this is redundant but i like the code here so it's easy to see what's going on ... 
		bestCidx = lowCidx;
		bestIidx = lowIidx;
	}
}





#endif