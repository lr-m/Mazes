// Path between 2 squares, if the path exists in the maze, then there is not a wall seperating the 2 squares
class Path {
    Square startSquare, endSquare;
    int direction;

    // Constructor
    Path(Square startSquare, Square endSquare) {
        this.startSquare = startSquare;
        this.endSquare = endSquare;
    }

    // Check if this path contains the passed square
    int contains(Square square) {
        if (startSquare == square) {
            return 0;
        } else if (endSquare == square) {
            return 1;
        } else {
            return -1;
        }
    }

    // Add a wall between the start and end square
    void addWallBetween() {
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
    void removeWallBetween() {
        if (startSquare.isLeft(endSquare)) {
            startSquare.removeRightWall();
            endSquare.removeLeftWall();
            direction = 1;
        } else if (startSquare.isRight(endSquare)) {
            endSquare.removeRightWall();
            startSquare.removeLeftWall();
            direction = 3;
        } else if (startSquare.isAbove(endSquare)) {
            endSquare.removeUpWall();
            startSquare.removeDownWall();
            direction = 2;
        } else if (startSquare.isBelow(endSquare)) {
            endSquare.removeDownWall();
            startSquare.removeUpWall();
            direction = 0;
        }
    }

    // Gets the first square in the path
    Square getStartSquare() {
        return startSquare;
    }

    // Gets the last square in the path
    Square getEndSquare() {
        return endSquare;
    }

    // Gets the orientation of the path
    int getDirection() {
        return direction;
    }
}
