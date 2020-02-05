#include<iostream>
#include "cuda.h"
#include "cuda_runtime.h"
#include<ctime>
#include<cstdlib>
#include<cstdio>
#include<unistd.h>

using namespace std;

int prng(int N=100)
{
	srand(getppid()*int(clock())*rand());
	int r = int(N*float(rand())/float(RAND_MAX));
	return r;
}

__global__ void add(int *a, int *b)
{
	a[0] += b[0];
}



int main()
{

	int a = 3, b = 5; 
	cout<<"Enter value of a: "; cin>>a;
	cout<<"Enter value of b: "; cin>>b;
	int *dev_a, *dev_b;

	cudaMalloc((void**)&dev_a, sizeof(int));
	cudaMalloc((void**)&dev_b, sizeof(int));
	cudaMemcpy(dev_a, &a, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, &b, sizeof(int), cudaMemcpyHostToDevice);

	add<<<1,1>>>(dev_a, dev_b);
	cudaMemcpy(&a, dev_a, sizeof(int), cudaMemcpyDeviceToHost);

	cout<<"a+b = "<<a<<endl;
	cudaFree(dev_a);
	cudaFree(dev_b);


	return 0;
}