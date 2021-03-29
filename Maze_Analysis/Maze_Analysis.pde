import java.util.*;

int mode = 1; // 0 = left, 1 = right, 2 = solution, 3 = deadEnds

ArrayList<Integer> sizes;

ArrayList<ArrayList<Label>> leftIterationsLabels;
ArrayList<ArrayList<Label>> rightIterationsLabels;
ArrayList<ArrayList<Label>> solutionLengthLabels;
ArrayList<ArrayList<Label>> deadEndsLabels;

ArrayList<ArrayList<Integer>> leftIterations;
ArrayList<ArrayList<Integer>> rightIterations;
ArrayList<ArrayList<Integer>> solutionLength;
ArrayList<ArrayList<Integer>> deadEnds;

ArrayList<Integer> pointsToDraw;

String[] data;
String[] names = {"Aldous Broder", "Backtracker", "Binary", "Recursive Prims", "Ellers", "Hunt & Kill", "Kruskals", "Prims", "Division", "Sidewinder", "Wilsons"};

int maxLeft = 0, maxRight = 0, maxSolution = 0, maxDeadEnds = 0;

int max, min;

int pointSize;
int lineThickness;

Boolean dataSetChanged = false;

int mazeAmount;
int oldMazeAmount = 1;

Slider pointSizeSelector;
Slider lineThicknessSelector;
Slider mazeSizeSlider;
Slider graphSelector;

int headerHeight = 100;
int footerHeight = 125;

Boolean allSelected = false;

Button up, down, reset;
PImage upImg, downImg, resetImg;

TickBox aldous, backtracker, binary, blobby, ellers, huntkill, kruskals, prims, recursive, sidewinder, wilsons, all;
TickBox labels, lines;

ArrayList<ArrayList<Label>> labelsToDisplay;
ArrayList<ArrayList<Integer>> pointsToDisplay;

void setup(){
  size(1280, 720);
  
  pointsToDraw = new ArrayList();
  
  pointSizeSelector = new Slider(width - 525, height - 35, 100, 15, 1, 10);
  lineThicknessSelector = new Slider(width - 350, height - 35, 100, 15, 1, 5);
  mazeSizeSlider = new Slider(width - 700, height - 35, 100, 15, 1, 6);
  graphSelector = new Slider(width/2 - 100, 50, 200, 10, 1, 4);
  
  graphSelector.setValue(1);
  
  upImg = loadImage("up.png");
  downImg = loadImage("down.png");
  resetImg = loadImage("reset.png");
  
  up = new Button("", width-75, height/2 - 125 , 50, 50);
  reset = new Button("", width-75, height/2 + 75, 50, 50);
  down = new Button("", width-75, height/2 - 25, 50, 50);
  
  aldous = new TickBox(width/(names.length+5), height - 70, 15, "Aldous-Broder");
  backtracker = new TickBox(2 * width/(names.length+5), height - 70, 15, "Backtracker");
  binary = new TickBox(3 * width/(names.length+5), height - 70, 15, "Binary");
  blobby = new TickBox(4 * width/(names.length+5), height - 70, 15, "Prims Recursive");
  ellers = new TickBox(5 * width/(names.length+5), height - 70, 15, "Eller's");
  huntkill = new TickBox(6 * width/(names.length+5), height - 70, 15, "Hunt & Kill");
  kruskals = new TickBox(width/(names.length+5), height - 35, 15, "Kruskal's");
  prims = new TickBox(2 * width/(names.length+5), height - 35, 15, "Prim's");
  recursive = new TickBox(3 * width/(names.length+5), height - 35, 15, "Recursive Divide");
  sidewinder = new TickBox(4 * width/(names.length+5), height - 35, 15, "Sidewinder");
  wilsons = new TickBox(5 * width/(names.length+5), height - 35, 15, "Wilson's");
  
  all = new TickBox(6 * width/(names.length+5), height - 35, 15, "All");
  
  labels = new TickBox(width-75, height - 50, 15, "Labels");
  lines = new TickBox(width-150, height - 50, 15, "Lines");
  
  leftIterationsLabels = new ArrayList();
  rightIterationsLabels = new ArrayList();
  solutionLengthLabels = new ArrayList();
  deadEndsLabels = new ArrayList();
  
  leftIterations = new ArrayList();
  rightIterations = new ArrayList();
  solutionLength = new ArrayList();
  deadEnds = new ArrayList();

  for (int i = 0; i < names.length; i++){
    leftIterationsLabels.add(new ArrayList());
    rightIterationsLabels.add(new ArrayList());
    solutionLengthLabels.add(new ArrayList());
    deadEndsLabels.add(new ArrayList());
    
    leftIterations.add(new ArrayList());
    rightIterations.add(new ArrayList());
    solutionLength.add(new ArrayList());
    deadEnds.add(new ArrayList());
  }
  
  loadData();
  
  sortLabels();
  
  max = maxLeft;
  min = 0;
}

