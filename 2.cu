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

__global__ void add_arrays(int *a, int *b, int n)
{
	int id = blockIdx.x*blockDim.x+threadIdx.x;
	if(id<n)
	{
		a[id]+=1;
	}
}

int main()
{
	system("clear");

	unsigned long long int n = 10;
	int *a = (int*)malloc(n*sizeof(int));
	int *b = (int*)malloc(n*sizeof(int));
	int *c = (int*)malloc(n*sizeof(int));

	for(unsigned long long int i=0;i<n;i++)
	{
		a[i] = prng();
		b[i] = prng();
		c[i] = a[i];
	}

	int *dev_a, *dev_b;//, *dev_c;

	if(cudaMalloc((void**)&dev_a, sizeof(int)*n)==cudaSuccess
		&& cudaMalloc((void**)&dev_b, sizeof(int)*n)==cudaSuccess)
		//&& cudaMalloc((void**)&dev_c, sizeof(int)*n)==cudaSuccess)
	{
		NULL;
	}
	else
	{
		cout<<"Failed to allocate memory on device. Exiting.";
		exit(0);
	}

	cudaMemcpy(dev_a, &a, sizeof(a)*n,cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, &b, sizeof(b)*n,cudaMemcpyHostToDevice);
	//cudaMemcpy(dev_c, &c, sizeof(c)*n,cudaMemcpyHostToDevice);

	add_arrays<<<1,n>>>(dev_a, dev_b, n);
	cudaMemcpy(&a, dev_a, sizeof(c)*n,cudaMemcpyDeviceToHost);


	for(unsigned long long int i=0;i<n;i++)
	{
		//cout<<a[i]<<'+'<<b[i]<<"="<<c[i]<<endl;
		cout<<c[i]<<' '<<a[i]<<endl;
	}

	free(a); free(b); free(c);
	cudaFree(dev_a); cudaFree(dev_b); //cudaFree(dev_c);

	return 0;
}