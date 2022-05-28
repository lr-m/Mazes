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
    
    int getSize(){
       return size; 
    }

    // Adds a square to the hashmap
    void addSquare(Square square) {
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
    int getKey(Square square) {
        return square.getXCo() * square.getYCo();
    }

    // Calculates the hash function for specified coordinates
    int getKey(int xCo, int yCo) {
        return xCo * yCo;
    }

    // Retrieves the square with the passed coordinates from the hashmap if it exists
    Square getSquare(int xCo, int yCo) {

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
    boolean containsSquare(Square square) {

        if (square == null) {
            return false;
        }

        int keyToFind = getKey(square.getXCo(), square.getYCo());

        return squares.get(keyToFind).contains(square);
    }

    // Removes the passed square from the hashmap
    void removeSquare(Square square) {
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
    void addPath(Path path, Boolean refill) {
        paths.get(getKey(path)).add(path);
        path.removeWallBetween(refill);
        pathList.add(path);
        path.updateSquares();
    }

    // Performs the hash function on the specified path
    int getKey(Path path) {
        return path.startSquare.getXCo() + path.startSquare.getYCo();
    }

    // Performs the hash function on a specified square
    int getKey(Square startSquare) {
        return startSquare.getXCo() + startSquare.getYCo();
    }

    // Gets the paths from the list corresponding to the entered hash value
    ArrayList < Path > getPaths(int enteredKey) {
        return paths.get(enteredKey);
    }

    // Checks if the hashmap contains a path connecting the 2 passed squares
    boolean containsPath(Square square1, Square square2) {
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
    ArrayList < ArrayList <Square> > sets;
    int currentSet;

    // Initialises the set hashmap with the specified size
    Set_Hash() {
        sets = new ArrayList();
        currentSet = 0;
    }

    // Adds a square to the specified set number
    void addToSet(int setNumber, Square square) {
        if (setNumber < sets.size()){
            square.setSet(setNumber);
            sets.get(setNumber).add(square);
            squaresToUpdate.add(square);
        } else {
            addNewSet(square);
        }
    }
    
    void addNewSet(Square square){
        square.setSet(this.currentSet);
        
        sets.add(new ArrayList());
        sets.get(this.currentSet).add(square);
        
        this.currentSet++;
        
        squaresToUpdate.add(square);
    }

    // Gets the small square hash for the specified set number
    ArrayList<Square> getSet(int setNumber) {
        return sets.get(setNumber);
    }
    
    void clearSet(int setNum){
        sets.get(setNum).clear();
    }

    // Merges the 2 sets with the passed numbers into a single set
    void mergeSets(int setNumber1, int setNumber2) {
        if (setNumber1 == setNumber2) {
            return;
        }

        if (sets.get(setNumber1).size() > sets.get(setNumber2).size()) {
            for (Square square: sets.get(setNumber2)) {
                sets.get(setNumber1).add(square);
                square.setSet(setNumber1);
                squaresToUpdate.add(square);
            }

            sets.set(setNumber2, null);
        } else {
            for (Square square: sets.get(setNumber1)) {
                sets.get(setNumber2).add(square);
                square.setSet(setNumber2);
                squaresToUpdate.add(square);
            }

            sets.set(setNumber1, null);
        }
    }
}
