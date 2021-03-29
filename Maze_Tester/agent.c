#include <stdio.h>
#include <stdlib.h>

#include "agent.h"
#include "stack.h"
#include "hash.h"

void solve(struct solver_agent *agent, int rows, int cols, char maze[rows][cols], int* moves){
    int backtracking = 0;
    addToHash(agent -> visited, agent -> xCo, agent -> yCo, cols);
    while (agent -> yCo < rows-2 | agent -> xCo < cols-2){   
        *moves+=1;
        if (backtracking == 0){
            if (getCharLeftOfAgent(agent, rows, cols, maze) == '-'){
                pushToStack(agent, agent -> xCo, agent -> yCo);
                turnAgentLeft(agent);
                moveAgentForward(agent);
                addToHash(agent -> visited, agent -> xCo, agent -> yCo, cols);
                continue;
            }

            if (getCharAheadOfAgent(agent, rows, cols, maze) == '-'){
                pushToStack(agent, agent -> xCo, agent -> yCo);
                moveAgentForward(agent);
                addToHash(agent -> visited, agent -> xCo, agent -> yCo, cols);
                continue;
            }

            if (getCharRightOfAgent(agent, rows, cols, maze) == '-'){
                pushToStack(agent, agent -> xCo, agent -> yCo);
                turnAgentRight(agent);
                moveAgentForward(agent);
                addToHash(agent -> visited, agent -> xCo, agent -> yCo, cols);
                continue;
            }

            addToHash(agent -> visited, agent -> xCo, agent -> yCo, cols);
            pushToStack(agent, agent -> xCo, agent -> yCo);

            backtracking = 1;
            turnAround(agent);
        } else {
            int* assessXCo = malloc(sizeof(*assessXCo));
            int* assessYCo = malloc(sizeof(*assessYCo));
            
            if (getCharLeftOfAgent(agent, rows, cols, maze) == '-'){

                getLeftOfAgentCoordinates(agent, assessXCo, assessYCo);
                if (inHash(agent -> visited, *assessXCo, *assessYCo, cols) == 0){
                    turnAgentLeft(agent);
                    moveAgentForward(agent);

                    backtracking = 0;
                    addToHash(agent -> visited, agent -> xCo, agent -> yCo, cols);

                    free(assessYCo);
                    free(assessXCo);
                    continue;
                } else {
                    turnAgentLeft(agent);
                    moveAgentForward(agent);
                    struct element * removed = popFromStack(agent);
                    addToHash(agent -> visited, agent -> xCo, agent -> yCo, cols);

                    free(assessYCo);
                    free(assessXCo);
                    pushElement(agent->popped, removed);
                    continue;
                }
            }

            

            if (getCharAheadOfAgent(agent, rows, cols, maze) == '-'){
                getAheadOfAgentCoordinates(agent, assessXCo, assessYCo);
                if (inHash(agent -> visited, *assessXCo, *assessYCo, cols) == 0){
                    moveAgentForward(agent);

                    backtracking = 0;
                    addToHash(agent -> visited, agent -> xCo, agent -> yCo, cols);

                    free(assessYCo);
                    free(assessXCo);
                    continue;
                } else {
                    moveAgentForward(agent);

                    struct element * removed = popFromStack(agent);
                    addToHash(agent -> visited, agent -> xCo, agent -> yCo, cols);

                    free(assessYCo);
                    free(assessXCo);
                    pushElement(agent->popped, removed);
                    continue;
                }
            }
            

            if (getCharRightOfAgent(agent, rows, cols, maze) == '-'){
                getRightOfAgentCoordinates(agent, assessXCo, assessYCo);
                if (inHash(agent -> visited, *assessXCo, *assessYCo, cols) == 0){
                    turnAgentRight(agent);
                    moveAgentForward(agent);

                    backtracking = 0;
                    addToHash(agent -> visited, agent -> xCo, agent -> yCo, cols);

                    free(assessYCo);
                    free(assessXCo);
                    continue;
                } else {
                    turnAgentRight(agent);
                    moveAgentForward(agent);

                    struct element * removed = popFromStack(agent);
                    addToHash(agent -> visited, agent -> xCo, agent -> yCo, cols);

                    free(assessYCo);
                    free(assessXCo);
                    pushElement(agent->popped, removed);
                    continue;
                }
            }

            free(assessYCo);
            free(assessXCo);
        }
    }
    pushToStack(agent, agent -> xCo, agent -> yCo);
}

void getLeftOfAgentCoordinates(struct solver_agent *agent, int *x, int *y){
    if (agent -> direction == 0){
        *x = (agent -> xCo) - 1;
        *y = (agent -> yCo);
    } else if (agent -> direction == 1){
        *x = (agent -> xCo);
        *y = (agent -> yCo) - 1;
    } else if (agent -> direction == 2){
        *x = (agent -> xCo) + 1;
        *y = (agent -> yCo);
    } else if (agent -> direction == 3){
        *x = (agent -> xCo);
        *y = (agent -> yCo) + 1;
    }
}

