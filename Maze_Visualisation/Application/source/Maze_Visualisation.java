import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Queue; 
import java.util.LinkedList; 
import java.util.Arrays; 
import java.lang.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Maze_Visualisation extends PApplet {






PrintWriter output;

ArrayList < Square > squaresToUpdate = new ArrayList();
ArrayList < Square > solutionList = new ArrayList();

Square_HashMap solution;

PImage play, pause, skipToEnd, next, resetButImage;

Maze maze;
Square currentSquare;

Maze_Tree tree;

IGenerator[] generators;
ISolver[] solvers;

Button generateMaze, solveMaze, clearSolution, resetPoints;
Boolean generatePressed = false, solvePressed = false;

int speed;

Boolean generated, solved, clearedAfterGeneration, startingPointSelected, endingPointSelected;

int selectedGeneration = 0, selectedSolver = 0, selectedSave = 0;

DropList generationSelector, solveSelector, saveSelector;

Square startingPoint, endingPoint;

Boolean reset = false, paused = false;
Button resetBut, pauseBut, save, skipToEndBut, nextBut;

Slider sizeSlider, speedSlider;

int picMazeNumber = 0, txtMazeNumber = 0;

public void settings() {
    fullScreen();
}

public void setup() {
    frameRate(60);
    background(225);
    rectMode(CENTER);
    
    tree = new Maze_Tree();

    generateMaze = new Button("Generate", 15, 210, 160, 20);
    solveMaze = new Button("Solve", 15, 350, 160, 20);
    clearSolution = new Button("Clear Solution", 15, 380, 160, 20);
    resetPoints = new Button("Reset Points", 15, 410, 160, 20);

    sizeSlider = new Slider(20, 70, 150, 16, 8, 64);
    speedSlider = new Slider(20, 125, 150, 16, 1, 500);

    generationSelector = new DropList(15, 180, 160, 20, "Generation Method", new ArrayList(Arrays.asList("Aldous-Broder", "BackTrack", "Binary Tree", "Blobby Recursive", "Eller's", "Houston", "Hunt & Kill", "Kruskal's", "Prim's", "Recursive Division", "Sidewinder", "Wilson's")));
    solveSelector = new DropList(15, 320, 160, 20, "Solver Method", new ArrayList(Arrays.asList("A* (Manhattan)", "Breadth-First", "Depth-First", "Left-Wall", "Right-Wall")));
    saveSelector = new DropList(15, 270, 75, 20, "Save as", new ArrayList(Arrays.asList("Text", "Image")));

    maze = new Maze(200, 75, width - 225, height - 100);
    maze.create();
    maze.overwrite();

    generated = false;
    solved = false;
    clearedAfterGeneration = false;
    startingPointSelected = false;
    endingPointSelected = false;

    pauseBut = new Button("", 10, height - 50, 35, 35);
    resetBut = new Button("", 145, height - 50, 35, 35);
    skipToEndBut = new Button("", 100, height - 50, 35, 35);
    nextBut = new Button("", 55, height - 50, 35, 35);
    save = new Button("Save", 100, 270, 75, 20);

    play = loadImage("play.png");
    pause = loadImage("pause.png");
    resetButImage = loadImage("reset.png");
    skipToEnd = loadImage("skipToEnd.png");
    next = loadImage("next.png");
    
    strokeCap(PROJECT);

    textAlign(CENTER, CENTER);
    ellipseMode(CORNER);

    fill(0);
    textSize(36);
    text("Maze Generation and Solving Visualised", width / 2, 30);
}

public void draw() {
    // Gets visualisation speed from the slider
    speed = (int) speedSlider.getValue();

    // If reset flag is true, reset the current generation and solver if it has been solved, then the visualisation
    if (reset) {
        reset();
        reset = false;
    }
    
    rectMode(CORNER);
    drawButtons();
    rectMode(CENTER);

    if (paused) {
        return;
    }

    // Generate the maze if the generate button has been pressed
    if (!generated && generatePressed) {
        for (int i = 0; i < speed; i++) {
            generators[selectedGeneration - 1].generate();
        }
    }

    // Once the generation is completed, is should clear the coloured squares to show the maze
    if (!clearedAfterGeneration) {
        clearedAfterGeneration = !clearedAfterGeneration;
    }

    // If start point, end point and solve button pressed, perform the solve
    if (startingPointSelected && endingPointSelected && solvePressed) {
        for (int i = 0; i < speed; i++) {
            solvers[selectedSolver - 1].solve();
        }
    }
    
    // Draw the maze and the buttons
    maze.display();
    
    fill(0);
    text(frameRate, 25, 10);
}

public void mousePressed() {
    // Update the number of rows and columns of the maze as the size slider value changes
    if (!generatePressed && !solvePressed) {
        maze.updateRowAndColCounts();
        sizeSlider.press();
    }
    speedSlider.press();

    // If generator selected, reset all the generators to fit the maze
    int genPressed = generationSelector.checkForPress();
    if (!generatePressed && genPressed != -1) {
        generators = new IGenerator[] {
            new Aldous_Broder(), new Backtracker(), new Binary_Tree(), new Blobby_Recursive(), new Ellers(), new Houston(), new Hunt_Kill(), new Kruskals(), new Prims(), new Recursive_Divide(), new Side_Winder(), new Wilsons()
        };
        selectedGeneration = genPressed;
    }

    // If solver selected, reset all the solvers to fit the maze
    int solPressed = solveSelector.checkForPress();
    if (!solvePressed && solPressed != -1) {
        solvers = new ISolver[] {
            new A_Star(), new Breadth_First(), new Depth_First(), new Left_Wall(), new Right_Wall()
        };
        selectedSolver = solveSelector.checkForPress();
    }
    
    int savPressed = saveSelector.checkForPress();
    if (savPressed != -1){
      selectedSave = savPressed;
    }

    // If pause button pressed, pause or unpause depending on the inital flag value
    if (pauseBut.MouseIsOver()) {
        paused = !paused;
    }

    // Clear the maze solution if the button is pressed
    if (solved && clearSolution.MouseIsOver() && !solveSelector.dropped) {
        maze.clearSolution();
    }
    
    if (generated && !startingPointSelected && !endingPointSelected && !solvePressed && save.MouseIsOver() && !saveSelector.dropped){
      if (selectedSave == 1){
        downloadTextMaze();
      } else if (selectedSave == 2){
        downloadPictureMaze();
      }
    }

    // Reset the points if the button is pressed
    if ((startingPointSelected || endingPointSelected) && resetPoints.MouseIsOver() && !solveSelector.dropped) {
        resetPoints();
    }

    // Check if reset button is pressed, only if neither of the selectors are dropped
    if (!generationSelector.dropped && !solveSelector.dropped) {
        reset = checkButton(resetBut);
    }

    // See if the user is trying to select a start or end point
    if (generated && maze.MouseIsOver()) {
        if (!startingPointSelected) {
            startingPoint = maze.getSelectedSquare();
            if (startingPoint != null) {
                squaresToUpdate.add(startingPoint);
                startingPointSelected = true;
            }
            return;
        }

        if (!endingPointSelected) {
            endingPoint = maze.getSelectedSquare();
            if (endingPoint != null && endingPoint != startingPoint) {
                squaresToUpdate.add(endingPoint);
                endingPointSelected = true;
            }
            return;
        }
    }
    
    // If skip button pressed, skip to the end of the generation
    if (!generated & generatePressed & skipToEndBut.MouseIsOver()){
      skipToEndGeneration();
    }
    
    // If skip button pressed, skip to the end of the solve
    if (!solved & solvePressed & skipToEndBut.MouseIsOver()){
      skipToEndSolve();
    }
    
    // If next button pressed, perform an iteration of the generation 
    if (!generated & generatePressed & nextBut.MouseIsOver()){
      generators[selectedGeneration-1].generate();
    }
    
    // If next button pressed, perform an iteration of the solve
    if (!solved & solvePressed & nextBut.MouseIsOver()){
      solvers[selectedSolver-1].solve();
    }

    // Check if the generation/solve button is pressed
    if (!generatePressed && !generationSelector.dropped && !generated && generateMaze.MouseIsOver() && selectedGeneration != 0) {
      maze.create();
      generatePressed = true;
      generators[selectedGeneration-1].initialise();
    }

    // Check if the solve selection button has been pressed, user is limited to when they can press the buttons as to not break the visualisation interface
    if (!solvePressed && !solveSelector.dropped && startingPointSelected && endingPointSelected && selectedSolver != 0 && solveMaze.MouseIsOver()) {
        solvePressed = true;
        solvers[selectedSolver-1].initialise(startingPoint);
    }
}

public void mouseReleased() {
    // Lock the slider values in
    sizeSlider.release();
    speedSlider.release();

}

public void keyPressed() {
    // Extra key shortcuts
    if (key == ' ') {
        paused = !paused;
    }

    if (key == 'r') {
        reset = true;
    }
    
    if (key == 'a'){
      tree.build(startingPoint);
    }
}

// Resets the visualisation
public void reset() {
    // Reset indicators
    generatePressed = false;
    generated = false;
    solvePressed = false;
    solved = false;
    paused = false;
    clearedAfterGeneration = false;

    // Clear start and end solving points
    startingPointSelected = false;
    endingPointSelected = false;
    startingPoint = null;
    endingPoint = null;

    squaresToUpdate.clear();

    // Clear solution
    currentSquare = null;
    solution = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
    solutionList.clear();

    // Reset maze
    maze.reset();
    maze.overwrite();
}

public void skipToEndGeneration(){
  while(!generated){
    generators[selectedGeneration-1].generate();
  }
}

public void skipToEndSolve(){
  while(!solved){
    solvers[selectedSolver-1].solve();
  }
}

// Clears the start and end points selected by the user
public void resetPoints() {
    squaresToUpdate.add(startingPoint);
    squaresToUpdate.add(endingPoint);

    startingPoint = null;
    endingPoint = null;
    startingPointSelected = false;
    endingPointSelected = false;

    maze.clearSolution();
}

// Function to draw a button depending on a flag value
public void drawButtonState(Button button, boolean pressed) {
    if (pressed) {
        button.drawSelected();
    } else {
        button.Draw();
    }
}

// Draws the interface
public void drawButtons() {
    fill(225);
    stroke(256);
    rect(0, 0, 180, height - 50);

    if (generatePressed) {
        generateMaze.drawSelected();
    } else {
        generateMaze.Draw();
    }

    if (solvePressed) {
        solveMaze.drawSelected();
    } else {
        solveMaze.Draw();
    }

    clearSolution.Draw();
    resetPoints.Draw();

    resetBut.Draw(resetButImage);
    save.Draw();
    skipToEndBut.Draw(skipToEnd);
    nextBut.Draw(next);

    sizeSlider.display();
    speedSlider.display();

    if (paused) {
        pauseBut.Draw(play);
    } else if (!paused) {
        pauseBut.Draw(pause);
    }
    
    fill(0);
    textSize(15);
    text("Configure", 95, 20);
    text("Generate", 95, 160);
    text("Save", 95, 250);
    text("Solve", 95, 305);
    text("Controls", 95, height - 65);

    textSize(12);
    fill(100);
    text("Square Size: " + (int)(sizeSlider.getValue()), 95, 50);
    text("Iterations per Frame: " + speed, 95, 105);

    solveSelector.Draw();
    saveSelector.Draw();
    generationSelector.Draw();
}

// Indicates if the passed button has been pressed
public boolean checkButton(Button button) {
    if (button.MouseIsOver()) {
        return true;
    }
    return false;
}

// Exports the picture of the maze to an image
public void downloadPictureMaze(){
  PImage mazeImage = get(maze.x - 10, maze.y - 10, maze.w + 20, maze.h + 20);
  mazeImage.save("pictureMazes/maze" + (picMazeNumber+=1) + ".png");
}

// Prints the text representation of the maze to a text file
public void downloadTextMaze(){
  output = createWriter("textMazes/" + generators[selectedGeneration - 1].getName() + "/" + (maze.getNumberOfColumns()+1) + "x" + (maze.getNumberOfRows()+1) +"/maze" + (txtMazeNumber+=1) + ".txt");
  char[][] textVersion = maze.getTextRepresentation();
  
  for (int i = 0; i < textVersion[0].length; i++){
    for (int j = 0; j < textVersion.length; j++){
      output.print(textVersion[j][i]);
    }
    output.println();
  }
  
  output.flush();
  output.close();
}
/**
 * The Square_HashMap class is a data structure that is used to store squares in order to decrease lookup time.
 */
class Square_HashMap {
    ArrayList < ArrayList < Square > > squares = new ArrayList < ArrayList < Square > > ();
    int size;

    // Initialises the hashmap with the given capacity
    Square_HashMap(int capacity) {
        size = 0;
      
        for (int i = 0; i < capacity; i++) {
            squares.add(new ArrayList < Square > ());
        }
    }
    
    public int getSize(){
       return size; 
    }

    // Adds a square to the hashmap
    public void addSquare(Square square) {
        if (square != null) {
            if (getKey(square) > squares.size()) {
                return;
            } else {
                squares.get(getKey(square)).add(square);
                size++;
            }
        }
    }

    // Calculates the hash function and returns the value for a specified square
    public int getKey(Square square) {
        return square.getXCo() * square.getYCo();
    }

    // Calculates the hash function for specified coordinates
    public int getKey(int xCo, int yCo) {
        return xCo * yCo;
    }

    // Retrieves the square with the passed coordinates from the hashmap if it exists
    public Square getSquare(int xCo, int yCo) {

        int hashKey = getKey(xCo, yCo);

        if (hashKey < 0 || hashKey > squares.size()) {
            return null;
        }

        ArrayList < Square > found = squares.get(hashKey);

        for (Square square: found) {
            if (square.getXCo() == xCo && square.getYCo() == yCo) {
                return square;
            }
        }
        return null;
    }

    // Checks if the passed square exists in the hashmap
    public boolean containsSquare(Square square) {

        if (square == null) {
            return false;
        }

        int keyToFind = getKey(square.getXCo(), square.getYCo());

        return squares.get(keyToFind).contains(square);
    }

    // Removes the passed square from the hashmap
    public void removeSquare(Square square) {
        int keyToFind = getKey(square.getXCo(), square.getYCo());

        ArrayList < Square > foundSquares = squares.get(keyToFind);

        foundSquares.remove(square);
        
        size--;
    }
}

/**
 * The Path_HashMap class is a data structure that is used to store paths in order to decrease lookup time.
 */
class Path_HashMap {
    ArrayList < ArrayList < Path > > paths = new ArrayList < ArrayList < Path > > ();
    ArrayList < Path > pathList = new ArrayList();

    // Initialises the Path hashmap with the given capacity
    Path_HashMap(int capacity) {
        for (int i = 0; i < capacity; i++) {
            paths.add(new ArrayList < Path > ());
        }
    }

    // Adds a path to the hashmap
    public void addPath(Path path, Boolean refill) {
        paths.get(getKey(path)).add(path);
        path.removeWallBetween(refill);
        pathList.add(path);
        path.updateSquares();
    }

    // Performs the hash function on the specified path
    public int getKey(Path path) {
        return path.startSquare.getXCo() + path.startSquare.getYCo();
    }

    // Performs the hash function on a specified square
    public int getKey(Square startSquare) {
        return startSquare.getXCo() + startSquare.getYCo();
    }

    // Gets the paths from the list corresponding to the entered hash value
    public ArrayList < Path > getPaths(int enteredKey) {
        return paths.get(enteredKey);
    }

    // Checks if the hashmap contains a path connecting the 2 passed squares
    public boolean containsPath(Square square1, Square square2) {
        ArrayList < Path > foundPaths = paths.get(getKey(square1));

        for (Path path: foundPaths) {
            if (path.startSquare == square1 || path.startSquare == square2) {
                if (path.endSquare == square1 || path.endSquare == square2) {
                    return true;
                }
            }
        }
        return false;
    }
}

/**
 * The Set_Hash class is a data structure that is used to store sets in order to decrease lookup time.
 * It is used in the generation algorithms that use sets, such as Kruskals and Ellers.
 */
class Set_Hash {
    ArrayList < Small_Square_Hash > sets;

    // Initialises the set hashmap with the specified size
    Set_Hash(int size) {
        sets = new ArrayList();
        for (int i = 0; i < size; i++) {
            sets.add(null);
        }
    }

    // Adds a square to the specified set number
    public void addToSet(int setNumber, Square square) {
        if (getSet(setNumber) == null) {
            sets.set(setNumber, new Small_Square_Hash((maze.getNumberOfColumns()) + (maze.getNumberOfRows() + 1)));
        }

        Small_Square_Hash set = sets.get(setNumber);
        square.setSet(setNumber);
        set.addSquare(square);
        squaresToUpdate.add(square);
    }

    // Gets the small square hash for the specified set number
    public Small_Square_Hash getSet(int setNumber) {
        Small_Square_Hash toReturn = sets.get(setNumber);
        if (toReturn != null) {
            return toReturn;
        }
        return null;
    }

    // Gets a random square from the specified set number
    public Square getRandomSquare(int setNumber) {
        return sets.get(setNumber).allSquares.get(Math.round(random(0, sets.get(setNumber).allSquares.size() - 1)));
    }

    // Merges the 2 sets with the passed numbers into a single set
    public void mergeSets(int setNumber1, int setNumber2) {
        if (setNumber1 == setNumber2) {
            return;
        }

        if (sets.get(setNumber1).allSquares.size() > sets.get(setNumber2).allSquares.size()) {
            for (Square square: sets.get(setNumber2).allSquares) {
                sets.get(setNumber1).addSquare(square);
                square.setSet(setNumber1);
                squaresToUpdate.add(square);
            }

            sets.set(setNumber2, null);
        } else {
            for (Square square: sets.get(setNumber1).allSquares) {
                sets.get(setNumber2).addSquare(square);
                square.setSet(setNumber2);
                squaresToUpdate.add(square);
            }

            sets.set(setNumber1, null);
        }
    }
}

/**
 * The Small_Square_Hash class is a data structure that is used to store 
 * squares in order to decrease lookup time, it uses a hash function with 
 * a smaller range than Square_Hash as to reduce the amount of ArrayList 
 * instances.
 */
class Small_Square_Hash {
    ArrayList < ArrayList < Square > > squares = new ArrayList < ArrayList < Square > > ();
    ArrayList < Square > allSquares = new ArrayList();

    // Initialises the hashmap with the specified size
    Small_Square_Hash(int capacity) {
        for (int i = 0; i < capacity; i++) {
            squares.add(new ArrayList < Square > ());
        }
    }

    // Adds a square to the hashmap
    public void addSquare(Square square) {
        squares.get(getKey(square)).add(square);
        allSquares.add(square);
    }

    // Performs the hash function on the specified square
    public int getKey(Square square) {
        return square.getXCo() + square.getYCo();
    }

    // Performs the hash function on the specified coordinates
    public int getKey(int xCo, int yCo) {
        return xCo + yCo;
    }

    // Gets the square with the specified coordinates if it exists in the hash
    public Square getSquare(int xCo, int yCo) {

        int hashKey = getKey(xCo, yCo);

        if (hashKey < 0 || hashKey > squares.size()) {
            return null;
        }

        ArrayList < Square > found = squares.get(hashKey);

        for (Square square: found) {
            if (square.getXCo() == xCo && square.getYCo() == yCo) {
                return square;
            }
        }
        return null;
    }

    // Checks if the passed square exists in the hashmap
    public boolean containsSquare(Square square) {

        if (square == null) {
            return false;
        }

        int keyToFind = getKey(square.getXCo(), square.getYCo());

        return squares.get(keyToFind).contains(square);
    }

    // Returns a list of all squares in the hashmap
    public ArrayList < Square > getAllSquares() {
        return allSquares;
    }

    // Removes the specified square from the hashmap
    public void removeSquare(Square square) {
        allSquares.remove(square);
        int keyToFind = getKey(square.getXCo(), square.getYCo());

        ArrayList < Square > foundSquares = squares.get(keyToFind);

        foundSquares.remove(square);
    }
}
/**
 * The interface used by the maze generators.
 */
interface IGenerator {
    public String getName();
    
    public void initialise();
  
    public void generate();
}

/**
 * Implements the Aldous-Broder algorithm for maze generation.
 */
class Aldous_Broder implements IGenerator {
    int added;
    Square_HashMap visitedSquares;

    Aldous_Broder() {}
    
    public void initialise(){
      this.added = 1;
      this.visitedSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
      
      currentSquare = maze.getRandomSquare();
      squaresToUpdate.add(currentSquare);
      visitedSquares.addSquare(currentSquare);
    }
    
    public String getName(){
      return "1_aldous";
    }

    public void generate() {
        if (generated) {
            return;
        }

        Square oldSquare = currentSquare;
        ArrayList < Integer > possibleDirections = new ArrayList(Arrays.asList(0, 1, 2, 3));

        do {
            int randInd = Math.round(random(-0.5f, possibleDirections.size() - 0.5f));
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
    
    public void initialise(){
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
    
    public String getName(){
      return "2_backtracker";
    }

    public void generate() {
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

                int direction = directions.get(Math.round(random(-0.5f, directions.size() - 0.5f)));

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

    public Square popSquare() {
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

    public boolean atDeadEnd() {
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

    public boolean checkLeft(Square square) {
        return checkStack(maze.getSquareLeft(square));
    }

    public boolean checkAbove(Square square) {
        return checkStack(maze.getSquareAbove(square));
    }

    public boolean checkRight(Square square) {
        return checkStack(maze.getSquareRight(square));
    }

    public boolean checkBelow(Square square) {
        return checkStack(maze.getSquareBelow(square));
    }

    public boolean checkStack(Square square) {
        return visitedSquares.containsSquare(square);
    }

    public int getRandomDir() {
        return Math.round(random(-0.5f, 3.5f));
    }
}

/**
 * Implements the Binary-tree algorithm for maze generation.
 */
class Binary_Tree implements IGenerator {
    int xPos, yPos;
    
    Binary_Tree() {}
    
    public String getName(){
      return "3_binary";
    }
    
    public void initialise(){
        yPos = maze.getNumberOfRows();
        xPos = maze.getNumberOfColumns();
    }

    public void generate() {
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

    public void addAbove(Square thisSquare) {
        Path newPath = new Path(thisSquare, maze.getSquare(thisSquare.getXCo(), thisSquare.getYCo() - 1));
        maze.getPaths().addPath(newPath, true);
        squaresToUpdate.add(maze.getSquare(thisSquare.getXCo(), thisSquare.getYCo() - 1));
    }

    public void addLeft(Square thisSquare) {
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
    
    public String getName(){
      return "4_blobby_recursive";
    }
    
    public void initialise(){
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

    public void generate() {
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
                    if (random(1) > 0.5f) {
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
                    if (random(1) > 0.5f) {
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

    public void nextSet() {
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

    public Square[] getRandomSeeds(int setNumber) {
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
    
    public String getName(){
      return "5_ellers";
    }
    
    public void initialise(){
      this.row = 0;
      this.col = 0;
      this.currentStage = 1;
      this.lastRow = false;
      this.setsWithDownPaths = new ArrayList();
      
      this.ellersSets = new Set_Hash((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
    }

    public void generate() {
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

    public void createSets(int row) {
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

    public void randomUnion(int row) {
        if (col < maze.getNumberOfColumns()) {
            Square startSquare = maze.getSquare(col, row);
            Square endSquare = maze.getSquare(col + 1, row);
            if (random(1) < 0.5f && startSquare.getSet() != endSquare.getSet()) {
                ellersSets.mergeSets(startSquare.getSet(), endSquare.getSet());
                Path newPath = new Path(startSquare, endSquare);
                maze.getPaths().addPath(newPath, false);
                newPath.removeWallBetween(true);
            }
        }
    }

    public void createDownPaths(int row) {
        if (col <= maze.getNumberOfColumns()) {
            Square topSquare = maze.getSquare(col, row);
            Square bottomSquare = maze.getSquare(col, row + 1);

            if (random(1) < 0.5f) {
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

    public void joinLastRow() {
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
    
    public String getName(){
      return "6_hunt_kill";
    }
    
    public void initialise(){
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

    public void generate() {
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

    public void hunt() {
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

    public void kill() {
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

    public Square nextToVisitedSquare(Square square) {
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

    public int getDirectionOfValidSquare() {
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

    public boolean checkLeft() {
        if (maze.getSquareLeft(currentSquare) == null) {
            return false;
        }

        return maze.getSquareLeft(currentSquare).getSet() == -1;
    }

    public boolean checkRight() {
        if (maze.getSquareRight(currentSquare) == null) {
            return false;
        }

        return maze.getSquareRight(currentSquare).getSet() == -1;
    }

    public boolean checkUp() {
        if (maze.getSquareAbove(currentSquare) == null) {
            return false;
        }

        return maze.getSquareAbove(currentSquare).getSet() == -1;
    }

    public boolean checkDown() {
        if (maze.getSquareBelow(currentSquare) == null) {
            return false;
        }

        return maze.getSquareBelow(currentSquare).getSet() == -1;
    }

    public boolean atDeadEnd(Square square) {
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

    public boolean checkLeft(Square square) {
        return checkStack(maze.getSquareLeft(square));
    }

    public boolean checkAbove(Square square) {
        return checkStack(maze.getSquareAbove(square));
    }

    public boolean checkRight(Square square) {
        return checkStack(maze.getSquareRight(square));
    }

    public boolean checkBelow(Square square) {
        return checkStack(maze.getSquareBelow(square));
    }

    public boolean checkStack(Square square) {
        return visitedSquares.containsSquare(square);
    }

    public int getRandomDir() {
        return Math.round(random(-0.5f, 3.5f));
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
    
    public String getName(){
      return "7_kruskals";
    }
    
    public void initialise(){
        this.setNumber = 0;
        this.remainingPaths = new ArrayList();
        
        kruskalsSets = new Set_Hash((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
        getAllPossiblePaths();
    }

    public void generate() {
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

    public void getAllPossiblePaths() {
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
    
    public String getName(){
      return "8_prims";
    }
    
    public void initialise(){
        this.mainSet = new ArrayList();
        this.possiblePaths = new ArrayList();
        
        mainSetSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
        getFirstSquare();
    }

    public void generate() {
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

    public void pickRandomWall() {
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

    public void getFirstSquare() {
        Square first = maze.getRandomSquare();
        primStartSquare = first;
        first.setSet(1);
        mainSet.add(first);
        mainSetSquares.addSquare(first);
        squaresToUpdate.add(first);
    }

    public void getPossibleWalls() {
        try {
            getPossiblePaths(mainSet.get(mainSet.size() - 1));
        } catch (Exception ArrayIndexOutOfBoundsException) {
            mainSet.clear();
            generated = true;
            maze.generationComplete();
        }
    }

    public void getPossiblePaths(Square square) {
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

    public Path primCheckAbove(Square square) {
        Square aboveSquare = maze.getSquareAbove(square);
        if (aboveSquare != null && aboveSquare.getSet() == -1) {
            return new Path(square, aboveSquare);
        }
        return null;
    }

    public Path primCheckBelow(Square square) {
        Square belowSquare = maze.getSquareBelow(square);
        if (belowSquare != null && belowSquare.getSet() == -1) {
            return new Path(square, belowSquare);
        }
        return null;
    }

    public Path primCheckLeft(Square square) {
        Square leftSquare = maze.getSquareLeft(square);
        if (leftSquare != null && leftSquare.getSet() == -1) {
            return new Path(square, leftSquare);
        }
        return null;
    }

    public Path primCheckRight(Square square) {
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
    
    public String getName(){
      return "9_recursive_divide";
    }
    
    public void initialise(){
        this.fieldStack = new ArrayList();
        this.pathsGenerated = false;
      
        maze.clear();
        fieldStack.add(new ArrayList(Arrays.asList(0, 0, maze.getNumberOfColumns(), maze.getNumberOfRows())));
    }

    public void generate() {
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

    public void addToStack(int startX, int startY, int endX, int endY) {
        ArrayList < Integer > toAdd = new ArrayList(Arrays.asList(startX, startY, endX, endY));
        fieldStack.add(toAdd);
    }

    public void deleteFromStack(int startX, int startY, int endX, int endY) {
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
    public void addHorizontalWall(int startX, int endX, int y) {
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
    public void addVerticalWall(int startY, int endY, int x) {
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
    
    public String getName(){
      return "10_sidewinder";
    }
    
    public void initialise(){
        this.sideY = 1;
        this.sideX = 0;
        this.setNumber = 0;
        this.setsAddedToRow = new ArrayList();
      
        rowRunSets = new Set_Hash((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
        clearTopRow();
    }

    public void generate() {
        if (generated) {
            return;
        }

        if (sideX <= maze.getNumberOfColumns()) {
            Square currentSquare = maze.getSquare(sideX, sideY);

            rowRunSets.addToSet(setNumber, currentSquare);

            squaresToUpdate.add(currentSquare);

            if (sideX != maze.getNumberOfColumns()) {
                if (random(1) < 0.5f) {
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

    public void clearTopRow() {
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
    
    public String getName(){
      return "11_wilsons";
    }
    
    public void initialise(){
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

    public void generate() {
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

    public Square getRandomPoint() {
        Square randomSquare;

        do {
            randomSquare = maze.getSquare(Math.round(random(0, maze.getNumberOfColumns())), Math.round(random(0, maze.getNumberOfRows())));
        } while (visitedSquares.containsSquare(randomSquare));

        return randomSquare;
    }

    public void randomWalk() {
        Square nextSquare = null;
        ArrayList < Integer > possible = new ArrayList(Arrays.asList(0, 1, 2, 3));

        do {
            int randInd = Math.round(random(-0.5f, possible.size() - 0.5f));
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

    public void eraseLoopInCurrentWalk(Square square) {
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

    public void addCurrentWalkToLoop() {
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
  
  public String getName(){
     return "12_houston";
  }
  
  public void initialise(){
      this.aldousSolver = new Aldous_Broder();
      this.wilsonsSolver = new Wilsons();
      
      this.stage = 1;
      
      aldousSolver.initialise();
  }
  
  Houston(){}
  
  public void generate(){
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
/**
 * This class implements a drop list that allows the user to select a value from a list.
 */
class DropList {
    int x, y, w, h;
    ArrayList < String > labels;
    Button dropList;
    int currentlySelected;
    String title;
    Boolean dropped = false;
    
    int animateI;

    DropList(int x, int y, int buttonWidth, int buttonHeight, String defaultLabel, ArrayList < String > labels) {
        this.x = x;
        this.y = y;
        this.w = buttonWidth;
        this.h = buttonHeight;
        this.labels = labels;
        this.title = defaultLabel;
        
        this.animateI = 0;

        dropList = new Button(">", x + w - 20, y, 20, h);
    }

    // Draws the droplist on the sketch
    public void Draw() {
        noStroke();
        fill(255);
        rect(x, y, w, h, h);
        fill(0);
        text(title, x + ((w - 20) / 2), y + ((h) / 2));

        if (dropped) {
            dropList.drawSelected();
        } else {
            dropList.Draw();
        }

        if (dropped) {
            if (animateI < labels.size()-1){
              animateI++;
            }
          
            int currY = y + h;
            int col = 250;
            for (int i = 0; i <= animateI; i++) {
                fill(col);
                rect(x, currY, w - 20, h, h);
                fill(0);
                text(labels.get(i), x + ((w - 20) / 2), currY + ((h) / 2));
                currY += h;
                col -= (100) / labels.size();
            }
        } else {
            if (animateI >= 0){
              animateI--;
            }
          
            int currY = y + h;
            int col = 250;
            for (int i = 0; i <= animateI; i++) {
                fill(col);
                rect(x, currY, w - 20, h, h);
                fill(0);
                text(labels.get(i), x + ((w - 20) / 2), currY + ((h) / 2));
                currY += h;
                col -= (100) / labels.size();
            }
        }
    }

    // Checks if the button to drop the list has been pressed, and if an element of the list has been selected
    public int checkForPress() {
        if (dropList.MouseIsOver()) {
            dropped = !dropped;
        }

        int toReturn = -1;
        if (dropped && mouseX > x && mouseX < x + w && mouseY > y + h && mouseY < y + (h * (labels.size() + 1))) {
            toReturn = (mouseY - y) / h;
            title = labels.get(toReturn - 1);
        }
        return toReturn;
    }

    // 'Undrops' the droplist
    public void unShowDropList() {
        stroke(256);
        fill(225);
        rect(x, y + h, w + 1, 1 + (h * labels.size()));
    }
}

/**
 * This class implements a button that can be pressed by the user.
 */
class Button {
    String label;
    float x, y, w, h;

    boolean pressed = false; // indicates if the button has been pressed
    float animationI = 0; // Where the button is in the pressed animation

    // Button constructor
    Button(String label, float x, float y, float w, float h) {
        this.label = label;
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    // Draw the button with default label
    public void Draw() {
        noStroke();
        if (pressed) {
            pressed = false;
        }

        if (animationI > 0) {
            fill(lerpColor(color(200), color(255), (25 - animationI) / 25));
            animationI--;
        } else {
            fill(255);
        }

        textSize(12);
        rect(x, y, w, h, h);
        fill(0);
        text(label, x + (w / 2), y + (h / 2));
    }

    // Draw the button with the passed PImage
    public void Draw(PImage image) {
        noStroke();
        fill(225);
        rect(x, y, w, h, h);
        image(image, x, y, w, h);
        fill(0);
    }

    // Draws the button with a darker fill to signify that it has been selected.
    public void drawSelected() {
        if (pressed == true) {
            if (animationI < 8) {
                fill(lerpColor(color(255), color(200), animationI / 8));
                animationI++;
            } else {
                fill(200);
            }
        }

        textSize(12);
        rect(x, y, w, h, h);
        fill(0);
        text(label, x + (w / 2), y + (h / 2));
    }

    // Returns a boolean indicating if the mouse was above the button when the mouse was pressed
    public boolean MouseIsOver() {
        if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) {
            pressed = true;
            return true;
        }
        return false;
    }
}

/**
 * This class implements a slider that can be used by the user to select a value.
 */
class Slider {
    int startX, startY, sliderWidth, sliderHeight;
    float minVal, maxVal;
    int labelSize;
    float sliderX;
    int currentVal;
    String label;
    boolean sliderPressed = false;
    boolean floatOrInt = false;

    // Constructor
    Slider(int startX, int startY, int sliderWidth, int sliderHeight, float minVal, float maxVal) {
        this.startX = startX;
        this.startY = startY;
        this.sliderWidth = sliderWidth;
        this.sliderHeight = sliderHeight;
        this.minVal = minVal;
        this.maxVal = maxVal;

        this.currentVal = (int)(minVal + maxVal) / 2;

        sliderX = startX + sliderWidth / 2;
    }

    // Returns the value of the slider
    public float getValue() {
        return currentVal;
    }

    // Draws the slider on the sketch
    public void display() {
        noStroke();
        if (sliderPressed) {
            press();
        }

        fill(255);
        rect(startX - sliderHeight / 2, startY, sliderWidth + sliderHeight, sliderHeight, sliderHeight);

        fill(100);
        rect(sliderX - sliderHeight / 2, startY, sliderHeight, sliderHeight, sliderHeight);
    }

    // Checks if the slider has been clicked
    public void press() {
        if (mouseX > startX && mouseX < startX + sliderWidth) {
            if (mouseY > startY && mouseY < startY + sliderHeight || sliderPressed) {
                sliderPressed = true;
            }
        }

        if (sliderPressed) {
            if (mouseX <= startX + sliderWidth && mouseX >= startX) {
                sliderX = mouseX;
                currentVal = Math.round(map(mouseX, startX, startX + sliderWidth, minVal, maxVal));
                return;
            } else if (mouseX > startX + sliderWidth) {
                sliderX = startX + sliderWidth;
                currentVal = Math.round(maxVal);
                return;
            } else if (mouseX < startX) {
                sliderX = startX;
                currentVal = Math.round(minVal);
                return;
            }
        }
    }

    // Releases the slider so the value change stops
    public void release() {
        sliderPressed = false;
    }

    // Updates the position of the slider
    public void update() {
        sliderPressed = true;
        sliderX = mouseX;
        currentVal = (int) map(mouseX, sliderX, sliderX + sliderWidth, minVal, maxVal);
    }
}
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
    
    public int getWidth() {
        return w;
    }

    public int getHeight() {
        return h;
    }

    // Returns the maximum xCo of squares in the maze
    public int getNumberOfRows() {
        return numOfRows;
    }

    // Returns the maximum yCo of squares in the maze
    public int getNumberOfColumns() {
        return numOfColumns;
    }

    // Returns the paths used in the maze
    public Path_HashMap getPaths() {
        return paths;
    }
    
    public void addPath(Square start, Square end){
        Path newPath = new Path(start, end);
        paths.addPath(newPath, false);
        newPath.removeWallBetween(true);
    }

    // Returns the square at the specified and y position
    public Square getSquare(int x, int y) {
        return squareHashMap.getSquare(x, y);
    }

    public Square getSquare(ArrayList < Integer > input) {
        try {
            return squareHashMap.getSquare(input.get(0), input.get(1));
        } catch (Exception NullPointerException) {
            return null;
        }
    }

    // Returns an arraylist of all the squares that the maze is composed of
    public ArrayList < Square > getSquares() {
        return squares;
    }
    
    // Gets a random square from the maze
    public Square getRandomSquare() {
        Square toReturn = null;
        while (toReturn == null) {
            toReturn = maze.getSquare(Math.round(random(0, maze.getNumberOfColumns())), Math.round(random(0, maze.getNumberOfRows())));
        }
        return toReturn;
    }
    
    // Return the square that has been clicked on by the user
    public Square getSelectedSquare() {
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
    public ArrayList < Square > getSquareNeighbours(Square square) {
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
    public Square getSquareAbove(Square square) {
        squaresToUpdate.add(square);
        return getSquare(square.getXCo(), square.getYCo() - 1);
    }

    // Get the square located below the passed square
    public Square getSquareBelow(Square square) {
        squaresToUpdate.add(square);
        return getSquare(square.getXCo(), square.getYCo() + 1);
    }

    // Get the square located right of the passed square
    public Square getSquareRight(Square square) {
        squaresToUpdate.add(square);
        return getSquare(square.getXCo() + 1, square.getYCo());
    }

    // Get the square located left of the passed square
    public Square getSquareLeft(Square square) {
        squaresToUpdate.add(square);
        return getSquare(square.getXCo() - 1, square.getYCo());
    }
    
    // Setters
    
    // Update the num of rows and num of col variables as the size slider changes
    public void updateRowAndColCounts() {
        squareSize = sizeSlider.getValue();

        numOfColumns = (int) Math.floor(w / squareSize) - 1;
        numOfRows = (int) Math.floor(h / squareSize) - 1;
    }
    
    // Utility

    // Create the maze grid
    public void create() {
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
    
    public float getSquareHeight(){
      return squareHeight;
    }
    
    public float getSquareWidth(){
      return squareWidth;
    }
    
    
    public char[][] getTextRepresentation(){
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
    public void overwrite() {
        fill(255);
        noStroke();
        rect(x + (w/2), y + (h/2), w, h);
    }

    // Clear the solution of the maze
    public void clearSolution() {
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
    public void drawSolution() {
        for (int i = 1; i < solutionList.size(); i++) {
            connectSquares(solutionList.get(i - 1), solutionList.get(i));
        }
    }

    // Connect the 2 squares with an amber line (used to visualise the solution)
    public void connectSquares(Square square1, Square square2) {
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
    public void generationComplete() {
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
    public void generatePaths() {
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
    public void clear() {
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
    public void reset() {
        maze.paths = new Path_HashMap((int) Math.pow(numOfColumns + 1, 2));
        for (Square square: squares) {
            square.setWalls(true, true, true, true);
            square.setSet(-1);
        }
    }

    // Draw the grid
    public void display() {
        fill(256);
        stroke(0);
        strokeWeight(12);
        rect(x + (w/2), y + (h/2), w + 12.5f, h + 12.5f);
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
    public boolean MouseIsOver() {
        if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) {
            return true;
        }
        return false;
    }
}
class Maze_Tree{
    Maze_Tree_Node root;
    
    Maze_Tree(){
        this.root = null;
    }
    
    public void build(Square startingPoint){
        Tree_Builder builder = new Tree_Builder(this, startingPoint);
        
        builder.depthFirstBuild();
    }
}

class Tree_Builder{
    Maze_Tree tree;
    Square startingSquare;
    Square currentSquare;
    
    ArrayList<Maze_Tree_Node> nodeStack;
    
    Tree_Builder(Maze_Tree tree, Square startingSquare){
        this.tree = tree;
        this.startingSquare = startingSquare;
        this.currentSquare = startingSquare;
        this.nodeStack = new ArrayList();
    }
    
    public void depthFirstBuild(){
        tree.root = new Maze_Tree_Node(null, currentSquare, 0);
        
        Square lastSquare = currentSquare;
        
        for (int direction : currentSquare.getPossibleDirections()){
          moveInDirection(direction);
          findNextJunction(currentSquare, tree.root, lastSquare);
        }
    }
    
    public void findNextJunction(Square startingPosition, Maze_Tree_Node lastNode, Square previous){
      currentSquare = startingPosition;
      for (int direction : startingPosition.getPossibleDirections()){
        Square lastSquare = previous;
        
        moveInDirection(direction);
        
        if (currentSquare.xCo == lastSquare.xCo && currentSquare.yCo == lastSquare.yCo){
          continue;
        }
        
        while(currentSquare.getPossibleDirections().size() == 2){
          for (int dir : currentSquare.getPossibleDirections()){
            if (getSquareInDirection(dir).xCo == lastSquare.xCo && getSquareInDirection(dir).yCo == lastSquare.yCo){
              continue;
            } else {
              lastSquare = currentSquare;
              moveInDirection(dir);
              break;
            }
          }
        }
        
        Maze_Tree_Node newNode = new Maze_Tree_Node(lastNode, currentSquare, lastNode.depth+1);
        lastNode.addChild(newNode);
        println("adding node: " + currentSquare.xCo + " " + currentSquare.yCo);
        
        if (currentSquare.getPossibleDirections().size() == 1){
          println("returning");
          return;
        }
        
        findNextJunction(currentSquare, newNode, lastSquare);
      }
    }
    
    public Square getSquareInDirection(int direction){
      if (direction == 0){
        return maze.getSquareAbove(currentSquare);
      } else if (direction == 1){
        return maze.getSquareRight(currentSquare);
      } else if (direction == 2){
        return maze.getSquareBelow(currentSquare);
      } else if (direction == 3){
        return maze.getSquareLeft(currentSquare);
      }
      
      return null;
    }
    
    public void moveInDirection(int direction){
      
      if (direction == 0){
        currentSquare = maze.getSquareAbove(currentSquare);
      } else if (direction == 1){
        currentSquare = maze.getSquareRight(currentSquare);
      } else if (direction == 2){
        currentSquare = maze.getSquareBelow(currentSquare);
      } else if (direction == 3){
        currentSquare = maze.getSquareLeft(currentSquare);
      }
      println("Moving in  direction " + direction + " [" + currentSquare.xCo + " " + currentSquare.yCo + "]");
    }
}

class Maze_Tree_Node{
    Maze_Tree_Node parent;
    ArrayList<Maze_Tree_Node> children;
    Square position;
    int depth;
    
    Maze_Tree_Node(Maze_Tree_Node parent, Square position, int depth){
        this.parent = parent;
        this.depth = depth;
        this.position = position;
        children = new ArrayList();
    }
    
    public void addChild(Maze_Tree_Node child){
        children.add(child);
    }
    
    public Maze_Tree_Node getParent(){
        return parent;
    }
    
    public ArrayList<Maze_Tree_Node> getChildren(){
        return children;
    }
}
/**
 * This class implements a path between 2 squares of the maze.
 */
class Path {
    Square startSquare, endSquare;
    int direction;
    float buffer;

    // Constructor
    Path(Square startSquare, Square endSquare) {
        this.startSquare = startSquare;
        this.endSquare = endSquare;
    }
    
    // Getters
    
    // Gets the first square in the path
    public Square getStartSquare() {
        return startSquare;
    }

    // Gets the last square in the path
    public Square getEndSquare() {
        return endSquare;
    }

    // Gets the orientation of the path
    public int getDirection() {
        return direction;
    }
    
    // Utility

    // Check if this path contains the passed square
    public int contains(Square square) {
        if (startSquare == square) {
            return 0;
        } else if (endSquare == square) {
            return 1;
        } else {
            return -1;
        }
    }

    // Update the squares
    public void updateSquares() {
        squaresToUpdate.add(startSquare);
        squaresToUpdate.add(endSquare);
    }

    // Add a wall between the start and end square
    public void addWallBetween() {
        if (startSquare.isLeft(endSquare)) {
            startSquare.addRightWall();
            endSquare.addLeftWall();
            direction = 1;
        } else if (startSquare.isRight(endSquare)) {
            endSquare.addRightWall();
            startSquare.addLeftWall();
            direction = 3;
        } else if (startSquare.isAbove(endSquare)) {
            endSquare.addUpWall();
            startSquare.addDownWall();
            direction = 2;
        } else if (startSquare.isBelow(endSquare)) {
            endSquare.addDownWall();
            startSquare.addUpWall();
            direction = 0;
        }
    }

    // Remove the edge between the start and end square, indicating if the wall should be removed in the visualisation
    public void removeWallBetween(boolean refill) {
        squaresToUpdate.add(startSquare);
        squaresToUpdate.add(endSquare);
      
        if (refill) {
            stroke(255);
            fill(255);
            buffer = 0;
        }

        if (startSquare.isLeft(endSquare)) {
            startSquare.removeRightWall();
            endSquare.removeLeftWall();
            direction = 1;

            if (refill) {
                rect(startSquare.x + buffer + maze.getSquareWidth(), startSquare.y + buffer + maze.getSquareHeight()/2, (2 * maze.getSquareWidth()) - 2*buffer, maze.getSquareHeight() - 2*buffer);
            }
        } else if (startSquare.isRight(endSquare)) {
            endSquare.removeRightWall();
            startSquare.removeLeftWall();
            direction = 3;

            if (refill) {
                rect(endSquare.x + buffer + maze.getSquareWidth(), endSquare.y + buffer + maze.getSquareHeight()/2, (2 * maze.getSquareWidth()) - 2*buffer, maze.getSquareHeight() - 2*buffer);
            }
        } else if (startSquare.isAbove(endSquare)) {
            endSquare.removeUpWall();
            startSquare.removeDownWall();
            direction = 2;

            if (refill) {
                rect(startSquare.x + buffer + maze.getSquareWidth()/2, startSquare.y + buffer + maze.getSquareHeight(), maze.getSquareWidth() - 2*buffer, (2 * maze.getSquareHeight()) - 2*buffer);
            }
        } else if (startSquare.isBelow(endSquare)) {
            endSquare.removeDownWall();
            startSquare.removeUpWall();
            direction = 0;

            if (refill) {
                rect(endSquare.x + buffer + maze.getSquareWidth()/2, endSquare.y + buffer + maze.getSquareHeight(), maze.getSquareWidth() - 2*buffer, (2 * maze.getSquareHeight()) - 2*buffer);
            }
        }
    }
}
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
    public Square getSquare() {
        return square;
    }

    // Gets current direction
    public int getDirection() {
        return direction;
    }
    
    // Setters
    
    // Clear the previous squares visited by the turtle
    public void clearPrevSquares() {
        prevSquares = null;
    }
    
    // Rotates the agent clockwise
    public void rotateCW() {
        this.direction += 1;
        if (this.direction == 4) {
            this.direction = 0;
        }
    }

    // Rotates the agent counter clockwise
    public void rotateCCW() {
        this.direction -= 1;
        if (this.direction == -1) {
            this.direction = 3;
        }
    }
    
    // Utility

    // Returns the possible directions that the agent can visit to squares that have not already been visited
    public ArrayList < Integer > getPossibleDirections() {
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
    public void backtrack() {
        Square lastSquare = route.get(route.size() - 1);
        this.square = lastSquare;

        if (getPossibleDirections().size() == 0) {
            route.remove(lastSquare);
            routeSquares.removeSquare(lastSquare);
            currPos--;
        }
    }

    // Makes the agent walk in the specified direction
    public void walkInDirection(int dir) {
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
    public void walkUp() {
        this.square = maze.getSquare(square.getXCo(), square.getYCo() - 1);
    }

    // Makes the agent walk to the square above the current square
    public void walkDown() {
        this.square = maze.getSquare(square.getXCo(), square.getYCo() + 1);
    }

    // Makes the agent walk to the square above the current square
    public void walkLeft() {
        this.square = maze.getSquare(square.getXCo() - 1, square.getYCo());
    }

    // Makes the agent walk to the square above the current square
    public void walkRight() {
        this.square = maze.getSquare(square.getXCo() + 1, square.getYCo());
    }
}
/**
 * The interface used by the maze solvers.
 */
interface ISolver {
    public void initialise(Square startingPoint);
    
    public void solve();
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
    
    public void initialise(Square startingPoint){
        this.possibleSquares = new ArrayList();
        this.allElements = new ArrayList();
      
        currentSolveSquare = startingPoint;
        solveVisitedSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
    }

    public void solve() {
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

    public void getLowestHSquare() {
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

    public void calculateHeuristic(Square square) {
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
    
    public void initialise(Square startingPoint){
        this.solverQueue = new LinkedList();
        this.currentElement = new ArrayList();
        this.allElements = new ArrayList();
      
        solveVisitedSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
        currentSolveSquare = startingPoint;
        solveVisitedSquares.addSquare(currentSolveSquare);
        solverQueue.add(new ArrayList(Arrays.asList(currentSolveSquare, null)));
    }

    public void solve() {
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

    public void addToQueue(ArrayList < Square > arrList) {
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
    
    public void initialise(Square startingPoint){
        ArrayList < Integer > dirs = startingPoint.getPossibleDirections();
        turtle = new Solver_Agent(startingPoint, dirs.get(0));
        turtle.walkInDirection(turtle.getDirection());
    }

    public void solve() {
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
    
    public void initialise(Square startingPoint){
        ArrayList < Integer > dirs = startingPoint.getPossibleDirections();
        turtle = new Solver_Agent(startingPoint, dirs.get(0));
        turtle.walkInDirection(turtle.getDirection());
    }

    public void solve() {
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
    public boolean turtleCheckLeft() {
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
    public boolean turtleCheckAhead() {
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
    
    public void initialise(Square startingPoint){
        ArrayList < Integer > dirs = startingPoint.getPossibleDirections();
        turtle = new Solver_Agent(startingPoint, dirs.get(0));
        turtle.walkInDirection(turtle.getDirection());
    }

    public void solve() {
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
    public boolean turtleCheckRight() {
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
    public boolean turtleCheckAhead() {
        int aheadDir = turtle.getDirection();
        if (turtle.getSquare().getPossibleDirections().contains(aheadDir)) {
            return true;
        }
        return false;
    }
}
/**
 * Class that represents each square within the maze.
 */
class Square {
    float x, y, w, h;
    int xCo, yCo;
    boolean upWall, leftWall, downWall, rightWall;

    // For generators/solvers
    int set;
    float distance;
    float heuristic;

    // Constructor
    Square(float sWidth, float sHeight, float x, float y, int xCo, int yCo) {
        this.w = sWidth;
        this.h = sHeight;
        this.x = x;
        this.y = y;
        this.xCo = xCo;
        this.yCo = yCo;
        
        this.set = -1;
        this.distance = 0;

        this.upWall = true;
        this.downWall = true;
        this.rightWall = true;
        this.leftWall = true;
    }
    
    // Getters
    
    // Returns the distance between this square and the passed square
    public float getDistanceFrom(Square square) {
        return (float) Math.sqrt(Math.pow(square.getXCo() - getXCo(), 2) + Math.pow(square.getYCo() - getYCo(), 2));
    }
    
    public float getHeuristic(){
      return heuristic;
    }
    
    // Gets the distance of the square
    public float getDistance(){
        return distance;
    }
    
    public int getSet() {
        return set;
    }

    public float getX() {
        return x;
    }

    public float getY() {
        return y;
    }

    public float getWidth() {
        return w;
    }

    public float getHeight() {
        return h;
    }

    public float getCenterX() {
        return x + w / 2;
    }

    public float getCenterY() {
        return y + h / 2;
    }

    // Returns an arraylist indicating which edges of the squares are walls
    public ArrayList < Boolean > getWalls() {
        return new ArrayList(Arrays.asList(upWall, rightWall, downWall, leftWall));
    }
    
    // Getters and setters for square
    public int getXCo() {
        return xCo;
    }

    public int getYCo() {
        return yCo;
    }

    public ArrayList < Integer > getCoords() {
        return new ArrayList(Arrays.asList(xCo, yCo));
    }

    // Setters
    
    public void setHeuristic(float heuristic){
      this.heuristic = heuristic;
    }
    
    // Sets the distance of the square
    public void setDistance(float distance){
        this.distance = distance;
    }
    
    public void setSet(int set) {
        this.set = set;
    }
    
    // Check if square is above the passed square
    public void setWalls(boolean up, boolean right, boolean down, boolean left) {
        this.upWall = up;
        this.rightWall = right;
        this.downWall = down;
        this.leftWall = left;
    }
    
    // Utility

    // Gets all of the possible directions that can be navigated to by an agent, i.e, a surrounding square that doesnt have a wall between it and this square 
    public ArrayList < Integer > getPossibleDirections() {
        ArrayList < Integer > toReturn = new ArrayList();
        
        int thisSquareKey = (int) (this.xCo + this.yCo);
        
        ArrayList<Path> foundPaths = maze.getPaths().getPaths(thisSquareKey);

        for (Path path: foundPaths) {
            int containsCheck = path.contains(this);
            if (path.contains(this) != -1) {
                if (containsCheck == 0) {
                    toReturn.add(path.getDirection());
                } else {
                    if (path.getDirection() == 0) {
                        toReturn.add(2);
                    }

                    if (path.getDirection() == 1) {
                        toReturn.add(3);
                    }

                    if (path.getDirection() == 2) {
                        toReturn.add(0);
                    }

                    if (path.getDirection() == 3) {
                        toReturn.add(1);
                    }
                }
            }
        }
        return (toReturn);
    }

    // Draws the square
    public void display() {
      rectMode(CENTER);
        if(generated && !solved && solvePressed) {
            noStroke();
            
            // Specific colouring for each solver
            switch(selectedSolver){
                case 1:
                    A_Star aStar = (A_Star) solvers[selectedSolver-1];
                    if (aStar.solveVisitedSquares.containsSquare(this)) {
                        colorMode(HSB);
                        fill(map(getHeuristic(), 0, (Math.abs(startingPoint.getX() - endingPoint.getX()) + (Math.abs(startingPoint.getY() - endingPoint.getY()))), 120, 255), 255, 225);
                        rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                        colorMode(RGB);
                    }
    
                    if (aStar.possibleSquares.contains(this)) {
                        fill(0);
                        rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                    }
                    break;
                case 2:
                    Breadth_First breadthFirst = (Breadth_First) solvers[selectedSolver-1];
                    if (breadthFirst.solveVisitedSquares.containsSquare(this)) {
                        colorMode(HSB);
                        fill(map(distance%((maze.getWidth()+maze.getHeight())/maze.squareSize), 0, ((maze.getWidth()+maze.getHeight())/maze.squareSize), 0, 255), 255, 225);
                        rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                        colorMode(RGB);
                    }
                    break;
                case 3:
                    Depth_First depthFirst = (Depth_First) solvers[selectedSolver-1];
                    if (depthFirst.turtle.prevSquares.containsSquare(this)) {
                        fill(0);
                        rect(x + maze.squareSize/2, y + maze.squareSize/2, w, h);
                    }
    
                    if (depthFirst.turtle.routeSquares.containsSquare(this)) {
                        colorMode(HSB);
                        fill(map(distance%(width/maze.squareSize), 0, (width/maze.squareSize), 0, 255), 255, 225);
                        rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                        colorMode(RGB);
                    }
                    break;
                case 4:
                    Left_Wall leftWall = (Left_Wall) solvers[selectedSolver-1];
                    if (leftWall.turtle!=null){
                        if (leftWall.turtle.prevSquares.containsSquare(this)) {
                            fill(0);
                            rect(x + maze.squareSize/2, y + maze.squareSize/2, w, h);
                        }
        
                        if (leftWall.turtle.routeSquares.containsSquare(this)) {
                            colorMode(HSB);
                            fill(map(distance%(width/maze.squareSize), 0, (width/maze.squareSize), 0, 255), 255, 225);
                            rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                            colorMode(RGB);
                        }
                    }
                    break;
                case 5:
                    Right_Wall rightWall = (Right_Wall) solvers[selectedSolver-1];
                    if (rightWall.turtle!=null){
                        if (rightWall.turtle.prevSquares.containsSquare(this)) {
                            fill(0);
                            rect(x + maze.squareSize/2, y + maze.squareSize/2, w, h);
                        }
        
                        if (rightWall.turtle.routeSquares.containsSquare(this)) {
                            colorMode(HSB);
                            fill(map(distance%(width/maze.squareSize), 0, (width/maze.squareSize), 0, 255), 255, 225);
                            rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                            colorMode(RGB);
                        }
                    }
                    break;
            }
        }
        
        // If starting or ending point, fill in specific colour
        if (generated){
            noStroke();
            if (this == startingPoint) {
                fill(255, 0, 0);
                circle(x + maze.squareSize/12, y + maze.squareSize/12, min(w - (maze.squareSize/6), h - (maze.squareSize/6)));
            } else if (this == endingPoint) {
                fill(0, 255, 0);
                circle(x + maze.squareSize/12, y + maze.squareSize/12, min(w - (maze.squareSize/6), h - (maze.squareSize/6)));
            }
        }

        if (!generated && generatePressed){
            noStroke();
            
            // Specific colouring methods for each generator
            switch(selectedGeneration){
            case(1):
                // Aldous
                Aldous_Broder aldousbroder = (Aldous_Broder) generators[selectedGeneration-1];
                
                if (aldousbroder.visitedSquares.containsSquare(this)){
                    fill(lerpColor(color(255, 0, 0), color(0, 255, 0), x/width ) + lerpColor(color(0, 0, 0), color(0, 0, 255), y/height ));
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                } 
                
                if (this == currentSquare){
                    fill(0);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                }
                break;
            case(2):
                // backtrack
                Backtracker backtracker = (Backtracker) generators[selectedGeneration-1];
                
                if (backtracker.routeSquares.containsSquare(maze.getSquare(getCoords()))) {
                    fill(0, 0, 255);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                } else if (backtracker.checkStack(this)) {
                    fill(255, 0, 0);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                }
                break;
            case(3):
                // binarytree
                if (this == currentSquare){
                    noStroke();
                    fill(0, 255, 0);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                } else {
                    noStroke();
                    fill(255);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                }
                break;
            case(4):
                // Blobby
                if (set != -1 && set != 0){
                  colorMode(HSB);
                  fill(map(getSet()%17, 0, 17, 0, 255), 255, 225);
                  rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                  colorMode(RGB);
                } else {
                  noStroke();
                    fill(255);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                }
                break;
            case(5):
                // Ellers
                colorMode(HSB);
                fill(map(getSet()%maze.getNumberOfRows(), 0, maze.getNumberOfRows(), 0, 255), 255, 225);
                rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                colorMode(RGB);
                break;
                
            case(6):
                // Houston
                Houston houston = (Houston) generators[selectedGeneration-1];
                if (houston.wilsonsSolver.currentWalk!=null && houston.wilsonsSolver.currentWalk.containsSquare(this)){
                    noStroke();
                    fill(0);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                } else if ((houston.stage == 2 && houston.wilsonsSolver.visitedSquares.containsSquare(this)) || houston.aldousSolver.visitedSquares.containsSquare(this)){
                    fill(lerpColor(color(255, 0, 0), color(0, 255, 0), x/width ) + lerpColor(color(0, 0, 0), color(0, 0, 255), y/height ));
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                } else {
                    noStroke();
                    fill(255);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                }
                break;
            case(7):
                // Hunt & Kill
                Hunt_Kill huntKill = (Hunt_Kill) generators[selectedGeneration-1];
                
                if (huntKill.checkStack(this)) {
                    fill(lerpColor(color(212,20,90), color(0,176,176), (float) (this.y/height)));
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                }
                break;
            case(8):
                // Kruskal
                colorMode(HSB);
                fill(map(getSet()%maze.getNumberOfRows(), 0, maze.getNumberOfRows(), 0, 255), 255, 225);
                rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                colorMode(RGB);
                break;
            case(9):
                // Prims
                Prims prims = (Prims) generators[selectedGeneration-1];
                
                if (prims.mainSetSquares.containsSquare(this) && !generated) {
                    fill(lerpColor(color(0xffFC354C), color(0xff0ABFBC), (float)(1.5f * (getDistanceFrom(prims.primStartSquare)) / (maze.getNumberOfRows() * Math.sqrt(2)))));
                   rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                }
                break;
            case(11):
                // SideWinder
                Side_Winder sidewind = (Side_Winder) generators[selectedGeneration-1];
                
                if (yCo == sidewind.sideY){
                    colorMode(HSB);
                    fill(map(getSet()%(maze.getNumberOfRows()), 0, maze.getNumberOfRows(), 0, 255), 255, 225);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                    colorMode(RGB);
                } else {
                    noStroke();
                    fill(255);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                }
                break;
            case(12):
                // Wilson
                Wilsons wilsons = (Wilsons) generators[selectedGeneration-1];
                
                if (wilsons.currentWalk.containsSquare(this)){
                    noStroke();
                    fill(0);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - floor(maze.squareSize/1.5f), h - floor(maze.squareSize/1.5f));
                } else if (wilsons.visitedSquares.containsSquare(this)){
                    fill(lerpColor(color(255, 0, 0), color(0, 255, 0), x/width ) + lerpColor(color(0, 0, 0), color(0, 0, 255), y/height ));
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/2), h - (maze.squareSize/2));
                } else {
                    noStroke();
                    fill(255);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - ceil(maze.squareSize/3), h - ceil(maze.squareSize/3));
                }
                break;
             default:
                break;
            }
        }

        // Draws the walls of the edges for specific generations and at the end of the generation
        strokeWeight((int) (max(1, maze.squareSize/10)));
        stroke(0);
        if (!(selectedGeneration == 12 || selectedGeneration == 6) || 
             (selectedGeneration == 12 && ((Wilsons) generators[selectedGeneration-1]).visitedSquares.containsSquare(this)) || 
             (selectedGeneration == 6 && ((((Houston) generators[selectedGeneration-1]).stage == 2 && ((Houston) generators[selectedGeneration-1]).wilsonsSolver.visitedSquares.containsSquare(this)) || (((Houston) generators[selectedGeneration-1]).aldousSolver.visitedSquares.containsSquare(this))))){
          if (upWall) {
              line(x, y, x + w, y);
          }
          
          if (leftWall) {
              line(x, y, x, y + h);
          }
  
          if (downWall) {
              line(x, y + h, x + w, y + h);
          }
  
          if (rightWall) {
              line(x + w, y, x + w, y + h);
          }
        }
    }

    // Check if square is above the passed square
    public boolean isAbove(Square square) {
        if (square != null) {
            return square.getYCo() > this.getYCo();
        }
        return false;
    }
    
    // Check if square is above the passed square
    public boolean isBelow(Square square) {
        if (square != null) {
            return square.getYCo() < this.getYCo();
        }
        return false;
    }

    // Check if square is above the passed square
    public boolean isLeft(Square square) {
        if (square != null) {
            return square.getXCo() > this.getXCo();
        }
        return false;
    }

    // Check if square is above the passed square
    public boolean isRight(Square square) {
        if (square != null) {
            return square.getXCo() < this.getXCo();
        }
        return false;
    }

    // Remove the top wall
    public void removeUpWall() {
        this.upWall = false;
    }

    // Remove the right wall
    public void removeRightWall() {
        this.rightWall = false;
    }

    // Remove the bottom wall
    public void removeDownWall() {
        this.downWall = false;
    }

    // Remove the left wall
    public void removeLeftWall() {
        this.leftWall = false;
    }

    // Add the top wall
    public void addUpWall() {
        this.upWall = true;
    }

    // Add the right wall
    public void addRightWall() {
        this.rightWall = true;
    }

    // Add the bottom wall
    public void addDownWall() {
        this.downWall = true;
    }

    // Add the left wall
    public void addLeftWall() {
        this.leftWall = true;
    }

    

    
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--hide-stop", "Maze_Visualisation" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
