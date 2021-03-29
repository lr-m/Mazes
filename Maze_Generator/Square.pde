// Class that represents a square in the maze
class Square {
    int xCo, yCo;
    boolean upWall, leftWall, downWall, rightWall;

    // For generators/solvers
    int set = -1;

    // Constructor
    Square(int xCo, int yCo) {
        this.xCo = xCo;
        this.yCo = yCo;

        this.upWall = true;
        this.downWall = true;
        this.rightWall = true;
        this.leftWall = true;
    }

    // Returns the distance between this square and the passed square
    float getDistanceFrom(Square square) {
        return (float) Math.sqrt(Math.pow(square.getXCo() - getXCo(), 2) + Math.pow(square.getYCo() - getYCo(), 2));
    }

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

    // Check if square is above the passed square
    void setWalls(boolean up, boolean right, boolean down, boolean left) {
        this.upWall = up;
        this.rightWall = right;
        this.downWall = down;
        this.leftWall = left;
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

    void setSet(int set) {
        this.set = set;
    }

    int getSet() {
        return set;
    }

    // Returns an arraylist indicating which edges of the squares are walls
    ArrayList < Boolean > getWalls() {
        return new ArrayList(Arrays.asList(upWall, rightWall, downWall, leftWall));
    }
}
