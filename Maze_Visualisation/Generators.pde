import java.util.Collections;

/**
 * The interface used by the maze generators.
 */
interface IGenerator {
    String getName();
    
    void initialise();
  
    void generate();
}

class Words implements IGenerator {
  String words;
  int textSize;
  
  int direction = 1;
  
  Prims prims;
  
  ArrayList<Square> modifiedSets;
  ArrayList<Square> wordSquares;
  
  boolean firstVertexPicked = false;
  boolean mst_generated = false;
  
  ArrayList <Node_Store> mstSets = new ArrayList();
  
  Words(){}
  
  void drawText(String words, int text_size){
    PFont mono;
    mono = createFont("data/font2.ttf", 128);
    textFont(mono);
    
    textSize(text_size);
    
    fill(255);
    
    String[] split = words.split(" ");
    int curr_x = 0;
    int limit = int(maze.w-textWidth('o'));
    int curr_y = int(maze.y + wordsHeight.getValue());
    
    String curr = "";
    for (String string : split){
      if (curr_x + textWidth(string) > limit){
        if (textWidth(string) > limit){
          if (curr_x != 0){
            text(curr, maze.x + maze.w/2, curr_y);
            
            curr = "";
            curr_x = 0;
            curr_y += textAscent()*1.25;
          }
          
          int i = 0;
          while(i < string.length()){
            while(curr_x + textWidth(string.charAt(i)) < limit){
              curr_x+=textWidth(string.charAt(i));
              curr+=string.charAt(i);
              i++;
              
              if (i == string.length()){
                break;
              }
            }
            
             if (i == string.length()){
               curr+=' ';
                break;
              }
            
            text(curr, maze.x + maze.w/2, curr_y);
            
            curr = "";
            curr_x = 0;
            curr_y += textAscent()*1.25;
          }
          continue;
        } else {
          text(curr, maze.x + maze.w/2, curr_y);
          curr = "";
          curr_x = 0;
          curr_y += textAscent()*1.25;
        }
      }
      curr += string + " ";
      curr_x += textWidth(string);
    }
    
    if (curr.length() > 0 && curr.charAt(curr.length()-1) == ' '){
      curr = curr.substring(0, curr.length()-1);
    }
    text(curr, maze.x + maze.w/2, curr_y);
    
    textFont(normal_font);
  }
  
  void initialise(){
    modifiedSets = new ArrayList();
    wordSquares = new ArrayList();
    
    mstSets = new ArrayList();
    
    path = new ArrayList();
    mstSet = new Node_Store();
    mst = new ArrayList();
    
    nodes = new Node_HashMap(100000);
    edges = new Edge_HashMap(100000);
    
    direction = 1;
    
    firstVertexPicked = false;
    mst_generated = false;
    
    textSize = int(wordsFontSizeSlider.getValue());
    words = wordEntry.getInput();
    
    drawText(words, textSize);
    
    for (Square square : maze.squares){
      int count = 0;
      
      if (square.xCo <= 1 || square.yCo <= 1 || square.xCo >= maze.numOfColumns-1 || square.yCo >= maze.numOfRows-1){
        continue;
      }

      for (int i = floor(square.x); i < square.x + square.w; i++){
        for (int j = floor(square.y); j < square.y + square.h; j++){
          if (get(i, j) == color(255, 255, 255)){
            count++;
          }
        }
        
        if (count > 2 * (square.w * square.h) / 3){
            square.in_word = true;
            wordSquares.add(square);
            
            break;
          }
      }
      
    }
    
    maze.overwrite();
  }
  
  String getName(){
    return "13_words";
  }
  
