
#ifndef MATRIX_H
#define MATRIX_H

#include <cstddef>
#include <iostream>
//using std::ostream;

#include <limits>

#define NDEBUG //turns asserts off.  uncomment out when not debugging.
#include <cassert>



using namespace std;




class matrix
{
public:
	matrix(void) : r(0), c(0) {data = new double[1];} // So call to delete [] doesn't error.  ok?
	matrix(double scalar) : r(1), c(1) {data=new double[1]; data[0] = scalar;}
	matrix(unsigned int rows, unsigned int cols) : r(rows), c(cols) {data = new double[r*c];}// So call to delete [] doesn't error.  ok?
	matrix(unsigned int rows, unsigned int cols, double val);
	matrix(unsigned int rows, unsigned int cols, const double val[], unsigned int valLength); //not robust. Like GAUSS' reshape.
	//matrix(unsigned int rows, unsigned int cols, const double *val, unsigned int valLength); //not robust. Like GAUSS' reshape.
	matrix(const matrix& b);
	matrix& operator =(const matrix& b);
	~matrix(void);

	//Accessors
	unsigned int rows() const {return r;}
	unsigned int cols() const {return c;}
	//Accessor: Same as mutator ...
	inline double operator ()(unsigned int row, unsigned int col) const;
	inline double& operator ()(unsigned int ind) const;
	//Mutator.  Same as accessor ...
	inline double& operator ()(unsigned int row, unsigned int col);
	inline double& operator ()(unsigned int ind);
	unsigned int length() const {return r*c;}
	bool isVector() const {return (r==1 || c==1);} //For testing mostly

	//a&=b is like a+=b.  Returns ref to a.  Same for |=.
	matrix& operator |=(const matrix b);//vertical concat. Very inefficient.
	matrix& operator &=(const matrix b); // Horizontal concat. Very inefficient.

	//Arithmetic operators
	friend const matrix operator +(const matrix &a, const matrix &b); //inefficient
	friend const matrix operator +(const matrix &a, double b); //inefficient
	friend const matrix operator +(double a, const matrix &b); //inefficient
	friend const matrix operator -(const matrix &a, double b); //inefficient
	friend const matrix operator -(double a, const matrix &b); //inefficient
	const matrix operator -() const;
	friend const matrix operator -(const matrix &a, const matrix &b); //inefficient

	friend ostream& operator <<(ostream& outs, const matrix& mat);
	void gau5writer(char *fmtName);

	double* getDataPtr() const;//Don't use this function! bad programming practice!
	//"copy" should be delete'd already; it will be allocated and filled

private:
	unsigned int r; //rows
	unsigned int c; //cols
	double *data; 
	int index(unsigned int rows, unsigned int cols) const {return rows*c + cols;} //start-at-0 indexing

};




//inline Mutators/Accessors
inline double& matrix::operator ()(unsigned int row, unsigned int col){
	return data[index(row,col)];
}

//vector version, mutator/accessor
inline double& matrix::operator ()(unsigned int ind){
	assert(c==1 || r==1);

	if (c==1)
		return data[index(ind,0)];
	else if (r==1)
		return data[index(0,ind)];
	else
	{ cerr<< "tmperror, matrix::()\n"; exit(1);}
	/*
	else {
		cerr << "matrix::operator(): Tried to access non-vector matrix as a vector.\n"; 
		cerr << "r==" << r << " and c==" << c << endl;
		exit(1);
	}
	*/
}

//accessor
inline double matrix::operator ()(unsigned int row, unsigned int col) const{
	return data[index(row,col)];
}

//vector version (accessor)
inline double& matrix::operator ()(unsigned int ind) const {
	assert(c==1 || r==1);
	if (c==1)
		return data[index(ind,0)];
	else if (r==1)
		return data[index(0,ind)];
	else
	{ cerr<< "tmperror, matrix::()\n"; exit(1);}
	/*
	else {
		cerr << "matrix::operator(): Tried to access non-vector matrix as a vector.\n"; 
		cerr << "r==" << r << " and c==" << c << endl;
		exit(1);
	}
	*/
}

/********************************** "ARRAY" storage class *****************************/
/**************************************************************************************/
/**************************************************************************************/
/**************************************************************************************/


class Array
{
public:
	Array(void) : numDims(0), currDims(0), safeToDeleteData(true) {data = new double[1]; dimSizes = new unsigned int[1]; dimSwitches = new bool[1]; fixedIndices = new unsigned int[1];} // So call to delete [] doesn't error.  ok?
	Array(double scalar) : numDims(1), currDims(1), safeToDeleteData(true)  {
		dimSizes = new unsigned int[1]; dimSizes[0] = 1;
		dimSwitches = new bool[1]; dimSwitches[0] = 1; //"on"
		fixedIndices = new unsigned int[1]; fixedIndices[0] = 0; //0 to unsigned bc value shouldnt matter if "on"
		data=new double[1]; data[0] = scalar;
	}

	

