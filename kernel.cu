
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include "cu_queue.cuh"
#include "myQueue.cuh"

#include "Lock.cuh"

#include <stdio.h>


cudaError_t cudaHelper();


__global__ void kernel(Lock* lck, cu_queue<int>* q) {
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	myQueue<int> m_q(lck, q);
	//int blockId = blockIdx.x + blockIdx.y * gridDim.x;
	//int i = blockId * (blockDim.x * blockDim.y) + (threadIdx.y * blockDim.x) + threadIdx.x;

	if (i == 0) {
		int firstVal = 0;
		m_q.push(firstVal);
	}
	else{
		m_q.push(i);	
	}
	
	__syncthreads();
}

int main()
{
	cudaError_t cudaStatus = cudaHelper();

	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "addWithCuda failed!");
		return 1;
	}
	cudaStatus = cudaDeviceReset();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaDeviceReset failed!");
		return 1;
	}

	return 0;
}

cudaError_t cudaHelper() {
	cudaError_t cudaStatus;
	cudaStatus = cudaSetDevice(0);

	cu_queue<int>* h_q = new cu_queue<int>();	//host queue
	cu_queue<int>* d_q;							//device queue
	Lock* h_lock = new Lock();
	Lock* d_lock;

	int* tmp_mutex; //to hold h_lock->mutex


	cudaStatus = cudaMalloc((void**)&d_q, sizeof(cu_queue<int>));
	cudaStatus = cudaMalloc((void**)&d_lock, sizeof(Lock));

	cudaStatus = cudaMalloc((void**)&tmp_mutex, sizeof(int));
	//cudaStatus = cudaMalloc((void**)&d_lock->mutex, 1 * sizeof(int)); //does not work

	/*IN GENERAL, members of a class must be copied manually into Device instances*/

	//Tricky trick to copy memory of a pointer within an pointer instance of a class
	cudaStatus = cudaMemcpy(tmp_mutex, h_lock->mutex, sizeof(int), cudaMemcpyHostToDevice); \

	cudaStatus = cudaMemcpy(d_q, h_q, sizeof(cu_queue<int>), cudaMemcpyHostToDevice);
	cudaStatus = cudaMemcpy(d_lock, h_lock, sizeof(Lock), cudaMemcpyHostToDevice);

	//Tricky trick to copy memory of a pointer within a pointer instance of a class
	cudaStatus = cudaMemcpy(&(d_lock->mutex), &tmp_mutex, sizeof(int*), cudaMemcpyHostToDevice);


	dim3 gridSize(32, 1, 1);	//Number of blocks
	dim3 blockSize(1, 1, 1);	//Number of threads per block, max=1024, depending on GPU

	kernel << <gridSize, blockSize >> > (d_lock, d_q);

	cudaStatus = cudaGetLastError();
	cudaStatus = cudaDeviceSynchronize();

	return cudaStatus;
}