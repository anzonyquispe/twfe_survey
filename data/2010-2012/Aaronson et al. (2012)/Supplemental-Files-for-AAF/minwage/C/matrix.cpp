



#include "matrix.h"
//#include <iostream> //in "matrix.h"
using std::endl;
using std::cerr;
using std::cout;

#include <fstream>
using std::ofstream; //temporary


#include "c_gaussIO.h"

//bad style functions / accessors
double* matrix::getDataPtr() const {//Don't use this function! bad programming practice!

	double *copy = new double[r*c];
	for (unsigned long int t=0; t<r*c; t++){
		copy[t] = data[t];
	}
	return copy;
}

/*Constructors */
matrix::matrix(unsigned int rows, unsigned int cols, double val){
	r = rows;
	c = cols;

	data = new double[r*c];
	for (unsigned int i=0; i<r*c; i++)
		data[i] = val;

	/*  // if data is double**
	r = rows;
	c = cols;
	data = new double*[r];
	for (unsigned int i=0; i<r; i++)
		data[i] = new double[c];

	for (unsigned int i=0; i<r; i++)
		for (unsigned int j=0;j<c;j++)
			data[i][j] = val;
			*/
}



matrix::matrix(unsigned int rows, unsigned int cols,  const double val[], unsigned int valLength){
	r = rows;
	c = cols;
	
	data = new double[r*c];

	unsigned int i=0; unsigned int j=0;
	while (j<r*c) {//Depends on order that C++ stores values in arrays (row by row) 
		data[j] = val[i];
		if ( i<valLength-1 ) 
			i++; 
		else{
			i=0;
		}
		j++;
	}


	/* // use if data is double**
	r = rows;
	c = cols;
	data = new double*[r];
	for (unsigned int i=0; i<r; i++)
		data[i] = new double[c];
	
	for (unsigned int i=0; i<r; i++)
		for (unsigned int j=0;j<c;j++)
			data[i][j] = val[i][j];
			*/
}



matrix::matrix(const matrix& b){
	r = b.r;
	c = b.c;
	data = new double[r*c];
	for (unsigned int i=0; i<r*c; i++)
		data[i] = b.data[i];
}


matrix& matrix::operator =(const matrix& b){
	if (this == &b) return *this;
	else{
		r = b.r;
		c = b.c;
		delete [] data;  // "inefficient" ? see void constructor
		data = new double[r*c];
		for (unsigned int i=0; i<r*c; i++)
			data[i] = b.data[i];
	}
	return *this;
}


matrix& matrix::operator |=(const matrix b){//vertical concat.  pass-by-val allows a|=a
	matrix tmp = *this;

	if (c != b.c){
		cerr << "Matrix::operator || : Vertical Concatenation error, rows not same length (diff # cols).\n"; 
		exit(1);
	}

	//c = a.c; //already
	r += b.r;
	
	/* This could be modified to be more efficient. Particularly to save copying tmp so many times.*/
	delete [] data;
	data = new double[r*c];

	for (unsigned int aRows=0; aRows<tmp.r; aRows++){
		for (unsigned int aCols=0; aCols<tmp.c; aCols++){
			data[index(aRows, aCols)] = tmp.data[tmp.index(aRows,aCols)];
		}
	}
	for (unsigned int bRows=0; bRows<b.r; bRows++){
		for (unsigned int bCols=0; bCols<b.c; bCols++){
			data[index(tmp.r+bRows,bCols)] = b.data[b.index(bRows,bCols)];
		}
	}
	return *this;
}

matrix& matrix::operator &=(const matrix b) { //horizont. pass-by-val allows a&=a
	matrix a = *this;


	if (a.r != b.r) { //error checking
		cerr << "Matrix::operator && : Horizontal Concatenation error, cols not same length (diff # rows).\n"; 
		exit(1);
	}

	c = a.c + b.c;

	/* This could be modified to be more efficient. Particularly to save copying tmp so many times.*/
	delete [] data;
	data = new double[r*c];

	for (unsigned int aRows=0; aRows<a.r; aRows++){
		for (unsigned int aCols=0; aCols<a.c; aCols++){
			data[index(aRows,aCols)] = a.data[a.index(aRows,aCols)];
		}
	}
	for (unsigned int bRows=0; bRows<b.r; bRows++){
		for (unsigned int bCols=0; bCols<b.c; bCols++){
			data[index(bRows, a.c+bCols)] = b.data[b.index(bRows, bCols)];
			
		}
	}
	return *this;
}