	//Allocator/Initializer are essentially constructors; renamed for clarity
	void allocator(const matrix &dimensions);
	void allocator(const unsigned int *dimensions, unsigned int numDimensions);
	//void initializer(const matrix &dimensions); //intitialize array to look like matrix.
	void initializer(const matrix &dimensions, double scalar);
	void initializer(const unsigned int *dimensions, unsigned int numDimensions, double scalar);
	void initializer(double *dataPtr, const matrix &dimensions); //Dangerous.  This sets dataPtr to NULL! Reference to Ptr.
//	matrix(unsigned int rows, unsigned int cols) : r(rows), c(cols) {data = new double[r*c];}// So call to delete [] doesn't error.  ok?
//	matrix(unsigned int rows, unsigned int cols, double val);
//	matrix(unsigned int rows, unsigned int cols, const double val[], unsigned int valLength); //not robust. Like GAUSS' reshape.
//	//matrix(unsigned int rows, unsigned int cols, const double *val, unsigned int valLength); //not robust. Like GAUSS' reshape.
	Array(const Array& b);
	Array& operator =(const Array& b);
	~Array(void);

	double operator ()(const matrix &indices) const;  //TO INLINE or not to inline?
	double& operator ()(const matrix &indices);//TO INLINE or not to inline?
	double operator ()(const unsigned int &theIndex) const;  //TO INLINE or not to inline?
	double& operator ()(const unsigned int &theIndex);//TO INLINE or not to inline?

	
	unsigned int vecLength() const;//vecLength requires the Array has only 1 free dimension.
	void fixIatM(int I, unsigned int M) {if (dimSwitches[I]) {currDims--;} dimSwitches[I]=0; fixedIndices[I]=M;} //"fix" the I-th dimension at M <= numDims
	void freeI(int I) {if (!dimSwitches[I]) currDims++; dimSwitches[I] = 1;}
	void freeAll() {currDims=numDims; for (int i=0; i<numDims; i++) {dimSwitches[i]=1;} }
	inline void fixAllDimsStrictlyLessThan(int n, const unsigned int *indices);
	inline void fixAllDimsStrictlyLessThan(int n, const matrix &indices);
	//bool isVector() const {return (numDims==1 && dimSwitches[0]==1);} //For testing mostly. 
	bool isVector() const {return (currDims==1 && dimSwitches[0]==1);} //For testing mostly. 
	friend ostream& operator <<(ostream& outs, const Array& mat);
	void write_ASCII() const;

	//functions:
	
	//Array should be 2D.  (e.g. all but 2 dims should be fixed)
	//Should move aindiceslowhighwghts/ etc into this function
	inline double linearInterpolation2D(unsigned int lowIdx1, unsigned int highIdx1, unsigned int lowIdx2, unsigned int highIdx2, 
										double weightHigh1, double weightHigh2) const;


	//void getDataPtr(double *copy) const;//Don't use this function! bad programming practice!
	//"copy" should be delete'd already; it will be allocated and filled


private:  //could have implemented as numdims x 3 matrix ... but would be tied to matrix class and couldnt use "bool"
//public:
	bool safeToDeleteData;	//If array is (unsafely) initialized using initializor(double*, matrix), you can't delete the data.
	int			numDims;		// numDims dimensional array. A scalar is considered one-dimensional (not zero!).
	unsigned int *dimSizes;		//dimSizes is length numDims
	double *data;				//Should always be allocated/"new"'d.
	bool *dimSwitches;	//length numDims. Makes N-dim array behave like M-dim array, 1<=M<=N, by "switching" indices off.
	//0==fixed/off

	int currDims; //currDims = numDims - (# of dimSwitches set to "fixed")
	unsigned int *fixedIndices;	//Used with dimSwitches; Stores the "fixed" indices, letting the others vary.
	//fixedIndices[i] undefined if dimSwitches[i]==1.

	//These are "absolute" indexers, e.g. same behavior regardless of fixedIndices
	inline unsigned int index(const unsigned int* indices) const;
	inline unsigned int index(const matrix &indices) const; //converts doubles to ints! careful.
};


