#include<iostream>
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

void display(int *A, int n)
{
	for(size_t i=0;i<n;i++)
	{
		cout<<A[i]<<' ';
	}
	cout<<endl;
}


int main(int argc, char* argv[])
{
	system("clear");

	size_t n = 2e1;
	double d = 0, distance;
	if(argc>1)
	{
		n = (size_t)atoi(argv[1]);
	}

	xyz* points = (xyz*)(malloc(sizeof(xyz)*n));
	int* nn = (int*)(malloc(sizeof(int)*n));

	for(size_t i=0;i<n;i++)
	{
		points[i].x = prng();
		points[i].y = prng();
		points[i].z = prng();
		nn[i] = 0;
	}

	auto start = chrono::high_resolution_clock::now();
	for(size_t i=0;i<n;i++)
	{
		d = 1e37;
		for(size_t j=0;j<n;j++)
		{
			if(i!=j)
			{
				distance = pow((points[i].x-points[j].x),2);
				distance += pow((points[i].y-points[j].y),2);
				distance += pow((points[i].z-points[j].z),2);
				//distance = sqrt(distance);

				if(distance<d)
				{
					nn[i] = j+1;
					d = distance;
				}				
			}			
		}
	}
	auto end = chrono::high_resolution_clock::now();

	//display(nn, n);
	double exec_t = chrono::duration_cast<chrono::microseconds>(end-start).count();
	cout<<"n = "<<n<<endl<<"Time taken = "<<exec_t<<" us\n";

	return 0;
}