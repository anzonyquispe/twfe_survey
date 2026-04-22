/* GAUSS.cpp: Some GAUSS functions that I have coded into C++ 
--Charles Doss
10/23/07
*/

#include "GAUSS.h"
//#include "matrix.h" //in GAUSS.h


matrix seqa(double start, double inc, unsigned int n){
	matrix result(n,1);
	double val(start);
	result(0,0) = val;
	for (unsigned int i=1; i<n; i++){
		val += inc;
		result(i,0) = val;
	} 
	return result;
}
