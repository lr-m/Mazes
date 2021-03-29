// Generator interface
interface IGenerator {
    String getName();
  
    void generate();

    void reset();
}

// Implements the Aldous-Broder algorithm for maze generation
class Aldous_Broder implements IGenerator {
    boolean aldousInitialised;
    int added;
    Square_HashMap visitedSquares;

    Aldous_Broder() {
        this.aldousInitialised = false;
        this.visitedSquares = new Square_HashMap((maze.getNumberOfRows()) * (maze.getNumberOfColumns()));
    }
    
    String getName(){
      return "01_aldous";
    }

    void reset() {
        this.aldousInitialised = false;
        this.added = 0;
    }

    void generate() {
        if (generated) {
            return;
        }

        if (!aldousInitialised) {
            visitedSquares = new Square_HashMap((maze.getNumberOfRows()) * (maze.getNumberOfColumns()));
            currentSquare = maze.getRandomSquare();
            aldousInitialised = true;
            visitedSquares.addSquare(currentSquare);
            added = 1;
        }

        Square oldSquare = currentSquare;
        ArrayList < Integer > possibleDirections = new ArrayList(Arrays.asList(0, 1, 2, 3));

        do {
           int randInd = Math.round(random(-0.5, possibleDirections.size() - 0.5));

            int dir = possibleDirections.get(randInd);

            possibleDirections.remove(randInd);

            currentSquare = oldSquare;

            if (dir == 0) {
                currentSquare = maze.getSquareAbove(currentSquare);
            } else if (dir == 1) {
                currentSquare = maze.getSquareRight(currentSquare);
            } else if (dir == 2) {
                currentSquare = maze.getSquareBelow(currentSquare);
            } else if (dir == 3) {
                currentSquare = maze.getSquareLeft(currentSquare);
            }
        }
        while (currentSquare == null);

        if (!visitedSquares.containsSquare(currentSquare)) {
            maze.getPaths().addPath(new Path(currentSquare, oldSquare));
            visitedSquares.addSquare(currentSquare);
            added++;
        }

        if (added == (maze.getNumberOfRows()) * (maze.getNumberOfColumns())) {
            generated = true;
            maze.generationComplete();
        }
    }
}

// Implements a backtracking algorithm for maze generation
class Backtracker implements IGenerator {
    ArrayList < ArrayList < Integer >> routeStack;
    ArrayList < ArrayList < Integer >> visitedStack;
    Square_HashMap visitedSquares;
    Square_HashMap routeSquares;
    Boolean backtracking;

    Backtracker() {
        this.routeStack = new ArrayList();
        this.visitedStack = new ArrayList();
        this.backtracking = false;
    }
    
    String getName(){
      return "02_backtracker";
    }

    void reset() {
        routeStack = new ArrayList();
        visitedStack = new ArrayList();
        backtracking = false;
    }

    void generate() {
        if (generated) {
            return;
        }

        if (backtracking) {
            if (atDeadEnd()) {
                currentSquare = maze.getSquare(popCoord());
                return;
            } else {
                backtracking = false;
                return;
            }
        }

        if (routeStack.isEmpty()) {
            currentSquare = maze.getRandomSquare();
            routeStack.add(currentSquare.getCoords());
            visitedStack.add(currentSquare.getCoords());

            visitedSquares = new Square_HashMap((maze.getNumberOfRows()) * (maze.getNumberOfColumns()));
            routeSquares = new Square_HashMap((maze.getNumberOfRows()) * (maze.getNumberOfColumns()));

            visitedSquares.addSquare(currentSquare);
            routeSquares.addSquare(currentSquare);
        } else {
            Square oldSquare = currentSquare;
            ArrayList < Integer > directions = new ArrayList(Arrays.asList(0, 1, 2, 3));
            do {
                if (currentSquare == null) {
                    currentSquare = oldSquare;
                }

                int direction = directions.get(Math.round(random(-0.5, directions.size()-0.501)));

                directions.remove((Integer) direction);

                if (direction == 0 && !checkStack(maze.getSquare(oldSquare.getXCo(), oldSquare.getYCo() - 1))) {
                    currentSquare = maze.getSquare(oldSquare.getXCo(), oldSquare.getYCo() - 1);
                } else if (direction == 1 && !checkStack(maze.getSquare(oldSquare.getXCo() + 1, oldSquare.getYCo()))) {
                    currentSquare = maze.getSquare(oldSquare.getXCo() + 1, oldSquare.getYCo());
                } else if (direction == 2 && !checkStack(maze.getSquare(oldSquare.getXCo(), oldSquare.getYCo() + 1))) {
                    currentSquare = maze.getSquare(oldSquare.getXCo(), oldSquare.getYCo() + 1);
                } else if (direction == 3 && !checkStack(maze.getSquare(oldSquare.getXCo() - 1, oldSquare.getYCo()))) {
                    currentSquare = maze.getSquare(oldSquare.getXCo() - 1, oldSquare.getYCo());
                } else {
                    currentSquare = null;
                }
            } while (currentSquare == null);

            maze.getPaths().addPath(new Path(currentSquare, oldSquare));
            routeStack.add(currentSquare.getCoords());
            visitedStack.add(currentSquare.getCoords());

            routeSquares.addSquare(currentSquare);
            visitedSquares.addSquare(currentSquare);

            if (atDeadEnd()) {
                backtracking = true;
            }
        }
    }

    ArrayList < Integer > popCoord() {
        ArrayList < Integer > toReturn;

        try {
            toReturn = routeStack.get(routeStack.size() - 1);
        } catch (Exception ArrayIndexOutOfBoundsException) {
            visitedStack.clear();

            visitedSquares = new Square_HashMap((maze.getNumberOfRows()) * (maze.getNumberOfColumns()));
            routeSquares = new Square_HashMap((maze.getNumberOfRows()) * (maze.getNumberOfColumns()));

            generated = true;
            maze.generationComplete();
            return null;
        }
        
        routeSquares.removeSquare(maze.getSquare(routeStack.get(routeStack.size() - 1)));
        routeStack.remove(routeStack.size() - 1);

        return toReturn;
    }

