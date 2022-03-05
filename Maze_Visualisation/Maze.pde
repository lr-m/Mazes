/**
 * This class implements the maze that is used to display the generation and solving algorithms.
 */
class Maze {
    int x, y, w, h;
    ArrayList < Square > squares;
    Square_HashMap squareHashMap;
    Path_HashMap paths;
    int numOfRows, numOfColumns;
    float squareSize;
    
    float squareHeight, squareWidth;

    // Constructor
    Maze(int x, int y, int w, int h) {
        this.squares = new ArrayList();
        this.w = w;
        this.h = h;
        this.x = x;
        this.y = y;
    }
    
    // Getters
    
    int getWidth() {
        return w;
    }

    int getHeight() {
        return h;
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
    
    void addPath(Square start, Square end){
        Path newPath = new Path(start, end);
        paths.addPath(newPath, false);
        newPath.removeWallBetween(true);
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
    
    // Gets a random square from the maze
    Square getRandomSquare() {
        Square toReturn = null;
        while (toReturn == null) {
            toReturn = maze.getSquare(Math.round(random(0, maze.getNumberOfColumns())), Math.round(random(0, maze.getNumberOfRows())));
        }
        return toReturn;
    }
    
    // Return the square that has been clicked on by the user
    Square getSelectedSquare() {
        for (Square square: squares) {
            if (square.getX() <= mouseX && square.getX() + square.getWidth() >= mouseX) {
                if (square.getY() <= mouseY && square.getY() + square.getHeight() >= mouseY) {
                    return square;
                }
            }
        }
        return null;
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
        squaresToUpdate.add(square);
        return getSquare(square.getXCo(), square.getYCo() - 1);
    }

    // Get the square located below the passed square
    Square getSquareBelow(Square square) {
        squaresToUpdate.add(square);
        return getSquare(square.getXCo(), square.getYCo() + 1);
    }

    // Get the square located right of the passed square
    Square getSquareRight(Square square) {
        squaresToUpdate.add(square);
        return getSquare(square.getXCo() + 1, square.getYCo());
    }

    // Get the square located left of the passed square
    Square getSquareLeft(Square square) {
        squaresToUpdate.add(square);
        return getSquare(square.getXCo() - 1, square.getYCo());
    }
    
    // Setters
    
    // Update the num of rows and num of col variables as the size slider changes
    void updateRowAndColCounts() {
        squareSize = sizeSlider.getValue();

        numOfColumns = (int) Math.floor(w / squareSize) - 1;
        numOfRows = (int) Math.floor(h / squareSize) - 1;
    }
    
    // Utility

    // Create the maze grid
    void create() {
        squareSize = sizeSlider.getValue();

        float xBuffer = squareSize * ((w / squareSize) - (int)(w / squareSize));
        float yBuffer = squareSize * ((h / squareSize) - (int)(h / squareSize));

        numOfColumns = (int) Math.floor(w / squareSize) - 1;
        numOfRows = (int) Math.floor(h / squareSize) - 1;

        squareHashMap = new Square_HashMap((int)((w / squareSize) * (h / squareSize)));
        squares.clear();

        for (int xCo = 0; xCo * squareSize <= w - squareSize; xCo++) {
            for (int yCo = 0; yCo * squareSize <= h - squareSize; yCo++) {
                Square newSquare = new Square(squareSize + (xBuffer / numOfColumns), squareSize + (yBuffer / numOfRows), x + (xCo * (squareSize + (xBuffer / numOfColumns))), y + (yCo * (squareSize + (yBuffer / numOfRows))), xCo, yCo);
                squareHashMap.addSquare(newSquare);
                squares.add(newSquare);
            }
        }
        
        this.squareHeight = squareSize + (yBuffer / numOfRows);
        this.squareWidth = squareSize + (xBuffer / numOfColumns);

        paths = new Path_HashMap((int) Math.pow(numOfColumns + 1, 2));
        solution = new Square_HashMap((numOfRows + 1) * (numOfColumns + 1));
    }
    
    float getSquareHeight(){
      return squareHeight;
    }
    
    float getSquareWidth(){
      return squareWidth;
    }
    
    
    char[][] getTextRepresentation(){
      char[][] maze = new char[1 + (getNumberOfColumns()+1)*2][1 + (getNumberOfRows()+1)*2];
      if (generated){
        for (int i = 0; i < 1 + (getNumberOfColumns()+1)*2; i++){
          maze[i][0] = 'x';
          maze[i][(getNumberOfRows()+1)*2] = 'x';
        }
        
        for (int i = 0; i < 1 + (getNumberOfRows()+1)*2; i++){
          maze[0][i] = 'x';
          maze[(getNumberOfColumns()+1)*2][i] = 'x';
        }
      }
      
      for (Square square : getSquares()){
        int xCo = square.getXCo();
        int yCo = square.getYCo();
        
        if (square.leftWall){
          maze[2*xCo][1 + 2*yCo] = 'x';
          maze[2*xCo][2 + 2*yCo] = 'x';
          maze[2*xCo][2*yCo] = 'x';
        }
        
        if (square.upWall){
          maze[1 + 2*xCo][2*yCo] = 'x';
          maze[2*xCo][2*yCo] = 'x';
          maze[2 + 2*xCo][2*yCo] = 'x';
        }
      }
      
      for (int i = 0; i < 1 + (getNumberOfRows()+1)*2; i++){
        for (int j = 0; j < 1 + (getNumberOfColumns()+1)*2; j++){
          if(maze[j][i] != 'x'){
            maze[j][i] = 'o';
          }
          output.print(maze[j][i]);
        }
        output.println();
      }
      
      return maze;
    }

    // Overwrite the maze with a white background
    void overwrite() {
        fill(25);
        noStroke();
        rect(x + (w/2), y + (h/2), w, h);
    }

    // Clear the solution of the maze
    void clearSolution() {
        solutionList.clear();
        solved = false;
        solution = new Square_HashMap((numOfRows + 1) * (numOfColumns + 1));
        solvePressed = false;
        overwrite();

        for (Square square: getSquares()) {
            square.display();
        }
    }

    // Draw the solution of the maze
    void drawSolution() {
        for (int i = 1; i < solutionList.size(); i++) {
            connectSquares(solutionList.get(i - 1), solutionList.get(i));
        }
    }

    // Connect the 2 squares with an amber line (used to visualise the solution)
    void connectSquares(Square square1, Square square2) {
        float square1X = square1.getCenterX();
        float square1Y = square1.getCenterY();
        float square2X = square2.getCenterX();
        float square2Y = square2.getCenterY();

        strokeWeight((float)(9 - (Math.log(numOfRows) / Math.log(2))));
        stroke(225, 150, 0);
        line(square1X, square1Y, square2X, square2Y);

        stroke(0);
        strokeWeight(1);
    }

    // Once the generation is complete, clear the maze and draw the walls
    void generationComplete() {
        if ((generated && !solved || (solved && generated))) {
            overwrite();

            for (Square square: maze.squares) {
                square.display();
            }
        }
        paths = new Path_HashMap((int) Math.pow(numOfColumns + 1, 2));
        generatePaths();
    }

    // Clears all edges from the maze
    void generatePaths() {
        for (Square square: maze.getSquares()) {
            ArrayList < Boolean > edges = square.getWalls();

            if (!edges.get(0)) {
                maze.getPaths().addPath(new Path(square, maze.getSquare(square.getXCo(), square.getYCo() - 1)), false);
            }

            if (!edges.get(1)) {
                maze.getPaths().addPath(new Path(square, maze.getSquare(square.getXCo() + 1, square.getYCo())), false);
            }

            if (!edges.get(2)) {
                maze.getPaths().addPath(new Path(square, maze.getSquare(square.getXCo(), square.getYCo() + 1)), false);
            }

            if (!edges.get(3)) {
                maze.getPaths().addPath(new Path(square, maze.getSquare(square.getXCo() - 1, square.getYCo())), false);
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
        maze.paths = new Path_HashMap((int) Math.pow(numOfColumns + 1, 2));
        for (Square square: squares) {
            square.setWalls(true, true, true, true);
            square.setSet(-1);
        }
    }
    
    void redrawEdge(){
        fill(256);
        stroke(255);
        strokeWeight(5);
        rect(x + (w/2), y + (h/2), w + 5, h + 5);
        strokeWeight(1);   
    }

    // Draw the grid
    void display() {
        fill(256);
        stroke(255);
        strokeWeight(5);
        rect(x + (w/2), y + (h/2), w + 2.5, h + 2.5);
        strokeWeight(1);

        if (solved) {
            drawSolution();
        }

        for (Square square: squaresToUpdate) {
            if (square != null) {
                square.display();
            }
        }

        squaresToUpdate.clear();
    }

    // Check if the mouse is positioned over the maze
    boolean MouseIsOver() {
        if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) {
            return true;
        }
        return false;
    }
}
