/**
 * The interface used by the maze solvers.
 */
interface ISolver {
    void initialise(Square startingPoint);
    
    void solve();
}

/**
 * Implements the A* search method for the maze, uses the Manhattan distance as the heursistic.
 */
class A_Star implements ISolver {
    ArrayList < Square > possibleSquares;
    ArrayList < ArrayList > allElements;
    Square_HashMap solveVisitedSquares;
    Square currentSolveSquare;

    A_Star() {}
    
    void initialise(Square startingPoint){
        this.possibleSquares = new ArrayList();
        this.allElements = new ArrayList();
      
        currentSolveSquare = startingPoint;
        solveVisitedSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
    }

    void solve() {
        if (solved == true) {
            return;
        }

        if (currentSolveSquare == endingPoint) {
            solved = true;
            maze.generationComplete();

            solution.addSquare(currentSolveSquare);
            solutionList.add(currentSolveSquare);
            squaresToUpdate.add(currentSolveSquare);
            Square currentCheck = currentSolveSquare;
            Square parent;

            while (!solution.containsSquare(startingPoint)) {
                for (ArrayList arr: allElements) {
                    if ((Square) arr.get(0) == currentCheck) {
                        parent = (Square) arr.get(1);
                        solution.addSquare(parent);
                        solutionList.add(parent);
                        currentCheck = parent;
                        break;
                    }
                }
            }
            possibleSquares.clear();
            solveVisitedSquares = null;
            return;
        }

        solveVisitedSquares.addSquare(currentSolveSquare);

        ArrayList < Integer > toCalculate = currentSolveSquare.getPossibleDirections();

        if (toCalculate.contains(0)) {
            Square foundSquare = maze.getSquareAbove(currentSolveSquare);
            if (!solveVisitedSquares.containsSquare(foundSquare)) {
                calculateHeuristic(foundSquare);
                possibleSquares.add(foundSquare);
                squaresToUpdate.add(foundSquare);
                allElements.add(new ArrayList(Arrays.asList(foundSquare, currentSolveSquare)));
            }
        }

        if (toCalculate.contains(1)) {
            Square foundSquare = maze.getSquareRight(currentSolveSquare);
            if (!solveVisitedSquares.containsSquare(foundSquare)) {
                calculateHeuristic(foundSquare);
                possibleSquares.add(foundSquare);
                squaresToUpdate.add(foundSquare);
                allElements.add(new ArrayList(Arrays.asList(foundSquare, currentSolveSquare)));
            }
        }

        if (toCalculate.contains(2)) {
            Square foundSquare = maze.getSquareBelow(currentSolveSquare);
            if (!solveVisitedSquares.containsSquare(foundSquare)) {
                calculateHeuristic(foundSquare);
                possibleSquares.add(foundSquare);
                squaresToUpdate.add(foundSquare);
                allElements.add(new ArrayList(Arrays.asList(foundSquare, currentSolveSquare)));
            }
        }

        if (toCalculate.contains(3)) {
            Square foundSquare = maze.getSquareLeft(currentSolveSquare);
            if (!solveVisitedSquares.containsSquare(foundSquare)) {
                calculateHeuristic(foundSquare);
                possibleSquares.add(foundSquare);
                squaresToUpdate.add(foundSquare);
                allElements.add(new ArrayList(Arrays.asList(foundSquare, currentSolveSquare)));
            }
        }

        getLowestHSquare();
    }

    void getLowestHSquare() {
        Square lowestH = possibleSquares.get(0);
        for (Square square: possibleSquares) {
            if (square.getHeuristic() < lowestH.getHeuristic()) {
                lowestH = square;
            }
        }
        possibleSquares.remove(lowestH);
        squaresToUpdate.add(lowestH);
        currentSolveSquare = lowestH;
    }

    void calculateHeuristic(Square square) {
        square.setHeuristic(Math.abs(currentSolveSquare.getX() - endingPoint.getX()) + Math.abs(currentSolveSquare.getY() - endingPoint.getY()));
    }
}

/**
 * Implements the Breadth-First search solver.
 */