    boolean atDeadEnd() {
        if (currentSquare != null) {
            if (currentSquare.getXCo() == 0 && currentSquare.getYCo() == 0) {
                return checkBot(currentSquare) && checkRight(currentSquare);
            } else if (currentSquare.getXCo() == (maze.getNumberOfColumns() - 1) && currentSquare.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkTop(currentSquare) && checkLeft(currentSquare);
            } else if (currentSquare.getXCo() == 0 && currentSquare.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkTop(currentSquare) && checkRight(currentSquare);
            } else if (currentSquare.getXCo() == (maze.getNumberOfColumns() - 1) && currentSquare.getYCo() == 0) {
                return checkBot(currentSquare) && checkLeft(currentSquare);
            } else if (currentSquare.getXCo() == 0) {
                return checkTop(currentSquare) && checkBot(currentSquare) && checkRight(currentSquare);
            } else if (currentSquare.getYCo() == 0) {
                return checkLeft(currentSquare) && checkRight(currentSquare) && checkBot(currentSquare);
            } else if (currentSquare.getXCo() == (maze.getNumberOfColumns() - 1)) {
                return checkTop(currentSquare) && checkBot(currentSquare) && checkLeft(currentSquare);
            } else if (currentSquare.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkLeft(currentSquare) && checkRight(currentSquare) && checkTop(currentSquare);
            } else {
                return checkLeft(currentSquare) && checkRight(currentSquare) && checkTop(currentSquare) && checkBot(currentSquare);
            }
        }
        return true;
    }

    boolean atDeadEnd(Square square) {
        if (currentSquare != null) {
            if (square.getXCo() == 0 && square.getYCo() == 0) {
                return checkBot(square) && checkRight(square);
            } else if (square.getXCo() ==(maze.getNumberOfColumns() - 1) && square.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkTop(square) && checkLeft(square);
            } else if (square.getXCo() == 0 && square.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkTop(square) && checkRight(square);
            } else if (square.getXCo() == (maze.getNumberOfColumns() - 1) && square.getYCo() == 0) {
                return checkBot(square) && checkLeft(square);
            } else if (square.getXCo() == 0) {
                return checkTop(square) && checkBot(square) && checkRight(square);
            } else if (square.getYCo() == 0) {
                return checkLeft(square) && checkRight(square) && checkBot(square);
            } else if (square.getXCo() == (maze.getNumberOfColumns() - 1)) {
                return checkTop(square) && checkBot(square) && checkLeft(square);
            } else if (square.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkLeft(square) && checkRight(square) && checkTop(square);
            } else {
                return checkLeft(square) && checkRight(square) && checkTop(square) && checkBot(square);
            }
        }
        return true;
    }

    boolean checkLeft(Square square) {
        return checkStack(maze.getSquare(square.getXCo() - 1, square.getYCo()));
    }

    boolean checkTop(Square square) {
        return checkStack(maze.getSquare(square.getXCo(), square.getYCo() - 1));
    }

    boolean checkRight(Square square) {
        return checkStack(maze.getSquare(square.getXCo() + 1, square.getYCo()));
    }

    boolean checkBot(Square square) {
        return checkStack(maze.getSquare(square.getXCo(), square.getYCo() + 1));
    }

    boolean checkStack(Square square) {
        return visitedSquares.containsSquare(square);
    }

    // 0 = up, 1 = right, 2 = down, 3 = left
    int getRandomDir() {
        return Math.round(random(-0.5, 3.5));
    }
}

// Implements the Binary-Tree maze generation algorithm
class Binary_Tree implements IGenerator {
    int xPos, yPos;
    boolean binaryInitialised;
    Square_HashMap binaryAdded;

    Binary_Tree() {
        this.binaryInitialised = false;
    }
    
    String getName(){
      return "03_binary";
    }

    void reset() {
        binaryInitialised = false;
    }

    void generate() {
        if (generated) {
            return;
        }

        if (!binaryInitialised) {
            binaryAdded = new Square_HashMap((maze.getNumberOfColumns()) * (maze.getNumberOfRows()));
            xPos = maze.getNumberOfColumns()-1;
            yPos = maze.getNumberOfRows()-1;
            binaryInitialised = !binaryInitialised;
        }

        if (yPos >= 0) {
            if (xPos >= 0) {
                currentSquare = maze.getSquare(xPos, yPos);

                if (xPos == 0 && yPos == 0) {
                    currentSquare = null;
                    generated = true;
                    binaryAdded = null;
                    maze.generationComplete();
                    return;
                } else if (currentSquare.getXCo() == 0) {
                    binaryNorth(currentSquare);
                } else if (currentSquare.getYCo() == 0) {
                    binaryWest(currentSquare);
                } else {
                    int rand = Math.round(random(0, 1));

                    if (rand == 1) {
                        binaryWest(currentSquare);
                    } else {
                        binaryNorth(currentSquare);
                    }
                }
                xPos--;
            } else {
                xPos = maze.getNumberOfColumns()-1;
                yPos--;
            }
        }
    }

    void binaryNorth(Square thisSquare) {
        Path newPath = new Path(thisSquare, maze.getSquare(thisSquare.getXCo(), thisSquare.getYCo() - 1));
        maze.getPaths().addPath(newPath);
        binaryAdded.addSquare(thisSquare);
        binaryAdded.addSquare(maze.getSquare(thisSquare.getXCo(), thisSquare.getYCo() - 1));
    }

    void binaryWest(Square thisSquare) {
        Path newPath = new Path(thisSquare, maze.getSquare(thisSquare.getXCo() - 1, thisSquare.getYCo()));
        maze.getPaths().addPath(newPath);
        binaryAdded.addSquare(thisSquare);
        binaryAdded.addSquare(maze.getSquare(thisSquare.getXCo() - 1, thisSquare.getYCo()));
    }
}

class Blobby_Recursive implements IGenerator {
    Set_Hash sets;
    Boolean setsCreated;
    ArrayList < Integer > setNumbersToDivide;
    int setNumber;

    boolean finish = false;
    boolean nextSet = true;

    int setNumberToDivide;
    Small_Square_Hash setSquares;
    Square[] randSquares;
    ArrayList < Square > frontier0;
    ArrayList < Square > frontier1;
    int set0;
    int set1;
    ArrayList < Path > potentialPaths;

    Blobby_Recursive() {
        setsCreated = false;
        setNumbersToDivide = new ArrayList();
        setNumber = 0;
        nextSet = true;
    }
    
    String getName(){
      return "04_blobby_recursive";
    }

    void reset() {
        setsCreated = false;
        setNumber = 0;
        setNumbersToDivide.clear();
        nextSet = true;
    }

