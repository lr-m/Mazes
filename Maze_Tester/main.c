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

    int start_x = atoi(argv[4]);
    int start_y = atoi(argv[5]);
    int end_x = atoi(argv[6]);
    int end_y = atoi(argv[7]);

    int verbose = 0;

    int moves = 0;

    if (argc == 9){
        char *verboseFlag = argv[8];
        
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

    for(int i=0;i<=rows;i++){
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
    agent->xCo = start_x;
    agent->yCo = start_y;
    agent->target_x = end_x;
    agent->target_y = end_y;

    agent->direction = 1;
    agent->stack = stack;
    agent->popped = popped;
    agent->visited = hash;

    if (maze[end_y][end_x] == '#'){
        printf("\nTarget is in a wall, exiting...");
        return 0;
    }

    if (maze[start_y][start_x] == '#'){
        printf("\nStart is in a wall, exiting");
        return 0;
    }

    // Solve the maze
    solve(agent, rows, cols, maze, &moves);

    // Print the solution of the maze and the solution on the maze
    if (verbose == 1){
        printf("\nSolution:\n");
        printStack(agent);

        printf("\nSolution on maze:\n");

        struct element* currPos = agent->stack->head;

        for (int i = 0; i < agent->stack->size-1; i++){
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

    printf("\nAgent Moves: %d \nSolution Length: %ld\n", moves, agent->stack->size);

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