  void generate(){
    if (generated){
      return;
    }
    
    try{
    
      ArrayList<Square> carvedSquares = new ArrayList();
        
      // Form the minimum spanning tree
      if (wordSquares.size() > 0){
        // Generate hamiltonian path around all of the squares
        for (Square square : maze.getSquares()){
          if (square.xCo%2 == 0 && square.yCo%2 == 0 && square.in_word
            && maze.getSquareRight(square) != null && maze.getSquareBelow(square) != null
            && maze.getSquareRight(square).in_word && maze.getSquareBelow(square).in_word){
                Node newNode = new Node(int(square.x + maze.squareWidth), int(square.y + maze.squareWidth));
                nodes.addNode(newNode);
                
                if (!maze.getSquareBelow(maze.getSquareRight(square)).in_word){
                  maze.getSquareBelow(maze.getSquareRight(square)).in_word = true;
                  wordSquares.add(maze.getSquareBelow(maze.getSquareRight(square)));
                }
          }
        }
        
        for (Node node: nodes.getNodeList()) {
            if (node.getNodeBelow() != null) {
              Edge newEdge = new Edge(node, node.getNodeBelow());
              edges.addEdge(newEdge);
            }
    
            if (node.getNodeRight() != null) {
              Edge newEdge = new Edge(node, node.getNodeRight());
              edges.addEdge(newEdge);
            }
        }
    
        while (mst_generated == false) {
            if (!firstVertexPicked) {
                int rand = Math.round(random(0, nodes.getNodeList().size() - 1));
    
                Node firstVertex = nodes.getNodeList().get(rand);
                firstVertex.primsKey = 0;
                firstVertexPicked = true;
            }
  
            if (mst.size() != nodes.getNodeList().size() - 2) {
                Node min = getMinKey();
                
                if (min == null){
                  boolean hit = false;
                  for (Node node : nodes.getNodeList()){
                    boolean check = false;
                    for (Node_Store mstSetCheck : mstSets){
                      if (mstSetCheck.getList().contains(node)){
                        check = true;
                        break;
                      }
                    }
                    
                    if (!mstSet.getList().contains(node) && !check){
                      Node_Store toAdd = new Node_Store();
                      for (Node add_node : mstSet.getList()){
                        toAdd.add(add_node);
                      }
                      mstSets.add(toAdd);
                      
                      node.primsKey = 0;
                      min = node;
                      hit = true;
                      
                      mstSet = new Node_Store();
                      
                      break;
                    }
                  }
                  
                  if (hit == false){
                    mst_generated = true;
                    mstSets.add(mstSet);
                    break;
                  }
                }
    
                Edge addedEdge = null;
                for (Node vertex: mstSet.getList()) {
                    addedEdge = getEdge(min, vertex);
                    if (addedEdge != null) {
                        mst.add(addedEdge);
                        min.addEdge(addedEdge);
                        vertex.addEdge(addedEdge);
                        edges.removeEdge(addedEdge);
                        break;
                    }
                }
    
                mstSet.add(min);
    
                ArrayList < Node > possibleVertices = getPossibleVertices(min);
    
                for (Node vertex: possibleVertices) {
                    if (getEdge(min, vertex).weight < vertex.primsKey) {
                        vertex.primsKey = (getEdge(min, vertex).weight);
                    }
                }
            } else {
              mstSets.add(mstSet);
              mst_generated = true;
            }
        }
        
        // Bridge the MSTs
        while(mstSets.size() > 1){
          // Find the closest set to the first set (and get the closest nodes)
          Node close1 = null;
          Node close2 = null;
          float min_dist = MAX_INT;
          Node_Store mergedSet = null;
          for (Node_Store mstSet : mstSets){
            if (mstSets.get(0) != mstSet){
              for (Node test : mstSets.get(0).getList()){
                for (Node test2 : mstSet.getList()){
                  if (dist(test.x, test.y, test2.x, test2.y) < min_dist){
                    min_dist = dist(test.x, test.y, test2.x, test2.y);
                    close1 = test;
                    close2 = test2;
                    mergedSet = mstSet;
                  }
                }
              }
            }
          }
          
          joinNodes(close1, close2);
          
          for (Node node : mergedSet.getList()){
            mstSets.get(0).add(node);
          }
          
          mstSets.remove(mergedSet);
        }
        
        
        // Generate the hamiltonian path, and carve into maze
        for (int i = 0; i < 2; i++){
          Node firstNode = null;
          Node prevNode = null;
          Node currentNode = null;
          
          for (Node node : mstSets.get(0).getList()){
            for (Edge edge : node.getEdges()){
              edge.traversed = false;
            }
            if (node.getEdges().size() == 1){
              firstNode = node;
            }
          }
          
          currentNode = firstNode;
          
          ArrayList<Node> stack = new ArrayList();
          stack.add(firstNode);
          
          boolean possibleMove = false;
          do{
            possibleMove = false;
            prevNode = currentNode;
            
            // Get next node, save so not traversed again
            for (Edge edge : currentNode.getEdges()){
              if (!edge.traversed){
                if (edge.start != currentNode){
                  currentNode = edge.start;
                } else {
                  currentNode = edge.end;
                }
                edge.traversed = true;
                possibleMove = true;
                stack.add(currentNode);
                
                if (i == 0){
                  for (Square square : edge.carve()){
                    carvedSquares.add(square);
                  }
                } else {
                  edge.addWall();
                }
  
                break;
              }
            }
            
            // If no moves, pop stack until there are possible moves
            while (!possibleMove && stack.size() > 0){
              currentNode = stack.remove(stack.size()-1);
              for (Edge edge : currentNode.getEdges()){
                if (!edge.traversed){
                  possibleMove = true;
                  stack.add(currentNode);
                  break;
                }
              }
            }
            
            if (stack.size() == 0){
              break;
            }
            
            // Carve out squares on the left and right of edge between the nodes
          } while (currentNode != firstNode);
        }
      }
      
      // Remove the squares from word squares that have not been used for the hamiltonian cycle
      for (Square square : carvedSquares){
        wordSquares.remove(square);
        square.in_word = true;
      }
      
      for (Square square : wordSquares){
        square.in_word = false;
      }
       
      // Split the environment into 2 parts (to use word as bottleneck)
      Square left = carvedSquares.get(0);
      Square right = carvedSquares.get(0);
      Collections.shuffle(carvedSquares);
      
      for (Square square : carvedSquares){
        if (square.in_word && maze.getSquareRight(square).in_word 
            && !maze.getSquareAbove(square).in_word 
            && !maze.getSquareAbove(maze.getSquareRight(square)).in_word){
          
          Square current = square;
          boolean check = false;
          while(true) {
            current = maze.getSquareAbove(current);
            
            if (current == null){
              break;
            }
            
            if (current.in_word || maze.getSquareRight(current).in_word){
              check = true;
              break;
            }
          }
          
          if (check) continue;
         
          if (square.yCo <= left.yCo){
            left = square;
            right = maze.getSquareRight(square);
          }
        }
      }
      
      // get min and max yCo
      int min = maze.numOfRows;
      int max = -1;
      for (Square square : carvedSquares){
        min = min(min, square.yCo);
        max = max(max, square.yCo);
      }
    
      for (Square square : maze.squares){
        if (left != null && !square.in_word && square.xCo > left.xCo){
            square.setSet(-2);
            modifiedSets.add(square);
            
            if (square.yCo < min - 2 || square.yCo > max + 2){
              if (maze.getSquareLeft(square) != null && random(1) > 0.6){
                Square curr = square;
                for (int i = 0; i < random(3); i++){
                  if (maze.getSquareLeft(maze.getSquareLeft(curr)) == null){
                    break;
                  }
                  if (!maze.getSquareLeft(maze.getSquareLeft(curr)).in_word){
                    maze.getSquareLeft(curr).setSet(-2);
                    modifiedSets.add(maze.getSquareLeft(curr));
                    curr = maze.getSquareLeft(curr);
                  } else {
                    break;
                  }
                }
              } else if (maze.getSquareRight(square) != null && random(1) > 0.6){
                Square curr = square;
                for (int i = 0; i < random(3); i++){
                  if (maze.getSquareRight(maze.getSquareRight(curr)) == null){
                    break;
                  }
                  if (!maze.getSquareRight(maze.getSquareRight(curr)).in_word){
                    maze.getSquareRight(curr).setSet(-1);
                    curr = maze.getSquareRight(curr);
                  } else {
                    break;
                  }
                }
              }
            }
        }
      }
      
      // First half
      prims = new Prims();
      prims.initialise(maze.getSquareAtPosition(int(maze.x + 2*maze.squareWidth), maze.y + maze.h/2));
      left.in_word = false;
      while(!generated){
        prims.generate();
      }
      
      left.in_word = true;
      right.in_word = false;
      
      generated = false;
      
      for (Square square : modifiedSets){
        square.setSet(-1);
      }
      
      // Second half
      prims = new Prims();
      prims.initialise(maze.getSquareAtPosition(int(maze.x + maze.w - 2*maze.squareWidth), maze.y + maze.h/2));
      while(!generated){
        prims.generate();
      } 
      
      while(true){
        boolean found = false;
        for (Square square : maze.squares){
          if (!square.in_word && square.set == -1){
            prims = new Prims();
            prims.initialise(square);
            generated = false;
            found = true;
            break;
          }
        }
        
        if (found){
          while(!generated){
            prims.generate();
          }
        } else {
          left.addRightWall();
          right.addLeftWall();
          maze.removePathBetween(left, right);
          
          maze.generatePaths();
          generated = true;
          
          return;
        }
      }
    } catch (Exception e){
      generated = true;
      squaresToUpdate.clear();
      fill(255);
      if (wordEntry.getInput().equals("")){
        text("Generation failed: Empty input", maze.x + maze.w/2, maze.y + maze.h/2);
      } else {
        text("Generation failed: Increase font size or decrease square size", maze.x + maze.w/2, maze.y + maze.h/2);
      }
    }
  }
  
