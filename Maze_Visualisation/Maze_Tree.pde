class Maze_Tree{
    Maze_Tree_Node root;
    
    Maze_Tree(){
        this.root = null;
    }
    
    void build(Square startingPoint){
        Tree_Builder builder = new Tree_Builder(this, startingPoint);
        
        builder.depthFirstBuild();
    }
}

class Tree_Builder{
    Maze_Tree tree;
    Square startingSquare;
    Square currentSquare;
    
    ArrayList<Maze_Tree_Node> nodeStack;
    
    Tree_Builder(Maze_Tree tree, Square startingSquare){
        this.tree = tree;
        this.startingSquare = startingSquare;
        this.currentSquare = startingSquare;
        this.nodeStack = new ArrayList();
    }
    
    void depthFirstBuild(){
        tree.root = new Maze_Tree_Node(null, currentSquare, 0);
        
        Square lastSquare = currentSquare;
        
        for (int direction : currentSquare.getPossibleDirections()){
          moveInDirection(direction);
          findNextJunction(currentSquare, tree.root, lastSquare);
        }
    }
    
    void findNextJunction(Square startingPosition, Maze_Tree_Node lastNode, Square previous){
      currentSquare = startingPosition;
      for (int direction : startingPosition.getPossibleDirections()){
        Square lastSquare = previous;
        
        moveInDirection(direction);
        
        if (currentSquare.xCo == lastSquare.xCo && currentSquare.yCo == lastSquare.yCo){
          continue;
        }
        
        while(currentSquare.getPossibleDirections().size() == 2){
          for (int dir : currentSquare.getPossibleDirections()){
            if (getSquareInDirection(dir).xCo == lastSquare.xCo && getSquareInDirection(dir).yCo == lastSquare.yCo){
              continue;
            } else {
              lastSquare = currentSquare;
              moveInDirection(dir);
              break;
            }
          }
        }
        
        Maze_Tree_Node newNode = new Maze_Tree_Node(lastNode, currentSquare, lastNode.depth+1);
        lastNode.addChild(newNode);
        println("adding node: " + currentSquare.xCo + " " + currentSquare.yCo);
        
        if (currentSquare.getPossibleDirections().size() == 1){
          println("returning");
          return;
        }
        
        findNextJunction(currentSquare, newNode, lastSquare);
      }
    }
    
    Square getSquareInDirection(int direction){
      if (direction == 0){
        return maze.getSquareAbove(currentSquare);
      } else if (direction == 1){
        return maze.getSquareRight(currentSquare);
      } else if (direction == 2){
        return maze.getSquareBelow(currentSquare);
      } else if (direction == 3){
        return maze.getSquareLeft(currentSquare);
      }
      
      return null;
    }
    
    void moveInDirection(int direction){
      
      if (direction == 0){
        currentSquare = maze.getSquareAbove(currentSquare);
      } else if (direction == 1){
        currentSquare = maze.getSquareRight(currentSquare);
      } else if (direction == 2){
        currentSquare = maze.getSquareBelow(currentSquare);
      } else if (direction == 3){
        currentSquare = maze.getSquareLeft(currentSquare);
      }
      println("Moving in  direction " + direction + " [" + currentSquare.xCo + " " + currentSquare.yCo + "]");
    }
}

class Maze_Tree_Node{
    Maze_Tree_Node parent;
    ArrayList<Maze_Tree_Node> children;
    Square position;
    int depth;
    
    Maze_Tree_Node(Maze_Tree_Node parent, Square position, int depth){
        this.parent = parent;
        this.depth = depth;
        this.position = position;
        children = new ArrayList();
    }
    
    void addChild(Maze_Tree_Node child){
        children.add(child);
    }
    
    Maze_Tree_Node getParent(){
        return parent;
    }
    
    ArrayList<Maze_Tree_Node> getChildren(){
        return children;
    }
}
