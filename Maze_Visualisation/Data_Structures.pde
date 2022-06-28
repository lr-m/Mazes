
class Node_Store{
  PriorityQueue<Node> nodes;
  int right_x, left_x, top_y, bottom_y;
  
  Node_Store(){
    nodes = new PriorityQueue();
    
    right_x = 0;
    left_x = width;
    top_y = height;
    bottom_y = 0;
  }
  
  void add(Node node){
    nodes.add(node);
    
    left_x = min(left_x, node.x);
    right_x = max(right_x, node.x);
    top_y = min(top_y, node.y);
    bottom_y = max(bottom_y, node.y);
  }
  
  PriorityQueue<Node> getList(){
    return nodes;
  }
  
  void clear(){
    nodes.clear();
  }
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
    
    void removePath(Square start, Square end){
      ArrayList < Path > foundPaths = new ArrayList();

      // Remove path from start square paths
      for (Path path: paths.get(getKey(start))) {
          if (path.startSquare == start || path.startSquare == end) {
            foundPaths.add(path);
          }
          
          if (path.startSquare == end || path.startSquare == start) {
            foundPaths.add(path);
          }
      }
      
      for (Path path : foundPaths){
        paths.get(getKey(start)).remove(path);
      }
      
      foundPaths.clear();

      // Remove path from end square paths
      for (Path path: paths.get(getKey(end))) {
          if (path.startSquare == start || path.startSquare == end) {
            foundPaths.add(path);
          }
          
          if (path.startSquare == end || path.startSquare == start) {
            foundPaths.add(path);
          }
      }
      
      for (Path path : foundPaths){
        paths.get(getKey(end)).remove(path);
      }
      
      foundPaths.clear();
    }
    