/*
matrix& matrix::operator |=(const matrix b){//vertical concat
	if (c != b.c){
		cerr << "Matrix::operator || : Vertical Concatenation error, rows not same length (diff # cols).\n"; 
		exit(1);
	}

	matrix result;
	result.c = a.c;
	result.r = a.r + b.r;
	result.data = new double[result.r*result.c];
	for (unsigned int aRows=0; aRows<a.r; aRows++){
		for (unsigned int aCols=0; aCols<a.c; aCols++){
			result.data[result.index(aRows, aCols)] = a.data[a.index(aRows,aCols)];
		}
	}
	for (unsigned int bRows=0; bRows<b.r; bRows++){
		for (unsigned int bCols=0; bCols<b.c; bCols++){
			result.data[result.index(a.r+bRows,bCols)] = b.data[b.index(bRows,bCols)];
		}
	}
	return result;
}

matrix& matrix::operator &=(const matrix b) { //horizont //errors with passing by reference? or no?
	matrix a = *this;


	if (a.r != b.r) { //error checking
		cerr << "Matrix::operator && : Horizontal Concatenation error, cols not same length (diff # rows).\n"; 
		exit(1);
	}

	matrix result;
	result.c = a.c + b.c;
	result.r = a.r;
	result.data = new double[result.r*result.c];
	for (unsigned int aRows=0; aRows<a.r; aRows++){
		for (unsigned int aCols=0; aCols<a.c; aCols++){
			result.data[result.index(aRows,aCols)] = a.data[a.index(aRows,aCols)];
		}
	}
	for (unsigned int bRows=0; bRows<b.r; bRows++){
		for (unsigned int bCols=0; bCols<b.c; bCols++){
			result.data[result.index(bRows, a.c+bCols)] = b.data[b.index(bRows, bCols)];
			
		}
	}
	return result;
}
*/


matrix::~matrix(void)
{
	delete [] data;

	/* //use if data is double**
	for (unsigned int i=0; i<r; i++)
		delete [] data[i];
	delete [] data;
	*/
}





/******** functions ********/

const matrix matrix::operator -() const{
	matrix result(*this);
	for (unsigned int i=0; i<r*c; i++){
		result.data[i] = -result.data[i];
	}
	return result;
}

const matrix operator +(const matrix &a, const matrix &b){
	if ((a.r != b.r) || (a.c != b.c)){
		cerr << "matrix +: Non Conformable Matrices.";
		exit(1);
	}

	/*
	matrix result;
	result.r = a.r; 
	result.c = a.c;
	result.data = new double[a.r*a.c];
	int ind;
	for (unsigned int rows=0; rows<a.r; rows++){
		for (unsigned int cols=0; cols<b.c; cols++){
			ind = a.index(rows,cols);
			result.data[ind] = a.data[ind];
		}
	}

	return result;
	*/

	double *data = new double[a.r*a.c];
	int ind;
	for (unsigned int rows=0; rows<a.r; rows++){
		for (unsigned int cols=0; cols<b.c; cols++){
		ind = a.index(rows,cols);
			data[ind] = a.data[ind] + b.data[ind];
		}
	}
	matrix tmp = matrix(b.r, b.c, data, b.r*b.c);
	return tmp;
	
}

const matrix operator +(const matrix &a, double b){ //inefficient
	matrix result(a);
	register double d=b;
	for (unsigned int i=0; i<result.r*result.c; i++){
		result.data[i] += d;
	}
	return result;
}

const matrix operator -(const matrix &a, const matrix &b){ //inefficient
	return a + -b;
}

const matrix operator -(const matrix &a, double b){ //inefficient
	matrix result(a);
	register double d=b;
	for (unsigned int i=0; i<result.r*result.c; i++){
		result.data[i] -= d;
	}
	return result;
}

const matrix operator -(double a, const matrix &b){ //inefficient
	matrix result(b);
	register double d=a;
	for (unsigned int i=0; i<result.r*result.c; i++){
		result.data[i] = d - result.data[i];
	}
	return result;
}

