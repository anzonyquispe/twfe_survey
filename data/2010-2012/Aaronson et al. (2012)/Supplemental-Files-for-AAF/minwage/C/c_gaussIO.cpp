/*Formerly known as wealthio, taken from code from Ken for 
  deNardi, French and Jones */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#include "c_gaussIO.h"

char rootdir[ADDRESS_LEN]; 
char outputdir[ADDRESS_LEN]; 
char datadir[ADDRESS_LEN]; 

/*--------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------*/
/*  Below is C/GAUSS I/O code written by Ken Housinger                       */
/*--------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------*/
/*  This function takes a char* and either reverses bits within bytes or bytes */
/*  themselves or both.  It returns a pointer to the original buffer which is  */
/*  altered. */

unsigned char * gread(unsigned char *inbuf, int bytes, int byte_rev, int bit_rev) 
   {
    unsigned char *tempbuf;
    unsigned char tempbyte, tempbit;
    int i, j;

    tempbuf = (unsigned char *) malloc(bytes);
    for (i = 0; i < bytes; i++) 
       {
        if (byte_rev) *(tempbuf + i) = *(inbuf + bytes - i - 1);
        else *(tempbuf + i) = *(inbuf + i);

        if (bit_rev) 
           {
            tempbyte = 0;
            for (j = 0; j < CHAR_BIT; j++) 
               {
                tempbit = *(tempbuf + i) >> (CHAR_BIT - j - 1);
                tempbit = tempbit << (CHAR_BIT - 1);
                tempbit = tempbit >> (CHAR_BIT - j - 1);
                tempbyte = tempbyte | tempbit;
               }
            *(tempbuf + i) = tempbyte;
           }
       }

    for (i = 0; i < bytes; i++)
        *(inbuf + i) = *(tempbuf + i);
    free(tempbuf);

    return(inbuf);
   }

/*--------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------*/
/*  This function reads a Gauss v5.0 fmt file into a Matrix structure and  */
/*  returns the structure.  */

GMatrix gau5read(char *fmt) 
   {
/*  Initialize the matrix to be 1x1 and the byte/bit order to 0.  */
    GMatrix mat = {1, 1}; 
    unsigned int i;
    int type, byte, bit;
    unsigned char *cread;
    int bit_rev = 0, byte_rev = 0;
    FILE *fd;

    if (sizeof(int) != 4 || sizeof(double) != 8 || CHAR_BIT != 8) 
       {
        printf("Incompatable machine architecture.\n");
        return (mat);
       }

/*  Allocate enough space to store the header.  */
    cread = (unsigned char *) malloc(BASIC_HEADER_LEN); 
/*  Open *fmt for reading only.  */
    fd = fopen(fmt, "rb"); 
  
/*  Read the basic header (128 bytes) all at once.  */

    fread((void *) cread, 1, BASIC_HEADER_LEN, fd);
    byte = (int) *(cread + (BYTE_POS * sizeof(int)));  /* (0=Backward) */
    bit = (int) *(cread + (BIT_POS * sizeof(int)));    /* (0=Backward) */

/*  To get some system independence, we detect whether we have to reverse */
/*  the bytes or bits or both.  If x and x_SYSTEM match, no reverse is  */
/*  necessary. */

    if ((bit || BIT_SYSTEM) && !(bit && BIT_SYSTEM)) bit_rev=1;
    if ((byte || BYTE_SYSTEM) && !(byte && BYTE_SYSTEM)) byte_rev=1;

    type = *( (int *) gread((cread + (TYPE_POS * sizeof(int))), sizeof(int), 
                             byte_rev, bit_rev) );

/*  If the fmt file type is not a scalar, there are another two */
/*  ints of header giving the values of m and n.  If a matrix, also reset n. */

    if (type > SCALAR) 
       { 
        fread((void *) cread, 1, sizeof(int), fd);
        mat.m = *((unsigned int *) gread(cread, sizeof(int), byte_rev, bit_rev));
        fread((void *) cread, 1, sizeof(int), fd);
        if (type == MATRIX)
          mat.n = *((unsigned int *) gread(cread, sizeof(int), byte_rev, bit_rev));
      } 

/*  Allocate memory for the matrix.  The amount needed is m * n * sizeof(double). */
/*  Next, read in the data all at once.  Then use gread to reverse */
/*  bytes/bits if necessary. */

    free(cread);

    mat.data = (double *) malloc(mat.m * mat.n * sizeof(double));
    fread((void *) mat.data, sizeof(double), mat.m * mat.n, fd);
    if (byte_rev || bit_rev)
      for(i = 0; i < mat.m * mat.n; i++)
        gread((unsigned char *) mat.data + (i * sizeof(double)), sizeof(double), 
               byte_rev, bit_rev);

    fclose(fd);

    return (mat);
   }




void gau5write(char *fmt, GMatrix mat) 
   {
/*  This ugly mess is the basic header. */

    unsigned int header[(BASIC_HEADER_LEN / sizeof(int)) + 2] = 
        {0xffffffff, 0, 0xffffffff, 0, 0xffffffff, 0, 0,
         0xabcdef01,1, 0, 1, 1008, sizeof(double), 0, 1,
         SCALAR, 1, 0, BASIC_HEADER_LEN};

    FILE *fd;

    if (sizeof(int) != 4 || sizeof(double) != 8 || CHAR_BIT != 8) 
       {
        printf("Incompatable machine architecture.\n");
        return;
       }

/*  If forward byte, make 6th int 0xffffffff. */
/*  If forward bit, make 7th int 0xffffffff. */

    if (BYTE_SYSTEM) header[BYTE_POS] = 0xffffffff;
    if (BIT_SYSTEM) header[BIT_POS] = 0xffffffff;

/*  If not a scalar, increase the 16th int by 1 and the 19th int (header */ 
/*  length) by 8 (2 * sizeof(int)).  Also, set m in int 33. */

    if (!(mat.m * mat.n == 1)) 
       {
        header[TYPE_POS] += 1;
        header[HEADER_LEN_POS] += (2 * sizeof(int));
        header[M_POS] = mat.m;

    /*  If not a vector (and not a scalar), increase the 16th int by 1 again */
    /*  and set m in int 34. */
        if (!(mat.n == 1)) 
           {
            header[TYPE_POS] += 1;
            header[N_POS] = mat.n;
           }
       }
  /*
  **Open fmt for writing and create if it does not exist.  If you create it,
  **make it a regular file with permissions 0640.  See comment in gau5read
  **for detail on how read (and similarly, write) work.
  **
  **Order: Write the basic header
  **       If not a scalar, write the other 2 ints of header 
  **       Write the m * n elements of data
  */

    fd = fopen(fmt, "wb"); 
    if ((mat.m * mat.n == 1))
      fwrite((void *) header, 1, BASIC_HEADER_LEN, fd);
    else
      fwrite((void *) header, 1, BASIC_HEADER_LEN + (2 * sizeof(int)), fd);
    fwrite((void *) mat.data, sizeof(double), mat.m * mat.n, fd);
    fclose(fd);
   }  