    void generate() {
        if (generated) {
            return;
        }

        if (!setsCreated) {
            maze.clear();
            sets = new Set_Hash(2 * (maze.getNumberOfRows()) * (maze.getNumberOfColumns()));
            setsCreated = !setsCreated;

            for (Square square: maze.getSquares()) {
                sets.addToSet(0, square);
            }

            setNumbersToDivide.add(0);
        }

        if (setNumbersToDivide.size() > 0 || !nextSet) {
            if (nextSet) {
                nextSet();
                nextSet = false;
            }

            if (frontier0.size() > 0 || frontier1.size() > 0) {
                ArrayList < Square > newFrontier = new ArrayList(frontier0);

                for (Square frontierSquare: frontier0) {
                    if (random(1) > 0.5) {
                        for (Square square: maze.getSquareNeighbours(frontierSquare)) {
                            if (sets.getSet(set1).containsSquare(square)) {
                                potentialPaths.add(new Path(frontierSquare, square));
                            }

                            if (setSquares.containsSquare(square) && !sets.getSet(set1).containsSquare(square) && (square.getSet() == setNumberToDivide || square.getSet() == set1)) {
                                newFrontier.add(square);
                                sets.addToSet(set0, square);
                            }
                        }
                        newFrontier.remove(frontierSquare);
                    }
                }

                frontier0 = newFrontier;

                newFrontier = new ArrayList(frontier1);

                for (Square frontierSquare: frontier1) {
                    if (random(1) > 0.5) {
                        for (Square square: maze.getSquareNeighbours(frontierSquare)) {
                            if (setSquares.containsSquare(square) && !sets.getSet(set0).containsSquare(square) && (square.getSet() == setNumberToDivide || square.getSet() == set0)) {
                                newFrontier.add(square);
                                sets.addToSet(set1, square);
                            }
                        }
                        newFrontier.remove(frontierSquare);
                    }
                }

                frontier1 = newFrontier;
                return;
            }

            if (sets.getSet(set0).allSquares.size() >= 4) {
                setNumbersToDivide.add(set0);
            } else {
                for (Square square: sets.getSet(set0).allSquares) {
                    square.setSet(-1);
                }
            }

            if (sets.getSet(set1).allSquares.size() >= 4) {
                setNumbersToDivide.add(set1);
            } else {
                for (Square square: sets.getSet(set1).allSquares) {
                    square.setSet(-1);
                }
            }

            if (potentialPaths.size() > 0) {
                maze.paths.addPath(potentialPaths.remove(Math.round(random(0, potentialPaths.size() - 1))));

                for (Path path: potentialPaths) {
                    path.addWallBetween();
                }
            }

            potentialPaths.clear();
            nextSet = true;
            return;
        }

        maze.generatePaths();
        generated = true;
        maze.generationComplete();
    }

    void nextSet() {
        setNumberToDivide = setNumbersToDivide.remove(setNumbersToDivide.size() - 1);

        setSquares = sets.getSet(setNumberToDivide);

        randSquares = getRandomSeeds(setNumberToDivide);

        frontier0 = new ArrayList();
        frontier1 = new ArrayList();

        frontier0.add(randSquares[0]);
        frontier1.add(randSquares[1]);

        set0 = setNumber += 1;
        set1 = (int) Math.floor(((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1)) / 2) + setNumber;

        sets.addToSet(set0, randSquares[0]);
        sets.addToSet(set1, randSquares[1]);

        potentialPaths = new ArrayList();
    }

    Square[] getRandomSeeds(int setNumber) {
        Square seed1 = sets.getRandomSquare(setNumber);
        Square seed2 = sets.getRandomSquare(setNumber);

        while (seed2 == seed1) {
            seed2 = sets.getRandomSquare(setNumber);
        }

        Square[] squares = {
            seed1,
            seed2
        };

        return squares;
    }
}

// Implements the Ellers algorithm for maze generation
class Ellers implements IGenerator {
    Set_Hash ellersSets;
    boolean setsCreated;
    int row, col, currentStage, setNumber;
    boolean lastRow;
    ArrayList < Integer > setsWithDownPaths;

    Ellers() {
        this.setsCreated = false;
        this.row = 0;
        this.col = 0;
        this.currentStage = 1;
        this.lastRow = false;
        this.setsWithDownPaths = new ArrayList();
    }
    
    String getName(){
      return "05_ellers";
    }

    void reset() {
        row = 0;
        currentStage = 1;
        col = 0;
        lastRow = false;
        setsCreated = false;
    }

    void generate() {
        if (generated) {
            return;
        }

        if (!setsCreated) {
            ellersSets = new Set_Hash((maze.getNumberOfRows()) * (maze.getNumberOfColumns()));
            setsCreated = true;
        }

        if (!lastRow && row < maze.getNumberOfRows()-1) {
            if (currentStage == 1) {
                if (col < maze.getNumberOfColumns()) {
                    createSets(row);
                    col++;
                    return;
                }
                currentStage = 2;
                return;
            } else if (currentStage == 2) {
                if (col >= 0) {
                    randomUnion(row);
                    col--;
                    return;
                }
                col = 0;
                currentStage = 3;
                return;
            } else if (currentStage == 3) {
                if (col < maze.getNumberOfColumns()) {
                    createDownPaths(row);
                    col++;
                    return;
                }
                col = maze.getNumberOfColumns();
                currentStage = 2;
                row++;
                setsWithDownPaths = new ArrayList();
                return;
            }
        }

        lastRow = true;

        if (col < maze.getNumberOfColumns()) {
            createSets(maze.getNumberOfRows());
            col++;
            return;
        }

        joinLastRow();
        generated = true;
        maze.generationComplete();
    }

    void createSets(int row) {
        if (col == 0) {
            setNumber = row * (maze.getNumberOfColumns());
        }

        if (col < maze.getNumberOfColumns()) {
            if (maze.getSquare(col, row).getSet() == -1) {
                ellersSets.addToSet(setNumber, maze.getSquare(col, row));
                setNumber++;
            }
        }
    }

    void randomUnion(int row) {
        if (col < maze.getNumberOfColumns()-1) {
            Square startSquare = maze.getSquare(col, row);
            Square endSquare = maze.getSquare(col + 1, row);
            if (random(1) < 0.5 && startSquare.getSet() != endSquare.getSet()) {
                ellersSets.mergeSets(startSquare.getSet(), endSquare.getSet());
                maze.getPaths().addPath(new Path(startSquare, endSquare));
            }
        }
    }

