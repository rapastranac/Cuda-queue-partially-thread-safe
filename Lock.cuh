#ifndef LOCK_H
#define LOCK_H

#include <cuda.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>

/*This lock does not work for threads within same warp,
	It will lead to a deadlock*/
struct Lock
{
	int* mutex;
	__host__ __device__ Lock() {
		mutex = new int(0); //It has to be zero
	}
	__host__ __device__ ~Lock()
	{
		delete mutex;
	}

	__host__ __device__ void lock()
	{
		//This condition allows to ignore when compiling on host
		//printf("Mutex : %d \n", *mutex);
		#if __CUDA_ARCH__ >= 200
		while (atomicCAS(mutex, 0, 1) != 0);
		//printf("Mutex acquired by thread : %d \n", i);
		#endif
	}
	__host__ __device__ void unlock()
	{
		#if __CUDA_ARCH__ >= 200
		atomicExch(mutex, 0);
		//printf("Mutex released by thread : %d\n",i );
		#endif
	}
};

#endif // !LOCK_H