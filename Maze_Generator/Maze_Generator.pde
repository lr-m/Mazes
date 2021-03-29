import java.util.Queue;
import java.util.LinkedList;
import java.util.Arrays;
import java.lang.*;

PrintWriter output;

Maze maze;
Square currentSquare;

IGenerator[] generators;

Button generateMaze;
Boolean generatePressed = false;

int autoGenCount = 0;

Boolean generated, clearedAfterGeneration;

int selectedGeneration = 0;

DropList generationSelector, genAmountSelector;

Boolean reset = false;
Button resetBut, pauseBut;

Slider numberOfColumns, numberOfRows;

int txtMazeNumber = 0;

void settings() {
    size(195, 650);
}

void setup() {
    frameRate(30);
    background(225);

    generateMaze = new Button("Generate", 15, 270, 160, 30);

    numberOfColumns = new Slider(20, 70, 150, 16, 4, 500);
    numberOfRows = new Slider(20, 125, 150, 16, 4, 500);

    generationSelector = new DropList(15, 185, 160, 30, "Generation Method", new ArrayList(Arrays.asList("Aldous-Broder", "BackTrack", "Binary Tree", "Blobby Recursive", "Eller's", "Hunt & Kill", "Kruskal's", "Prim's", "Recursive Division", "Sidewinder", "Wilson's")));
    genAmountSelector = new DropList(15, 225, 160, 30, "Amount", new ArrayList(Arrays.asList("1", "10", "100", "1000", "10000")));

    maze = new Maze();
    maze.create();

    generated = false;
    clearedAfterGeneration = false;

    pauseBut = new Button("", 25, height - 75, 60, 60);
    resetBut = new Button("", 100, height - 75, 60, 60);

    textAlign(CENTER, CENTER);
    ellipseMode(CORNER);
}

// Resets the visualisation
void reset() {
    // Reset indicators
    generatePressed = false;
    generated = false;
    clearedAfterGeneration = false;

    // Clear solution
    currentSquare = null;

    // Reset maze
    maze.reset();
}

void draw() {
    // Draw the maze and the buttons
    drawButtons();
}

void mousePressed() {
    // Update the number of rows and columns of the maze as the size slider value changes
    if (!generatePressed) {
        maze.updateRowAndColCounts();
        numberOfColumns.press();
    }
    numberOfRows.press();

    // If generator selected, reset all the generators to fit the maze
    if (generationSelector.checkForPress() != -1) {
        generators = new IGenerator[] {
            new Aldous_Broder(), new Backtracker(), new Binary_Tree(), new Blobby_Recursive(), new Ellers(), new Hunt_Kill(), new Kruskals(), new Prims(), new Recursive_Divide(), new Side_Winder(), new Wilsons()
        };
        selectedGeneration = generationSelector.checkForPress();
    }
    
    // If solver selected, reset all the solvers to fit the maze
    if (genAmountSelector.checkForPress() != -1) {
        autoGenCount = (int) Math.pow(10, genAmountSelector.checkForPress()-1);
    }

    // Check if the generation/solve button is pressed
    if (!genAmountSelector.dropped && !generationSelector.dropped && !generated && generateMaze.MouseIsOver() && selectedGeneration != 0) {
      maze.create();
      autoGenerate(autoGenCount);
    }
}

void mouseReleased() {
    // Lock the slider values in
    numberOfColumns.release();
    numberOfRows.release();
}

void keyPressed() {
    if (key == 'r') {
        reset = true;
    }
    
    if (key == ' '){
      for (int i = 4; i <= 128; i*=2){
          numberOfColumns.setValue(i);
          numberOfRows.setValue(i);
          maze.updateRowAndColCounts();
          maze.create();
          autoGenerateAll(1000);
      }
    }
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
    rect(0, 0, 180, height - 75);

    if (generatePressed) {
        generateMaze.drawSelected();
    } else {
        generateMaze.Draw();
    }

    numberOfColumns.display();
    numberOfRows.display();
    
    fill(0);
    textSize(20);
    text("Configure", 95, 20);
    text("Generate", 95, 160);

    textSize(13);
    fill(100);
    text("Columns: " + (int)(numberOfColumns.getValue() - (numberOfColumns.getValue() % 2)), 95, 50);
    text("Rows: " + (int)(numberOfRows.getValue() - (numberOfRows.getValue() % 2)), 95, 110);
    
    genAmountSelector.Draw();
    generationSelector.Draw();
}

// Indicates if the passed button has been pressed
boolean checkButton(Button button) {
    if (button.MouseIsOver()) {
        return true;
    }
    return false;
}

// Prints the text representation of the maze to a text file
void downloadTextMaze(){
  output = createWriter("Mazes/" + generators[selectedGeneration - 1].getName() + "/" + (2 * maze.getNumberOfColumns()+1) + "x" + (2 * maze.getNumberOfRows()+1) +"/maze" + (txtMazeNumber+=1) + ".txt");
  char[][] textVersion = maze.getTextRepresentation();
  
  for (int i = 0; i < textVersion[0].length; i++){
    for (int j = 0; j < textVersion.length; j++){
      if (textVersion[j][i] == '#'){
        output.print('#');
      } else {
        output.print('-');
      }
      
    }
    output.println();
  }
  
  output.flush();
  output.close();
}

void autoGenerateAll(int passed){
    generators = new IGenerator[] {new Aldous_Broder(), new Backtracker(), new Binary_Tree(), new Blobby_Recursive(), new Ellers(), new Hunt_Kill(), new Kruskals(), new Prims(), new Recursive_Divide(), new Side_Winder(), new Wilsons()};
    selectedGeneration = 1;
    for (IGenerator generator : generators){
      int j = 0;     
      while (j < passed){
        while (!generated){
          generator.generate();
        }
        maze.generationComplete();
        downloadTextMaze();
        
        generator.reset();
    
        // Clear solution
        currentSquare = null;
        
        generated = false;
    
        // Reset maze
        maze.reset();

        j++;
      }
      selectedGeneration++;

      txtMazeNumber = 0;
    }
    selectedGeneration = 0;
}

void autoGenerate(int amount){
  for (int i = 0; i < amount; i++){
    while (!generated){
      generators[selectedGeneration - 1].generate();
    }
    maze.generationComplete();
    downloadTextMaze();
    
    generators[selectedGeneration - 1].reset();

    reset();
    
    delay(50);
  }
}
