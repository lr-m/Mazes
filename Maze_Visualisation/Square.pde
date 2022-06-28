/**
 * Class that represents each square within the maze.
 */
class Square {
    float x, y, w, h;
    int xCo, yCo;
    boolean upWall, leftWall, downWall, rightWall;
    
    boolean in_word = false;
    
    int index = -1;

    // For generators/solvers
    int set;
    float distance;
    float heuristic;
    
    Square parent;
    
    ArrayList<Square> children;

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
    
    int getPathCount(){
        int count = 0;
        
        if (!upWall) count++;
        if (!downWall) count++;
        if (!rightWall) count++;
        if (!leftWall) count++;
        
        return count;
    }
    
    // Getters
    
    // Returns the distance between this square and the passed square
    float getDistanceFrom(Square square) {
        return (float) Math.sqrt(Math.pow(square.getXCo() - getXCo(), 2) + Math.pow(square.getYCo() - getYCo(), 2));
    }
    
    float getHeuristic(){
      return heuristic;
    }
    
    void setParent(Square parent){
        this.parent = parent;   
    }
    
    Square getParent(){
        return this.parent;
    }
    
    // Gets the distance of the square
    float getDistance(){
        return distance;
    }
    
    int getSet() {
        return set;
    }

    float getX() {
        return x;
    }

    float getY() {
        return y;
    }

    float getWidth() {
        return w;
    }

    float getHeight() {
        return h;
    }

    float getCenterX() {
        return x + w / 2;
    }

    float getCenterY() {
        return y + h / 2;
    }

    // Returns an arraylist indicating which edges of the squares are walls
    ArrayList < Boolean > getWalls() {
        return new ArrayList(Arrays.asList(upWall, rightWall, downWall, leftWall));
    }
    
    // Getters and setters for square
    int getXCo() {
        return xCo;
    }

    int getYCo() {
        return yCo;
    }

    ArrayList < Integer > getCoords() {
        return new ArrayList(Arrays.asList(xCo, yCo));
    }

    // Setters
    
    void setHeuristic(float heuristic){
      this.heuristic = heuristic;
    }
    
    // Sets the distance of the square
    void setDistance(float distance){
        this.distance = distance;
    }
    
    void setSet(int set) {
        this.set = set;
    }
    
    // Check if square is above the passed square
    void setWalls(boolean up, boolean right, boolean down, boolean left) {
        this.upWall = up;
        this.rightWall = right;
        this.downWall = down;
        this.leftWall = left;
    }
    
    // Utility