    void createDownPaths(int row) {
        if (col < maze.getNumberOfColumns()) {
            Square topSquare = maze.getSquare(col, row);
            Square bottomSquare = maze.getSquare(col, row + 1);

            if (random(1) < 0.5) {
                maze.getPaths().addPath(new Path(topSquare, bottomSquare));
                ellersSets.addToSet(topSquare.getSet(), bottomSquare);
                if (!setsWithDownPaths.contains(topSquare.getSet())) {
                    setsWithDownPaths.add(topSquare.getSet());
                }
            } else {
                for (int i = 0; i <= col; i++) {
                    Square otherTopSquare = maze.getSquare(i, row);

                    if (!setsWithDownPaths.contains(otherTopSquare.getSet())) {
                        ArrayList < Square > squaresInSet = new ArrayList();

                        squaresInSet.add(otherTopSquare);

                        int lookAhead = 1;
                        while (maze.getSquare(otherTopSquare.getXCo() + lookAhead, otherTopSquare.getYCo()) != null && maze.getSquare(otherTopSquare.getXCo() + lookAhead, otherTopSquare.getYCo()).getSet() == otherTopSquare.getSet()) {
                            squaresInSet.add(maze.getSquare(otherTopSquare.getXCo() + lookAhead, otherTopSquare.getYCo()));
                            lookAhead++;
                        }

                        Square randomSquare = squaresInSet.get(Math.round(random(0, squaresInSet.size() - 1)));
                        Square otherBottomSquare = maze.getSquare(randomSquare.getXCo(), row + 1);

                        setsWithDownPaths.add(randomSquare.getSet());

                        ellersSets.addToSet(randomSquare.getSet(), otherBottomSquare);
                        maze.getPaths().addPath(new Path(randomSquare, otherBottomSquare));
                    }
                }
            }
        }

        if (col == maze.getNumberOfColumns()) {
            setNumber = row * (maze.getNumberOfColumns());
        }

        if (col <= maze.getNumberOfColumns()) {
            if (maze.getSquare(col, row + 1).getSet() == -1) {
                ellersSets.addToSet(setNumber, maze.getSquare(col, row + 1));
                setNumber++;
            }
        }
    }

    void joinLastRow() {
        for (int i = 1; i < maze.getNumberOfColumns(); i++) {
            Square startSquare = maze.getSquare(i - 1, maze.getNumberOfRows()-1);
            Square endSquare = maze.getSquare(i, maze.getNumberOfRows()-1);
            if (startSquare.getSet() != endSquare.getSet()) {
                ellersSets.mergeSets(startSquare.getSet(), endSquare.getSet());
                maze.getPaths().addPath(new Path(startSquare, endSquare));
            }
        }
    }
}

// Implements the hunt and kill maze generation algorithm
class Hunt_Kill implements IGenerator {
    // false = hunt, true == kill
    boolean mode;
    ArrayList < Square > remainingSquaresInMaze;
    Square_HashMap visitedSquares;
    ArrayList < ArrayList < Integer >> visitedStack;

    Hunt_Kill() {
        this.mode = true;
        this.visitedStack = new ArrayList();
        this.remainingSquaresInMaze = new ArrayList();
    }
    
    String getName(){
      return "06_hunt_kill";
    }

    void reset() {
        mode = true;
        visitedStack.clear();
        remainingSquaresInMaze.clear();
    }

    void generate() {
        if (generated) {
            return;
        }

        if (visitedStack.size() == 0) {
            currentSquare = maze.getRandomSquare();
            currentSquare.setSet(1);
            visitedStack.add(currentSquare.getCoords());

            visitedSquares = new Square_HashMap(maze.getNumberOfColumns() * maze.getNumberOfRows());

            visitedSquares.addSquare(currentSquare);

            for (int i = 0; i < maze.getNumberOfColumns(); i++) {
                for (int j = 0; j < maze.getNumberOfRows(); j++) {
                    remainingSquaresInMaze.add(maze.getSquare(i, j));
                }
            }
        }

        if (atDeadEnd()) {
            visitedStack.add(currentSquare.getCoords());
            visitedSquares.addSquare(currentSquare);

            remainingSquaresInMaze.remove(currentSquare);

            mode = false;
        } else {
            mode = true;
        }

        if (mode == false) {
            hunt();
        } else {
            kill();
        }
    }

    void hunt() {
        // Scan grid for unvisited cell next to a visited cell    
        for (Square square: remainingSquaresInMaze) {
            Square found = nextToVisitedSquare(square);
            if (found != null && !atDeadEnd(found)) {

                currentSquare = found;

                int directionToGo = getDirectionOfValidSquare();

                Square oldSquare = currentSquare;
                if (directionToGo == 0) {
                    walkUp();
                } else if (directionToGo == 1) {
                    walkRight();
                } else if (directionToGo == 2) {
                    walkDown();
                } else {
                    walkLeft();
                }

                maze.getPaths().addPath(new Path(oldSquare, currentSquare));
                currentSquare.setSet(1);
                visitedStack.add(oldSquare.getCoords());
                visitedSquares.addSquare(oldSquare);

                remainingSquaresInMaze.remove(oldSquare);

                mode = true;
                return;
            }
        }
        visitedStack.clear();
        visitedSquares = new Square_HashMap((maze.getNumberOfRows()) * (maze.getNumberOfColumns()));
        currentSquare = null;
        generated = true;
        maze.generationComplete();
    }

    void kill() {
        // random walk

        int dir = getRandomDir();

        Square oldSquare = currentSquare;
        ArrayList < Integer > possibleDirections = new ArrayList(Arrays.asList(0, 1, 2, 3));
        do {
            if (possibleDirections.size() == 0) {
                generated = true;
                return;
            }

            int ind = Math.round(random(0, possibleDirections.size() - 1));
            dir = possibleDirections.get(ind);
            possibleDirections.remove(ind);
            currentSquare = oldSquare;

            if (dir == 0) {
                walkUp();
            } else if (dir == 1) {
                walkRight();
            } else if (dir == 2) {
                walkDown();
            } else if (dir == 3) {
                walkLeft();
            }
        } while (currentSquare == null || currentSquare.getSet() != -1);

        maze.getPaths().addPath(new Path(oldSquare, currentSquare));
        currentSquare.setSet(1);
        visitedStack.add(oldSquare.getCoords());
        visitedSquares.addSquare(oldSquare);

        remainingSquaresInMaze.remove(oldSquare);
    }

