#ifndef  MY_QUEUE_H
#define MY_QUEUE_H

#include "cu_queue.cuh"
#include "Lock.cuh"

template <typename TYPE>
class myQueue {
public:
	__host__ __device__ myQueue() {
		this->lck = nullptr;
		this->q = nullptr;
		this->SIZE = nullptr;
	}
	__host__ __device__ myQueue(Lock* lck, cu_queue<TYPE>* q) {
		this->lck = lck;
		this->q = q;
		this->SIZE = q->size();
	}
	__host__ __device__ bool push(TYPE const& value) {
		lck->lock();
		this->q->push(value);
		lck->unlock();
		return true;
	}

	__host__ __device__ size_t size() {
		return *(this->SIZE);
	}

	// deletes the retrieved element, do not use for non integral types
	__host__ __device__ bool pop(TYPE& v) {
		lck->lock();
		if ((this->q->empty())) {
			lck->unlock();
			return false;
		}
		v = this->q->front();
		this->q->pop();
		lck->unlock();
		return true;
	}
	__host__ __device__ bool empty() {
		lck->lock();
		bool val = this->q->empty();
		lck->unlock();
		return val;
	}
private:
	cu_queue<TYPE>* q;
	Lock* lck;
	size_t* SIZE;
};

#endif // ! MY_QUEUE_H