class Breadth_First implements ISolver {
    Queue < ArrayList > solverQueue = new LinkedList();
    ArrayList currentElement;
    ArrayList < ArrayList > allElements;
    Square_HashMap solveVisitedSquares;
    Square currentSolveSquare;

    Breadth_First() {}
    
    void initialise(Square startingPoint){
        this.solverQueue = new LinkedList();
        this.currentElement = new ArrayList();
        this.allElements = new ArrayList();
      
        solveVisitedSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
        currentSolveSquare = startingPoint;
        solveVisitedSquares.addSquare(currentSolveSquare);
        solverQueue.add(new ArrayList(Arrays.asList(currentSolveSquare, null)));
    }

    void solve() {
        Square squareToQueue;

        if (solved == true) {
            currentSolveSquare = null;
            solveVisitedSquares = null;
            return;
        }

        currentElement = solverQueue.remove();

        currentSolveSquare = (Square) currentElement.get(0);
        solveVisitedSquares.addSquare(currentSolveSquare);

        squaresToUpdate.add(currentSolveSquare);

        if (currentSolveSquare == endingPoint) {
            solved = true;

            solution.addSquare(currentSolveSquare);
            solutionList.add(currentSolveSquare);
            Square currentCheck = currentSolveSquare;
            Square parent;

            while (!solution.containsSquare(startingPoint)) {
                for (ArrayList arr: allElements) {
                    if ((Square) arr.get(0) == currentCheck) {
                        parent = (Square) arr.get(1);
                        solution.addSquare(parent);
                        solutionList.add(parent);
                        currentCheck = parent;
                        break;
                    }
                }
            }
            maze.generationComplete();
        }

        ArrayList < Integer > possibleDirections = currentSolveSquare.getPossibleDirections();

        if (possibleDirections.contains(0)) {
            squareToQueue = maze.getSquare(currentSolveSquare.getXCo(), currentSolveSquare.getYCo() - 1);

            if (squareToQueue != null) {
                squareToQueue.setDistance(currentSolveSquare.getDistance() + squareToQueue.getDistanceFrom(currentSolveSquare));
            }

            addToQueue(new ArrayList(Arrays.asList(squareToQueue, currentSolveSquare)));
        }

        if (possibleDirections.contains(1)) {
            squareToQueue = maze.getSquare(currentSolveSquare.getXCo() + 1, currentSolveSquare.getYCo());

            if (squareToQueue != null) {
                squareToQueue.setDistance(currentSolveSquare.getDistance() + squareToQueue.getDistanceFrom(currentSolveSquare));
            }

            addToQueue(new ArrayList(Arrays.asList(squareToQueue, currentSolveSquare)));
        }

        if (possibleDirections.contains(2)) {
            squareToQueue = maze.getSquare(currentSolveSquare.getXCo(), currentSolveSquare.getYCo() + 1);

            if (squareToQueue != null) {
                squareToQueue.setDistance(currentSolveSquare.getDistance() + squareToQueue.getDistanceFrom(currentSolveSquare));
            }

            addToQueue(new ArrayList(Arrays.asList(squareToQueue, currentSolveSquare)));
        }

        if (possibleDirections.contains(3)) {
            squareToQueue = maze.getSquare(currentSolveSquare.getXCo() - 1, currentSolveSquare.getYCo());

            if (squareToQueue != null) {
                squareToQueue.setDistance(currentSolveSquare.getDistance() + squareToQueue.getDistanceFrom(currentSolveSquare));
            }

            addToQueue(new ArrayList(Arrays.asList(squareToQueue, currentSolveSquare)));
        }
    }

    void addToQueue(ArrayList < Square > arrList) {
        if (!solveVisitedSquares.containsSquare(arrList.get(0))) {
            solverQueue.add(arrList);
            allElements.add(arrList);
        }
    }
}

/**
 * Implements the Depth-First search solver.
 */
class Depth_First implements ISolver {
    Solver_Agent turtle;

    Depth_First() {}
    
