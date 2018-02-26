#include <iostream>
#include <math.h>
#include <stdlib.h>
#include <assert.h>

// Kernel function to add the elements of two arrays
__global__
void add(int n, float *x, float *y)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;
  for (int i = index; i < n; i += stride)
    y[i] = x[i] + y[i];
}

typedef struct {
  int width;
  int height;
  float * elements;
} Matrix;


Matrix initMatrix(int height, int width) {
  Matrix A;
  A.width = width;
  A.height = height;
  A.elements = (float*)malloc(width * height * sizeof(float));
  return A;
}

void setRandom(Matrix A) {
  for (int i = 0; i < A.height; i++)
    for (int j = 0; j < A.width; j++)
      A.elements[i*A.width + j] = (float)(rand() % 3);
}

void printMatrix(Matrix A){
  for (int i = 0; i < A.height; i++)
    for(int j = 0; j < A.width; j++) {
	  if ( j == 0 ) printf("\n");
	  printf(" %f ", A.elements[i*A.width + j]);
	}
  printf("\n");
}

float cell(Matrix A, int row, int column) {
	return A.elements[row * A.width + column];
}

Matrix allocateMatrixToDevice(Matrix A) {
	Matrix d_A;
	d_A.width = A.width;
	d_A.height = A.height;
	size_t size = A.width * A.height * sizeof(float);
	cudaError_t err = cudaMalloc(&d_A.elements, size);
	printf("CUDA malloc Matrix : %s\n", cudaGetErrorString(err));
	err = cudaMemcpy(d_A.elements, A.elements, size, cudaMemcpyHostToDevice);
	printf("Copy Matrix to device: %s\n",cudaGetErrorString(err));
	return d_A;
}

__global__ void MatMulKernel(Matrix A, Matrix B, Matrix C) {
  
  float Cvalue = 0.0;
  
  /* calculate value for C(row, column) */
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  
  /* not all threads in grid need return a value, as C may not fit exactly the grid */
  if (row > A.height || col > B.width) return;
  
  /* we are using Row Major representation for the matrix */
  for (int e = 0; e < A.width; ++e) {
	int a = row * A.width + e; /* row major, so just add e to index*/
	int b = e * B.width + col; /* row major, so multiply index by e */
    Cvalue += (A.elements[a] * B.elements[b]);
  }
  C.elements[row * C.width + col] = Cvalue;
}

void matmul(Matrix A, Matrix B, Matrix C) {

    /* copy the matrices to the GPU */
	Matrix d_A = allocateMatrixToDevice(A);
	Matrix d_B = allocateMatrixToDevice(B);
	Matrix d_C = allocateMatrixToDevice(C);
	
	/* specify 2 dimensional blocks of 16 x 16 = 256 threads per block */
	dim3 dimBlock(16,16);
	
	/* calculate how many blocks we need to perform the calculation */
	/* the grid is based on the size of the product matrix */
	/* ie: A(2,3) * B(3,4) = C(2,4) */
	/* A(height,width) * B(height,width) = C(A height, B width) */
	dim3 dimGrid(
	            ( (B.width + dimBlock.x - 1 ) / dimBlock.x),
				( (A.height + dimBlock.y -1 ) / dimBlock.y)
				);
	
	/* launch a grid and run the kernel function*/
	MatMulKernel<<<dimGrid, dimBlock>>>(d_A,d_B,d_C);
	
	/* wait for all threads to finish */
	cudaError_t err = cudaThreadSynchronize();
	
	err = cudaMemcpy(C.elements, d_C.elements, C.height * C.width * sizeof(float), cudaMemcpyDeviceToHost);
	cudaFree(d_A.elements);
	cudaFree(d_B.elements);
}



int main(void)
{
  Matrix A = initMatrix(4,4);
  Matrix B = initMatrix(4,4);
  Matrix C = initMatrix(4,4);
  
  setRandom(A);
  setRandom(B);
  
  printMatrix(A);
  printMatrix(B);
  
  matmul(A,B,C);
  printMatrix(C);

  float c_0_0 = cell(A,0,0) * cell(B,0,0) + cell(A,0,1) * cell(B,1,0) + cell(A,0,2) * cell(B,2,0) + cell(A,0,3) * cell(B,3,0);
  printf("%f\n", c_0_0);
  assert(c_0_0 == cell(C,0,0));
  
}
