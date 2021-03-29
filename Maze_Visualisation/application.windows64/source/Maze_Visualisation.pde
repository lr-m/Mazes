import java.util.Queue;
import java.util.LinkedList;
import java.util.Arrays;
import java.lang.*;

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

void settings() {
    fullScreen();
}

void setup() {
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

void draw() {
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

void mousePressed() {
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

void mouseReleased() {
    // Lock the slider values in
    sizeSlider.release();
    speedSlider.release();

}

void keyPressed() {
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
void reset() {
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

void skipToEndGeneration(){
  while(!generated){
    generators[selectedGeneration-1].generate();
  }
}

void skipToEndSolve(){
  while(!solved){
    solvers[selectedSolver-1].solve();
  }
}

// Clears the start and end points selected by the user
void resetPoints() {
    squaresToUpdate.add(startingPoint);
    squaresToUpdate.add(endingPoint);

    startingPoint = null;
    endingPoint = null;
    startingPointSelected = false;
    endingPointSelected = false;

    maze.clearSolution();
}

// Function to draw a button depending on a flag value
void drawButtonState(Button button, boolean pressed) {
    if (pressed) {
        button.drawSelected();
    } else {
        button.Draw();
    }
}

// Draws the interface
void drawButtons() {
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
boolean checkButton(Button button) {
    if (button.MouseIsOver()) {
        return true;
    }
    return false;
}

// Exports the picture of the maze to an image
void downloadPictureMaze(){
  PImage mazeImage = get(maze.x - 10, maze.y - 10, maze.w + 20, maze.h + 20);
  mazeImage.save("pictureMazes/maze" + (picMazeNumber+=1) + ".png");
}

// Prints the text representation of the maze to a text file
void downloadTextMaze(){
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
