
/* WEALTHIO.H

*/

#ifndef WEALTHIO_H
#define WEALTHIO_H

/* this defines a matrix with given # of rows and */
/* columns and gives the address of the first element */
typedef struct {   
  unsigned int m;  //# of rows
  unsigned int n; //# of columns
  double *data;} GMatrix;

#define BASIC_HEADER_LEN 128 /* Length of a scalar header */
#define BYTE_POS 5           /* Int offset in header of byte order */
#define BIT_POS 6            /* Int offset in header of bit order */
#define TYPE_POS 15          /* Int offset in header of matrix type */
#define HEADER_LEN_POS 18    /* Int offset in header of header length */
#define M_POS 32             /* Int offset in header of value for m */
#define N_POS 33             /* Int offset in header of value for n */
#define SCALAR 0             /* Value of type that indicates a scalar */
#define MATRIX 2             /* Value of type that indicates a matrix */
#define BIT_SYSTEM 0         /* Value of bit order (0=backwards/i386) */
#define BYTE_SYSTEM 0        /* Value of byte order (0=backwards/i386) */


/* Strings of directory names */
#define ADDRESS_LEN 90
extern char rootdir[]; 
extern char outputdir[]; 
extern char datadir[]; 



/*  GAUSS-C++ I/O programs written by K. Housinger */
unsigned char * gread(unsigned char *inbuf, int bytes, int byte_reverse, int bit_reverse);
GMatrix gau5read(char *fmt);
void gau5write(char *fmt, GMatrix mat); /* writes matrix to hard drive*/


/* confused about this writeData function.  Not for gauss, i presume? */
void WriteData(double **cohsimMat, double **netIncomesimMat, double **consumptionsimMat, 
               double **healthcostsimMat, double **zetaindexsimMat, double **marstatsimMat, 
               GMatrix agesim95Ptr, GMatrix PIsim95Ptr, double **healthsimhMat, 
               double **healthsimwMat);






#endif