    Square nextToVisitedSquare(Square square) {
        if (square != null) {
            // Above
            if (maze.getSquare((int) square.getXCo(), (int) square.getYCo() - 1) != null) {
                if (visitedSquares.containsSquare(maze.getSquare((int) square.getXCo(), (int) square.getYCo() - 1))) {
                    return maze.getSquare((int) square.getXCo(), (int) square.getYCo() - 1);
                }
            }

            // Below
            if (maze.getSquare((int) square.getXCo(), (int) square.getYCo() + 1) != null) {
                if (visitedSquares.containsSquare(maze.getSquare((int) square.getXCo(), (int) square.getYCo() + 1))) {
                    return maze.getSquare((int) square.getXCo(), (int) square.getYCo() + 1);
                }
            }

            // Left
            if (maze.getSquare((int) square.getXCo() - 1, (int) square.getYCo()) != null) {
                if (visitedSquares.containsSquare(maze.getSquare((int) square.getXCo() - 1, (int) square.getYCo()))) {
                    return maze.getSquare((int) square.getXCo() - 1, (int) square.getYCo());
                }
            }

            // Right
            if (maze.getSquare((int) square.getXCo() + 1, (int) square.getYCo()) != null) {
                if (visitedSquares.containsSquare(maze.getSquare((int) square.getXCo() + 1, (int) square.getYCo()))) {
                    return maze.getSquare((int) square.getXCo() + 1, (int) square.getYCo());
                }
            }
        }

        return null;
    }

    int getDirectionOfValidSquare() {
        ArrayList < Integer > validDirs = new ArrayList();

        if (checkUp()) {
            validDirs.add(0);
        }

        if (checkRight()) {
            validDirs.add(1);
        }

        if (checkDown()) {
            validDirs.add(2);
        }

        if (checkLeft()) {
            validDirs.add(3);
        }

        return validDirs.get(Math.round(random(0, validDirs.size() - 1)));
    }

    boolean checkLeft() {

        Square leftSquare = maze.getSquare(currentSquare.getXCo() - 1, currentSquare.getYCo());

        if (leftSquare == null) {
            return false;
        }

        return leftSquare.getSet() == -1;
    }

    boolean checkRight() {

        Square rightSquare = maze.getSquare(currentSquare.getXCo() + 1, currentSquare.getYCo());

        if (rightSquare == null) {
            return false;
        }

        return rightSquare.getSet() == -1;
    }

    boolean checkUp() {

        Square upSquare = maze.getSquare(currentSquare.getXCo(), currentSquare.getYCo() - 1);

        if (upSquare == null) {
            return false;
        }

        return upSquare.getSet() == -1;
    }

    boolean checkDown() {

        Square downSquare = maze.getSquare(currentSquare.getXCo(), currentSquare.getYCo() + 1);

        if (downSquare == null) {
            return false;
        }

        return downSquare.getSet() == -1;
    }

    void walkUp() {
        currentSquare = maze.getSquare(currentSquare.getXCo(), currentSquare.getYCo() - 1);
    }

    void walkDown() {
        currentSquare = maze.getSquare(currentSquare.getXCo(), currentSquare.getYCo() + 1);
    }

    void walkLeft() {
        currentSquare = maze.getSquare(currentSquare.getXCo() - 1, currentSquare.getYCo());
    }

    void walkRight() {
        currentSquare = maze.getSquare(currentSquare.getXCo() + 1, currentSquare.getYCo());
    }

    boolean atDeadEnd() {
        if (currentSquare != null) {
            if (currentSquare.getXCo() == 0 && currentSquare.getYCo() == 0) {
                return checkBot(currentSquare) && checkRight(currentSquare);
            } else if (currentSquare.getXCo() == (maze.getNumberOfColumns() - 1) && currentSquare.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkTop(currentSquare) && checkLeft(currentSquare);
            } else if (currentSquare.getXCo() == 0 && currentSquare.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkTop(currentSquare) && checkRight(currentSquare);
            } else if (currentSquare.getXCo() == (maze.getNumberOfColumns() - 1) && currentSquare.getYCo() == 0) {
                return checkBot(currentSquare) && checkLeft(currentSquare);
            } else if (currentSquare.getXCo() == 0) {
                return checkTop(currentSquare) && checkBot(currentSquare) && checkRight(currentSquare);
            } else if (currentSquare.getYCo() == 0) {
                return checkLeft(currentSquare) && checkRight(currentSquare) && checkBot(currentSquare);
            } else if (currentSquare.getXCo() == (maze.getNumberOfColumns() - 1)) {
                return checkTop(currentSquare) && checkBot(currentSquare) && checkLeft(currentSquare);
            } else if (currentSquare.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkLeft(currentSquare) && checkRight(currentSquare) && checkTop(currentSquare);
            } else {
                return checkLeft(currentSquare) && checkRight(currentSquare) && checkTop(currentSquare) && checkBot(currentSquare);
            }
        }
        return true;
    }

    boolean atDeadEnd(Square square) {
        if (currentSquare != null) {
            if (square.getXCo() == 0 && square.getYCo() == 0) {
                return checkBot(square) && checkRight(square);
            } else if (square.getXCo() ==(maze.getNumberOfColumns() - 1) && square.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkTop(square) && checkLeft(square);
            } else if (square.getXCo() == 0 && square.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkTop(square) && checkRight(square);
            } else if (square.getXCo() == (maze.getNumberOfColumns() - 1) && square.getYCo() == 0) {
                return checkBot(square) && checkLeft(square);
            } else if (square.getXCo() == 0) {
                return checkTop(square) && checkBot(square) && checkRight(square);
            } else if (square.getYCo() == 0) {
                return checkLeft(square) && checkRight(square) && checkBot(square);
            } else if (square.getXCo() == (maze.getNumberOfColumns() - 1)) {
                return checkTop(square) && checkBot(square) && checkLeft(square);
            } else if (square.getYCo() == (maze.getNumberOfRows() - 1)) {
                return checkLeft(square) && checkRight(square) && checkTop(square);
            } else {
                return checkLeft(square) && checkRight(square) && checkTop(square) && checkBot(square);
            }
        }
        return true;
    }

    boolean checkStack(Square square) {
        return visitedSquares.containsSquare(square);
    }

    boolean checkLeft(Square square) {
        return checkStack(maze.getSquare(square.getXCo() - 1, square.getYCo()));
    }

    boolean checkTop(Square square) {
        return checkStack(maze.getSquare(square.getXCo(), square.getYCo() - 1));
    }

    boolean checkRight(Square square) {
        return checkStack(maze.getSquare(square.getXCo() + 1, square.getYCo()));
    }

    boolean checkBot(Square square) {
        return checkStack(maze.getSquare(square.getXCo(), square.getYCo() + 1));
    }

    int getRandomDir() {
        return Math.round(random(-0.5, 3.5));
    }
}

// Class that implements the Kruskals maze generation algorithm
class Kruskals implements IGenerator {
    boolean pathsInitialised;
    Set_Hash kruskalsSets;
    int setNumber = 0;
    ArrayList < Integer > remainingPaths;
    Boolean setsCreated;