    void removePathAddWall(Square start, Square end){
      ArrayList < Path > foundPaths = new ArrayList();

      // Remove path from start square paths
      for (Path path: paths.get(getKey(start))) {
          if (path.startSquare == start && path.endSquare == end) {
            foundPaths.add(path);
          }
          
          if (path.startSquare == end && path.endSquare == start) {
            foundPaths.add(path);
          }
      }
      
      for (Path path : foundPaths){
        path.addWallBetween();
        paths.get(getKey(start)).remove(path);
      }
      
      foundPaths.clear();

      // Remove path from end square paths
      for (Path path: paths.get(getKey(end))) {
          if (path.startSquare == start && path.endSquare == end) {
            foundPaths.add(path);
          }
          
          if (path.startSquare == end && path.endSquare == start) {
            foundPaths.add(path);
          }
      }
      
      for (Path path : foundPaths){
        path.addWallBetween();
        paths.get(getKey(end)).remove(path);
      }
      
      foundPaths.clear();
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

class Node implements Comparable < Node > {
    int x,
    y;
    int primsKey;
    ArrayList<Edge> edges;

    Node(int x, int y) {
        this.x = x;
        this.y = y;
        
        edges = new ArrayList();

        primsKey = MAX_INT;
    }
    
    void addEdge(Edge edge){
      edges.add(edge);
    }
    
    ArrayList<Edge> getEdges(){
      return edges;
    }

    void Draw() {
        fill(255,0,0);
        rect(x-2, y - 2, 4, 4);
    }

    Node getNodeAbove() {
      for (int i = int(y - 5*maze.squareWidth/2); i < y - 3*maze.squareWidth/2; i++){
        if (nodes.getNode(x, i) != null){
          return nodes.getNode(x, i);
        }
      }
      
      return nodes.getNode(x, int(y - 2 * maze.squareWidth));
    }

    Node getNodeRight() {
      for (int i = int(x + 3*maze.squareWidth/2); i < x + 5*maze.squareWidth/2; i++){
        if (nodes.getNode(i, y) != null){
          return nodes.getNode(i, y);
        }
      }
    
      return nodes.getNode(int(x + 2 * maze.squareWidth), y);
    }

    Node getNodeBelow() {
      for (int i = int(y + 3*maze.squareWidth/2); i < y + 5*maze.squareWidth/2; i++){
        if (nodes.getNode(x, i) != null){
          return nodes.getNode(x, i);
        }
      }
      
      return nodes.getNode(x, int(y + 2 * maze.squareWidth));
    }

    Node getNodeLeft() {
      for (int i = int(x - 5*maze.squareWidth/2); i < x - 3*maze.squareWidth/2; i++){
        if (nodes.getNode(i, y) != null){
          return nodes.getNode(i, y);
        }
      }
      
      return nodes.getNode(int(x - 2 * maze.squareWidth), y);
    }

    int compareTo(Node node) {
        if (primsKey < node.primsKey) {
            return -1;
        } else if (primsKey == node.primsKey) {
            return 0;
        } else {
            return 1;
        }
    }

    String toString() {
        return primsKey + " " + x + " " + y;
    }
}

class Node_HashMap {
    ArrayList < ArrayList < Node > > nodes = new ArrayList < ArrayList < Node >> ();
    ArrayList < Node > nodeList = new ArrayList < Node > ();

    Node_HashMap(int capacity) {
        for (int i = 0; i < capacity; i++) {
            nodes.add(new ArrayList < Node > ());
        }
    }

    void addNode(Node node) {
        if (getKey(node) > nodes.size()) {
            return;
        } else {
            nodes.get(getKey(node)).add(node);
            nodeList.add(node);
        }
    }

    void setNodeKey(Node node, int primsKey) {
        node.primsKey = primsKey;
    }

    int getKey(Node node) {
        return Math.round((node.x / maze.squareWidth) * (node.y / maze.squareWidth));
    }

    int getKey(int x, int y) {
        return Math.round((x / maze.squareWidth) * (y / maze.squareWidth));
    }

    Node getNode(int x, int y) {

        int hashKey = getKey(x, y);

        if (hashKey < 0 || hashKey > nodes.size()) {
            return null;
        }

        ArrayList < Node > found = nodes.get(hashKey);

        for (Node node: found) {
            if (node.x == x && node.y == y) {
                return node;
            }
        }
        return null;
    }

    ArrayList < Node > getNodeList() {
        return nodeList;
    }
}

class Edge implements Comparable < Edge > {
    Node start,
    end;
    int weight;
    boolean traversed = false;

    Edge(Node start, Node end) {
        this.start = start;
        this.end = end;

        this.weight = Math.round(random(1, 10000));
    }

    void Draw() {
        strokeWeight(2);
        stroke(0, 255, 0);
        line(start.x, start.y, end.x, end.y);
    }

    int compareTo(Edge edge) {
        if (weight < edge.weight) {
            return -1;
        } else if (weight == edge.weight) {
            return 0;
        } else {
            return 1;
        }
    }
    
    ArrayList<Square> carve(){
      ArrayList<Square> carved = new ArrayList();
      
      // Get vector between nodes
      PVector v = new PVector(start.x - end.x, start.y - end.y);
      PVector half_v = new PVector(start.x - end.x, start.y - end.y);
      
      // Normalise vector and project onto square width
      v.normalize().mult(maze.squareWidth);
      half_v.normalize().mult(maze.squareWidth/2);
      
      // Get perpendicular vectors
      PVector pv = new PVector(-half_v.y, half_v.x);
      
      // Join 4 size squares
      PVector start_v1 = new PVector(end.x, end.y).sub(half_v).add(pv);
      PVector start_v2 = new PVector(end.x, end.y).sub(half_v).sub(pv);
      for (int i = 0; i < 3; i++){
        Square s1_l = maze.getSquareAtPosition(int(start_v1.x + i*v.x), int(start_v1.y + i*v.y));
        Square s2_l = maze.getSquareAtPosition(int(start_v1.x + (i+1)*v.x), int(start_v1.y + (i+1)*v.y));
        
        Square s1_r = maze.getSquareAtPosition(int(start_v2.x + i*v.x), int(start_v2.y + i*v.y));
        Square s2_r = maze.getSquareAtPosition(int(start_v2.x + (i+1)*v.x), int(start_v2.y + (i+1)*v.y));
        
        maze.addPath(s1_l, s2_l);
        maze.addPath(s1_r, s2_r);
        
        carved.add(s1_l);
        carved.add(s2_l);
        carved.add(s1_r);
        carved.add(s2_r);
      }
      
      //// If only 1 edge, join the 2 squares at the end 
      if (end.getEdges().size() == 1){
        maze.addPath(maze.getSquareAtPosition(int(start_v1.x), int(start_v1.y)), maze.getSquareAtPosition(int(start_v2.x), int(start_v2.y)));
      } else if (start.getEdges().size() == 1){
        PVector end_v1 = new PVector(start.x, start.y).add(half_v).add(pv);
        PVector end_v2 = new PVector(start.x, start.y).add(half_v).sub(pv);
        
        maze.addPath(maze.getSquareAtPosition(int(end_v1.x), int(end_v1.y)), maze.getSquareAtPosition(int(end_v2.x), int(end_v2.y)));
      }
      
      return carved;
    }
    
    void addWall(){
      // Get vector between nodes
      PVector v = new PVector(start.x - end.x, start.y - end.y);
      PVector half_v = new PVector(start.x - end.x, start.y - end.y);
      
      // Normalise vector and project onto square width
      v.normalize().mult(maze.squareWidth);
      half_v.normalize().mult(maze.squareWidth/2);
      
      // Get perpendicular vectors
      PVector pv = new PVector(-half_v.y, half_v.x);
      
      // Join 4 size squares
      PVector start_v1 = new PVector(end.x, end.y).add(half_v).add(pv);
      PVector start_v2 = new PVector(end.x, end.y).add(half_v).sub(pv);
      for (int i = 0; i < 2; i++){
        maze.getPaths().removePathAddWall(maze.getSquareAtPosition(int(start_v1.x + i*v.x), int(start_v1.y + i*v.y)), maze.getSquareAtPosition(int(start_v2.x + i*v.x), int(start_v2.y + i*v.y)));
      }
    }

    String toString() {
        return weight + "";
    }
}

class Edge_HashMap {
    ArrayList < ArrayList < Edge > > edges = new ArrayList < ArrayList < Edge >> ();
    ArrayList < Edge > edgeList = new ArrayList < Edge > ();

    Edge_HashMap(int capacity) {
        for (int i = 0; i < capacity; i++) {
            edges.add(new ArrayList < Edge > ());
        }
    }

    void addEdge(Edge edge) {
        if (getKey(edge) > edges.size()) {
            return;
        } else {
            edges.get(getKey(edge)).add(edge);
            edgeList.add(edge);
        }
    }

    int getKey(Edge edge) {
        Node node1 = edge.start;
        Node node2 = edge.end;
        return (int)(((node1.x / maze.squareWidth) + (node2.x / maze.squareWidth)));
    }

    int getKey(Node node1, Node node2) {
        return (int)(((node1.x / maze.squareWidth) + (node2.x / maze.squareWidth)));
    }

    Edge getEdge(Node node1, Node node2) {

        int hashKey = getKey(node1, node2);

        if (hashKey < 0 || hashKey > edges.size()) {
            return null;
        }

        ArrayList < Edge > found = edges.get(hashKey);

        for (Edge edge: found) {
            if (((edge.start.x == node1.x && edge.start.y == node1.y) && (edge.end.x == node2.x && edge.end.y == node2.y)) || (edge.end.x == node1.x && edge.end.y == node1.y) && (edge.start.x == node2.x && edge.start.y == node2.y)) {
                return edge;
            }
        }

        return null;
    }

    void removeEdge(Edge edge) {
        int keyToFind = getKey(edge.start, edge.end);

        ArrayList < Edge > foundEdges = edges.get(keyToFind);

        foundEdges.remove(edge);

        edgeList.remove(edge);
    }

    ArrayList < Edge > getEdgeList() {
        return edgeList;
    }
}
