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

using namespace std;

struct xyz
{
	double x, y ,z;
	xyz()
	{
		x=0; y=0; z=0;
	}

	xyz(double a, double b, double c)
	{
		x=a; y=b; z=c;
	}
};

float prng(int N=100)
{
	srand(getppid()*int(clock())*rand());
	float r = N*float(rand())/float(RAND_MAX);
	return r;
}

__global__ void nearest(xyz* points, int* nn, int n)
{
	if(n<=1)
	{
		return;
	}
	int id = blockIdx.x * blockDim.x + threadIdx.x;

	xyz priv_point;

	if(id<n)
	{
		priv_point = points[id];
		double d = 1e37, distance=0;;
		for(size_t i=0;i<n;i++)
		{
			if(i==id) continue;
			distance = pow((priv_point.x - points[i].x),2);
			distance += pow((priv_point.y - points[i].y),2);
			distance += pow((priv_point.z - points[i].z),2);
			//distance = sqrt(distance);
			if(distance<d)
			{
				nn[id] = i+1;
				d = distance; 
			}
		}
	}

}


int main(int argc, char* argv[])
{
	//system("clear");

	size_t n = 2e1;
	if(argc>1)
	{
		n = (size_t)atoi(argv[1]);
	}

	xyz* points = (xyz*)(malloc(sizeof(xyz)*n));
	int* nn = (int*)(malloc(sizeof(int)*n));

	xyz* dev_points;
	int* dev_nn;

	for(size_t i=0;i<n;i++)
	{
		points[i].x = prng();
		points[i].y = prng();
		points[i].z = prng();
		nn[i] = 0;
	}

	cudaMalloc((void**)&dev_points, sizeof(xyz)*n);
	cudaMalloc((void**)&dev_nn, sizeof(int)*n);

	cudaMemcpy(dev_points, points, sizeof(xyz)*n, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_nn, nn, sizeof(int)*n, cudaMemcpyHostToDevice);

	auto start = chrono::high_resolution_clock::now();
	nearest<<<1+(n/256),n>>>(points, nn, n);
	auto end = chrono::high_resolution_clock::now();

	double exec_t = chrono::duration_cast<chrono::nanoseconds>(end-start).count();
	cudaMemcpy(nn, dev_nn, sizeof(int)*n, cudaMemcpyDeviceToHost);

	cout<<"Time taken = "<<exec_t<<" ns\n";

	free(points); free(nn);
	cudaFree(dev_points); cudaFree(dev_nn);

	return 0;
}