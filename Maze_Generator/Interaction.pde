// A droplist that has various values that can be selected 
class DropList {
    int x, y, w, h;
    ArrayList < String > labels;
    Button dropList;
    int currentlySelected;
    String title;
    Boolean dropped = false;

    DropList(int x, int y, int buttonWidth, int buttonHeight, String defaultLabel, ArrayList < String > labels) {
        this.x = x;
        this.y = y;
        this.w = buttonWidth;
        this.h = buttonHeight;
        this.labels = labels;
        this.title = defaultLabel;

        dropList = new Button(">", x + w - 20, y, 20, h);
    }

    // Draws the droplist on the sketch
    void Draw() {
        noStroke();
        fill(255);
        rect(x, y, w, h);
        fill(0);
        text(title, x + ((w - 20) / 2), y + ((h) / 2));

        if (dropped) {
            dropList.drawSelected();
        } else {
            dropList.Draw();
        }

        if (dropped) {
            int currY = y + h;
            int col = 250;
            for (int i = 0; i < labels.size(); i++) {
                fill(col);
                rect(x, currY, w - 20, h);
                fill(0);
                text(labels.get(i), x + ((w - 20) / 2), currY + ((h) / 2));
                currY += h;
                col -= (100) / labels.size();
            }
        }
    }

    // Checks if the button to drop the list has been pressed, and if an element of the list has been selected
    int checkForPress() {
        if (dropList.MouseIsOver()) {
            if (dropped == true) {
                unShowDropList();
            }
            dropped = !dropped;
        }

        int toReturn = -1;
        if (dropped && mouseX > x && mouseX < x + w && mouseY > y + h && mouseY < y + (h * (labels.size() + 1))) {
            toReturn = (mouseY - y) / h;
            title = labels.get(toReturn - 1);
            unShowDropList();
        }
        return toReturn;
    }

    // 'Undrops' the droplist
    void unShowDropList() {
        stroke(256);
        fill(225);
        rect(x, y + h, w + 1, 1 + (h * labels.size()));
    }
}

// A button that can be pressed by the user to perform an action
class Button {
    String label;
    float x, y, w, h;

    boolean pressed = false; // indicates if the button has been pressed
    float animationI = 0; // Where the button is in the pressed animation

    // Button constructor
    Button(String label, float x, float y, float w, float h) {
        this.label = label;
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    // Draw the button with default label
    void Draw() {
        noStroke();
        if (pressed) {
            pressed = false;
        }

        if (animationI > 0) {
            fill(lerpColor(color(200), color(255), (25 - animationI) / 25));
            animationI--;
        } else {
            fill(255);
        }

        textSize(13);
        rect(x, y, w, h);
        fill(0);
        text(label, x + (w / 2), y + (h / 2));
    }

    // Draw the button with the passed PImage
    void Draw(PImage image) {
        noStroke();
        fill(225);
        rect(x, y, w, h);
        image(image, x, y, w, h);
        fill(0);
    }

    // Draws the button with a darker fill to signify that it has been selected.
    void drawSelected() {
        if (pressed == true) {
            if (animationI < 8) {
                fill(lerpColor(color(255), color(200), animationI / 8));
                animationI++;
            } else {
                fill(200);
            }
        }

        textSize(13);
        rect(x, y, w, h);
        fill(0);
        text(label, x + (w / 2), y + (h / 2));
    }

    // Returns a boolean indicating if the mouse was above the button when the mouse was pressed
    boolean MouseIsOver() {
        if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) {
            pressed = true;
            return true;
        }
        return false;
    }
}

// A slider that the user can use to interact with the visualisation
class Slider {
    int startX, startY, sliderWidth, sliderHeight;
    float minVal, maxVal;
    int labelSize;
    float sliderX;
    int currentVal;
    String label;
    boolean sliderPressed = false;
    boolean floatOrInt = false;

    // Constructor
    Slider(int startX, int startY, int sliderWidth, int sliderHeight, float minVal, float maxVal) {
        this.startX = startX;
        this.startY = startY;
        this.sliderWidth = sliderWidth;
        this.sliderHeight = sliderHeight;
        this.minVal = minVal;
        this.maxVal = maxVal;

        this.currentVal = (int)(minVal + maxVal) / 2;

        sliderX = startX + sliderWidth / 2;
    }
    
    void setValue(int value){
        this.currentVal = value;
        this.sliderX = map(value, minVal, maxVal, startX, startX + sliderWidth);
    }

    // Returns the value of the slider
    float getValue() {
        return currentVal;
    }

    // Draws the slider on the sketch
    void display() {
        noStroke();
        if (sliderPressed) {
            press();
        }

        fill(255);
        rect(startX - sliderHeight / 2, startY, sliderWidth + sliderHeight, sliderHeight);

        fill(100);
        rect(sliderX - sliderHeight / 2, startY, sliderHeight, sliderHeight);
    }

    // Checks if the slider has been clicked
    void press() {
        if (mouseX > startX && mouseX < startX + sliderWidth) {
            if (mouseY > startY && mouseY < startY + sliderHeight || sliderPressed) {
                sliderPressed = true;
            }
        }

        if (sliderPressed) {
            if (mouseX <= startX + sliderWidth && mouseX >= startX) {
                sliderX = mouseX;
                currentVal = Math.round(map(mouseX, startX, startX + sliderWidth, minVal, maxVal));
                return;
            } else if (mouseX > startX + sliderWidth) {
                sliderX = startX + sliderWidth;
                currentVal = Math.round(maxVal);
                return;
            } else if (mouseX < startX) {
                sliderX = startX;
                currentVal = Math.round(minVal);
                return;
            }
        }
    }

    // Releases the slider so the value change stops
    void release() {
        sliderPressed = false;
    }

    // Updates the position of the slider
    void update() {
        sliderPressed = true;
        sliderX = mouseX;
        currentVal = (int) map(mouseX, sliderX, sliderX + sliderWidth, minVal, maxVal);
    }
}

class TickBox{
    boolean activated = false;
    int x, y;
    String label;
    int size;
    
    TickBox(int x, int y, int size, String label){
        this.x = x;
        this.y = y;
        this.label = label;
        this.size = size;
    }
    
    void Draw(){
        strokeWeight(0);
        colorMode(RGB);
        
        fill(255, 175);
        rect(x - size, y - size/3, 3*size, 2.25*size, size/2);
        
        if (activated){
            fill(0, 255, 0);
        } else {
            fill(255, 0 ,0);
        }
        rect(x, y, size, size, size/4);
        fill(0);
        textSize(10);
        text(label, x + size/2, y+1.5*size);
    }
    
    void checkForPress(){
        if (mouseX > x && mouseX < x + size){
            if (mouseY > y && mouseY < y + size){
                activated = !activated;
            }
        }
    }
    
    boolean getState(){
        return activated;
    }
}
