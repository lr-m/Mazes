class Label{
  int mazeSizeIndex, nameIndex;
  int value;
  int pos;
  int x, y;
  int w, h;
  
  int lastY = (int) (height/2);
  float currentY = height/2;
  int animateI = 0;
  
  Label(int mazeSizeIndex, int nameIndex, int value){
    this.mazeSizeIndex = mazeSizeIndex;
    this.nameIndex = nameIndex;
    this.value = value;
    this.h = 35;
    this.w = 110;
  }
  
  void setPos(int pos){
    this.pos = pos;
  }
  
  void setY(int yDest){
    lastY = this.y;
    currentY = lastY;
    animateI = 0;
    this.y = yDest;
  }
  
  void Draw(){
    if (mazeSizeIndex >= mazeAmount){
      return;
    }
    
    if (animateI < 8){
      float difference = y-lastY;
      
      currentY += (int) (difference/8);
      animateI++;
    }
    
    if ((pointsToDraw.contains(nameIndex) || allSelected) && value <= max && value >= min){
      if (labels.getState()){
        fill(225, 225);
        strokeWeight(2);
        stroke(map(nameIndex, 0, 10, 0, 255), 255, 255);
        rect(map(mazeSizeIndex, -0.25, mazeAmount, 150, width-50), (-h/2) + currentY, w, h, 25);
        textSize(10);
        fill(0);
        text((pos+1) + ". " + names[nameIndex] + ":\n " + value, map(mazeSizeIndex, -0.25, mazeAmount, 150, width-50) + 55, currentY);
        strokeWeight(1);
        stroke(0);
        line(map(mazeSizeIndex, -0.25, mazeAmount, 100, width - 100), map(value, min, max, height-footerHeight, headerHeight), map(mazeSizeIndex, -0.25, mazeAmount, 150, width-50), currentY);
      }
      
      strokeWeight(pointSize);
      stroke(map(nameIndex, 0, 10, 0, 255), 255, 255);
      point(map(mazeSizeIndex, -0.25, mazeAmount, 100, width - 100), map(value, min, max, height-footerHeight, headerHeight));
    }
  }
  
  boolean isClashing(Label label){
    if (label.y == y){
      if (label.x < x + h || x < label.x + label.h){
        return true;
      }
    }
    return false;
  }
}