//RECALL: hard to have inline functions not in header file    dont move these
//This is an _interpolation_ function.  For values _off_ the grid, behavior is, in a sense,
//undefined. by which, i mean that we return -infinite for going off the bottom and 
//use the value of the topmost grid point for going off the top, on either of the two grids.
//Code for going below the grid shoudl be to set weight to -1 and for going above set it to -2 
inline double Array::linearInterpolation2D(unsigned int lowIdx1, unsigned int highIdx1, unsigned int lowIdx2, unsigned int highIdx2, 
									double weightHigh1, double weightHigh2) const{
	//error checking.
	assert(currDims == 2);
	
	matrix idx1(2,1), idx2(2,1), idx3(2,1), idx4(2,1);
	idx1(0)=lowIdx1;	idx1(1)=lowIdx2;
	idx2(0)=lowIdx1;	idx2(1)=highIdx2;
	idx3(0)=highIdx1;	idx3(1)=lowIdx2;
	idx4(0)=highIdx1;	idx4(1)=highIdx2;

	if (weightHigh1==-1)		return -numeric_limits<double>::max();
	else if (weightHigh1==-2)	weightHigh1 = 1;//Off top of grid, so just use highest grid point. [indices might even be equal.]
	if (weightHigh2==-1)		return -numeric_limits<double>::max();
	else if (weightHigh2==-2)	weightHigh2 = 1;//Off top of grid, so just use highest grid point. [indices might even be equal.]

	//might attempt to control order-of-ops for precision consistency
	return			((  (((1-weightHigh1)*(1-weightHigh2)) * (*this)(idx1)) + 
					    (((1-weightHigh1)*(weightHigh2)) * (*this)(idx2)) )   +
					    (((weightHigh1)*(1-weightHigh2)) * (*this)(idx3)) )   +
					    (((weightHigh1)*(weightHigh2)) * (*this)(idx4));
}

inline unsigned int Array::index(const unsigned int* indices) const{
	unsigned int ind=0, subMatSizes=1;
	for (int dim=numDims-1; dim>=0; dim--){
		ind += indices[dim] * subMatSizes;
		subMatSizes *= dimSizes[dim];
	}
	return ind;
}

inline unsigned int Array::index(const matrix &indices) const{
	assert(indices.isVector() && indices.length() == numDims);
	unsigned int ind=0, subMatSizes=1;
	for (int dim=numDims-1; dim>=0; dim--){
		ind += (unsigned int)indices(dim) * subMatSizes;
		subMatSizes *= dimSizes[dim];
	}
	return ind;
}

inline void Array::fixAllDimsStrictlyLessThan(int n, const unsigned int *indices){
	for (int i=0; i<n; i++){
		if (dimSwitches[i]) currDims--;
		dimSwitches[i] = 0;
		fixedIndices[i] = indices[i];
	}
}

inline void Array::fixAllDimsStrictlyLessThan(int n, const matrix &indices){
	assert(indices.isVector());
	for (int i=0; i<n; i++){
		if (dimSwitches[i]) currDims--;
		dimSwitches[i] = 0;
		fixedIndices[i] = (unsigned int)indices(i);
	}
}

	
//
//public:
//	matrix(void) : r(0), c(0) {data = new double[1];} // So call to delete [] doesn't error.  ok?
//	matrix(double scalar) : r(1), c(1) {data=new double[1]; data[0] = scalar;}
//	matrix(unsigned int rows, unsigned int cols) : r(rows), c(cols) {data = new double[r*c];}// So call to delete [] doesn't error.  ok?
//	matrix(unsigned int rows, unsigned int cols, double val);
//	matrix(unsigned int rows, unsigned int cols, const double val[], unsigned int valLength); //not robust. Like GAUSS' reshape.
//	//matrix(unsigned int rows, unsigned int cols, const double *val, unsigned int valLength); //not robust. Like GAUSS' reshape.
//	matrix(const matrix& b);
//	matrix& operator =(const matrix& b);
//	~matrix(void);
//
//	//Accessor. Same as mutator ...
//	//const double operator ()(unsigned int row, unsigned int col) const;
//	//Mutator.  Same as accessor ...
//	inline double& operator ()(unsigned int row, unsigned int col);
//	inline double& operator ()(unsigned int ind);
//	unsigned int length() const {return r*c;}
//	bool isVector() const {return (r==1 || c==1);} //For testing mostly
//
//	matrix& operator |=(const matrix b);//vertical concat. Very inefficient.
//	matrix& operator &=(const matrix b); // Horizontal concat. Very inefficient.
//
//	//Arithmetic operators
//	friend const matrix operator +(const matrix &a, const matrix &b); //inefficient
//	friend const matrix operator +(const matrix &a, double b); //inefficient
//	friend const matrix operator +(double a, const matrix &b); //inefficient
//	friend const matrix operator -(const matrix &a, double b); //inefficient
//	friend const matrix operator -(double a, const matrix &b); //inefficient
//	const matrix operator -() const;
//	friend const matrix operator -(const matrix &a, const matrix &b); //inefficient
//
//	friend ostream& operator <<(ostream& outs, const matrix& mat);
//	



#endif