const matrix operator +(double a, const matrix &b){ //inefficient
	matrix result(b);
	register double d=a;
	for (unsigned int i=0; i<result.r*result.c; i++){
		result.data[i] += d;
	}
	return result;
}

ostream& operator <<(ostream& outs, const matrix& mat){
	unsigned int r, c;
	r = mat.r;
	c = mat.c;
	outs << "\n";
	if (r<1 || c<1) {outs << "Null Matrix\n";}
	else {
		for (unsigned int rows=0; rows<r; rows++){
			for (unsigned int cols=0; cols<c; cols++){
				outs << (mat.data)[mat.index(rows,cols)] << " ";
			}
			outs << endl;
		}
	}
	return outs;
}



void matrix::gau5writer(char *fmtName){
	GMatrix tmp; //type used by ken's function
	tmp.n = c;
	tmp.m = r;
	tmp.data = data;
	gau5write(fmtName, tmp);
}

/* //safe version
int matrix::index(unsigned int rows, unsigned int cols) const{
	unsigned int i;
	i = rows*c + cols;
	if (i > r*c-1) {
		cerr << "Index out of range.\n";
		exit(1);
	}
	else 
		return i;
}
*/ 









/********************************** "ARRAY" storage class *****************************/
/**************************************************************************************/
/**************************************************************************************/
/**************************************************************************************/



/* //bad!
void getDataPtr(double *copy) const {//Don't use this function! bad programming practice!
	unsigned long int totalSize=1;
	for (int d=0; d< numDims; d++) {
		totalSize *= dimSizes[d];
	}
	copy = new double[totalSize];
	for (unsigned long int t=0; t<totalSize; t++){
		copy[t] = data[t];
	}
}
*/

Array::Array(const Array& b){
	safeToDeleteData = true;
	numDims = b.numDims; currDims = b.currDims;
	dimSizes=new unsigned int[numDims]; 
	dimSwitches=new bool[numDims]; 
	fixedIndices=new unsigned int[numDims];
	long unsigned int totalSize=1;
	for (int d=0; d<numDims; d++){
		dimSizes[d]=b.dimSizes[d];
		dimSwitches[d]=b.dimSwitches[d];
		fixedIndices[d]=b.fixedIndices[d];
		totalSize*=dimSizes[d];
	}
	data = new double[totalSize];
	for (long unsigned int t=0; t<totalSize; t++){
		data[t] = b.data[t];
	}
}

//this didnt use to call ~array; error?
Array& Array::operator =(const Array &b){ //how come not const
	if (&b==this) return *this;
	else if (!(this->safeToDeleteData)) {
		cerr << "Array::operator= : Not Safe to Delete Data (points to same as an initializer() double*).\n";
		exit(1);
	}
	else{
		this->~Array();
		//safeToDeleteData stays at true; even if b has it false, since we copy the data to a new pointer location
		numDims = b.numDims; currDims = b.currDims;
		dimSizes=new unsigned int[numDims]; 
		dimSwitches=new bool[numDims]; 
		fixedIndices=new unsigned int[numDims];
		long unsigned int totalSize=1;
		for (int d=0; d<numDims; d++){
			dimSizes[d]=b.dimSizes[d];
			dimSwitches[d]=b.dimSwitches[d];
			fixedIndices[d]=b.fixedIndices[d];
			totalSize*=dimSizes[d];
		}
		data = new double[totalSize];
		for (long unsigned int t=0; t<totalSize; t++){
			data[t] = b.data[t];
		}
	}
	return *this;
}

Array::~Array(){
	if (safeToDeleteData){
		delete [] data;
		delete [] dimSizes;
		delete [] dimSwitches;
		delete [] fixedIndices;
	}
	else{
		//delete [] data;
		delete [] dimSizes;
		delete [] dimSwitches;
		delete [] fixedIndices;
	}
}


