#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "stack.h"
#include "agent.h"
#include "hash.h"

int main(int argc, char *argv[])
{
    char *filename = malloc(100);
    strcpy(filename, argv[1]);
    int cols = atoi(argv[2]);
    int rows = atoi(argv[3]);

    int verbose = 0;

    int moves = 0;

    if (argc == 5){
        char *verboseFlag = argv[4];
        
        if (*verboseFlag == 'v'){
            verbose = 1;
        }
    }
    
    if (verbose == 1){
        printf("Arguments:\n");
        printf("Filename: %s\n", filename);
        printf("Number of columns: %d\n", cols);
        printf("Number of rows: %d\n", rows);
    }
    
    FILE *file;
    file = fopen(filename, "r");
    char maze[rows][cols];

    for(int i=0;i<rows;i++){
        fscanf(file, "%s", (char*) &maze[i]);
    }

    if (verbose == 1){
        printf("\nImported Maze:\n");

        for (int i = 0; i < rows; i++){
            for (int j = 0; j < cols; j++){
                if (maze[i][j] == '#'){
                    printf("# ");
                } else {
                    printf("- ");
                }
            }
            printf("\n");
        }
    }
    
    struct stack *stack = (struct stack*) malloc(sizeof(struct stack));
    struct stack *popped = (struct stack*) malloc(sizeof(struct stack));
    stack->size = 0;
    popped->size = 0;

    struct hash *hash = (struct hash*) malloc(sizeof(struct hash));

    int *hashArray = (int*) calloc(rows * cols, sizeof(int));

    hash -> array = hashArray;
    
    struct solver_agent *agent = (struct solver_agent*) malloc(sizeof(struct solver_agent));
    agent->xCo = 1;
    agent->yCo = 1;
    agent->direction = 1;
    agent->stack = stack;
    agent->popped = popped;
    agent->visited = hash;

    // Solve the maze
    solve(agent, rows, cols, maze, &moves);

    // Print the solution of the maze and the solution on the maze
    if (verbose == 1){
        printf("\nSolution:\n");
        printStack(agent);

        printf("\nSolution on maze:\n");


        struct element* currPos = agent->stack->head;

        while(currPos->next != NULL){
            maze[currPos->yCo][currPos->xCo] = 's';
            currPos = currPos->next;
        }
        maze[currPos->yCo][currPos->xCo] = 's';

        for (int i = 0; i < rows; i++){
            for (int j = 0; j < cols; j++){
                if (maze[i][j] == '#'){
                    printf("# ");
                } else if (maze[i][j] == '-'){
                    printf("- ");
                } else {
                    printf("%c ", maze[i][j]);
                }
            }
            printf("\n");
        }
    }

    printf("%d %ld\n", moves, agent->stack->size);

    // Free memory
    free(hashArray);
    free_stack(stack);
    free(stack);
    free_stack(popped);
    free(popped);
    free(hash);
    free(agent);
    free(filename);

    // Close file
    fclose(file);
}

