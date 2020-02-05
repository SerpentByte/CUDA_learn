#include<iostream>
#include<ctime>
#include<cstdlib>
#include<cstdio>
#include<unistd.h>
#include<chrono>

using namespace std;

int prng(int N=100)
{
	srand(getppid()*int(clock())*rand());
	int r = int(N*float(rand())/float(RAND_MAX));
	return r;
}

int* scalar_add(int *a, int*b, int n)
{
	int* c = (int*)malloc(n*sizeof(int));
	for(unsigned long long int i=0;i<n;i++)
	{
		c[i]=a[i]+b[i];
	}

	return c;
}

void display(int *A, int n)
{
	for(unsigned long long int i=0;i<n;i++)
	{
		cout<<A[i]<<' ';
	}
	cout<<endl;
}

int main(int argc, char* argv[])
{
	system("clear");

	unsigned long long int n = 1e7;
	if(argc>1)
	{
		n = (unsigned long long int)atoi(argv[1]);
	}
	int *a = (int*)malloc(n*sizeof(int));
	int *b = (int*)malloc(n*sizeof(int));
	int *c = (int*)malloc(n*sizeof(int));

	for(unsigned long long int i=0;i<n;i++)
	{
		a[i] = prng();
		b[i] = prng();
		c[i] = 0;
	}

	auto start = chrono::high_resolution_clock::now();
	c = scalar_add(a,b,n);
	auto end = chrono::high_resolution_clock::now();

	double exec_t = chrono::duration_cast<chrono::microseconds>(end-start).count();
	
	cout<<"n = "<<n<<endl<<"Time taken = "<<exec_t<<" us\n";

	free(a); free(b); free(c);

	return 0;
}