void Array::allocator(const matrix &dimensions){
	this->~Array(); //doesn't delete data if !safeToDeleteData
	if (!safeToDeleteData) {
		cerr << "Array::allocator: !safeToDeleteData, can't allocate.\n";
		exit(1);
	}
	assert(dimensions.isVector());
	if (!dimensions.isVector()) {cerr << "Array::Array(matrix): argument not a vector\n"; exit(1);}
	unsigned long int totalSize=1;
	numDims = dimensions.length();
	currDims = numDims;
	dimSwitches = new bool[numDims];
	fixedIndices = new unsigned int[numDims];
	dimSizes = new unsigned int[numDims];
	for (int i=0; i<numDims; i++){
		dimSwitches[i]=1; 
		dimSizes[i] = (unsigned int)dimensions(i); 
		totalSize *= dimSizes[i];
		fixedIndices[i]=0; //Not required by rules, since dimswitches[i]==1
	}
	data = new double[totalSize];
}


void Array::allocator(const unsigned int *dimensions, unsigned int numDimensions){
	this->~Array(); //doesn't delete data if !safeToDeleteData
	if (!safeToDeleteData) {
		cerr << "Array::allocator: !safeToDeleteData, can't allocate.\n";
		exit(1);
	}

	unsigned long int totalSize=1;
	numDims = numDimensions;
	currDims = numDims;
	dimSwitches = new bool[numDims];
	fixedIndices = new unsigned int[numDims];
	dimSizes = new unsigned int[numDims];
	for (int i=0; i<numDims; i++){
		dimSwitches[i]=1; 
		dimSizes[i] = dimensions[i]; 
		totalSize *= dimSizes[i];
		fixedIndices[i]=0; //Not required by rules, since dimswitches[i]==1
	}
	data = new double[totalSize];
}

void Array::initializer(const unsigned int *dimensions, unsigned int numDimensions, double scalar){
	this->~Array(); //doesn't delete data if !safeToDeleteData
	if (!safeToDeleteData) {
		cerr << "Array::initializer: !safeToDeleteData, can't initialize.\n";
		exit(1);
	}

	unsigned long int totalSize=1;
	numDims = numDimensions;
	currDims = numDims;
	dimSwitches = new bool[numDims];
	fixedIndices = new unsigned int[numDims];
	dimSizes = new unsigned int[numDims];
	for (int i=0; i<numDims; i++){
		dimSwitches[i]=1; 
		dimSizes[i] = dimensions[i]; 
		totalSize *= dimSizes[i];
		fixedIndices[i]=0; //Not required by rules, since dimswitches[i]==1
	}
	data = new double[totalSize];

	register double s=scalar; //initialize to scalar
	for (unsigned long int t=0; t<totalSize; t++){
		data[t] = s;
	}
}

// dimensions gives the dimensions of the array (like allocator) and then values are set to scalar
void Array::initializer(const matrix &dimensions, double scalar){
	this->~Array(); //doesn't delete data if !safeToDeleteData
	if (!safeToDeleteData) {
		cerr << "Array::initializer: !safeToDeleteData, can't initialize.\n";
		exit(1);
	}
	
	assert(dimensions.isVector());
	if (!dimensions.isVector()) {cerr << "Array::Array(matrix): argument not a vector\n"; exit(1);}
	unsigned long int totalSize=1;
	numDims = dimensions.length();
	currDims = numDims;
	dimSwitches = new bool[numDims];
	fixedIndices = new unsigned int[numDims];
	dimSizes = new unsigned int[numDims];
	for (int i=0; i<numDims; i++){
		dimSwitches[i]=1; 
		dimSizes[i] = (unsigned int)dimensions(i); 
		totalSize *= dimSizes[i];
		fixedIndices[i]=0; //Not required by rules, since dimswitches[i]==1
	}
	data = new double[totalSize];

	register double s=scalar; //initialize to scalar
	for (unsigned long int t=0; t<totalSize; t++){
		data[t] = s;
	}
}

