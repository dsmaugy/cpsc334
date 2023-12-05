import java.util.LinkedList;
import java.util.Arrays;
import java.util.stream.Collectors;
import java.util.ConcurrentModificationException;

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
        && x >= this.x-boundingWidth/2 && x <= this.x+boundingWidth/2
        && y >= this.y-boundingHeight/2 && y <= this.y+boundingHeight/2);
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

    int rectAlign = CENTER;

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
        line(x-this.width/2+5, y-this.height/2+5, x+this.width/2-5, y+this.height/2-5);
        line(x-this.width/2+5, y+this.height/2-5, x+this.width/2-5, y-this.height/2+5);
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

    @Override
    public void drawElement() {
        super.drawElement();
        drawText();
    }

    void drawText() {
        try {
            fill(textColor);
            textAlign(xAlign, yAlign);
            textFont(textFont, fontSize);
            text(text, x+leftMargin, y+topMargin, this.width-leftMargin, this.height-topMargin);
        } catch (ConcurrentModificationException e) {
            // no idea why this happens, but it's rare
            // EDIT: version 21 of JAVAFX on linux seems to fix this 
            // EDIT: nevermind
            println("weird concurrent modification bug");
        }

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

class DecodeBox extends MessageBox {

    char[] originalText;
    int currentShift = 0;

    public DecodeBox(int x, int y, int z, int width, int height, color boxColor, color textColor, String text) {
        super(x, y, z, width, height, boxColor, textColor, text);
        
        originalText = new char[text.length()];
        for (int i = 0; i < text.length(); i++) {
            originalText[i] = text.charAt(i);
        }
    }

    public void setShift(int newShift) {
        if (currentShift != newShift) {
            currentShift = newShift;

            char[] shiftedText = new char[originalText.length];
            for (int i = 0; i < shiftedText.length; i++) {
                shiftedText[i] = (char)(originalText[i] + currentShift);
            }
            
            text = new String(shiftedText);
        }
    }

    public void addShift(int n) {
        setShift(currentShift+n);
    }

}

class TextEntryBox extends MessageBox {

    boolean isCursorVisible = false;
    int cursorBlinkRate = 1000;
    int lastCursorBlink = 0;

    LinkedList<Character> textEntry;

    public TextEntryBox(int x, int y, int z, int width, int height, color boxColor, color textColor, String text) {
        super(x, y, z, width, height, boxColor, textColor, text);
        textEntry = new LinkedList<>();
        for (Character c : text.toCharArray()) {
            textEntry.add(c); // do this manually cuz java dumb
        }
    }

    @Override
    public void drawElement() {
        if (millis() - lastCursorBlink > cursorBlinkRate) {
            lastCursorBlink = millis();
            if (isCursorVisible) {
                isCursorVisible = false;
                textEntry.removeLast();
            } else {
                isCursorVisible = true;
                textEntry.add('|');
            }
        }


        text = textEntry.stream()
            .map(Object::toString)
            .collect(Collectors.joining());

        super.drawElement();
    }

    public void addChar(char c) {
        int lastCharIdx = isCursorVisible ? textEntry.size() - 1: textEntry.size();
        textEntry.add(lastCharIdx, c);
    }

    public void removeChar() {
        int lastCharIdx = isCursorVisible ? textEntry.size() - 2: textEntry.size() - 1;
        if (lastCharIdx >= 0)
            textEntry.remove(lastCharIdx);
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

    String msg;
    int buttonCombo, txPot;
    float txDist;

    // takes in field coords instead of sketch coords
    public Transmission(String name, int fieldX, int fieldY, String msg, int buttonCombo, int txPot, float txDist) {
        super(0, 0, totalNumTransmissions * -1, getTxRadius(msg)*2, getTxRadius(msg)*2); // placeholder x, y coords
        totalNumTransmissions++;
        this.fieldX = fieldX;
        this.fieldY = fieldY;
        this.r = getTxRadius(msg);
        this.name = name;
        isClickable = true;

        this.msg = msg;
        this.buttonCombo = buttonCombo;
        this.txPot = txPot;
        this.txDist = txDist;

        calcNumRings();
    }

    public void updateMsg(String msg) {
        this.msg = msg;
        this.r = getTxRadius(msg);
        this.boundingWidth = this.boundingHeight = r*2;
        calcNumRings();
    }

    private void calcNumRings() {
        // radius divided by the radius difference for each ring
        maxNumRings = (r+5) / 10;
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
    public void onClick() {
        super.onClick();
        openTransmission(this);
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
        return name + ": (" + fieldX + "," + fieldY + ") -> r: " + r;
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

class SensorGauge extends UIElement {
    float desiredAngle = 0;
    private float currentAngle = 0;
    private int lastTickerMove = 0;
    private int tickerCooldown = 5;

    int sensorValue = 0;
    String sensorName;
    String valueUnit;

    public SensorGauge(int x, int y, int z, int width, int height, String sensorName, String valueUnit) {
        super(x, y, z, width, height);
        this.sensorName = sensorName;
        this.valueUnit = valueUnit;
    }

    @Override
    public void drawElement() {
        shapeMode(CENTER);
        shape(gaugeSvg, x, y, boundingWidth, boundingHeight);

        stroke(color(170, 0, 0));
        strokeWeight(3);

        int endX = x-boundingWidth/2;
        int endY = y+boundingHeight/2;
        int tickerLength = boundingWidth/2;

        if (millis() - lastTickerMove > tickerCooldown) {
            lastTickerMove = millis();
            float delta = map(abs(desiredAngle - currentAngle), 0, 180, 0, 10);
            currentAngle += desiredAngle - currentAngle > 0 ? delta : -delta;

            if (random(1) < 0.1) {
                currentAngle += random(-1, 1);
            }
        }

        float theta = radians(currentAngle);
        line(x, y+boundingHeight/2, x - tickerLength*cos(theta), endY - tickerLength*sin(theta));

        fill(255, 255, 255);
        textAlign(CENTER, BASELINE);
        textFont(startFont, 18);
        text(sensorName, x+5, y - boundingHeight + 20);
        text("" + sensorValue + " " + valueUnit, x+5, y + boundingHeight - 10);
    }

    public void setAngle(float degrees) {
        desiredAngle = degrees;
    }

    public void setValue(int sensorValue) {
        this.sensorValue = sensorValue;
    }
}

class ButtonCombo extends UIElement {

    int circleSpacing;
    boolean[] lightOn = {false, true, false};

    color colorOff = color(0, 100, 100);
    color colorOn = color(0, 255, 100);

    public ButtonCombo(int x, int y, int z, int boundingWidth, int boundingHeight) {
        super(x, y, z, boundingWidth, boundingHeight);
        circleSpacing = boundingWidth/4;
    }   

    @Override
    public void drawElement() {
        ellipseMode(CENTER);
        noStroke();
        for (int i=0; i<3; i++) {
            if (lightOn[i]) {
                fill(colorOn);
            } else {
                fill(colorOff);
            }
            circle(x-circleSpacing + (i*circleSpacing), y, boundingHeight);
        }
        
        fill(255, 255, 255);
        textAlign(CENTER, BASELINE);
        textFont(startFont, 18);
        text("Encoding Method", x, y - boundingHeight + 10);
    }
    
}

class LoadingAnimation extends ButtonCombo {

    int currentOnButton = 0;
    int lastButtonTransition = 0;
    final int ANIMATION_SPEED = 800;
    boolean isLoadingDone = false;
    int loadLength;
    int loadStart;

    color colorOff = color(54, 63, 64);
    color colorOn = color(107, 214, 219);

    CallableAction<LoadingAnimation> onDone = null;
    String doneText = "TRANSMISSION DONE";

    public LoadingAnimation(int x, int y, int z, int boundingWidth, int boundingHeight, int loadLength) {
        super(x, y, z, boundingWidth, boundingHeight);
        this.loadLength = loadLength;
        loadStart = millis();
    }

    @Override
    public void drawElement() {
        if (isLoadingDone) {
            fill(0, 255, 0);
            textAlign(CENTER, BASELINE);
            textFont(startFont, 24);
            text(doneText, x, y);
        } else {
            ellipseMode(CENTER);
            noStroke();
            for (int i=0; i<3; i++) {
                if (lightOn[i]) {
                    fill(colorOn);
                } else {
                    fill(colorOff);
                }
                circle(x-circleSpacing + (i*circleSpacing), y, boundingHeight);
            }

            if (millis() - lastButtonTransition > ANIMATION_SPEED) {
                lightOn[currentOnButton] = false;
                currentOnButton = (currentOnButton+1) % 3;
                lightOn[currentOnButton] = true;
                lastButtonTransition = millis();
            }

            if (millis() - loadStart > loadLength)
                finishLoading();        
        }
    }

    private void finishLoading() {
        if (onDone != null) {
            onDone.doAction(this);
        }

        isLoadingDone = true;
    }

}