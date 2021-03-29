/**
 * The interface used by the maze generators.
 */
interface IGenerator {
    String getName();
    
    void initialise();
  
    void generate();
}

/**
 * Implements the Aldous-Broder algorithm for maze generation.
 */
class Aldous_Broder implements IGenerator {
    int added;
    Square_HashMap visitedSquares;

    Aldous_Broder() {}
    
    void initialise(){
      this.added = 1;
      this.visitedSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
      
      currentSquare = maze.getRandomSquare();
      squaresToUpdate.add(currentSquare);
      visitedSquares.addSquare(currentSquare);
    }
    
    String getName(){
      return "1_aldous";
    }

    void generate() {
        if (generated) {
            return;
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

        squaresToUpdate.add(currentSquare);

        if (!visitedSquares.containsSquare(currentSquare)) {
            maze.addPath(currentSquare, oldSquare);
            visitedSquares.addSquare(currentSquare);
            added++;
        }

        if (added == (maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1)) {
            generated = true;
            maze.generationComplete();
        }
    }
}

/**
 * Implements the Backtracking algorithm for maze generation.
 */
class Backtracker implements IGenerator {
    ArrayList < Square> routeStack;
    Boolean backtracking;
    
    Square_HashMap visitedSquares;
    Square_HashMap routeSquares;

    Backtracker(){}
    
    void initialise(){
      this.routeStack = new ArrayList();
      this.backtracking = false;
      
      currentSquare = maze.getRandomSquare();
      routeStack.add(currentSquare);

      visitedSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
      routeSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));

      visitedSquares.addSquare(currentSquare);
      routeSquares.addSquare(currentSquare);
      
      squaresToUpdate.add(currentSquare);
    }
    
    String getName(){
      return "2_backtracker";
    }

    void generate() {
        if (generated) {
            return;
        }

        if (backtracking) {
            if (atDeadEnd()) {
                currentSquare = popSquare();
            } else {
                backtracking = false;
            }
        } else {
            Square oldSquare = currentSquare;
            ArrayList < Integer > directions = new ArrayList(Arrays.asList(0, 1, 2, 3));
            
            do {
                if (currentSquare == null) {
                    currentSquare = oldSquare;
                }

                int direction = directions.get(Math.round(random(-0.5, directions.size() - 0.5)));

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

            maze.addPath(currentSquare, oldSquare);
            
            routeStack.add(currentSquare);
            routeSquares.addSquare(currentSquare);
            visitedSquares.addSquare(currentSquare);

            if (atDeadEnd()) {
                backtracking = true;
            }
            
            squaresToUpdate.add(currentSquare);
        }
    }

    Square popSquare() {
        Square toReturn;

        try {
            toReturn = routeStack.get(routeStack.size() - 1);
        } catch (Exception ArrayIndexOutOfBoundsException) {
            visitedSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
            routeSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));

            generated = true;
            maze.generationComplete();
            return null;
        }

        squaresToUpdate.add(routeStack.get(routeStack.size() - 1));
        routeSquares.removeSquare(routeStack.get(routeStack.size() - 1));
        routeStack.remove(routeStack.size() - 1);

        return toReturn;
    }

    boolean atDeadEnd() {
        if (currentSquare != null) {
            if (currentSquare.getXCo() == 0 && currentSquare.getYCo() == 0) {
                return checkBelow(currentSquare) && checkRight(currentSquare);
            } else if (currentSquare.getXCo() == maze.getNumberOfColumns() && currentSquare.getYCo() == maze.getNumberOfRows()) {
                return checkAbove(currentSquare) && checkLeft(currentSquare);
            } else if (currentSquare.getXCo() == 0 && currentSquare.getYCo() == maze.getNumberOfRows()) {
                return checkAbove(currentSquare) && checkRight(currentSquare);
            } else if (currentSquare.getXCo() == maze.getNumberOfColumns() && currentSquare.getYCo() == 0) {
                return checkBelow(currentSquare) && checkLeft(currentSquare);
            } else if (currentSquare.getXCo() == 0) {
                return checkAbove(currentSquare) && checkBelow(currentSquare) && checkRight(currentSquare);
            } else if (currentSquare.getYCo() == 0) {
                return checkLeft(currentSquare) && checkRight(currentSquare) && checkBelow(currentSquare);
            } else if (currentSquare.getXCo() == maze.getNumberOfColumns()) {
                return checkAbove(currentSquare) && checkBelow(currentSquare) && checkLeft(currentSquare);
            } else if (currentSquare.getYCo() == maze.getNumberOfRows()) {
                return checkLeft(currentSquare) && checkRight(currentSquare) && checkAbove(currentSquare);
            } else {
                return checkLeft(currentSquare) && checkRight(currentSquare) && checkAbove(currentSquare) && checkBelow(currentSquare);
            }
        }
        return true;
    }

    boolean checkLeft(Square square) {
        return checkStack(maze.getSquareLeft(square));
    }

    boolean checkAbove(Square square) {
        return checkStack(maze.getSquareAbove(square));
    }

    boolean checkRight(Square square) {
        return checkStack(maze.getSquareRight(square));
    }

    boolean checkBelow(Square square) {
        return checkStack(maze.getSquareBelow(square));
    }

    boolean checkStack(Square square) {
        return visitedSquares.containsSquare(square);
    }

    int getRandomDir() {
        return Math.round(random(-0.5, 3.5));
    }
}