void draw(){
  strokeWeight(1);
  background(225);
  stroke(0);
  fill(255);
  rect(100, 75, width-200, height-190);
  
  pointSize = (int) pointSizeSelector.getValue();
  lineThickness = (int) lineThicknessSelector.getValue();
  mazeAmount = (int) mazeSizeSlider.getValue();
  mode = (int) graphSelector.getValue();
  
  allSelected = all.getState();
  
  aldous.Draw();
  backtracker.Draw();
  binary.Draw();
  blobby.Draw();
  ellers.Draw();
  huntkill.Draw();
  kruskals.Draw();
  prims.Draw();
  recursive.Draw();
  sidewinder.Draw();
  wilsons.Draw();
  
  all.Draw();
  
  text("Point Diameter: " + (int) pointSizeSelector.getValue(), width-475, height - 50);
  text("Line Thickness: " + (int) lineThicknessSelector.getValue(), width-300, height - 50);
  text("Maze Amount: " + (int) mazeSizeSlider.getValue(), width-650, height - 50);
  
  pointSizeSelector.display();
  lineThicknessSelector.display();
  mazeSizeSlider.display();
  graphSelector.display();
  
  labels.Draw();
  lines.Draw();
  
  up.Draw(upImg);
  down.Draw(downImg);
  reset.Draw(resetImg);
  
  textSize(12);
  drawScale();
  drawBottomLabels();
  
  drawConnectingLines();

  strokeWeight(10);
  colorMode(HSB);
  
  labelsToDisplay = new ArrayList();
  pointsToDisplay = new ArrayList();
  
  if (mode == 1){
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Left -> Right Depth First Search Iterations", width/2, 25);
    
    labelsToDisplay = leftIterationsLabels;
    pointsToDisplay = leftIterations;
  } else if (mode == 2){
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Right -> Left Depth First Search Iterations", width/2, 25);
    
    labelsToDisplay = rightIterationsLabels;
    pointsToDisplay = rightIterations;
  } else if (mode == 3){
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Length of Solution", width/2, 25);
    
    labelsToDisplay = solutionLengthLabels;
    pointsToDisplay = solutionLength;
  } else if (mode == 4){
    textSize(24);
    textAlign(CENTER, CENTER);
    text("Number of Dead Ends", width/2, 25);
    
    labelsToDisplay = deadEndsLabels;
    pointsToDisplay = deadEnds;
  }
  
  if (dataSetChanged){
    getMax();
    dataSetChanged = false;
  }
  
  for (ArrayList<Label> labelList : labelsToDisplay){
    int avg = 0;
    int count = 0;
    
    for (Label label : labelList){
      if (label.value < max & label.value > min){
        avg += label.value;
        count++;
      }
    }
    
    float avgCount = (float) avg / (float) count;
    float mid = ((float) max + (float) min)/2;
    
    Boolean topOrBot = (avgCount > mid);
    
    int aboveMax = 0;
    int belowMin = 0;
    
    for (Label label : labelList){
      if (label.value > max){
        aboveMax++;
      } 
      
      if (label.value < min){
        belowMin++;
      }
    }
    
    for (Label label : labelList){
      //if (topOrBot){
        if (label.y != (int) (map(labelList.indexOf(label) - aboveMax, 0, labelList.size()-1, headerHeight, height-footerHeight))){
          label.setY((int) map(labelList.indexOf(label) - aboveMax, 0, labelList.size()-1, headerHeight, height-footerHeight-10));
        }
        label.Draw();
      //} else {
      //  label.Draw(map(labelList.indexOf(label) + belowMin, 0, labelList.size()-1, headerHeight, height-footerHeight));
      //}
    }
  }
  
  if (mazeAmount != oldMazeAmount){
    getMax();
    oldMazeAmount = mazeAmount;
    println("change Detected");
  }
  colorMode(RGB);
}

