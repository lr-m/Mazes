#include "hash.h"

int inHash(struct hash *hash, int xCo, int yCo, int cols){
    return *(hash->array + getHashIndex(xCo, yCo, cols));
}

int getHashIndex(int xCo, int yCo, int cols){
    return (yCo * cols) + xCo;
}

void addToHash(struct hash *hash, int xCo, int yCo, int cols){
    *((hash->array) + getHashIndex(xCo, yCo, cols)) = 1;
}