/**
 * Implements the Binary-tree algorithm for maze generation.
 */
class Binary_Tree implements IGenerator {
    int xPos, yPos;
    
    Binary_Tree() {}
    
    String getName(){
      return "3_binary";
    }
    
    void initialise(){
        yPos = maze.getNumberOfRows();
        xPos = maze.getNumberOfColumns();
    }

    void generate() {
        if (generated) {
            return;
        }

        Square lastSquare = currentSquare;

        if (lastSquare != null) {
            squaresToUpdate.add(lastSquare);
        }

        if (yPos >= 0) {
            if (xPos >= 0) {
                currentSquare = maze.getSquare(xPos, yPos);

                squaresToUpdate.add(currentSquare);

                if (xPos == 0 && yPos == 0) {
                    currentSquare = null;
                    generated = true;
                    maze.generationComplete();
                    return;
                } else if (currentSquare.getXCo() == 0) {
                    addAbove(currentSquare);
                } else if (currentSquare.getYCo() == 0) {
                    addLeft(currentSquare);
                } else {
                    int rand = Math.round(random(0, 1));

                    if (rand == 1) {
                        addAbove(currentSquare);
                    } else {
                        addLeft(currentSquare);
                    }
                }
                xPos--;
            } else {
                xPos = maze.getNumberOfColumns();
                yPos--;
            }
        }
    }

    void addAbove(Square thisSquare) {
        Path newPath = new Path(thisSquare, maze.getSquare(thisSquare.getXCo(), thisSquare.getYCo() - 1));
        maze.getPaths().addPath(newPath, true);
        squaresToUpdate.add(maze.getSquare(thisSquare.getXCo(), thisSquare.getYCo() - 1));
    }

    void addLeft(Square thisSquare) {
        Path newPath = new Path(thisSquare, maze.getSquare(thisSquare.getXCo() - 1, thisSquare.getYCo()));
        maze.getPaths().addPath(newPath, true);
        squaresToUpdate.add(maze.getSquare(thisSquare.getXCo() - 1, thisSquare.getYCo()));
    }
}

/**
 * Implements a recursive division algorithm that does not produce straight walls for maze generation.
 */
class Blobby_Recursive implements IGenerator {
    Set_Hash sets;
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

    Blobby_Recursive() {}
    
    String getName(){
      return "4_blobby_recursive";
    }
    
