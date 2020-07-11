#ifndef CU_QUEUE_H
#define CU_QUEUE_H


template <class T>
class cu_queue
{
public:
	struct Node {
		T val;
		Node* head = nullptr;
		Node* tail = nullptr;
		__host__ __device__ Node() {}
		__host__ __device__ Node(Node* head, const T& val) {
			this->val = val;
			this->head = head;
		}

		__host__ __device__ ~Node() {
			if (tail) {
				delete tail;
			}
		}
	};

	__host__ __device__ T front() {
		if (node) {
			return node->val;
		}
		else {
			printf("front() called on empty deque");
		}
		return NULL;
	}

	__host__ __device__ T back() {
		if (last)
			return last->val;
		else
			printf("back() called on empty deque");
	}

	__host__ __device__ void pop() {
		if (SIZE == 0) {
			printf("pop() called on empty deque");
			return;
		}

		if (node->tail) {
			Node* _node = node->tail;
			_node->head = nullptr;
			node->tail = nullptr;
			delete node;
			node = _node;
			--this->SIZE;
			return;
		}
		delete node;
		//atomicSub(SIZE, 1);
		--this->SIZE;
	}

	__host__ __device__ void push(const T& val) {
		if (!node) {
			node = new Node();
			node->val = val;
			last = node;
			//atomicAdd(SIZE, 1);
			++SIZE;
			return;
		}
		last->tail = new Node(last, val);
		last = last->tail;

		//atomicAdd(SIZE, 1);
		++this->SIZE;
	}

	__host__ __device__ bool empty() {
		if (SIZE == 0)
			return true;
		else
			return false;
	}

	__host__ __device__ size_t* size() {
		return &this->SIZE;
	}

	__host__ __device__ cu_queue() {
		this->node = nullptr;;
		this->last = nullptr;
		this->SIZE = 0;
	}
	__host__ __device__ ~cu_queue() {
		delete node;
		delete last;
	}

private:
	Node* node;
	Node* last;
	size_t SIZE;
};


#endif // !CU_QUEUE_H