    void initialise(Square startingPoint){
        ArrayList < Integer > dirs = startingPoint.getPossibleDirections();
        turtle = new Solver_Agent(startingPoint, dirs.get(0));
        turtle.walkInDirection(turtle.getDirection());
    }

    void solve() {
        if (solved) {
            return;
        }

        if (turtle.getSquare() == endingPoint) {
            for (Square square: turtle.route) {
                solution.addSquare(square);
                solutionList.add(square);
            }

            solved = true;
            turtle.clearPrevSquares();
            maze.generationComplete();
            return;
        }

        ArrayList < Integer > possibleDirections = turtle.getPossibleDirections();

        if (possibleDirections.size() > 0) {
            turtle.walkInDirection(possibleDirections.get(Math.round(random(0, possibleDirections.size() - 1))));
        } else {
            turtle.backtrack();
        }
    }
}

/**
 * Implements the left-first Depth-First search solver.
 */
class Left_Wall implements ISolver {
    Solver_Agent turtle;

    Left_Wall() {}
    
    void initialise(Square startingPoint){
        ArrayList < Integer > dirs = startingPoint.getPossibleDirections();
        turtle = new Solver_Agent(startingPoint, dirs.get(0));
        turtle.walkInDirection(turtle.getDirection());
    }

    void solve() {
        if (solved) {
            return;
        }

        if (turtle.getSquare() == endingPoint) {

            for (Square square: turtle.route) {
                solution.addSquare(square);
                solutionList.add(square);
            }

            solved = true;
            turtle.clearPrevSquares();
            maze.generationComplete();
            return;
        }

        if (turtleCheckLeft()) {
            turtle.rotateCCW();
            turtle.walkInDirection(turtle.getDirection());
            return;
        }

        if (!turtleCheckAhead()) {
            turtle.rotateCW();
            return;
        }

        turtle.walkInDirection(turtle.getDirection());
    }

    // true if no wall to left, false if wall
    boolean turtleCheckLeft() {
        int leftDir = turtle.getDirection() - 1;
        if (leftDir == -1) {
            leftDir = 3;
        }

        if (turtle.getSquare().getPossibleDirections().contains(leftDir)) {
            return true;
        }
        return false;
    }

    // true if no wall ahead, false if wall
    boolean turtleCheckAhead() {
        int aheadDir = turtle.getDirection();
        if (turtle.getSquare().getPossibleDirections().contains(aheadDir)) {
            return true;
        }
        return false;
    }
}

/**
 * Implements the right-first Depth-First search solver.
 */
class Right_Wall implements ISolver {
    Solver_Agent turtle;

    Right_Wall() {}
    
    void initialise(Square startingPoint){
        ArrayList < Integer > dirs = startingPoint.getPossibleDirections();
        turtle = new Solver_Agent(startingPoint, dirs.get(0));
        turtle.walkInDirection(turtle.getDirection());
    }

    void solve() {
        if (solved) {
            return;
        }

        if (turtle.getSquare() == endingPoint) {

            for (Square square: turtle.route) {
                solution.addSquare(square);
                solutionList.add(square);
            }

            solved = true;
            turtle.clearPrevSquares();
            maze.generationComplete();
            return;
        }

        if (turtleCheckRight()) {
            turtle.rotateCW();
            turtle.walkInDirection(turtle.getDirection());
            return;
        }

        if (!turtleCheckAhead()) {
            turtle.rotateCCW();
            return;
        }

        turtle.walkInDirection(turtle.getDirection());
    }

    // true if no wall to left, false if wall
    boolean turtleCheckRight() {
        int rightDir = turtle.getDirection() + 1;
        if (rightDir == 4) {
            rightDir = 0;
        }

        if (turtle.getSquare().getPossibleDirections().contains(rightDir)) {
            return true;
        }
        return false;
    }

    // true if no wall ahead, false if wall
    boolean turtleCheckAhead() {
        int aheadDir = turtle.getDirection();
        if (turtle.getSquare().getPossibleDirections().contains(aheadDir)) {
            return true;
        }
        return false;
    }
}