    void initialise(){
        setNumbersToDivide = new ArrayList();
        setNumber = 0;
        nextSet = true;
      
        maze.clear();
        sets = new Set_Hash(2 * (maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
  
        for (Square square: maze.getSquares()) {
            sets.addToSet(0, square);
        }
  
        setNumbersToDivide.add(0);
    }

    void generate() {
        if (generated) {
            return;
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
                    squaresToUpdate.add(square);
                }
            }

            if (sets.getSet(set1).allSquares.size() >= 4) {
                setNumbersToDivide.add(set1);
            } else {
                for (Square square: sets.getSet(set1).allSquares) {
                    square.setSet(-1);
                    squaresToUpdate.add(square);
                }
            }

            if (potentialPaths.size() > 0) {
                maze.paths.addPath(potentialPaths.remove(Math.round(random(0, potentialPaths.size() - 1))), false);

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

/**
 * Implements Ellers algorithm for maze generation.
 */
class Ellers implements IGenerator {
    Set_Hash ellersSets;
    int row, col, currentStage, setNumber;
    boolean lastRow;
    ArrayList < Integer > setsWithDownPaths;

    Ellers() {}
    
    String getName(){
      return "5_ellers";
    }
    
    void initialise(){
      this.row = 0;
      this.col = 0;
      this.currentStage = 1;
      this.lastRow = false;
      this.setsWithDownPaths = new ArrayList();
      
      this.ellersSets = new Set_Hash((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
    }

    void generate() {
        if (generated) {
            return;
        }

        if (!lastRow && row < maze.getNumberOfRows()) {
            if (currentStage == 1) {
                if (col <= maze.getNumberOfColumns()) {
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
                if (col <= maze.getNumberOfColumns()) {
                    createDownPaths(row);
                    col++;
                    return;
                }
                col = maze.getNumberOfColumns() + 1;
                currentStage = 2;
                row++;
                setsWithDownPaths = new ArrayList();
                return;
            }
        }

        lastRow = true;

        if (col <= maze.getNumberOfColumns()) {
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
            setNumber = row * (maze.getNumberOfColumns() + 1);
        }

        if (col <= maze.getNumberOfColumns()) {
            if (maze.getSquare(col, row).getSet() == -1) {
                ellersSets.addToSet(setNumber, maze.getSquare(col, row));
                setNumber++;
            }
        }
    }

    void randomUnion(int row) {
        if (col < maze.getNumberOfColumns()) {
            Square startSquare = maze.getSquare(col, row);
            Square endSquare = maze.getSquare(col + 1, row);
            if (random(1) < 0.5 && startSquare.getSet() != endSquare.getSet()) {
                ellersSets.mergeSets(startSquare.getSet(), endSquare.getSet());
                Path newPath = new Path(startSquare, endSquare);
                maze.getPaths().addPath(newPath, false);
                newPath.removeWallBetween(true);
            }
        }
    }

    void createDownPaths(int row) {
        if (col <= maze.getNumberOfColumns()) {
            Square topSquare = maze.getSquare(col, row);
            Square bottomSquare = maze.getSquare(col, row + 1);

            if (random(1) < 0.5) {
                Path newPath = new Path(topSquare, bottomSquare);
                maze.getPaths().addPath(newPath, false);
                newPath.removeWallBetween(true);
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
                        Path newPath = new Path(randomSquare, otherBottomSquare);
                        maze.getPaths().addPath(newPath, false);
                        newPath.removeWallBetween(true);
                    }
                }
            }
        }

        if (col == maze.getNumberOfColumns() + 1) {
            setNumber = row * (maze.getNumberOfColumns() + 1);
        }

        if (col <= maze.getNumberOfColumns() + 1) {
            if (maze.getSquare(col, row + 1).getSet() == -1) {
                ellersSets.addToSet(setNumber, maze.getSquare(col, row + 1));
                setNumber++;
            }
        }
    }

    void joinLastRow() {
        for (int i = 1; i <= maze.getNumberOfColumns(); i++) {
            Square startSquare = maze.getSquare(i - 1, maze.getNumberOfRows());
            Square endSquare = maze.getSquare(i, maze.getNumberOfRows());
            if (startSquare.getSet() != endSquare.getSet()) {
                ellersSets.mergeSets(startSquare.getSet(), endSquare.getSet());
                Path newPath = new Path(startSquare, endSquare);
                maze.getPaths().addPath(newPath, false);
                newPath.removeWallBetween(true);
            }
        }
    }
}

/**
 * Implements the Hunt and Kill algorithm for maze generation.
 */
class Hunt_Kill implements IGenerator {
    boolean mode;
    ArrayList < Square > remainingSquaresInMaze;
    Square_HashMap visitedSquares;

    Hunt_Kill() {}
    
    String getName(){
      return "6_hunt_kill";
    }
    
    void initialise(){
        this.mode = true;
        this.remainingSquaresInMaze = new ArrayList();
        
        currentSquare = maze.getSquare(Math.round(random(0, maze.getNumberOfColumns())), Math.round(random(0, maze.getNumberOfRows())));
        currentSquare.setSet(1);

        visitedSquares = new Square_HashMap((int) Math.pow(maze.getNumberOfColumns(), 2));

        visitedSquares.addSquare(currentSquare);

        for (int i = 0; i <= maze.getNumberOfRows(); i++) {
            for (int j = 0; j <= maze.getNumberOfColumns(); j++) {
                remainingSquaresInMaze.add(maze.getSquare(j, i));
            }
        }
    }

    void generate() {
        if (generated) {
            return;
        }
        
        squaresToUpdate.add(currentSquare);

        if (atDeadEnd(currentSquare)) {
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
                    currentSquare = maze.getSquareAbove(currentSquare);
                } else if (directionToGo == 1) {
                    currentSquare = maze.getSquareRight(currentSquare);
                } else if (directionToGo == 2) {
                    currentSquare = maze.getSquareBelow(currentSquare);
                } else {
                    currentSquare = maze.getSquareLeft(currentSquare);
                }

                maze.addPath(oldSquare, currentSquare);
                currentSquare.setSet(1);
                visitedSquares.addSquare(oldSquare);

                remainingSquaresInMaze.remove(oldSquare);

                mode = true;
                return;
            }
        }
        
        visitedSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
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
                currentSquare = maze.getSquareAbove(currentSquare);
            } else if (dir == 1) {
                currentSquare = maze.getSquareRight(currentSquare);
            } else if (dir == 2) {
                currentSquare = maze.getSquareBelow(currentSquare);
            } else if (dir == 3) {
                currentSquare = maze.getSquareLeft(currentSquare);
            }
        } while (currentSquare == null || currentSquare.getSet() != -1);

        maze.addPath(oldSquare, currentSquare);
        
        currentSquare.setSet(1);
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
        if (maze.getSquareLeft(currentSquare) == null) {
            return false;
        }

        return maze.getSquareLeft(currentSquare).getSet() == -1;
    }

    boolean checkRight() {
        if (maze.getSquareRight(currentSquare) == null) {
            return false;
        }

        return maze.getSquareRight(currentSquare).getSet() == -1;
    }

    boolean checkUp() {
        if (maze.getSquareAbove(currentSquare) == null) {
            return false;
        }

        return maze.getSquareAbove(currentSquare).getSet() == -1;
    }

    boolean checkDown() {
        if (maze.getSquareBelow(currentSquare) == null) {
            return false;
        }

        return maze.getSquareBelow(currentSquare).getSet() == -1;
    }

    boolean atDeadEnd(Square square) {
        if (currentSquare != null) {
            if (square.getXCo() == 0 && square.getYCo() == 0) {
                return checkBelow(square) && checkRight(square);
            } else if (square.getXCo() == maze.getNumberOfColumns() && square.getYCo() == maze.getNumberOfRows()) {
                return checkAbove(square) && checkLeft(square);
            } else if (square.getXCo() == 0 && square.getYCo() == maze.getNumberOfRows()) {
                return checkAbove(square) && checkRight(square);
            } else if (square.getXCo() == maze.getNumberOfColumns() && square.getYCo() == 0) {
                return checkBelow(square) && checkLeft(square);
            } else if (square.getXCo() == 0) {
                return checkAbove(square) && checkBelow(square) && checkRight(square);
            } else if (square.getYCo() == 0) {
                return checkLeft(square) && checkRight(square) && checkBelow(square);
            } else if (square.getXCo() == maze.getNumberOfColumns()) {
                return checkAbove(square) && checkBelow(square) && checkLeft(square);
            } else if (square.getYCo() == maze.getNumberOfRows()) {
                return checkLeft(square) && checkRight(square) && checkAbove(square);
            } else {
                return checkLeft(square) && checkRight(square) && checkAbove(square) && checkBelow(square);
            }
        }
        return true;
    }

    boolean checkLeft(Square square) {
        return checkStack(maze.getSquareLeft(square));
    }

    boolean checkAbove(Square square) {
        return checkStack(maze.getSquareAbove(square));
    }

    boolean checkRight(Square square) {
        return checkStack(maze.getSquareRight(square));
    }

    boolean checkBelow(Square square) {
        return checkStack(maze.getSquareBelow(square));
    }

    boolean checkStack(Square square) {
        return visitedSquares.containsSquare(square);
    }

    int getRandomDir() {
        return Math.round(random(-0.5, 3.5));
    }
}

/**
 * Implements Kruskals algorithm for maze generation.
 */
class Kruskals implements IGenerator {
    Set_Hash kruskalsSets;
    int setNumber;
    ArrayList < Integer > remainingPaths;

