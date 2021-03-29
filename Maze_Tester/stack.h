/**
 * Struct that makes up the Queue used in the multithreading implementation.
 */
struct element {
  struct element * next;
  struct element * previous;
  int xCo;
  int yCo;
};

/**
 * Struct that holds a pointer to the head and the tail of the queue, as well 
 * as the size of the queue.
 */
struct stack {
  struct element * head;
  struct element * tail;
  long int size;
};

struct element * pop(struct stack * stack);

void push(struct stack * stack, int xCo, int yCo);

void pushElement(struct stack * stack, struct element * element);

void free_stack(struct stack * stack);