  // Joins 2 nodes with other nodes (used for joining MST)
  void joinNodes(Node node1, Node node2){
    Node curr = node1;
    Node last_curr = node1;
    Node target = node2;
    float curr_x = node1.x;
    float curr_y = node1.y;
    
    if (abs(node1.x - node2.x) > abs(node1.y - node2.y)){
      if (node1.x < node2.x){
        curr = new Node(int(curr_x + maze.squareWidth*2), int(curr_y));
        curr_x += maze.squareWidth*2;
        target = new Node(int(node2.x - maze.squareWidth*2), int(node2.y));
      } else {
        curr = new Node(int(curr_x - maze.squareWidth*2), int(curr_y));
        curr_x -= maze.squareWidth*2;
        target = new Node(int(node2.x + maze.squareWidth*2), int(node2.y));
      }
    } else {
      if (node1.y < node2.y){
        curr = new Node(int(curr_x), int(curr_y + maze.squareWidth*2));
        curr_y += maze.squareWidth*2;
        target = new Node(int(node2.x), int(node2.y - maze.squareWidth*2));
      } else {
        curr = new Node(int(curr_x), int(curr_y - maze.squareWidth*2));
        curr_y -= maze.squareWidth*2;
        target = new Node(int(node2.x), int(node2.y + maze.squareWidth*2));
      }
    }
    
    Edge startEdge = new Edge(node1, curr);
    Edge endEdge = new Edge(target, node2);
    
    node1.addEdge(startEdge);
    curr.addEdge(startEdge);
    
    target.addEdge(endEdge);
    node2.addEdge(endEdge);
    
    mstSets.get(0).add(target);
    mstSets.get(0).add(curr);
    
    mst.add(startEdge);
    mst.add(endEdge);
    
    while(abs(target.x-curr_x) > maze.squareWidth|| abs(target.y-curr_y) > maze.squareWidth){
      if (curr.x < target.x && abs(curr.x - target.x) > maze.squareWidth){
        last_curr = curr;
        curr_x += 2*maze.squareWidth;
        curr = new Node(int(curr_x), int(curr_y));
        mstSets.get(0).add(curr);
        
        Edge newEdge = new Edge(last_curr, curr);
        last_curr.addEdge(newEdge);
        curr.addEdge(newEdge);
        mst.add(newEdge);
      } 
      
      if (curr.x > target.x && abs(curr.x - target.x) > maze.squareWidth){
        last_curr = curr;
        curr_x -= 2*maze.squareWidth;
        curr = new Node(int(curr_x), int(curr_y));
        mstSets.get(0).add(curr);
        
        Edge newEdge = new Edge(last_curr, curr);
        last_curr.addEdge(newEdge);
        curr.addEdge(newEdge);
        mst.add(newEdge);
      }
      
      if (curr.y > target.y && abs(curr.y - target.y) > maze.squareWidth){
        last_curr = curr;
        curr_y -= 2*maze.squareWidth;
        curr = new Node(int(curr_x), int(curr_y));
        mstSets.get(0).add(curr);
        
        Edge newEdge = new Edge(last_curr, curr);
        last_curr.addEdge(newEdge);
        curr.addEdge(newEdge);
        mst.add(newEdge);
      }
      
      if (curr.y < target.y && abs(curr.y - target.y) > maze.squareWidth){
        last_curr = curr;
        curr_y += 2*maze.squareWidth;
        curr = new Node(int(curr_x), int(curr_y));
        mstSets.get(0).add(curr);
        
        Edge newEdge = new Edge(last_curr, curr);
        last_curr.addEdge(newEdge);
        curr.addEdge(newEdge);
        mst.add(newEdge);
      }
    }
    
    Edge newEdge = new Edge(last_curr, target);
    target.addEdge(newEdge);
    last_curr.addEdge(newEdge);
    mst.add(newEdge);
  }
  
