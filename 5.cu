#include<iostream>
#include<cuda.h>
#include<cuda_runtime.h>
#include<ctime>
#include<cstdlib>
#include<cstdio>
#include<unistd.h>
#include<chrono>
#include<omp.h>
#include<cmath>
#include<thrust/host_vector.h>
#include<thrust/device_vector.h>


using namespace std;

__global__ void sum(thrust::device_vector<float>* v1, 
	thrust::device_vector<float>* v2, float* sum, size_t n)
{
	size_t id = blockIdx.x*blockDim.x + threadIdx.x;
	sum[0] += v1[id]+v2[id];
}

float prng(int N=100)
{
	srand(getppid()*int(clock())*rand());
	float r = N*float(rand())/float(RAND_MAX);
	return r;
}

int main(int argc, char* argv[])
{
	//system("clear");

	size_t n = 2e1;
	float *sum = malloc(sizeof(float));
	float *dev_sum;

	if(argc>1)
	{
		n = (size_t)atoi(argv[1]);
	}

	thrust::host_vector<float> hv1(n,0);
	thrust::host_vector<float> hv2(n,0);
	thrust::device_vector<float> dv1(n,0);
	thrust::device_vector<float> dv2(n,0);

	cudaMalloc((void**)&dev_sum, sizeof(float));

	for(size_t i=0;i<n;i++)
	{
		hv1[i] = 1;
		hv2[i] = 1;
	}

	dv1 = hv1; dv2 = hv2;
	cudaMemcpy(dev_sum, &sum, sizeof(sum), cudaMemcpyHostToDevice);
	sum<<<1+(n/256)>>>(dv1, dv2, dev_sum, n);
	cudaMemcpy(&sum, dev_sum, sizeof(sum), cudaMemcpyDeviceToHost);

	cout<<"Sum= "<<sum<<endl;

	return 0;
}