void getAheadOfAgentCoordinates(struct solver_agent *agent, int *x, int *y){
    if (agent -> direction == 0){
        *x = (agent -> xCo);
        *y = (agent -> yCo) - 1;
    } else if (agent -> direction == 1){
        *x = (agent -> xCo) + 1;
        *y = (agent -> yCo);
    } else if (agent -> direction == 2){
        *x = (agent -> xCo);
        *y = (agent -> yCo) + 1;
    } else if (agent -> direction == 3){
        *x = (agent -> xCo) - 1;
        *y = (agent -> yCo);
    }
}

void getRightOfAgentCoordinates(struct solver_agent *agent, int *x, int *y){
    if (agent -> direction == 0){
        *x = (agent -> xCo) + 1;
        *y = (agent -> yCo);
    } else if (agent -> direction == 1){
        *x = (agent -> xCo);
        *y = (agent -> yCo) + 1;
    } else if (agent -> direction == 2){
        *x = (agent -> xCo) - 1;
        *y = (agent -> yCo);
    } else if (agent -> direction == 3){
        *x = (agent -> xCo);
        *y = (agent -> yCo) - 1;
    }
}

void turnAround(struct solver_agent *agent){
    agent -> direction += 2;

    if (agent -> direction > 3){
        agent -> direction -= 4;
    }
}

char getCharAheadOfAgent(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]){
    if (agent -> direction == 0){
        return(getCharUp(agent, rows, cols, maze));
    } else if (agent -> direction == 1){
        return(getCharRight(agent, rows, cols, maze));
    } else if (agent -> direction == 2){
        return(getCharDown(agent, rows, cols, maze));
    } else if (agent -> direction == 3){
        return(getCharLeft(agent, rows, cols, maze));
    }
}

char getCharRightOfAgent(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]){
    if (agent -> direction == 0){
        return(getCharRight(agent, rows, cols, maze));
    } else if (agent -> direction == 1){
        return(getCharDown(agent, rows, cols, maze));
    } else if (agent -> direction == 2){
        return(getCharLeft(agent, rows, cols, maze));
    } else if (agent -> direction == 3){
        return(getCharUp(agent, rows, cols, maze));
    }
}

char getCharLeftOfAgent(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]){
    if (agent -> direction == 0){
        return(getCharLeft(agent, rows, cols, maze));
    } else if (agent -> direction == 1){
        return(getCharUp(agent, rows, cols, maze));
    } else if (agent -> direction == 2){
        return(getCharRight(agent, rows, cols, maze));
    } else if (agent -> direction == 3){
        return(getCharDown(agent, rows, cols, maze));
    }
}

void turnAgentRight(struct solver_agent *agent){
    agent-> direction += 1;

    if (agent -> direction == 4){
        agent -> direction = 0;
    }
}

void turnAgentLeft(struct solver_agent *agent){
    agent-> direction -= 1;

    if (agent -> direction == -1){
        agent -> direction = 3;
    }
}

void moveAgentForward(struct solver_agent *agent){
    int dir = agent -> direction;

    if (dir == 0){
        moveAgentUp(agent);
    } else if (dir == 1){
        moveAgentRight(agent);
    } else if (dir == 2){
        moveAgentDown(agent);
    } else if (dir == 3){
        moveAgentLeft(agent);
    }
}

char getCharUp(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]){
    return maze[(agent->yCo) - 1][agent->xCo];
}

char getCharRight(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]){
    return maze[agent->yCo][(agent->xCo) + 1];
}

char getCharDown(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]){
    return maze[(agent->yCo) + 1][agent->xCo];
}

char getCharLeft(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]){
    return maze[agent->yCo][(agent->xCo) - 1];
}

void moveAgentUp(struct solver_agent *agent){
    agent->yCo -= 1;
}

void moveAgentRight(struct solver_agent *agent){
    agent->xCo += 1;
}

void moveAgentDown(struct solver_agent *agent){
    agent->yCo += 1;
}

void moveAgentLeft(struct solver_agent *agent){
    agent->xCo -= 1;
}

char getPosChar(struct solver_agent *agent, int rows, int cols, char maze[rows][cols])
{
    return maze[agent->yCo][agent->xCo];
}

void pushToStack(struct solver_agent *agent, int xCo, int yCo){
    push(agent->stack, xCo, yCo);
}

struct element * popFromStack(struct solver_agent *agent){
    return pop(agent->stack);
}

void printStack(struct solver_agent *agent){
    if (agent->stack->size == 0){
        return;
    }
    
    struct element *currentPos = agent->stack->head;
    
    if (agent->stack->size == 1){
        printf("[%d, %d]\n", currentPos->xCo, currentPos->yCo);
    } else {
        while (currentPos->next != NULL){
            printf("[%d, %d] -> ", currentPos->xCo, currentPos->yCo);
            currentPos = currentPos->next;
        }
        printf("[%d, %d]\n", currentPos->xCo, currentPos->yCo);
    }
}