void getMax(){
  max = 0;
  min = 0;
  for (ArrayList<Integer> data : pointsToDisplay){
    for (int i = 0; i < mazeAmount; i++){
      println(data.get(i));
      if (data.get(i) > max){
        max = data.get(i);
      }
    }
  } 
}

void mousePressed(){
  pointSizeSelector.press();
  lineThicknessSelector.press();
  mazeSizeSlider.press();
  graphSelector.press();
  
  if (mouseX < width - 100 && mouseX > 100 && mouseY > headerHeight && mouseY < height - footerHeight){
    if (mouseButton == LEFT){
      if ((max - min) > 20){
        zoomIn(mouseY);
      }
    }
    
    if (mouseButton == RIGHT){
      zoomOut(mouseY);
    }
  }
  
  if (up.MouseIsOver()){
    float upAmt = (max-min)/10;
    max+=upAmt;
    min+=upAmt;
  }
  
  if (down.MouseIsOver()){
    float downAmt = (max-min)/10;
    max-=downAmt;
    min-=downAmt;
  }
  
  if (reset.MouseIsOver()){
    if (mode == 1){
      max = maxLeft;
      min = 0;
    } else if (mode == 2){
      max = maxRight;
      min = 0;
    } else if (mode == 3){
      max = maxSolution;
      min = 0;
    } else if (mode == 4){
      max = maxDeadEnds;
      min = 0;
    }
  }
  
  aldous.checkForPress();
  backtracker.checkForPress();
  binary.checkForPress();
  blobby.checkForPress();
  ellers.checkForPress();
  huntkill.checkForPress();
  kruskals.checkForPress();
  prims.checkForPress();
  recursive.checkForPress();
  sidewinder.checkForPress();
  wilsons.checkForPress();
  
  all.checkForPress();
  
  labels.checkForPress();
  lines.checkForPress();
  
  getStates();
}

void mouseReleased(){
  pointSizeSelector.release();
  lineThicknessSelector.release();
  mazeSizeSlider.release();
  graphSelector.release();
}

void keyPressed(){
  if (key == '1'){
    max = maxLeft;
    min = 0;
    mode = 1;
    
    dataSetChanged = true;
  } else if (key == '2'){
    max = maxRight;
    min = 0;
    mode = 2;
    
    dataSetChanged = true;
  } else if (key == '3'){
    max = maxSolution;
    min = 0;
    mode = 3;
    
    dataSetChanged = true;
  } else if (key == '4'){
    max = maxDeadEnds;
    min = 0;
    mode = 4;
    
    dataSetChanged = true;
  }
}

void zoomIn(int input){
  int topDifference = input - headerHeight;
  int botDifference = (height - footerHeight) - input;
  
  float topAmount = ((float) topDifference/((float) topDifference + (float) botDifference)) * (float)(max-min);
  float botAmount = ((float) botDifference/((float) topDifference + (float) botDifference)) * (float)(max-min);
  
  max -= (topAmount/5);
  min += (botAmount/5);
}

void zoomOut(int input){
  int topDifference = input - headerHeight;
  int botDifference = (height - footerHeight) - input;
  
  float topAmount = ((float) topDifference/((float) topDifference + (float) botDifference)) * (float)(max-min);
  float botAmount = ((float) botDifference/((float) topDifference + (float) botDifference)) * (float)(max-min);
  
  max += (topAmount/5);
  min -= (botAmount/5);
}