    // Gets all of the possible directions that can be navigated to by an agent, i.e, a surrounding square that doesnt have a wall between it and this square 
    ArrayList < Integer > getPossibleDirections() {
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
    void display() {
      rectMode(CENTER);
      
      // If starting or ending point, fill in specific colour
      if (generated){
            noStroke();
            if (this == startingPoint) {
                fill(255, 0, 0);
                circle(x + maze.squareSize/12, y + maze.squareSize/12, min(w - (maze.squareSize/6), h - (maze.squareSize/6)));
                return;
            } else if (this == endingPoint) {
                fill(0, 255, 0);
                circle(x + maze.squareSize/12, y + maze.squareSize/12, min(w - (maze.squareSize/6), h - (maze.squareSize/6)));
                return;
            }
        }

        if (!generated && generatePressed){
            noStroke();
            
            float fill_size = w - (maze.squareSize/2);
            
            // Specific colouring methods for each generator
            switch(selectedGeneration){
            case(1):
                // Aldous
                Aldous_Broder aldousbroder = (Aldous_Broder) generators[selectedGeneration-1];
                
                if (aldousbroder.visitedSquares.containsSquare(this)){
                    //fill(lerpColor(color(255, 0, 0), color(0, 255, 0), x/width ) + lerpColor(color(0, 0, 0), color(0, 0, 255), y/height ));
                    fill(25);
                    square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                } 
                
                if (this == currentSquare){
                    fill(0, 255, 0);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (1.5 * maze.squareSize/2), h - (1.5 * maze.squareSize/2));
                }
                break;
            case(2):
                // backtrack
                //Backtracker backtracker = (Backtracker) generators[selectedGeneration-1];

                if (this == currentSquare){
                    fill(0, 255, 0);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (1.5 * maze.squareSize/2), h - (1.5 * maze.squareSize/2));
                } else {
                    fill(25);
                    square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                }
                
                //if (backtracker.routeSquares.containsSquare(maze.getSquare(getCoords()))) {
                //    fill(0, 0, 255);
                //    square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                //} else if (backtracker.checkStack(this)) {
                //    fill(0,206,209);
                //    square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                //}
                break;
            case(3):
                // binarytree
                noStroke();
                
                if (this == currentSquare){
                    fill(0, 255, 0);
                    square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                } else {
                    fill(25);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                }
                break;
            case(4):
                // Blobby
                if (set != -1 && set != 0){
                  colorMode(HSB);
                  
                  fill(25);
                  rect(x + maze.squareSize/2, y + maze.squareSize/2, w - 0.75 * (maze.squareSize/2), h - 0.75 * (maze.squareSize/2));
                  
                  fill(map(getSet()%17, 0, 17, 0, 255), 255, 225);
                  square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                  colorMode(RGB);
                } else {
                  noStroke();
                  fill(25);
                  rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                }
                break;
            case(5):
                // Ellers
                colorMode(HSB);
                
                fill(25);
                rect(x + maze.squareSize/2, y + maze.squareSize/2, w - 0.75 * (maze.squareSize/2), h - 0.75 * (maze.squareSize/2));
                
                fill(map(getSet()%maze.getNumberOfRows(), 0, maze.getNumberOfRows(), 0, 255), 255, 225);
                square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                colorMode(RGB);
                break;
                
            case(6):
                // Houston
                Houston houston = (Houston) generators[selectedGeneration-1];
                
                if (this == currentSquare){
                    if (houston.stage == 1){
                        fill(0, 255, 0);
                        rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (1.5 * maze.squareSize/2), h - (1.5 * maze.squareSize/2));
                    } else if (houston.endStage) {
                        fill(25);
                        square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                        houston.endStage = false;
                    }
                }
               
                else if (houston.wilsonsSolver.currentWalk!=null && houston.wilsonsSolver.currentWalk.containsSquare(this)){
                    noStroke();
                    
                    fill(25);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - 0.75 * (maze.squareSize/2), h - 0.75 * (maze.squareSize/2));
                    
                    fill(255);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - floor(maze.squareSize/2), h - floor(maze.squareSize/2));
                } else if ((houston.stage == 2 && houston.wilsonsSolver.visitedSquares.containsSquare(this)) || houston.aldousSolver.visitedSquares.containsSquare(this)){
                    //fill(lerpColor(color(255, 0, 0), color(0, 255, 0), x/width ) + lerpColor(color(0, 0, 0), color(0, 0, 255), y/height ));
                    fill(25);
                    square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                } else {
                    noStroke();
                    
                    fill(25);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w-0.5, h-0.5);
                }
                
                
                
                break;
            case(7):
                // Hunt & Kill
                Hunt_Kill huntKill = (Hunt_Kill) generators[selectedGeneration-1];
                
                if (huntKill.checkStack(this)) {
                    fill(lerpColor(color(212,20,90), color(0,176,176), (float) (this.y/height)));
                    square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                }
                break;
            case(8):
                // Kruskal
                colorMode(HSB);
                
                fill(25);
                rect(x + maze.squareSize/2, y + maze.squareSize/2, w - 0.75 * (maze.squareSize/2), h - 0.75 * (maze.squareSize/2));
                
                fill(map(getSet()%maze.getNumberOfRows(), 0, maze.getNumberOfRows(), 0, 255), 255, 225);
                square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                colorMode(RGB);
                break;
            case(9):
                // Prims
                Prims prims = (Prims) generators[selectedGeneration-1];
                
                //if (prims.mainSetSquares.containsSquare(this) && !generated) {
                //    fill(lerpColor(color(#FC354C), color(#0ABFBC), (float)(1.5 * (getDistanceFrom(prims.primStartSquare)) / (maze.getNumberOfRows() * Math.sqrt(2)))));
                //   square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                //}
                break;
            case(11):
                // SideWinder
                Side_Winder sidewind = (Side_Winder) generators[selectedGeneration-1];
                
                if (yCo == sidewind.sideY){
                    colorMode(HSB);
                    fill(map(getSet()%(maze.getNumberOfRows()), 0, maze.getNumberOfRows(), 0, 255), 255, 225);
                    square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                    colorMode(RGB);
                } else {
                    noStroke();
                    fill(25);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - (maze.squareSize/4), h - (maze.squareSize/4));
                }
                break;
            case(12):
                // Wilson
                Wilsons wilsons = (Wilsons) generators[selectedGeneration-1];
                
                if (wilsons.currentWalk.containsSquare(this)){
                    noStroke();
                    
                    fill(25);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - 0.75 * (maze.squareSize/2), h - 0.75 * (maze.squareSize/2));
                    
                    fill(255);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w - floor(maze.squareSize/1.5), h - floor(maze.squareSize/1.5));
                } else if (wilsons.visitedSquares.containsSquare(this)){
                    //fill(lerpColor(color(255, 0, 0), color(0, 255, 0), x/width ) + lerpColor(color(0, 0, 0), color(0, 0, 255), y/height ));
                    fill(25);
                    square(x + maze.squareSize/2, y + maze.squareSize/2, fill_size);
                } else {
                    noStroke();
                    
                    fill(25);
                    rect(x + maze.squareSize/2, y + maze.squareSize/2, w, h);
                }
                break;
             default:
                break;
            }
        }
        
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
                        fill(25);
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
                        fill(25);
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
                            fill(25);
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
                            fill(25);
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

        // Draws the walls of the edges for specific generations and at the end of the generation
        strokeWeight(1);
        stroke(255);
        
        if (!(selectedGeneration == 12 || selectedGeneration == 6) || 
             (selectedGeneration == 12 && ((Wilsons) generators[selectedGeneration-1]).visitedSquares.containsSquare(this)) || 
             (selectedGeneration == 6 && ((((Houston) generators[selectedGeneration-1]).stage == 2 && 
             ((Houston) generators[selectedGeneration-1]).wilsonsSolver.visitedSquares.containsSquare(this)) || 
             (((Houston) generators[selectedGeneration-1]).aldousSolver.visitedSquares.containsSquare(this))))){
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
    
    void drawCleared(){
        // Draws the walls of the edges for specific generations and at the end of the generation
        strokeWeight(1);
        stroke(255);
        
        fill(25);
        rect(x + maze.squareSize/2, y + maze.squareSize/2, w, h);
        
        if (!(selectedGeneration == 12 || selectedGeneration == 6) || 
             (selectedGeneration == 12 && ((Wilsons) generators[selectedGeneration-1]).visitedSquares.containsSquare(this)) || 
             (selectedGeneration == 6 && ((((Houston) generators[selectedGeneration-1]).stage == 2 && 
             ((Houston) generators[selectedGeneration-1]).wilsonsSolver.visitedSquares.containsSquare(this)) || 
             (((Houston) generators[selectedGeneration-1]).aldousSolver.visitedSquares.containsSquare(this))))){
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
    boolean isAbove(Square square) {
        if (square != null) {
            return square.getYCo() > this.getYCo();
        }
        return false;
    }
    
    // Check if square is above the passed square
    boolean isBelow(Square square) {
        if (square != null) {
            return square.getYCo() < this.getYCo();
        }
        return false;
    }

    // Check if square is above the passed square
    boolean isLeft(Square square) {
        if (square != null) {
            return square.getXCo() > this.getXCo();
        }
        return false;
    }

    // Check if square is above the passed square
    boolean isRight(Square square) {
        if (square != null) {
            return square.getXCo() < this.getXCo();
        }
        return false;
    }

    // Remove the top wall
    void removeUpWall() {
        this.upWall = false;
    }

    // Remove the right wall
    void removeRightWall() {
        this.rightWall = false;
    }

    // Remove the bottom wall
    void removeDownWall() {
        this.downWall = false;
    }

    // Remove the left wall
    void removeLeftWall() {
        this.leftWall = false;
    }

    // Add the top wall
    void addUpWall() {
        this.upWall = true;
    }

    // Add the right wall
    void addRightWall() {
        this.rightWall = true;
    }

    // Add the bottom wall
    void addDownWall() {
        this.downWall = true;
    }

    // Add the left wall
    void addLeftWall() {
        this.leftWall = true;
    }
}