void Array::initializer(double *dataPtr, const matrix &dimensions){//Dangerous.  This should set dataPtr to NULL but cant, GAUSS
	assert(dimensions.isVector());
	//cout << "arrayinitializer: make sure dataPtr is allocated ahead of time.\n";
	this->~Array(); //doesn't delete data if !safeToDeleteData
	if (!safeToDeleteData) {
		cerr << "Array::initializer: !safeToDeleteData, can't initialize with new pointer.\n";
		exit(1);
	}
	safeToDeleteData = false;
	data = dataPtr; // should be allocated!
	numDims = dimensions.length();
	currDims = numDims;
	dimSizes = new unsigned int[numDims];
	dimSwitches = new bool[numDims];
	fixedIndices = new unsigned int[numDims];
	for (int i=0; i<numDims; i++){
		dimSizes[i] = dimensions(i);
		dimSwitches[i] = true;
		fixedIndices[i] = -1; //would prefer to set to -1 == max value;
	}
	
	//if the below is uncommented, then you should remove the 'safetoDelete' member var.  
	//cant uncomment bc would defeat purpose dataPtr = NULL; //Don't want the pointer running around changing the array now.
}


double Array::operator ()(const matrix &indices) const{ // indexing operator.  behavior changes based on "current" dimension of array
	//error checking
	assert(indices.length() == currDims);
	//end error checking

	int indicesIdx=0;
	for (int d=0; d<numDims; d++){
		if (dimSwitches[d]) {
			fixedIndices[d] = (unsigned int)indices(indicesIdx); // can change these, since behavior is undefined.
			indicesIdx++;
		}
		//else fixedIndices[d] = fixedIndices[d];
	}
	return data[ index(fixedIndices) ];
}

double& Array::operator ()(const matrix &indices){
	//error checking
	assert(indices.length() == currDims);
	//end error checking

	int indicesIdx=0;
	for (int d=0; d<numDims; d++){
		if (dimSwitches[d]) {
			fixedIndices[d] = (unsigned int)(indices(indicesIdx)); // can change these, since behavior is undefined.
			indicesIdx++;
		}
		//else fixedIndices[d] = fixedIndices[d];
	}
	return data[ index(fixedIndices) ];
}

double Array::operator ()(const unsigned int &theIndex) const{
	//error checking
	assert(currDims == 1);
	//end error checking

	for (int d=0; d<numDims; d++){
		if (dimSwitches[d]) {
			fixedIndices[d] = theIndex; // can change these vals of fixedIndices, since behavior is undefined.
			break;
		}		//else fixedIndices[d] = fixedIndices[d];
	}
	return data[ index(fixedIndices) ];
}

double& Array::operator ()(const unsigned int &theIndex){
	//error checking
	assert(currDims == 1);
	//end error checking

	for (int d=0; d<numDims; d++){
		if (dimSwitches[d]) {
			fixedIndices[d] = theIndex; // can change these vals of fixedIndices, since behavior is undefined.
			break;
		}		//else fixedIndices[d] = fixedIndices[d];
	}
	return data[ index(fixedIndices) ];
}
 
unsigned int Array::vecLength() const{
	assert(currDims==1);

	for (int d=0; d<numDims; d++){
		if (dimSwitches[d])
			return dimSizes[d];
	}
}

ostream& operator <<(ostream& outs, const Array& mat){
	outs << "\n";
	unsigned int numDims = mat.numDims;
	if		(numDims<1) {outs << "Null Matrix\n";}
	else if (numDims==1){//includes scalar case	
		for (unsigned int rows=0; rows<mat.dimSizes[0]; rows++){
			outs << (mat.data)[rows] << " ";
		}
		outs << endl;
	}
	else if (numDims==2){
		matrix indices(2,1);
		for (unsigned int rows=0; rows<mat.dimSizes[0]; rows++){
			for (unsigned int cols=0; cols<mat.dimSizes[1]; cols++){
				indices(0)=rows; indices(1)=cols;
				outs << (mat.data)[int(mat.index(indices))] << " ";
			}
			outs << endl;
		}
	}
	else{
		unsigned long int size=1, idx=0;
		unsigned int r=mat.dimSizes[numDims-2], c=mat.dimSizes[numDims-1];
		for (unsigned int dim=0; dim<numDims-2; dim++){
			size *= mat.dimSizes[dim];
		}
			
		for (unsigned long int dim=0; dim<size; dim++){
			for (unsigned int rows=0; rows<r; rows++){
				for (unsigned int cols=0; cols<c; cols++){
					outs << (mat.data)[idx] << " ";
					idx++;
				}
				outs << endl;
			}
			outs << endl;
		}
		
	}
	return outs;
}

void Array::write_ASCII() const{

}

////////////////////////// Array functions //////////////////////////


