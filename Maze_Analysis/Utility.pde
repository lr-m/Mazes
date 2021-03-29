void loadData(){
  data = loadStrings("sorted-analysis.txt");
  
  for (int i = 0; i < data.length/6; i++){
    for (int j = 0; j < 6; j++){
      String line = data[(i*6) + j];
      String[] splitLine = line.split(" ");
      
      int left = Integer.parseInt(splitLine[3]);
      int right = Integer.parseInt(splitLine[4]);
      int solution = Integer.parseInt(splitLine[5]);
      int dead = Integer.parseInt(splitLine[6]);
      
      if (left > maxLeft){
        maxLeft = left;
      }
      
      if (right > maxRight){
        maxRight = right;
      }
      
      if (solution > maxSolution){
        maxSolution = solution;
      }
      
      if (dead > maxDeadEnds){
        maxDeadEnds = dead;
      }
      
      leftIterations.get(i).add(left);
      rightIterations.get(i).add(right);
      solutionLength.get(i).add(solution);
      deadEnds.get(i).add(dead);
      
      leftIterationsLabels.get(j).add(new Label(j, i, left));
      rightIterationsLabels.get(j).add(new Label(j, i, right));
      solutionLengthLabels.get(j).add(new Label(j, i, solution));
      deadEndsLabels.get(j).add(new Label(j, i, dead));
    }
  }
}

void sortLabels(){
  for (ArrayList<Label> labels : leftIterationsLabels){
    int n = labels.size(); 
    for (int i = 0; i < n-1; i++) 
        for (int j = 0; j < n-i-1; j++) 
            if (labels.get(j).value < labels.get(j+1).value) 
            { 
                // swap arr[j+1] and arr[j] 
                Label temp = labels.get(j); 
                labels.set(j, labels.get(j+1)); 
                labels.set(j+1, temp); 
            } 
            
    for (int i = 0; i < n; i++) 
        labels.get(i).setPos(i);
  }
  
  for (ArrayList<Label> labels : rightIterationsLabels){
    int n = labels.size(); 
    for (int i = 0; i < n-1; i++) 
        for (int j = 0; j < n-i-1; j++) 
            if (labels.get(j).value < labels.get(j+1).value) 
            { 
                // swap arr[j+1] and arr[j] 
                Label temp = labels.get(j); 
                labels.set(j, labels.get(j+1)); 
                labels.set(j+1, temp); 
            } 
            
     for (int i = 0; i < n; i++) 
        labels.get(i).setPos(i);
  }
  
  for (ArrayList<Label> labels : solutionLengthLabels){
    int n = labels.size(); 
    for (int i = 0; i < n-1; i++) 
        for (int j = 0; j < n-i-1; j++) 
            if (labels.get(j).value < labels.get(j+1).value) 
            { 
                // swap arr[j+1] and arr[j] 
                Label temp = labels.get(j); 
                labels.set(j, labels.get(j+1)); 
                labels.set(j+1, temp); 
            } 
            
     for (int i = 0; i < n; i++) 
        labels.get(i).setPos(i);
  }
  
  for (ArrayList<Label> labels : deadEndsLabels){
    int n = labels.size(); 
    for (int i = 0; i < n-1; i++) {
        for (int j = 0; j < n-i-1; j++){
            if (labels.get(j).value < labels.get(j+1).value) 
            { 
                // swap arr[j+1] and arr[j] 
                Label temp = labels.get(j); 
                labels.set(j, labels.get(j+1)); 
                labels.set(j+1, temp); 
            } 
        }
    }
    
    for (int i = 0; i < n; i++) 
        labels.get(i).setPos(i);
  }
}

void getStates(){
  pointsToDraw = new ArrayList();
  
  if (aldous.getState()){
    pointsToDraw.add(0);
  }
  
  if (backtracker.getState()){
    pointsToDraw.add(1);
  }
  
  if (binary.getState()){
    pointsToDraw.add(2);
  }
  
  if (blobby.getState()){
    pointsToDraw.add(3);
  }
  
  if (ellers.getState()){
    pointsToDraw.add(4);
  }
  
  if (huntkill.getState()){
    pointsToDraw.add(5);
  }
  
  if (kruskals.getState()){
    pointsToDraw.add(6);
  }
  
  if (prims.getState()){
    pointsToDraw.add(7);
  }
  
  if (recursive.getState()){
    pointsToDraw.add(8);
  }
  
  if (sidewinder.getState()){
    pointsToDraw.add(9);
  }
  
  if (wilsons.getState()){
    pointsToDraw.add(10);
  }
}