    Kruskals() {
        this.pathsInitialised = false;
        this.setNumber = 0;
        this.remainingPaths = new ArrayList();
        this.setsCreated = false;
    }
    
    String getName(){
      return "7_kruskals";
    }

    void reset() {
        pathsInitialised = false;
        setNumber = 0;
        remainingPaths = new ArrayList();
        setsCreated = false;
    }

    void generate() {
        if (!setsCreated) {
            if (kruskalsSets != null && kruskalsSets.size == ((maze.getNumberOfRows()-1) * (maze.getNumberOfColumns()-1))){
              kruskalsSets.clear();
            } else {
              kruskalsSets = new Set_Hash((maze.getNumberOfRows()-1) * (maze.getNumberOfColumns()-1));
            }
            setsCreated = true;
        }

        if (!pathsInitialised) {
            getAllPossiblePaths();
            pathsInitialised = true;
        }

        solve();
    }

    void solve() {
        if (generated == true) {
            return;
        }

        int rand = 0;

        boolean valid = false;

        int startX = 0, startY = 0, endX = 0, endY = 0;
        Square startSquare = null, endSquare = null;

        while (valid == false) {
            do {
                try {
                    rand = remainingPaths.get(Math.round(random(0, remainingPaths.size() - 1)));
                } catch (Exception NullPointerException) {
                    generated = true;
                    maze.generationComplete();
                    return;
                }

                remainingPaths.remove((Integer) rand);

                if (rand < ((maze.getNumberOfColumns()) * (maze.getNumberOfRows()-1))) {
                    startX = rand % (maze.getNumberOfColumns());
                    startY = (int)(rand / (maze.getNumberOfColumns()));

                    endX = 1 + (rand % (maze.getNumberOfColumns()));
                    endY = (int)((rand / (maze.getNumberOfColumns())));

                    startSquare = maze.getSquare(startX, startY);
                    endSquare = maze.getSquare(endX, endY);
                } else {
                    rand -= (maze.getNumberOfRows()-1) * (maze.getNumberOfColumns());

                    startX = rand % (maze.getNumberOfColumns());
                    startY = (int)(rand / (maze.getNumberOfColumns()));

                    endX = rand % (maze.getNumberOfColumns());
                    endY = 1 + (int)((rand / (maze.getNumberOfColumns())));

                    startSquare = maze.getSquare(startX, startY);
                    endSquare = maze.getSquare(endX, endY);
                }

            } while (startSquare == null || endSquare == null);

            if (startSquare.getSet() == endSquare.getSet() && (startSquare.getSet() != -1 && endSquare.getSet() != -1)) {
                continue;
            } else {
                valid = true;
            }

            maze.getPaths().addPath(new Path(startSquare, endSquare));

            if (startSquare.getSet() != -1 && endSquare.getSet() != -1) {
                kruskalsSets.mergeSets(endSquare.getSet(), startSquare.getSet());
            }

            if (startSquare.getSet() != -1 && endSquare.getSet() == -1) {
                kruskalsSets.addToSet(startSquare.getSet(), endSquare);
            }

            if (startSquare.getSet() == -1 && endSquare.getSet() != -1) {
                kruskalsSets.addToSet(endSquare.getSet(), startSquare);
            }

            if (startSquare.getSet() == -1 && endSquare.getSet() == -1) {
                kruskalsSets.addToSet(setNumber, startSquare);
                kruskalsSets.addToSet(setNumber, endSquare);
                setNumber++;
            }
        }
    }

    void getAllPossiblePaths() {
        for (int i = 0; i < (((maze.getNumberOfColumns()) * (maze.getNumberOfRows()-1)) + ((maze.getNumberOfColumns()-1) * (maze.getNumberOfRows()))); i++) {
            remainingPaths.add(i);
        }
    }
}

// Class the performs the Prims algorithm for maze generation
class Prims implements IGenerator {
    boolean primInitialised;
    ArrayList < Square > mainSet;
    Square_HashMap mainSetSquares;
    ArrayList < Path > possiblePaths;
    Square primStartSquare;

    Prims() {
        this.primInitialised = false;
        this.mainSet = new ArrayList();
        this.possiblePaths = new ArrayList();
    }
    
    String getName(){
      return "08_prims";
    }

    void reset() {
        primInitialised = false;
        mainSet.clear();
        possiblePaths.clear();
        primStartSquare = null;
    }

    void generate() {
        if (generated) {
            return;
        }

        if (!primInitialised) {
            mainSetSquares = new Square_HashMap((maze.getNumberOfRows()) * (maze.getNumberOfColumns()));
            getFirstSquare();
            primInitialised = true;
        }

        if (mainSet.size() < maze.squares.size()) {
            getPossibleWalls();
            pickRandomWall();
        } else {
            mainSet.clear();
            generated = true;
            maze.generationComplete();
        }
    }

    void pickRandomWall() {
        int randIndex = Math.round(random(0, possiblePaths.size() - 1));
        Path foundPath = possiblePaths.get(randIndex);
        foundPath.getEndSquare().setSet(1);
        mainSet.add(foundPath.getEndSquare());
        mainSetSquares.addSquare(foundPath.getEndSquare());
        maze.getPaths().addPath(foundPath);
        possiblePaths.remove(randIndex);
    }

    void getFirstSquare() {
        Square first = maze.getRandomSquare();
        primStartSquare = first;
        first.setSet(1);
        mainSet.add(first);
        mainSetSquares.addSquare(first);
    }

    void getPossibleWalls() {
        try {
            getPossiblePaths(mainSet.get(mainSet.size() - 1));
        } catch (Exception ArrayIndexOutOfBoundsException) {
            mainSet.clear();
            generated = true;
            maze.generationComplete();
        }
    }

    void getPossiblePaths(Square square) {

        int i = 0;
        while (i < possiblePaths.size()) {
            if (possiblePaths.get(i) == null) {
                return;
            }

            if (possiblePaths.get(i).contains(square) == 1) {
                possiblePaths.remove(possiblePaths.get(i));
                continue;
            }
            i++;
        }

        Path above = primCheckAbove(square);

        if (above != null) {
            possiblePaths.add(above);
        }

        Path below = primCheckBelow(square);
        if (below != null) {
            possiblePaths.add(below);
        }

        Path left = primCheckLeft(square);
        if (left != null) {
            possiblePaths.add(left);
        }

        Path right = primCheckRight(square);
        if (right != null) {
            possiblePaths.add(right);
        }
    }

