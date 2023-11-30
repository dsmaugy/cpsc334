
abstract class UIElement implements Comparable<UIElement> {

    int x, y, z;
    int size;
    int boundingWidth = -1;
    int boundingHeight = -1;
    boolean isClickable = false;

    boolean hoverJustEntered = false;
    boolean hoverIn = false;

    private UIElement(int x, int y, int z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    UIElement(int x, int y, int z, int boundingWidth, int boundingHeight) {
        this(x, y, z);
        this.boundingWidth = boundingWidth;
        this.boundingHeight = boundingHeight;
        size = boundingHeight * boundingWidth;
    }

    public void onHover() {
        if (hoverJustEntered) {
            hoverJustEntered = false;
        } 
        hoverIn = true;
    }

    public void onClick() {

    }

    abstract public void drawElement();

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

    public int compareTo(UIElement e2) {
        return this.z == e2.z ? e2.size - this.size : this.z - e2.z;
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

    int rectAlign = CORNER;

    public Box(int x, int y, int z, int width, int height, color boxColor) {
        super(x, y, z, width, height);
        this.width = width;
        this.height = height;
        this.boxColor = boxColor;
        this.unhoveredBoxColor = boxColor;
    }

    public void drawElement() {
        fill(boxColor);
        rectMode(rectAlign);
        if (boxStroke == -1) {
            noStroke();
        } else {
            stroke(boxStroke);
            strokeWeight(4);
        }
        rect(x, y, width, height);
    }
}

class CloseButton extends Box {

    CallableAction<CloseButton> clickAction = null;

    public CloseButton(int x, int y, int z, int width, int height) {
        super(x, y, z, width, height, color(240, 65, 82));
        isClickable = true;
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
        if (clickAction != null) {
            clickAction.doAction(this);
        }
    }
}

class MessageBox extends Box {
    color textColor;
    String text;
    PFont textFont = startFont;

    int topMargin = 5;
    int leftMargin = 5;
    int xAlign = CENTER;
    int yAlign = BASELINE;
    int fontSize = 28;

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
        textFont(textFont, fontSize);
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

class Transmission extends UIElement {
    /*
        Represents a transmission object in the starfield. Minimum radius should be like 35.
    */

    // drawing variables
    int fieldX, fieldY, r; 
    int maxNumRings;
    int currentRingGlow;

    private int tooltipWidth = 145;
    private int tooltipHeight = 40;
    private color tooltipColor = color(0, 255, 0);
    private color tooltipTextColor = color(0, 0, 0);
    private color colorOne = color(220, 202, 237);
    private color colorTwo = color(220, 248, 237);

    private int lastRingTransition = 0;
    private final int RING_GLOW_DELAY = 400;

    private String name;

    // takes in field coords instead of sketch coords
    public Transmission(String name, int fieldX, int fieldY, int r) {
        super(0, 0, totalNumTransmissions * -1, r*2, r*2); // placeholder x, y coords
        totalNumTransmissions++;
        this.fieldX = fieldX;
        this.fieldY = fieldY;
        this.r = r;
        this.name = name;
        isClickable = true;

        // radius divided by the radius difference for each ring
        maxNumRings = r / 10;
        currentRingGlow = int(random(0, maxNumRings+1));
    }

    public boolean transmissionVisible() {
        return (fieldX + r > currentCenterX - (width/2) && fieldX - r < currentCenterX + (width/2) 
        && fieldY + r > currentCenterY - (height/2) && fieldY - r < currentCenterY + (height/2));
    }

    @Override
    public boolean pointInsideElement(int x, int y) {
        return (x >= this.x-r && x <= this.x+r
        && y >= this.y-r && y <= this.y+r);
    }

    @Override
    public void drawElement() {
        // we want center coordinates
        x = ((fieldX - currentCenterX) + width/2);
        y = ((fieldY - currentCenterY) + height/2);
    
        ellipseMode(RADIUS);
        noFill();
        strokeWeight(hoverIn ? 4 : 3);

        int currentR = r;
        int ringNumber = 0;

        if (millis() - lastRingTransition > RING_GLOW_DELAY) {
            lastRingTransition = millis();
            currentRingGlow = (currentRingGlow + 1) % maxNumRings;
        }

        while (currentR > 5) {
            if (currentRingGlow == ringNumber) {
                stroke(colorTwo);
            } else {
                stroke(colorOne);
            }

            circle(x, y, currentR);
            currentR -= 10;
            ringNumber += 1;
        }
        
        // draw title card over transmission
        if (hoverIn) {
            rectMode(CENTER);
            
            int yFlipper = y - r - tooltipHeight < 0 ? -1 : 1;
            
            MessageBox tooltip = new MessageBox(x, y - ((r + tooltipHeight + 5) * yFlipper), 
                0, tooltipWidth, tooltipHeight, 
                tooltipColor, tooltipTextColor, "Transmission\n" + name);
            tooltip.fontSize = 12;
            tooltip.rectAlign = CENTER;
            tooltip.topMargin = 0;
            tooltip.leftMargin = 0;
            tooltip.yAlign = CENTER;
            tooltip.drawElement();
        }           
    }

    @Override
    public String toString() {
        return name + ": (" + fieldX + "," + fieldY + ")";
    }

    // need to override this to make sure we draw smaller transmissions on top 
    // break ties with transmission name
    @Override
    public int compareTo(UIElement e2) {
        if (e2 instanceof Transmission) {
            Transmission transObj = (Transmission) e2;
            return transObj.r == this.r ? this.name.compareTo(transObj.name) : transObj.r - this.r;
        } else {
            return super.compareTo(e2);
        }

    }
}