    Kruskals() {}
    
    String getName(){
      return "7_kruskals";
    }
    
    void initialise(){
        this.setNumber = 0;
        this.remainingPaths = new ArrayList();
        
        kruskalsSets = new Set_Hash((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
        getAllPossiblePaths();
    }

    void generate() {
        if (generated) {
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

                if (rand < ((maze.getNumberOfColumns()) * (maze.getNumberOfRows() + 1))) {
                    startX = rand % (maze.getNumberOfColumns());
                    startY = (int)(rand / (maze.getNumberOfColumns()));

                    endX = 1 + (rand % (maze.getNumberOfColumns()));
                    endY = (int)((rand / (maze.getNumberOfColumns())));

                    startSquare = maze.getSquare(startX, startY);
                    endSquare = maze.getSquare(endX, endY);
                } else {
                    rand -= (maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns());

                    startX = rand % (maze.getNumberOfColumns() + 1);
                    startY = (int)(rand / (maze.getNumberOfColumns()));

                    endX = rand % (maze.getNumberOfColumns() + 1);
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

            Path newPath = new Path(startSquare, endSquare);
            maze.getPaths().addPath(newPath, false);
            newPath.removeWallBetween(true);

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
        for (int i = 0; i < (((maze.getNumberOfColumns() + 1) * (maze.getNumberOfRows())) + ((maze.getNumberOfColumns()) * (maze.getNumberOfRows() + 1))); i++) {
            remainingPaths.add(i);
        }
    }
}

/**
 * Implements Prims algorithm for maze generation.
 */
class Prims implements IGenerator {
    ArrayList < Square > mainSet;
    Square_HashMap mainSetSquares;
    ArrayList < Path > possiblePaths;
    Square primStartSquare;

    Prims(){}
    
    String getName(){
      return "8_prims";
    }
    
    void initialise(){
        this.mainSet = new ArrayList();
        this.possiblePaths = new ArrayList();
        
        mainSetSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
        getFirstSquare();
    }

    void generate() {
        if (generated) {
            return;
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
        squaresToUpdate.add(foundPath.getEndSquare());
        maze.getPaths().addPath(foundPath, false);
        foundPath.removeWallBetween(true);
        possiblePaths.remove(randIndex);
    }

    void getFirstSquare() {
        Square first = maze.getRandomSquare();
        primStartSquare = first;
        first.setSet(1);
        mainSet.add(first);
        mainSetSquares.addSquare(first);
        squaresToUpdate.add(first);
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
        Square aboveSquare = maze.getSquareAbove(square);
        if (aboveSquare != null && aboveSquare.getSet() == -1) {
            return new Path(square, aboveSquare);
        }
        return null;
    }

    Path primCheckBelow(Square square) {
        Square belowSquare = maze.getSquareBelow(square);
        if (belowSquare != null && belowSquare.getSet() == -1) {
            return new Path(square, belowSquare);
        }
        return null;
    }

    Path primCheckLeft(Square square) {
        Square leftSquare = maze.getSquareLeft(square);
        if (leftSquare != null && leftSquare.getSet() == -1) {
            return new Path(square, leftSquare);
        }
        return null;
    }

    Path primCheckRight(Square square) {
        Square rightSquare = maze.getSquareRight(square);
        if (rightSquare != null && rightSquare.getSet() == -1) {
            return new Path(square, rightSquare);
        }
        return null;
    }
}

/**
 * Implements the Recursive Division algorithm for maze generation.
 */
class Recursive_Divide implements IGenerator {
    ArrayList < ArrayList < Integer >> fieldStack;
    boolean pathsGenerated;

    Recursive_Divide() {}
    
    String getName(){
      return "9_recursive_divide";
    }
    
    void initialise(){
        this.fieldStack = new ArrayList();
        this.pathsGenerated = false;
      
        maze.clear();
        fieldStack.add(new ArrayList(Arrays.asList(0, 0, maze.getNumberOfColumns(), maze.getNumberOfRows())));
    }

    void generate() {
        if (generated) {
            return;
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
        squaresToUpdate.add(maze.getSquare(colNum, y));
        while (colNum <= endX) {
            maze.getSquare(colNum, y).addDownWall();
            maze.getSquare(colNum, y + 1).addUpWall();
            squaresToUpdate.add(maze.getSquare(colNum, y + 1));
            colNum++;
        }
    }

    // Wall will be right of the specified squares
    void addVerticalWall(int startY, int endY, int x) {
        int rowNum = startY;
        squaresToUpdate.add(maze.getSquare(x, rowNum));
        while (rowNum <= endY) {
            maze.getSquare(x, rowNum).addRightWall();
            maze.getSquare(x + 1, rowNum).addLeftWall();
            squaresToUpdate.add(maze.getSquare(x + 1, rowNum));
            rowNum++;
        }
    }
}

/**
 * Implements the Sidewinder algorithm for maze generation.
 */
class Side_Winder implements IGenerator {
    Set_Hash rowRunSets;
    int sideY, sideX;
    ArrayList < Integer > setsAddedToRow;
    int setNumber = 0;

    Side_Winder() {}
    
    String getName(){
      return "10_sidewinder";
    }
    
    void initialise(){
        this.sideY = 1;
        this.sideX = 0;
        this.setNumber = 0;
        this.setsAddedToRow = new ArrayList();
      
        rowRunSets = new Set_Hash((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
        clearTopRow();
    }

    void generate() {
        if (generated) {
            return;
        }

        if (sideX <= maze.getNumberOfColumns()) {
            Square currentSquare = maze.getSquare(sideX, sideY);

            rowRunSets.addToSet(setNumber, currentSquare);

            squaresToUpdate.add(currentSquare);

            if (sideX != maze.getNumberOfColumns()) {
                if (random(1) < 0.5) {
                    maze.getPaths().addPath(new Path(currentSquare, maze.getSquare(currentSquare.getXCo() + 1, currentSquare.getYCo())), true);
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

        if (sideY < maze.getNumberOfRows()) {
            for (Integer setNumber: setsAddedToRow) {
                Small_Square_Hash set = rowRunSets.getSet(setNumber);
                int rand = Math.round(random(0, set.allSquares.size() - 1));

                Square selectedSquare = set.allSquares.get(rand);

                maze.getPaths().addPath(new Path(selectedSquare, maze.getSquare(selectedSquare.getXCo(), selectedSquare.getYCo() - 1)), true);

                for (Square square: set.allSquares) {
                    squaresToUpdate.add(square);
                }
            }
            setsAddedToRow.clear();
            sideY++;
        } else {
            for (Integer setNumber: setsAddedToRow) {
                Small_Square_Hash set = rowRunSets.getSet(setNumber);
                int rand = Math.round(random(0, set.allSquares.size() - 1));

                Square selectedSquare = set.allSquares.get(rand);

                maze.getPaths().addPath(new Path(selectedSquare, maze.getSquare(selectedSquare.getXCo(), selectedSquare.getYCo() - 1)), true);
            }

            currentSquare = null;
            generated = true;
            maze.generationComplete();
            generated = true;
        }
    }

    void clearTopRow() {
        squaresToUpdate.add(maze.getSquare(0, 0));
        for (int i = 0; i < maze.getNumberOfColumns(); i++) {
            maze.getPaths().addPath(new Path(maze.getSquare(i, 0), maze.getSquare(i + 1, 0)), true);
            squaresToUpdate.add(maze.getSquare(i + 1, 0));
        }
    }
}

/**
 * Implements Wilsons algorithm for maze generation.
 */
class Wilsons implements IGenerator {
    ArrayList < Square > currentWalkList;
    boolean walkStarted;
    Square_HashMap currentWalk;
    Square_HashMap visitedSquares;
    int numAdded;

    Wilsons() {}
    
    String getName(){
      return "11_wilsons";
    }
    
    void initialise(){
        this.currentWalkList = new ArrayList();
        this.numAdded = 1;
        this.walkStarted = false;
        this.visitedSquares = new Square_HashMap((maze.getNumberOfColumns() + 1) * (maze.getNumberOfRows() + 1));
        this.currentWalk = new Square_HashMap((maze.getNumberOfColumns() + 1) * (maze.getNumberOfRows() + 1));
        
        Square first = getRandomPoint();

        if (first == null) {
            maze.generationComplete();
            generated = true;
            return;
        }

        visitedSquares.addSquare(first);
        squaresToUpdate.add(first);
    }

    void generate() {
        if (generated) {
            return;
        }

        if (numAdded == (1 + maze.getNumberOfRows()) * (1 + maze.getNumberOfColumns())) {
            generated = true;
            maze.generationComplete();
            return;
        }

        if (!walkStarted) {
            currentSquare = getRandomPoint();
            currentWalkList.add(currentSquare);
            currentWalk.addSquare(currentSquare);
            squaresToUpdate.add(currentSquare);
            walkStarted = true;
        }
        
        randomWalk();
    }

    Square getRandomPoint() {
        Square randomSquare;

        do {
            randomSquare = maze.getSquare(Math.round(random(0, maze.getNumberOfColumns())), Math.round(random(0, maze.getNumberOfRows())));
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
            maze.addPath(nextSquare, currentWalkList.get(currentWalkList.size() - 1));
            addCurrentWalkToLoop();
            return;
        }

        currentSquare = nextSquare;
        currentWalkList.add(currentSquare);
        squaresToUpdate.add(currentSquare);
        currentWalk.addSquare(currentSquare);
    }

    void eraseLoopInCurrentWalk(Square square) {
        for (int i = currentWalkList.size() - 1; i >= 0; i--) {
            if (currentWalkList.get(i) == square) {
                int toDelInd = currentWalkList.size() - 1;
                for (int j = toDelInd; j > i; j--) {
                    currentWalkList.remove(j);
                }
                squaresToUpdate.add(square);
                break;
            }
            currentWalk.removeSquare(currentWalkList.get(i));
            squaresToUpdate.add(currentWalkList.get(i));
        }
        currentSquare = square;
    }

    void addCurrentWalkToLoop() {
        int nextInd = 1;
        for (Square square: currentWalkList) {

            if (nextInd < currentWalkList.size()) {
                maze.addPath(square, currentWalkList.get(nextInd));
                nextInd++;
            }

            visitedSquares.addSquare(square);
            numAdded++;
            currentWalk.removeSquare(square);
            squaresToUpdate.add(square);
        }
        currentWalkList.clear();
        walkStarted = false;
    }
}

/**
 * This class implements the Houston algorithm, which uses both Aldous-Broder and Wilson generators to converge quicker.
 */
class Houston implements IGenerator{
  Aldous_Broder aldousSolver;
  Wilsons wilsonsSolver;
  int stage;
  
  String getName(){
     return "12_houston";
  }
  
  void initialise(){
      this.aldousSolver = new Aldous_Broder();
      this.wilsonsSolver = new Wilsons();
      
      this.stage = 1;
      
      aldousSolver.initialise();
  }
  
  Houston(){}
  
  void generate(){
    if (generated){
       return; 
    }
    
    if (aldousSolver.visitedSquares.getSize() < Math.round((maze.getNumberOfRows() * maze.getNumberOfColumns())/5) && stage == 1){
      aldousSolver.generate();
    } else if (aldousSolver.visitedSquares.getSize() == Math.round((maze.getNumberOfRows() * maze.getNumberOfColumns())/5) && stage == 1){
      wilsonsSolver.initialise();
      wilsonsSolver.visitedSquares = aldousSolver.visitedSquares;
      wilsonsSolver.numAdded = Math.round((maze.getNumberOfRows() * maze.getNumberOfColumns())/5);
      stage = 2;
    } else {
      wilsonsSolver.generate(); 
    }
  }
}
