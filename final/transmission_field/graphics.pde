
class Star {
    public int x;
    public int y;
    public int height;
    public int width;

    public Star(int x, int y, int height, int width) {
        this.x = x;
        this.y = y;
        this.height = height;
        this.width = width;
    }
}

abstract class UIElement {

    int x, y, z;
    int boundingWidth = -1;
    int boundingHeight = -1;
    boolean isClickable = false;

    UIElement(int x, int y, int z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    UIElement(int x, int y, int z, int boundingWidth, int boundingHeight) {
        this(x, y, z);
        this.boundingWidth = boundingWidth;
        this.boundingHeight = boundingHeight;
    }

    public void onHover() {

    }

    public void onClick() {

    }

    public void drawElement() {

    }

    public boolean pointInsideElement(int x, int y) {
        return (boundingWidth > 0 && boundingHeight > 0 
        && x >= this.x && x <= this.x+boundingWidth
        && y >= this.y && y <= this.y+boundingHeight);
    }
}

interface CallableAction {
    void doAction();
}

class Box extends UIElement {
    int width, height;
    color boxColor;

    public Box(int x, int y, int z, int width, int height, color boxColor) {
        super(x, y, z, width, height);
        this.width = width;
        this.height = height;
        this.boxColor = boxColor;
    }

    public void drawElement() {
        fill(boxColor);
        noStroke();
        rect(x, y, width, height);
    }
}

class CloseButton extends Box {

    CallableAction action;

    public CloseButton(int x, int y, int z, int width, int height, CallableAction action) {
        super(x, y, z, width, height, color(240, 65, 82));
        isClickable = true;

        this.action = action;
    }

    public void drawElement() {
        super.drawElement();
        stroke(255, 255, 255);
        strokeWeight(6);
        line(x+5, y+5, x-5 + this.width, y-5 + this.height);
        line(x+5, y-5 + this.height, x-5 + this.width, y+5);
    }

    public void onClick() {
        action.doAction();
    }
}

class MessageBox extends Box {
    color textColor;
    String text;
    int topMargin = 5;
    int leftMargin = 5;
    int xAlign = CENTER;

    public MessageBox(int x, int y, int z, int width, int height, color boxColor, color textColor, String text) {
        super(x, y, z, width, height, boxColor);
        this.textColor = textColor;
        this.text = text;
    }

    public void drawElement() {
        super.drawElement();
        fill(textColor);
        textAlign(xAlign);
        text(text, x+leftMargin, y+topMargin, width-leftMargin, height-topMargin);
    }
}