  void drawPath() {
      stroke(255, 0, 0);
      strokeWeight(2);
      for (int i = 0; i < path.size() - 1; i++) {
          drawLineBetween(path.get(i), path.get(i + 1));
      }
  }
  
  void drawLineBetween(Square square1, Square square2) {
      line(square1.x + maze.squareWidth / 2, square1.y + maze.squareWidth / 2, square2.x + maze.squareWidth / 2, square2.y + maze.squareWidth / 2);
  }
  
  ArrayList < Node > getPossibleVertices(Node vertex) {
    ArrayList < Node > toReturn = new ArrayList();
    for (Edge edge: edges.getEdgeList()) {
        if (edge.start == vertex && !toReturn.contains(edge.end)) {
            toReturn.add(edge.end);
        } else if (edge.end == vertex && !toReturn.contains(edge.start)) {
            toReturn.add(edge.start);
        }
    }

    return toReturn;
  }
  
  Node getMinKey() {
    Node toReturn = null;
    int minKey = MAX_INT;

    for (Node vertex: nodes.getNodeList()) {
      boolean check = mstSet.getList().contains(vertex);
      
      for (Node_Store mstSetCheck : mstSets){
        if (mstSetCheck.getList().contains(vertex)){
          check = true;
        }
      }
      
      if (vertex.primsKey < minKey && !check) {
          toReturn = vertex;
          minKey = vertex.primsKey;
      }
    }

    return toReturn;
  }
  
  Edge getEdge(Node vert1, Node vert2) {
    if (vert1 == null || vert2 == null){
      return null;
    }
    return edges.getEdge(vert1, vert2);
  }
}

/**
 * Implements the Aldous-Broder algorithm for maze generation.
 */
class Aldous_Broder implements IGenerator {
    int added;
    Square_HashMap visitedSquares;

    Aldous_Broder() {}
    
    void initialise(){
      this.added = 1;
      this.visitedSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
      
      currentSquare = maze.getRandomSquare();
      squaresToUpdate.add(currentSquare);
      visitedSquares.addSquare(currentSquare);
    }
    
    String getName(){
      return "1_aldous";
    }

