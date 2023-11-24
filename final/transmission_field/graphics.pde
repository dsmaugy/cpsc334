abstract class UIElement {

    int x, y, z;
    int boundingWidth = -1;
    int boundingHeight = -1;
    boolean isClickable = false;

    boolean hoverJustEntered = false;
    boolean hoverIn = false;

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
        if (hoverJustEntered) {
            hoverJustEntered = false;
        } 
        hoverIn = true;
    }

    public void onClick() {

    }

    public void drawElement() {

    }

    public void onEnter() {
        hoverIn = true;
    }

    public void onLeave() {
        hoverJustEntered = true;
        hoverIn = false;
    }

    public boolean pointInsideElement(int x, int y) {
        return (boundingWidth > 0 && boundingHeight > 0 
        && x >= this.x && x <= this.x+boundingWidth
        && y >= this.y && y <= this.y+boundingHeight);
    }
}

interface CallableAction<T> {
    void doAction(T element);
}


class Box extends UIElement {
    int width, height;
    color boxColor;
    color boxStroke = -1;
    color hoveredBoxColor;
    color unhoveredBoxColor;

    public Box(int x, int y, int z, int width, int height, color boxColor) {
        super(x, y, z, width, height);
        this.width = width;
        this.height = height;
        this.boxColor = boxColor;
        this.unhoveredBoxColor = boxColor;
    }

    public void drawElement() {
        fill(boxColor);

        if (boxStroke == -1) {
            noStroke();
        } else {
            stroke(boxStroke);
        }
        rect(x, y, width, height);
    }
}

class CloseButton extends Box {

    CallableAction<CloseButton> action;

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
        super.onClick();
        action.doAction(this);
    }
}

class MessageBox extends Box {
    color textColor;
    String text;
    int topMargin = 5;
    int leftMargin = 5;
    int xAlign = CENTER;
    int yAlign = BASELINE;

    CallableAction<MessageBox> hoverAction = null;
    CallableAction<MessageBox> clickAction = null;
    CallableAction<MessageBox> leaveAction = null;

    public MessageBox(int x, int y, int z, int width, int height, color boxColor, color textColor, String text) {
        super(x, y, z, width, height, boxColor);
        this.textColor = textColor;
        this.text = text;
    }

    public void drawElement() {
        super.drawElement();
        fill(textColor);
        textAlign(xAlign, yAlign);
        text(text, x+leftMargin, y+topMargin, this.width-leftMargin, this.height-topMargin);
    }

    public void onClick() {
        super.onClick();
        if (clickAction != null) {
            clickAction.doAction(this);
        }
    }

    public void onHover() {
        super.onHover();
        if (hoverAction != null) {
            hoverAction.doAction(this);
        }
    }

    public void onLeave() {
        super.onLeave();
        if (leaveAction != null) {
            leaveAction.doAction(this);
        }
    }
}