    Path primCheckAbove(Square square) {
        Square aboveSquare = maze.getSquare(square.getXCo(), square.getYCo() - 1);
        if (aboveSquare != null && aboveSquare.getSet() == -1) {
            return new Path(square, aboveSquare);
        }
        return null;
    }

    Path primCheckBelow(Square square) {
        Square belowSquare = maze.getSquare(square.getXCo(), square.getYCo() + 1);
        if (belowSquare != null && belowSquare.getSet() == -1) {
            return new Path(square, belowSquare);
        }
        return null;
    }

    Path primCheckLeft(Square square) {
        Square leftSquare = maze.getSquare(square.getXCo() - 1, square.getYCo());
        if (leftSquare != null && leftSquare.getSet() == -1) {
            return new Path(square, leftSquare);
        }
        return null;
    }

    Path primCheckRight(Square square) {
        Square rightSquare = maze.getSquare(square.getXCo() + 1, square.getYCo());
        if (rightSquare != null && rightSquare.getSet() == -1) {
            return new Path(square, rightSquare);
        }
        return null;
    }
}

// Class the performs the Recursive Divide algorithm for maze generation
class Recursive_Divide implements IGenerator {
    boolean cleared;
    ArrayList < ArrayList < Integer >> fieldStack;
    boolean pathsGenerated;

    Recursive_Divide() {
        this.cleared = false;
        this.fieldStack = new ArrayList();
        this.pathsGenerated = false;
    }
    
    
    String getName(){
      return "09_recursive_divide";
    }

    void reset() {
        cleared = false;
        fieldStack.clear();
        pathsGenerated = false;
    }

    void generate() {
        if (generated) {
            return;
        }

        if (!cleared) {
            maze.clear();
            cleared = !cleared;
            fieldStack.add(new ArrayList(Arrays.asList(0, 0, maze.getNumberOfColumns()-1, maze.getNumberOfRows()-1)));
        }

        ArrayList < Integer > lastStackElem = new ArrayList();

        try {
            lastStackElem = fieldStack.get(fieldStack.size() - 1);
        } catch (Exception ArrayIndexOutOfBoundsException) {
            if (!pathsGenerated) {
                maze.generatePaths();
                pathsGenerated = true;
            }
            generated = true;
            maze.generationComplete();
            return;
        }

        int startX = lastStackElem.get(0);
        int startY = lastStackElem.get(1);
        int endX = lastStackElem.get(2);
        int endY = lastStackElem.get(3);

        if (endX - startX == 0 || endY - startY == 0) {
            deleteFromStack(startX, startY, endX, endY);
            return;
        }

        if (endY - startY > endX - startX) {
            int horizontalWallY = Math.round(random(startY, endY - 1));
            addHorizontalWall(startX, endX, horizontalWallY);

            int horizontalWallGapX = Math.round(random(startX, endX));
            maze.getSquare(horizontalWallGapX, horizontalWallY).removeDownWall();
            maze.getSquare(horizontalWallGapX, horizontalWallY + 1).removeUpWall();

            addToStack(startX, startY, endX, horizontalWallY);
            addToStack(startX, horizontalWallY + 1, endX, endY);
        } else if (endY - startY < endX - startX) {
            int verticalWallX = Math.round(random(startX, endX - 1));
            addVerticalWall(startY, endY, verticalWallX);

            int verticalWallGapY = Math.round(random(startY, endY));
            maze.getSquare(verticalWallX, verticalWallGapY).removeRightWall();
            maze.getSquare(verticalWallX + 1, verticalWallGapY).removeLeftWall();

            addToStack(startX, startY, verticalWallX, endY);
            addToStack(verticalWallX + 1, startY, endX, endY);
        } else {
            int rand = Math.round(random(0, 1));
            if (rand == 1) {
                int horizontalWallY = Math.round(random(startY, endY - 1));
                addHorizontalWall(startX, endX, horizontalWallY);

                int horizontalWallGapX = Math.round(random(startX, endX));
                maze.getSquare(horizontalWallGapX, horizontalWallY).removeDownWall();
                maze.getSquare(horizontalWallGapX, horizontalWallY + 1).removeUpWall();

                addToStack(startX, startY, endX, horizontalWallY);
                addToStack(startX, horizontalWallY + 1, endX, endY);
            } else {
                int verticalWallX = Math.round(random(startX, endX - 1));
                addVerticalWall(startY, endY, verticalWallX);

                int verticalWallGapY = Math.round(random(startY, endY));
                maze.getSquare(verticalWallX, verticalWallGapY).removeRightWall();
                maze.getSquare(verticalWallX + 1, verticalWallGapY).removeLeftWall();

                addToStack(startX, startY, verticalWallX, endY);
                addToStack(verticalWallX + 1, startY, endX, endY);
            }
        }
        deleteFromStack(startX, startY, endX, endY);
    }

    void addToStack(int startX, int startY, int endX, int endY) {
        ArrayList < Integer > toAdd = new ArrayList(Arrays.asList(startX, startY, endX, endY));
        fieldStack.add(toAdd);
    }

    void deleteFromStack(int startX, int startY, int endX, int endY) {
        ArrayList < Integer > toCheck = new ArrayList(Arrays.asList(startX, startY, endX, endY));
        int itt = fieldStack.size();
        for (int i = 0; i < itt; i++) {
            if (fieldStack.get(i).equals(toCheck)) {
                fieldStack.remove(fieldStack.get(i));
                break;
            }
        }
    }

    // Wall will be below the specified squares
    void addHorizontalWall(int startX, int endX, int y) {
        int colNum = startX;
        while (colNum <= endX) {
            maze.getSquare(colNum, y).addDownWall();
            maze.getSquare(colNum, y + 1).addUpWall();
            colNum++;
        }
    }

    // Wall will be right of the specified squares
    void addVerticalWall(int startY, int endY, int x) {
        int rowNum = startY;
        while (rowNum <= endY) {
            maze.getSquare(x, rowNum).addRightWall();
            maze.getSquare(x + 1, rowNum).addLeftWall();
            rowNum++;
        }
    }
}

// Class that performed the Sidewinder algorthm for maze generation
class Side_Winder implements IGenerator {
    Set_Hash rowRunSets;
    boolean sideInitialised;
    int sideY, sideX;
    ArrayList < Integer > setsAddedToRow;
    int setNumber = 0;

    Side_Winder() {
        this.sideInitialised = false;
        this.sideY = 1;
        this.sideX = 0;
        this.setNumber = 0;
        this.setsAddedToRow = new ArrayList();
    }
    
