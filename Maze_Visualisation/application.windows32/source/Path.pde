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
    
    // Utility

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

    // Update the squares
    void updateSquares() {
        squaresToUpdate.add(startSquare);
        squaresToUpdate.add(endSquare);
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
    void removeWallBetween(boolean refill) {
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
