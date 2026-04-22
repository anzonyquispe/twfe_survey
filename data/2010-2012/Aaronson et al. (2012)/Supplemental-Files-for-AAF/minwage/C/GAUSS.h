/* GAUSS.h: Some GAUSS functions that I have coded into C++ 
--Charles Doss
10/23/07
*/

#ifndef GAUSS_H
#define GAUSS_H

#include "matrix.h"

/*  Return an Arithmetic Sequence in a column vector.  
Mimic'ing GAUSS seqa. */
matrix seqa(double start, double inc, unsigned int n);

#endif