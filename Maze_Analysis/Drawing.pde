void drawConnectingLines(){
  if (lines.getState()){
    strokeWeight(lineThickness);
    colorMode(HSB);
    if (!all.getState()){
      for (Integer selected : pointsToDraw){
         stroke(map(selected, 0, 10, 0, 255), 255, 255);
         for (int i = 0; i < mazeAmount-1; i++){
           if (pointsToDisplay.get(selected).get(i+1) <= max && pointsToDisplay.get(selected).get(i) >= min){
             line(map(i, -0.25, mazeAmount, 100, width - 100), map(pointsToDisplay.get(selected).get(i), min, max, height-footerHeight, headerHeight), map(i+1, -0.25, mazeAmount, 100, width - 100), map(pointsToDisplay.get(selected).get(i+1), min, max, height-footerHeight, headerHeight));
           }
         }
      }
    } else {
      for (int j = 0; j < names.length; j++){
         stroke(map(j, 0, 10, 0, 255), 255, 255);
         for (int i = 0; i < mazeAmount-1; i++){
           if (pointsToDisplay.get(j).get(i+1) <= max && pointsToDisplay.get(j).get(i) >= min){
             line(map(i, -0.25, mazeAmount, 100, width - 100), map(pointsToDisplay.get(j).get(i), min, max, height-footerHeight, headerHeight), map(i+1, -0.25, mazeAmount, 100, width - 100), map(pointsToDisplay.get(j).get(i+1), min, max, height-footerHeight, headerHeight));
           }
         }
      }
    }
    colorMode(RGB);
  }
}

void drawScale(){
  textAlign(RIGHT, CENTER);
  for (int i = min; i < max; i+=(max-min)/10){
    fill(0);
    text(i, 75, map(i, max, min, headerHeight, height - footerHeight));
    stroke(200);
    strokeWeight(1);
    line(101, map(i, max, min, headerHeight, height - footerHeight), width-102, map(i, max, min, headerHeight, height - footerHeight));
  }
}

void drawBottomLabels(){
  textAlign(CENTER);
  textSize(14);
  for (int i = 0; i < mazeAmount; i++){
    text((int) (2*(Math.pow(2, (i + 2))) + 1) + " x " + (int) (2*(Math.pow(2, (i + 2))) + 1), map(i, -0.25, mazeAmount, 100, width-100), height-85);
    stroke(0);
    line(map(i, -0.25, mazeAmount, 100, width-100), height-115, map(i, -0.25, mazeAmount, 100, width-100), height-100);
  }
  
  
}
