#include <stdio.h>
#include <stdlib.h>

#include "stack.h"

/**
 * Removes the first element of the queue.
 * @param queue A pointer to the queue that should have the first element 
 * removed.
 * @return Pointer to the removed element.
 */
struct element * pop(struct stack * stack) {
  if (stack -> size == 0){
    return NULL;
  } else if (stack -> size == 1){
    stack -> size = 0;
    
    struct element * old_head = stack -> head;
    
    stack -> head = NULL;
    
    stack -> tail = NULL;
    
    return old_head;
  } else {
    struct element * old_tail = stack -> tail;
    
    stack -> tail = old_tail -> previous;
    
    old_tail->previous->next = NULL;
    
    old_tail->previous = NULL;
    
    stack -> size -= 1;

    return old_tail;
  }
}

/**
 * Creates an element containing the passed header and packet, and adds this 
 * created element to the end of the queue.
 * @param queue A pointer to the queue that the element should be added to.
 * @param header A pointer to the header that should be stored in the added 
 * element.
 * @param packet A pointer to the packet that should be stored in the added 
 * element.
 */
void push(struct stack * stack, int xCo, int yCo) {
  if (stack -> size == 0) {
    struct element * elem = malloc(sizeof(struct element));
    elem -> xCo = xCo;
    elem -> yCo = yCo;

    stack -> head = elem;
    stack -> tail = elem;
    stack -> size = 1;
  } else if (stack -> size > 0){
    struct element * elem_to_add = malloc(sizeof(struct element));

    elem_to_add -> xCo = xCo;
    elem_to_add -> yCo = yCo;

    elem_to_add -> previous = stack -> tail;
    stack -> tail -> next = elem_to_add;
    stack -> tail = elem_to_add;
    stack -> size += 1;
  }
}

void pushElement(struct stack * stack, struct element * elem) {
  if (stack -> size == 0) {
    stack -> head = elem;
    stack -> tail = elem;
    stack -> size = 1;
  } else if (stack -> size > 0){
    elem -> previous = stack -> tail;
    stack -> tail -> next = elem;
    stack -> tail = elem;
    stack -> size += 1;
  }
}

/**
 * Frees the memory used by all of the nodes in the queue.
 * @param queue A pointer to the queue that should be freed.
 */
void free_stack(struct stack * stack) {
  while (stack -> size > 0) {
    struct element * removed = pop(stack);
    free(removed);
  }
}