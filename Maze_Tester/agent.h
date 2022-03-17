struct solver_agent{
    int xCo;
    int yCo;

    int target_x;
    int target_y;

    int direction;
    
    struct stack *stack;
    struct stack *popped;
    
    struct hash *visited;
};

void printStack(struct solver_agent *agent);

void turnAround(struct solver_agent *agent);

void getLeftOfAgentCoordinates(struct solver_agent *agent, int *x, int *y);

void getAheadOfAgentCoordinates(struct solver_agent *agent, int *x, int *y);

void getRightOfAgentCoordinates(struct solver_agent *agent, int *x, int *y);

char getCharAheadOfAgent(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]);

char getCharRightOfAgent(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]);

char getCharLeftOfAgent(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]);

void solve(struct solver_agent *agent, int rows, int cols, char maze[rows][cols], int* moves);

void turnAgentRight(struct solver_agent *agent);

void turnAgentLeft(struct solver_agent *agent);

void moveAgentForward(struct solver_agent *agent);

int* getDirections(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]);

char getCharUp(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]);

char getCharLeft(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]);

char getCharRight(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]);

char getCharDown(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]);

void moveAgentUp(struct solver_agent *agent);

void moveAgentRight(struct solver_agent *agent);

void moveAgentDown(struct solver_agent *agent);

void moveAgentLeft(struct solver_agent *agent);

char getPosChar(struct solver_agent *agent, int rows, int cols, char maze[rows][cols]);

void pushToStack(struct solver_agent *agent, int xCo, int yCo);

struct element * popFromStack(struct solver_agent *agent);