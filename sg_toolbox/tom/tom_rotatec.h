

/* switch betwenn mex and C */
#define MATLAB  
/*#define ANSI_C*/

#define	 PI ((double)3.14159265358979323846264338327950288419716939937510)

/* Input Arguments */
#ifdef MATLAB  
	#define    INP    prhs[0]
	#define    OUT    prhs[1]	
	#define    EULER  prhs[2]
	#define    INT    prhs[3]
	#define    CENT   prhs[4]
#endif


void rot2d (float *,float *,long,long,float,char,float,float);
void rot3d (float *,float *,long,long,long,float,float,float,char,float,float,float);