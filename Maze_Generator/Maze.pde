// The displayed maze
class Maze {
    ArrayList < Square > squares;
    Square_HashMap squareHashMap;
    Path_HashMap paths;
    int numOfRows, numOfColumns;

    // Maze constructor
    Maze() {
        this.squares = new ArrayList();
    }

    // Returns the maximum xCo of squares in the maze
    int getNumberOfRows() {
        return numOfRows;
    }

    // Returns the maximum yCo of squares in the maze
    int getNumberOfColumns() {
        return numOfColumns;
    }

    // Returns the paths used in the maze
    Path_HashMap getPaths() {
        return paths;
    }

    // Returns the square at the specified and y position
    Square getSquare(int x, int y) {
        return squareHashMap.getSquare(x, y);
    }

    Square getSquare(ArrayList < Integer > input) {
        try {
            return squareHashMap.getSquare(input.get(0), input.get(1));
        } catch (Exception NullPointerException) {
            return null;
        }
    }

    // Returns an arraylist of all the squares that the maze is composed of
    ArrayList < Square > getSquares() {
        return squares;
    }

    // Update the num of rows and num of col variables as the size slider changes
    void updateRowAndColCounts() {
        numOfColumns = (int) (numberOfColumns.getValue() - (numberOfColumns.getValue()%2));
        numOfRows = (int) (numberOfRows.getValue() - (numberOfColumns.getValue()%2));
    }

    // Create the maze grid
    void create() {
        numOfColumns = (int) numberOfColumns.getValue();
        numOfRows = (int) numberOfRows.getValue();

        squareHashMap = new Square_HashMap((numOfColumns) * (numOfRows));
        squares.clear();

        for (int i = 0; i < getNumberOfColumns(); i++) {
            for (int j = 0; j < getNumberOfRows(); j++) {
                Square newSquare = new Square(i, j);
                squareHashMap.addSquare(newSquare);
                squares.add(newSquare);
            }
        }

        paths = new Path_HashMap(getNumberOfColumns() * getNumberOfRows());
    }
    
    
    char[][] getTextRepresentation(){
      char[][] maze = new char[1 + (getNumberOfColumns())*2][1 + (getNumberOfRows())*2];
      
      if (generated){
        for (int i = 0; i < 1 + (getNumberOfColumns())*2; i++){
          maze[i][0] = '#';
          maze[i][(getNumberOfRows())*2] = '#';
        }
        
        for (int i = 0; i < 1 + (getNumberOfRows())*2; i++){
          maze[0][i] = '#';
          maze[(getNumberOfColumns())*2][i] = '#';
        }
      }
      
      for (Square square : getSquares()){
        int xCo = square.getXCo();
        int yCo = square.getYCo();
        
        if (square.leftWall){
          maze[2*xCo][1 + 2*yCo] = '#';
          maze[2*xCo][2 + 2*yCo] = '#';
          maze[2*xCo][2*yCo] = '#';
        }
        
        if (square.upWall){
          maze[1 + 2*xCo][2*yCo] = '#';
          maze[2*xCo][2*yCo] = '#';
          maze[2 + 2*xCo][2*yCo] = '#';
        }
      }
      
      return maze;
    }

    // Once the generation is complete, clear the maze and draw the walls
    void generationComplete() {
        paths = new Path_HashMap(getNumberOfColumns() * getNumberOfRows());
        generatePaths();
    }

    // Gets a random square from the maze
    Square getRandomSquare() {
        Square toReturn = null;
        while (toReturn == null) {
            toReturn = maze.getSquare(Math.round(random(0, maze.getNumberOfColumns()-1)), Math.round(random(0, maze.getNumberOfRows()-1)));
        }
        return toReturn;
    }

    // Clears all edges from the maze
    void generatePaths() {
        for (Square square: maze.getSquares()) {
            ArrayList < Boolean > edges = square.getWalls();

            if (!edges.get(0)) {
                maze.getPaths().addPath(new Path(square, maze.getSquare(square.getXCo(), square.getYCo() - 1)));
            }

            if (!edges.get(1)) {
                maze.getPaths().addPath(new Path(square, maze.getSquare(square.getXCo() + 1, square.getYCo())));
            }

            if (!edges.get(2)) {
                maze.getPaths().addPath(new Path(square, maze.getSquare(square.getXCo(), square.getYCo() + 1)));
            }

            if (!edges.get(3)) {
                maze.getPaths().addPath(new Path(square, maze.getSquare(square.getXCo() - 1, square.getYCo())));
            }
        }
    }

    // Remove the walls from each square
    void clear() {
        for (Square square: squares) {
            square.setWalls(false, false, false, false);

            if (square.getXCo() == 0) {
                square.addLeftWall();
            }

            if (square.getXCo() == numOfColumns) {
                square.addRightWall();
            }

            if (square.getYCo() == 0) {
                square.addUpWall();
            }

            if (square.getYCo() == numOfRows) {
                square.addDownWall();
            }
        }
    }

    // Reset the maze
    void reset() {
        paths.clear();
        for (Square square: squares) {
            square.setWalls(true, true, true, true);
            square.setSet(-1);
        }
    }

    // Return the neighbours of the passed square
    ArrayList < Square > getSquareNeighbours(Square square) {
        ArrayList < Square > toReturn = new ArrayList();

        if (getSquareAbove(square) != null) {
            toReturn.add(getSquareAbove(square));
        }

        if (getSquareRight(square) != null) {
            toReturn.add(getSquareRight(square));
        }

        if (getSquareLeft(square) != null) {
            toReturn.add(getSquareLeft(square));
        }

        if (getSquareBelow(square) != null) {
            toReturn.add(getSquareBelow(square));
        }

        return toReturn;
    }

    // Get the square located above the passed square
    Square getSquareAbove(Square square) {
        return getSquare(square.getXCo(), square.getYCo() - 1);
    }

    // Get the square located below the passed square
    Square getSquareBelow(Square square) {
        return getSquare(square.getXCo(), square.getYCo() + 1);
    }

    // Get the square located right of the passed square
    Square getSquareRight(Square square) {
        return getSquare(square.getXCo() + 1, square.getYCo());
    }

    // Get the square located left of the passed square
    Square getSquareLeft(Square square) {
        return getSquare(square.getXCo() - 1, square.getYCo());
    }
}