    void generate() {
        if (generated) {
            return;
        }

        Square oldSquare = currentSquare;
        ArrayList < Integer > possibleDirections = new ArrayList(Arrays.asList(0, 1, 2, 3));

        do {
            int randInd = Math.round(random(-0.5, possibleDirections.size() - 0.5));
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
    
    int search_set = -1;
    
    Square_HashMap visitedSquares;
    Square_HashMap routeSquares;

    Backtracker(){}
    
    void initialise(){
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
    
    void initialise(Square square){
      this.routeStack = new ArrayList();
      this.backtracking = false;
      
      currentSquare = square;
      routeStack.add(currentSquare);

      visitedSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
      routeSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));

      visitedSquares.addSquare(currentSquare);
      routeSquares.addSquare(currentSquare);
      
      squaresToUpdate.add(currentSquare);
      
      search_set = square.getSet();
    }
    
    String getName(){
      return "2_backtracker";
    }

    void generate() {
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
            int last_dir = 0;
            
            do {
                if (currentSquare == null) {
                    currentSquare = oldSquare;
                }

                int direction = directions.get(Math.round(random(-0.5, directions.size() - 0.5)));

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

    Square popSquare() {
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

    boolean atDeadEnd() {
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

    boolean checkLeft(Square square) {
        return checkStack(maze.getSquareLeft(square));
    }

    boolean checkAbove(Square square) {
        return checkStack(maze.getSquareAbove(square));
    }

    boolean checkRight(Square square) {
        return checkStack(maze.getSquareRight(square));
    }

    boolean checkBelow(Square square) {
        return checkStack(maze.getSquareBelow(square));
    }

    boolean checkStack(Square square) {
        if (square != null){
          return visitedSquares.containsSquare(square) || square.in_word || square.getSet() != search_set;
        }
        return visitedSquares.containsSquare(square);
    }

    int getRandomDir() {
        return Math.round(random(-0.5, 3.5));
    }
}

/**
 * Implements the Binary-tree algorithm for maze generation.
 */
class Binary_Tree implements IGenerator {
    int xPos, yPos;
    
    Binary_Tree() {}
    
    String getName(){
      return "3_binary";
    }
    
    void initialise(){
        yPos = maze.getNumberOfRows();
        xPos = maze.getNumberOfColumns();
    }

    void generate() {
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

    void addAbove(Square thisSquare) {
        Path newPath = new Path(thisSquare, maze.getSquare(thisSquare.getXCo(), thisSquare.getYCo() - 1));
        maze.getPaths().addPath(newPath, true);
        squaresToUpdate.add(maze.getSquare(thisSquare.getXCo(), thisSquare.getYCo() - 1));
    }

    void addLeft(Square thisSquare) {
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
    ArrayList < Square > setSquares;
    ArrayList < Square > frontier;
    int set0;
    int set1;
    ArrayList < Path > potentialPaths;

    Blobby_Recursive() {}
    
    String getName(){
      return "4_blobby_recursive";
    }
    
    void initialise(){
        setNumbersToDivide = new ArrayList();
        setNumber = 0;
        nextSet = true;
      
        maze.clear();
        sets = new Set_Hash();
  
        for (Square square: maze.getSquares()) {
            sets.addToSet(0, square);
        }
  
        setNumbersToDivide.add(0);
        
        frontier = new ArrayList();
    }

    void generate() {
        if (generated) {
            return;
        }

        if (setNumbersToDivide.size() > 0 || !nextSet) {
            if (nextSet) {
                nextSet();
                nextSet = false;
            }
            
            ArrayList < Square > newFrontier;

            if (frontier.size() > 0) {
                newFrontier = new ArrayList();

                for (Square frontierSquare: frontier) {
                    if (random(1) > 0.4) {
                        for (Square square: maze.getSquareNeighbours(frontierSquare)) {
                            if ((frontierSquare.getSet() == set0 && square.getSet() == set1) ||
                                (frontierSquare.getSet() == set1 && square.getSet() == set0)) {
                                potentialPaths.add(new Path(square, frontierSquare));
                            } else if (square.getSet() == setNumberToDivide) {
                                newFrontier.add(square);
                                sets.addToSet(frontierSquare.getSet(), square);
                            }
                        }
                    } else {
                        newFrontier.add(frontierSquare);
                    }
                }

                frontier = newFrontier;
                return;
            }

            if (sets.getSet(set0).size() >= 4) {
                setNumbersToDivide.add(set0);
            } else {
                for (Square square: sets.getSet(set0)) {
                    square.setSet(-1);
                    squaresToUpdate.add(square);
                }
                sets.clearSet(set0);
            }

            if (sets.getSet(set1).size() >= 4) {
                setNumbersToDivide.add(set1);
            } else {
                for (Square square: sets.getSet(set1)) {
                    square.setSet(-1);
                    squaresToUpdate.add(square);
                }
                sets.clearSet(set1);
            }

            if (potentialPaths.size() > 0) {
                for (Path path: potentialPaths) {
                    path.addWallBetween();
                    squaresToUpdate.add(path.startSquare);
                }
                
                maze.paths.addPath(potentialPaths.remove(Math.round(random(0, potentialPaths.size() - 1))), false);
            }

            potentialPaths.clear();
            nextSet = true;
            
            sets.clearSet(setNumberToDivide);
            
            return;
        }

        maze.generatePaths();
        generated = true;
        maze.generationComplete();
    }

    void nextSet() {
        setNumberToDivide = setNumbersToDivide.remove(setNumbersToDivide.size() - 1);

        setSquares = sets.getSet(setNumberToDivide);

        getRandomSeeds(setNumberToDivide, frontier);

        set0 = setNumber += 1;
        set1 = setNumber += 1;

        sets.addToSet(set0, frontier.get(frontier.size()-1));
        sets.addToSet(set1, frontier.get(frontier.size()-2));

        potentialPaths = new ArrayList();
    }

    void getRandomSeeds(int setNumber, ArrayList<Square> frontier) {
        Square seed1 = sets.getSet(setNumber).get(Math.round(random(0, sets.getSet(setNumber).size()-1)));
        Square seed2 = sets.getSet(setNumber).get(Math.round(random(0, sets.getSet(setNumber).size()-1)));

        while (seed2 == seed1) {
            seed2 = sets.getSet(setNumber).get(Math.round(random(0, sets.getSet(setNumber).size()-1)));
        }

        frontier.add(seed1);
        frontier.add(seed2);
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
    
    String getName(){
      return "5_ellers";
    }
    
    void initialise(){
      this.row = 0;
      this.col = 0;
      this.currentStage = 1;
      this.lastRow = false;
      this.setsWithDownPaths = new ArrayList();
      
      this.ellersSets = new Set_Hash();
    }

    void generate() {
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

    void createSets(int row) {
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

    void randomUnion(int row) {
        if (col < maze.getNumberOfColumns()) {
            Square startSquare = maze.getSquare(col, row);
            Square endSquare = maze.getSquare(col + 1, row);
            if (random(1) < 0.5 && startSquare.getSet() != endSquare.getSet()) {
                ellersSets.mergeSets(startSquare.getSet(), endSquare.getSet());
                Path newPath = new Path(startSquare, endSquare);
                maze.getPaths().addPath(newPath, false);
                newPath.removeWallBetween(true);
            }
        }
    }

    void createDownPaths(int row) {
        if (col <= maze.getNumberOfColumns()) {
            Square topSquare = maze.getSquare(col, row);
            Square bottomSquare = maze.getSquare(col, row + 1);

            if (random(1) < 0.5) {
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

    void joinLastRow() {
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
    
    int leftMostCol = 0;
    int highestRow = 0;

    Hunt_Kill() {}
    
    String getName(){
      return "6_hunt_kill";
    }
    
    void initialise(){
        this.mode = true;
        this.remainingSquaresInMaze = new ArrayList();
        
        highestRow = Math.round(random(0, maze.getNumberOfRows()));
        leftMostCol = Math.round(random(0, maze.getNumberOfColumns()));
        
        currentSquare = maze.getSquare(leftMostCol, highestRow);
        currentSquare.setSet(1);

        visitedSquares = new Square_HashMap((int) Math.pow(maze.getNumberOfColumns(), 2));

        visitedSquares.addSquare(currentSquare);

        for (int i = 0; i <= maze.getNumberOfRows(); i++) {
            for (int j = 0; j <= maze.getNumberOfColumns(); j++) {
                remainingSquaresInMaze.add(maze.getSquare(j, i));
            }
        }
    }

    void generate() {
        if (generated) return;
        
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

    void hunt() {
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

    void kill() {
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

    Square nextToVisitedSquare(Square square) {
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

    int getDirectionOfValidSquare() {
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

    boolean checkLeft() {
        if (maze.getSquareLeft(currentSquare) == null) {
            return false;
        }

        return maze.getSquareLeft(currentSquare).getSet() == -1;
    }

    boolean checkRight() {
        if (maze.getSquareRight(currentSquare) == null) {
            return false;
        }

        return maze.getSquareRight(currentSquare).getSet() == -1;
    }

    boolean checkUp() {
        if (maze.getSquareAbove(currentSquare) == null) {
            return false;
        }

        return maze.getSquareAbove(currentSquare).getSet() == -1;
    }

    boolean checkDown() {
        if (maze.getSquareBelow(currentSquare) == null) {
            return false;
        }

        return maze.getSquareBelow(currentSquare).getSet() == -1;
    }

    boolean atDeadEnd(Square square) {
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

    boolean checkLeft(Square square) {
        return checkStack(maze.getSquareLeft(square));
    }

    boolean checkAbove(Square square) {
        return checkStack(maze.getSquareAbove(square));
    }

    boolean checkRight(Square square) {
        return checkStack(maze.getSquareRight(square));
    }

    boolean checkBelow(Square square) {
        return checkStack(maze.getSquareBelow(square));
    }

    boolean checkStack(Square square) {
        return visitedSquares.containsSquare(square);
    }

    int getRandomDir() {
        return Math.round(random(-0.5, 3.5));
    }
}

/**
 * Implements Kruskals algorithm for maze generation.
 */
class Kruskals implements IGenerator {
    int setNumber;
    ArrayList < Integer > remainingPaths;
    ArrayList < Integer > paths;
    ArrayList < ArrayList< Square > > sets;

    Kruskals() {}
    
    String getName(){
      return "7_kruskals";
    }
    
    void initialise(){
        this.setNumber = 0;
        this.remainingPaths = new ArrayList();

        sets = new ArrayList<ArrayList< Square >>();
        
        paths = new ArrayList<Integer>();
        
        for (int i = 0; i < maze.squares.size() * 2; i++){
            paths.add(i);
        }
    }

    void generate() {
        if (generated) {
            return;
        }

        boolean valid = false;

        Square startSquare = null, endSquare = null;

        while (valid == false) {
            int selectedPath = paths.remove(Math.round(random(0, paths.size()-1)));
            
            if (paths.size() == 0){
                generated = true;
                maze.generationComplete();
                return;
            }
            
            startSquare = maze.squares.get((int) Math.floor(selectedPath/2));
            
            switch (selectedPath % 2){
                case 0:
                    endSquare = maze.getSquareBelow(startSquare);
                    break;
                case 1:
                    endSquare = maze.getSquareRight(startSquare);
                    break;
            }
            
            if (endSquare == null){
                continue;
            }

            if ((startSquare.getSet() == endSquare.getSet()) 
                    && startSquare.getSet() != -1) {
                continue;
            } else {
                valid = true;
            }

            Path newPath = new Path(startSquare, endSquare);
            maze.getPaths().addPath(newPath, false);
            newPath.removeWallBetween(true);

            if (startSquare.getSet() != -1 && endSquare.getSet() != -1) {
                int startSetSize = sets.get(startSquare.getSet()).size();
                int endSetSize = sets.get(endSquare.getSet()).size();
                
                int startSquareInitSet = startSquare.getSet();
                int endSquareInitSet = endSquare.getSet();
                
                if (startSetSize > endSetSize){
                    while(sets.get(endSquareInitSet).size() > 0){
                        Square movingSquare = sets.get(endSquareInitSet).remove(sets.get(endSquareInitSet).size()-1);
                        
                        movingSquare.setSet(startSquare.getSet());
                        
                        sets.get(startSquare.getSet()).add(movingSquare);
                        
                        squaresToUpdate.add(movingSquare);
                    }
                } else if (startSetSize <= endSetSize){
                    while(sets.get(startSquareInitSet).size() > 0){
                        Square movingSquare = sets.get(startSquareInitSet).remove(sets.get(startSquareInitSet).size()-1);
                        
                        movingSquare.setSet(endSquare.getSet());
                        
                        sets.get(endSquare.getSet()).add(movingSquare);
                        
                        squaresToUpdate.add(movingSquare);
                    }
                }
            }

            if (startSquare.getSet() != -1 && endSquare.getSet() == -1) {
                endSquare.setSet(startSquare.getSet());
                sets.get(startSquare.getSet()).add(endSquare);
            }

            if (startSquare.getSet() == -1 && endSquare.getSet() != -1) {
                startSquare.setSet(endSquare.getSet());
                sets.get(endSquare.getSet()).add(startSquare);
            }

            if (startSquare.getSet() == -1 && endSquare.getSet() == -1) {
                sets.add(new ArrayList<Square>());
                
                startSquare.setSet(this.setNumber);
                endSquare.setSet(this.setNumber);
                
                sets.get(this.setNumber).add(startSquare);
                sets.get(this.setNumber).add(endSquare);
                
                this.setNumber++;
            }
            
            squaresToUpdate.add(startSquare);
            squaresToUpdate.add(endSquare);
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
    
    String getName(){
      return "8_prims";
    }
    
    void initialise(){
        this.mainSet = new ArrayList();
        this.possiblePaths = new ArrayList();
        
        mainSetSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
        getFirstSquare();
    }
    
    void initialise(Square first){
      this.mainSet = new ArrayList();
      this.possiblePaths = new ArrayList();
        
      mainSetSquares = new Square_HashMap((maze.getNumberOfRows() + 1) * (maze.getNumberOfColumns() + 1));
      
      primStartSquare = first;
      first.setSet(1);
      mainSet.add(first);
      mainSetSquares.addSquare(first);
      squaresToUpdate.add(first);
    }

    void generate() {
        if (generated) {
            return;
        }

        getPossibleWalls();
        
        if (mainSet.size() == maze.getSquares().size()){
          maze.generationComplete();
          mainSet.clear();
          generated = true;
          return;
        }
        
        try{
          int randIndex = Math.round(random(0, possiblePaths.size() - 1));
      
          Path foundPath = possiblePaths.get(randIndex);
          foundPath.getEndSquare().setSet(1);
          
          mainSet.add(foundPath.getEndSquare());
          mainSetSquares.addSquare(foundPath.getEndSquare());
          squaresToUpdate.add(foundPath.getEndSquare());
          
          maze.getPaths().addPath(foundPath, false);
          foundPath.removeWallBetween(true);
          possiblePaths.remove(randIndex);
        } catch (Exception IndexOutOfBoundsException){
          mainSet.clear();
          generated = true;
        }
    }

    void getFirstSquare() {
        Square first = null;
        do {
          first = maze.getRandomSquare();
        } while (first.getSet() != -1);
        
        primStartSquare = first;
        first.setSet(1);
        mainSet.add(first);
        mainSetSquares.addSquare(first);
        squaresToUpdate.add(first);
    }

    void getPossibleWalls() {
        try {
            getPossiblePaths(mainSet.get(mainSet.size() - 1));
        } catch (Exception ArrayIndexOutOfBoundsException) {
            mainSet.clear();
            generated = true;
            maze.generationComplete();
        }
    }

    void getPossiblePaths(Square square) {
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

    Path primCheckAbove(Square square) {
        Square aboveSquare = maze.getSquareAbove(square);
        if (aboveSquare != null && aboveSquare.getSet() == -1 && !square.in_word && !aboveSquare.in_word) {
            return new Path(square, aboveSquare);
        }
        return null;
    }

    Path primCheckBelow(Square square) {
        Square belowSquare = maze.getSquareBelow(square);
        if (belowSquare != null && belowSquare.getSet() == -1 && !square.in_word && !belowSquare.in_word) {
            return new Path(square, belowSquare);
        }
        return null;
    }

    Path primCheckLeft(Square square) {
        Square leftSquare = maze.getSquareLeft(square);
        if (leftSquare != null && leftSquare.getSet() == -1 && !square.in_word && !leftSquare.in_word) {
            return new Path(square, leftSquare);
        }
        return null;
    }

    Path primCheckRight(Square square) {
        Square rightSquare = maze.getSquareRight(square);
        if (rightSquare != null && rightSquare.getSet() == -1 && !square.in_word && !rightSquare.in_word) {
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
    
    String getName(){
      return "9_recursive_divide";
    }
    
    void initialise(){
        this.fieldStack = new ArrayList();
        this.pathsGenerated = false;
      
        maze.clear();
        fieldStack.add(new ArrayList(Arrays.asList(0, 0, maze.getNumberOfColumns(), maze.getNumberOfRows())));
    }

    void generate() {
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

    void addToStack(int startX, int startY, int endX, int endY) {
        ArrayList < Integer > toAdd = new ArrayList(Arrays.asList(startX, startY, endX, endY));
        fieldStack.add(toAdd);
    }

    void deleteFromStack(int startX, int startY, int endX, int endY) {
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
    void addHorizontalWall(int startX, int endX, int y) {
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
    void addVerticalWall(int startY, int endY, int x) {
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
    
    String getName(){
      return "10_sidewinder";
    }
    
    void initialise(){
        this.sideY = 1;
        this.sideX = 0;
        this.setNumber = 0;
        this.setsAddedToRow = new ArrayList();
      
        rowRunSets = new Set_Hash();
        clearTopRow();
    }

    void generate() {
        if (generated) {
            return;
        }

        if (sideX <= maze.getNumberOfColumns()) {
            Square currentSquare = maze.getSquare(sideX, sideY);
            
            rowRunSets.addToSet(setNumber, currentSquare);
            
            squaresToUpdate.add(currentSquare);
            
            if (sideX != maze.getNumberOfColumns()) {
                if (random(1) < 0.5) {
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
                int rand = Math.round(random(0, rowRunSets.getSet(setNumber).size() - 1));

                Square selectedSquare = rowRunSets.getSet(setNumber).get(rand);

                maze.getPaths().addPath(new Path(selectedSquare, maze.getSquare(selectedSquare.getXCo(), selectedSquare.getYCo() - 1)), true);

                for (Square square: rowRunSets.getSet(setNumber)) {
                    squaresToUpdate.add(square);
                }
            }
            setsAddedToRow.clear();
            sideY++;
        } else {
            for (Integer setNumber: setsAddedToRow) {
                int rand = Math.round(random(0, rowRunSets.getSet(setNumber).size() - 1));

                Square selectedSquare = rowRunSets.getSet(setNumber).get(rand);

                maze.getPaths().addPath(new Path(selectedSquare, maze.getSquare(selectedSquare.getXCo(), selectedSquare.getYCo() - 1)), true);
            }

            currentSquare = null;
            generated = true;
            maze.generationComplete();
        }
    }

    void clearTopRow() {
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
    
    String getName(){
      return "11_wilsons";
    }
    
    void initialise(){
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

    void generate() {
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

    Square getRandomPoint() {
        Square randomSquare;

        do {
            randomSquare = maze.getSquare(Math.round(random(0, maze.getNumberOfColumns())), Math.round(random(0, maze.getNumberOfRows())));
        } while (visitedSquares.containsSquare(randomSquare));

        return randomSquare;
    }

    void randomWalk() {
        Square nextSquare = null;
        ArrayList < Integer > possible = new ArrayList(Arrays.asList(0, 1, 2, 3));

        do {
            int randInd = Math.round(random(-0.5, possible.size() - 0.5));
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

    void eraseLoopInCurrentWalk(Square square) {
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

    void addCurrentWalkToLoop() {
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
  boolean endStage;
  
  String getName(){
     return "12_houston";
  }
  
  void initialise(){
      this.aldousSolver = new Aldous_Broder();
      this.wilsonsSolver = new Wilsons();
      
      this.stage = 1;
      this.endStage = false;
      
      aldousSolver.initialise();
  }
  
  Houston(){}
  
  void generate(){
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
      this.endStage = true;
    } else {
      wilsonsSolver.generate(); 
    }
  }
}
