/*
universe.h
Header file for the DP universe class.  
Also header file for the DP state class ? .
Since currently there are >=2 classes, they have their 
own individual comments above each def'n.
*/

#ifndef UNIVERSE_H
#define UNIVERSE_H

#include "matrix.h"

#include <iostream>
#include <fstream>
using namespace std;

/*
Defines all data for a given dynamic program run, i.e.
constants, such as grid sizes and global parameters.
Note: certain functionnos which might be considered part of the universe
(ie the getIncome function) are not defined here nor even pointed to.
*/
struct universe{
	
	///////Variables///////

	//Grid:
	matrix Astates, Sstates, PIstates, Tstates;	//State vars
	matrix Cdecs, Idecs;						//Dec vars
	matrix TSvals;				//Stochastic element, not State var

	//Parameters:
	double negativeInfiniteUtils;
	double downpaymentR, delta, R, PIgrowthR, incomeLevelAtHike, theta, 
		rho, beta, FDC_multiplier, initialPI; //fixedDurableCost is the fraction of todays stock that must be paid if I>0
	int PIgrowthChangeTime, hikeStart, AfloorFnVersion;	//afloorFnV is here to enforce 1 version per world
	matrix transitionM, wageHike, TSprobabilities;

	///////Functions ///////
	universe(void) {}
	universe(const matrix &Astates, const matrix &Sstates, const matrix &PIstates, const matrix& Tstates,
			const matrix &Cdecs, const matrix &Idecs, const matrix &TSvals,
			double downpaymentR, double delta, double R, double PIgrowthR, double incomeLevelAtHike, double theta, double rho,
			double beta, double fixedDurableCost, double negInf,
			int PIgrowthChangeTime, int hikeStart, int AfloorFnVersion,
			const matrix &transitionM, const matrix &TSprobabilities, const matrix &wageHike, double initialPI) :
			Astates(Astates), Sstates(Sstates), PIstates(PIstates), Tstates(Tstates), 
			Cdecs(Cdecs), Idecs(Idecs), TSvals(TSvals),
			downpaymentR(downpaymentR), delta(delta), R(R), PIgrowthR(PIgrowthR), incomeLevelAtHike(incomeLevelAtHike), theta(theta), rho(rho),
			beta(beta), FDC_multiplier(fixedDurableCost), negativeInfiniteUtils(negInf),
			PIgrowthChangeTime(PIgrowthChangeTime), hikeStart(hikeStart), AfloorFnVersion(AfloorFnVersion),
			transitionM(transitionM), TSprobabilities(TSprobabilities), wageHike(wageHike), initialPI(initialPI) {}

	int print(ofstream &out) const;
};


/*
the state (as in "state variable") class should work with the universe class.
 basically should hold indices for universe's grid.
 Would be nice to make these more abstract and provide iterators, but that
 might be excessive so i'm leaving them as more public structs and treating them
 as indices.  So, passing "lowDecisioin" and "highDecision" is standard.  Sort of ok,
 since the grids are required to be ordered, anyway.
 Convention is to use -1 as the undefined indices in a state.  So if you only want to talk
 about the stock state, set Aidx=-1.
*/
//struct state{
//	static universe &theUniverse;
//	int Aidx, Sidx, PIidx, Tidx;
//
//	//functions
//	state(int aIdx, int sIdx, int piIdx, int tIdx) : 
//	Aidx(aIdx), Sidx(sIdx), PIidx(piIdx), Tidx(tIdx) {}
//	double getSval() const;
//	double getAval() const;
//	double getPIval() const;
//	int getTval() const;
//
//};







/////////NO STATE AND DECISIOIN CLASSES USED/////
//Decided it would be unncessary complication. 
//re: aindices; passing Anext, snext; etc

//
//struct state{
//	double A, S, PI, T;
//
//	//functions
//	state() : A(0), S(0), PI(0), T(0) {}
//	state(double a, double s, double pi, int t) :
//	A(a), S(s), PI(pi), T(t) {}
//};
//
//
///*
// Convention is to use -1 as the undefined indices in a state.  So if you only want to talk
// about the consumption dec, set Iidx=-1.
// */
////struct decision{
////	static universe &theUniverse;
////	int Cidx, Iidx;
////
////	//functions
////	decision(int cIdx, int iIdx) : Cidx(cIdx), Iidx(iIdx) {}
////	double getCval() const;
////	double getIval() const;
////}
//
//struct decision{
//	double C, I;
//
//	//functions
//	decision() : C(-1), I(-1) {}
//	decision(double c, double i) :
//	C(c), I(i) {}
//};

#endif