    String getName(){
      return "10_sidewinder";
    }

    void reset() {
        this.sideInitialised = false;
        this.sideY = 1;
        this.sideX = 0;
        this.setNumber = 0;
        this.setsAddedToRow = new ArrayList();
    }

    void generate() {
        if (generated) {
            return;
        }

        if (!sideInitialised) {
            rowRunSets = new Set_Hash((maze.getNumberOfRows()) * (maze.getNumberOfColumns()));
            clearTopRow();
            sideInitialised = true;
        }

        if (sideX < maze.getNumberOfColumns()) {
            Square currentSquare = maze.getSquare(sideX, sideY);

            rowRunSets.addToSet(setNumber, currentSquare);

            if (sideX < maze.getNumberOfColumns()-1) {
                if (random(1) < 0.5) {
                    maze.getPaths().addPath(new Path(currentSquare, maze.getSquare(currentSquare.getXCo() + 1, currentSquare.getYCo())));
                } else {
                    setsAddedToRow.add(setNumber);
                    setNumber++;
                }
            } else {
                setsAddedToRow.add(setNumber);
                setNumber++;
            }
            sideX++;
            return;
        } else {
            sideX = 0;
        }

        if (sideY < maze.getNumberOfRows()-1) {
            for (Integer setNumber: setsAddedToRow) {
                Small_Square_Hash set = rowRunSets.getSet(setNumber);
                int rand = Math.round(random(0, set.allSquares.size() - 1));

                Square selectedSquare = set.allSquares.get(rand);

                maze.getPaths().addPath(new Path(selectedSquare, maze.getSquare(selectedSquare.getXCo(), selectedSquare.getYCo() - 1)));
            }
            setsAddedToRow.clear();
            sideY++;
        } else {
            for (Integer setNumber: setsAddedToRow) {
                Small_Square_Hash set = rowRunSets.getSet(setNumber);
                int rand = Math.round(random(0, set.allSquares.size() - 1));

                Square selectedSquare = set.allSquares.get(rand);

                maze.getPaths().addPath(new Path(selectedSquare, maze.getSquare(selectedSquare.getXCo(), selectedSquare.getYCo() - 1)));
            }

            currentSquare = null;
            generated = true;
            maze.generationComplete();
            generated = true;
        }
    }

    void clearTopRow() {
        for (int i = 0; i < maze.getNumberOfColumns()-1; i++) {
            maze.getPaths().addPath(new Path(maze.getSquare(i, 0), maze.getSquare(i + 1, 0)));
        }
    }
}

// Class the performs the Wilsons algorithm for maze generation
class Wilsons implements IGenerator {
    ArrayList < Square > currentWalkList;
    boolean wilsonInit;
    boolean walkStarted;
    Square_HashMap currentWalk;
    Square_HashMap visitedSquares;

    int numAdded;

    Wilsons() {
        this.currentWalkList = new ArrayList();
        this.numAdded = 1;
        this.wilsonInit = false;
        this.walkStarted = false;
    }
    
    String getName(){
      return "11_wilsons";
    }

    void reset() {
        currentWalkList.clear();
        wilsonInit = false;
        numAdded = 1;
        walkStarted = false;
    }

    void generate() {
        if (generated) {
            return;
        }

        if (numAdded == (maze.getNumberOfRows()) * (maze.getNumberOfColumns())) {
            generated = true;
            maze.generationComplete();
            return;
        }

        if (!wilsonInit) {
            visitedSquares = new Square_HashMap((maze.getNumberOfColumns()) * (maze.getNumberOfRows()));
            Square first = getRandomPoint();

            if (first == null) {
                maze.generationComplete();
                generated = true;
                return;
            }

            visitedSquares.addSquare(first);
            currentWalk = new Square_HashMap((maze.getNumberOfColumns()) * (maze.getNumberOfRows()));
            wilsonInit = true;
        }

        if (!walkStarted) {
            currentSquare = getRandomPoint();
            currentWalkList.add(currentSquare);
            currentWalk.addSquare(currentSquare);
            walkStarted = true;
        }
        randomWalk();
    }

    Square getRandomPoint() {
        Square randomSquare;

        do {
            randomSquare = maze.getRandomSquare();
        } while (visitedSquares.containsSquare(randomSquare));

        return randomSquare;
    }

    void randomWalk() {
        Square nextSquare = null;
        ArrayList < Integer > possible = new ArrayList(Arrays.asList(0, 1, 2, 3));

        do {
            int randInd = Math.round(random(-0.5, possible.size() - 0.5));

            int direction = possible.get(randInd);

            possible.remove((Integer) direction);

            if (direction == 0) {
                nextSquare = maze.getSquareAbove(currentSquare);
            } else if (direction == 1) {
                nextSquare = maze.getSquareRight(currentSquare);
            } else if (direction == 2) {
                nextSquare = maze.getSquareBelow(currentSquare);
            } else if (direction == 3) {
                nextSquare = maze.getSquareLeft(currentSquare);
            }

            if (currentWalkList.size() >= 2 && nextSquare == currentWalkList.get(currentWalkList.size() - 2)) {
                continue;
            }
        } while (nextSquare == null);


        if (currentWalk.containsSquare(nextSquare)) {
            eraseLoopInCurrentWalk(nextSquare);
            return;
        }

        if (visitedSquares.containsSquare(nextSquare)) {
            maze.getPaths().addPath(new Path(nextSquare, currentWalkList.get(currentWalkList.size() - 1)));
            addCurrentWalkToLoop();
            return;
        }

        currentSquare = nextSquare;
        currentWalkList.add(currentSquare);
        currentWalk.addSquare(currentSquare);
    }

    void eraseLoopInCurrentWalk(Square square) {
        for (int i = currentWalkList.size() - 1; i >= 0; i--) {
            if (currentWalkList.get(i) == square) {
                int toDelInd = currentWalkList.size() - 1;
                for (int j = toDelInd; j > i; j--) {
                    currentWalkList.remove(j);
                }
                break;
            }
            currentWalk.removeSquare(currentWalkList.get(i));
        }
        currentSquare = square;
    }

    void addCurrentWalkToLoop() {
        int nextInd = 1;
        for (Square square: currentWalkList) {

            if (nextInd < currentWalkList.size()) {
                maze.getPaths().addPath(new Path(square, currentWalkList.get(nextInd)));
                nextInd++;
            }

            visitedSquares.addSquare(square);
            numAdded++;
            currentWalk.removeSquare(square);
        }
        currentWalkList.clear();
        walkStarted = false;
    }
}
