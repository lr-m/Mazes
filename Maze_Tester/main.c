#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "stack.h"
#include "agent.h"
#include "hash.h"

int main(int argc, char *argv[])
{
    char *filename = malloc(100);
    
    FILE *file;

    // Get passed arguments
    int cols = atoi(argv[2]);
    int rows = atoi(argv[3]);
    int startX = atoi(argv[4]);
    int startY = atoi(argv[5]);
    int endX = atoi(argv[6]);

    char maze[rows][cols];
    int endY = atoi(argv[7]);

    int verbose = 0;
    int moves = 0;

    int leftSolveIterations = 0;
    int rightSolveIterations = 0;

    // Copy maze into file
    strcpy(filename, argv[1]);

    // Check verbose
    if (argc == 9){
        char *verboseFlag = argv[8];
        
        if (*verboseFlag == 'v'){
            verbose = 1;
        }

        printf("Arguments:\n");
        printf("Filename: %s\n", filename);
        printf("Number of Columns: %d\n", cols);
        printf("Number of Rows: %d\n", rows);
        printf("Start Coordinates: [ %d, %d ]\n", startX, startY);
        printf("End Coordinates: [ %d, %d ]\n", endX, endY);
    }
    
    file = fopen(filename, "r");

    for(int i=0;i<rows;i++){
        fscanf(file, "%s", (char*) &maze[i]);
    }

    // Display imported maze
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

    if (maze[startX][startY] == '#'){
        printf("\nERROR:\nProvided start coordinates map to a wall.\n");
        exit(0);
    }

    if (maze[endX][endY] == '#'){
        printf("\nERROR:\nProvided end coordinates map to a wall.\n");
        exit(0);
    }

    // Set up agent
    
    struct stack *stack = (struct stack*) malloc(sizeof(struct stack));
    struct stack *popped = (struct stack*) malloc(sizeof(struct stack));

    stack->size = 0;
    popped->size = 0;

    struct hash *hash = (struct hash*) malloc(sizeof(struct hash));

    int *hashArray = (int*) calloc(rows * cols, sizeof(int));

    hash -> array = hashArray;
    
    struct solver_agent *agent = (struct solver_agent*) malloc(sizeof(struct solver_agent));

    agent->xCo = startX;
    agent->yCo = startY;
    agent->direction = 2;
    agent->stack = stack;
    agent->popped = popped;
    agent->visited = hash;

    // Solve the maze using left-first DFS
    left_solve(agent, rows, cols, maze, &moves, startX, startY, endX, endY);

    leftSolveIterations = moves;

    // Free memory used in left-first DFS
    free(hashArray);
    free_stack(stack);
    free(stack);
    free_stack(popped);
    free(popped);
    free(hash);
    free(agent);
    free(filename);

    // Reset agent and perfrom right-first DFS
    stack = (struct stack*) malloc(sizeof(struct stack));
    popped = (struct stack*) malloc(sizeof(struct stack));
    
    stack->size = 0;
    popped->size = 0;

    hash = (struct hash*) malloc(sizeof(struct hash));

    hashArray = (int*) calloc(rows * cols, sizeof(int));

    hash -> array = hashArray;
    
    agent = (struct solver_agent*) malloc(sizeof(struct solver_agent));
    agent->xCo = startX;
    agent->yCo = startY;
    agent->direction = 2;
    agent->stack = stack;
    agent->popped = popped;
    agent->visited = hash;

    moves = 0;

    // Solve the maze using right-first DFS
    right_solve(agent, rows, cols, maze, &moves, startX, startY, endX, endY);

    // Print the solution of the maze and the solution on the maze
    if (verbose == 1){
        printf("\nSolution:\n");
        printStack(agent);

        printf("\nSolution on maze:\n");

        struct element* currPos = agent->stack->head;

        int counter = 0;

        while(counter < stack->size - 1){
            maze[currPos->yCo][currPos->xCo] = 's';
            currPos = currPos->next;
            counter++;
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

    // Print summary of analysis
    if (verbose == 0){
        printf("%d %d %ld\n", leftSolveIterations, moves, agent->stack->size);
    } else {
        printf("\nAnalysis Summary:\n");
        printf("Left-First Solver Iterations: %d\n", leftSolveIterations);
        printf("Right-First Solver Iterations: %d\n", moves);
        printf("Solution Length: %ld\n", agent->stack->size);
    }

    // Free memory
    free(hashArray);
    free_stack(stack);
    free(stack);
    free_stack(popped);
    free(popped);
    free(hash);
    free(agent);

    // Close file
    fclose(file);
}

