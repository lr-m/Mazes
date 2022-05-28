/**
 * An agent that navigates the maze, used in the depth-first searches.
 */
class Solver_Agent {
    Square_HashMap prevSquares;
    ArrayList < Square > route;
    Square_HashMap routeSquares;
    Square square;
    int direction;
    int currPos;

    // Constructor
    Solver_Agent(Square square, int direction) {
        this.square = square;
        this.direction = direction;
        this.currPos = 0;
        this.prevSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
        this.routeSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
        this.route = new ArrayList(Arrays.asList(square));

        prevSquares.addSquare(square);
        routeSquares.addSquare(square);
        square.setDistance(currPos);
    }
    
    // Getters
    
    // Gets current square
    Square getSquare() {
        return square;
    }

    // Gets current direction
    int getDirection() {
        return direction;
    }
    
    ArrayList<Square> getRoute(){
        return route;
    }
    
    // Setters
    
    // Clear the previous squares visited by the turtle
    void clearPrevSquares() {
        prevSquares = null;
    }
    
    // Rotates the agent clockwise
    void rotateCW() {
        this.direction += 1;
        if (this.direction == 4) {
            this.direction = 0;
        }
    }

    // Rotates the agent counter clockwise
    void rotateCCW() {
        this.direction -= 1;
        if (this.direction == -1) {
            this.direction = 3;
        }
    }
    
    // Utility

    // Returns the possible directions that the agent can visit to squares that have not already been visited
    ArrayList < Integer > getPossibleDirections() {
        ArrayList < Integer > squarePossibleDirections = square.getPossibleDirections();

        ArrayList < Integer > toReturn = new ArrayList(squarePossibleDirections);

        for (Integer direction: squarePossibleDirections) {
            if (direction == 0) {
                if (prevSquares.containsSquare(maze.getSquareAbove(square))) {
                    toReturn.remove((Integer) 0);
                }
            } else if (direction == 1) {
                if (prevSquares.containsSquare(maze.getSquareRight(square))) {
                    toReturn.remove((Integer) 1);
                }
            } else if (direction == 2) {
                if (prevSquares.containsSquare(maze.getSquareBelow(square))) {
                    toReturn.remove((Integer) 2);
                }
            } else if (direction == 3) {
                if (prevSquares.containsSquare(maze.getSquareLeft(square))) {
                    toReturn.remove((Integer) 3);
                }
            }
        }

        return toReturn;
    }

    // Makes the agent backtrack to its last position
    void backtrack() {
        Square lastSquare = route.get(route.size() - 1);
        this.square = lastSquare;

        if (getPossibleDirections().size() == 0) {
            route.remove(lastSquare);
            routeSquares.removeSquare(lastSquare);
            currPos--;
        }
    }

    // Makes the agent walk in the specified direction
    void walkInDirection(int dir) {
        squaresToUpdate.add(square);

        if (dir == 0) {
            walkUp();
        } else if (dir == 1) {
            walkRight();
        } else if (dir == 2) {
            walkDown();
        } else {
            walkLeft();
        }

        squaresToUpdate.add(square);

        if (!prevSquares.containsSquare(square)) {
            prevSquares.addSquare(square);
        }

        if (routeSquares.containsSquare(square)) {
            Square toRemove = route.get(route.size() - 1);
            route.remove(toRemove);
            currPos--;
            routeSquares.removeSquare(toRemove);
        } else {
            route.add(square);
            currPos++;
            square.setDistance(currPos);
            routeSquares.addSquare(square);
        }
    }

    // Makes the agent walk to the square above the current square
    void walkUp() {
        this.square = maze.getSquare(square.getXCo(), square.getYCo() - 1);
    }

    // Makes the agent walk to the square above the current square
    void walkDown() {
        this.square = maze.getSquare(square.getXCo(), square.getYCo() + 1);
    }

    // Makes the agent walk to the square above the current square
    void walkLeft() {
        this.square = maze.getSquare(square.getXCo() - 1, square.getYCo());
    }

    // Makes the agent walk to the square above the current square
    void walkRight() {
        this.square = maze.getSquare(square.getXCo() + 1, square.getYCo());
    }
}
