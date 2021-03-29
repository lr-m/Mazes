struct hash{
    int size;
    int *array;
};

int inHash(struct hash *hash, int xCo, int yCo, int rows);

int getHashIndex(int xCo, int yCo, int rows);

void addToHash(struct hash *hash, int xCo, int yCo, int rows);