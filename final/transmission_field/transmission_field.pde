import java.util.TreeSet;

// field/window size
final int FIELD_WIDTH = 4000;
final int FIELD_HEIGHT = 4000;
final int FIELD_SCROLL_BORDER = 30; // amount of pixels at the edge to begin scrolling
final int SCROLL_SPEED_BASE = 10;
int MAX_CENTER_X;
int MAX_CENTER_Y;

int currentCenterX = FIELD_WIDTH / 2;
int currentCenterY = FIELD_HEIGHT / 2;
int currentPosX = 0;
int currentPosY = 0;

// each transmission has its own unique Z value
// this is a hack for getting .equals to work on Transmission objects in TreeSet
int totalNumTransmissions = 0;

final int TX_COOLDOWN = 5000; // should be >= 20000 for prod
int lastTx = 0;
boolean readyToTransmit = false; // should be initialized to true for prod

PImage bgImage;
PFont startFont;

// draw elements in order of Z value, if tie, place smaller elements on top
TreeSet<UIElement> drawnElements = new TreeSet<>();
ArrayList<Transmission> transmissionList = new ArrayList<>(); 

enum State {
    INTRO, NAVIGATE, TRANSMIT;
}

State currentState = State.INTRO;

void setup() {
    // size(1920, 1080, P2D);
    fullScreen(JAVA2D, 1); // P2D renderer is WAY too slow
    // smooth(4);
    MAX_CENTER_X = FIELD_WIDTH - width / 2;
    MAX_CENTER_Y = FIELD_HEIGHT - height / 2;

    bgImage = loadImage("resources/background.jpg");
    startFont = createFont("resources/PressStart2P-Regular.ttf", 32);

    imageMode(CENTER);
    drawIntroScreen();

    transmissionList.add(new Transmission("TX7351", currentCenterX, currentCenterY, 60));
    transmissionList.add(new Transmission("TX7352", currentCenterX+60, currentCenterY, 90));
    transmissionList.add(new Transmission("TX7353", currentCenterX+70, currentCenterY+80, 40));
    transmissionList.add(new Transmission("TX7354", currentCenterX+100, currentCenterY+80, 40));    

    for (int i = 0; i < 20; i++) {
        transmissionList.add(new Transmission("TX" + int(random(100, 300)), int(currentCenterX+random(-500, 500)), int(currentCenterY+random(-400, 400)), int(random(35, 90))));
    }

    println(sketchPath());

}

void draw() {
    // set background starfield in relation to larger canvas
    image(bgImage, (width/2) + ((FIELD_WIDTH/2) - currentCenterX) , (height/2) + ((FIELD_HEIGHT/2) - currentCenterY));

    // base UI drawing (don't include in drawnElements for efficiency)
    drawCoordinates();
    updateTxReady();
    
    for (Transmission t : transmissionList) {
        if (t.transmissionVisible() && !drawnElements.contains(t)) {
            drawnElements.add(t);
            
        } else if (drawnElements.contains(t) && !t.transmissionVisible()) { // smart short circuit for efficiency
            drawnElements.remove(t);
        }
    }

    for (UIElement e : drawnElements) {
        e.drawElement();
    }


    if (currentState == State.NAVIGATE) {
        moveBackground();
        currentPosX = (mouseX - (width/2)) + currentCenterX;
        currentPosY = (mouseY - (height/2)) + currentCenterY;
    }
}

void mouseMoved() {
    boolean onClickableElement = false;
    boolean hoveredElementToggled = false; // so we don't double hover
    
    for (UIElement e : drawnElements.descendingSet()) {
        if (e.pointInsideElement(mouseX, mouseY) && !hoveredElementToggled) {

            if (e.isClickable) {
                onClickableElement = true;
            }

            if (e.hoverJustEntered) {
                e.onEnter();
            }
            e.onHover();
            hoveredElementToggled = true;
        } else if (e.hoverIn) {
            e.onLeave();
        }
    }

    if (onClickableElement) {
        cursor(HAND);
    } else {
        cursor(ARROW);
    }
}

void mousePressed() {
    boolean clickedOnElement = false;
    for (UIElement e : drawnElements.descendingSet()) {
        if (e.pointInsideElement(mouseX, mouseY)) {
            clickedOnElement = true;
            e.onClick();
            break;
        }
    }

    if (!clickedOnElement && currentState == State.NAVIGATE) {
        drawTransmissionScreen();
    }
}

void moveBackground() {
    if (mouseX < FIELD_SCROLL_BORDER && currentCenterX-width/2 > SCROLL_SPEED_BASE) {
        currentCenterX -= SCROLL_SPEED_BASE;
    } else if (mouseX > width-FIELD_SCROLL_BORDER && currentCenterX + width/2 < FIELD_WIDTH-SCROLL_SPEED_BASE) {
        currentCenterX += SCROLL_SPEED_BASE;
    } 

    if (mouseY < FIELD_SCROLL_BORDER && currentCenterY-height/2 > SCROLL_SPEED_BASE) {
        currentCenterY -= SCROLL_SPEED_BASE;
    } else if (mouseY > height-FIELD_SCROLL_BORDER && currentCenterY+height/2 < FIELD_HEIGHT-SCROLL_SPEED_BASE) {
        currentCenterY += SCROLL_SPEED_BASE;
    }
}

void drawCoordinates() {
    textSize(28);
    textAlign(LEFT, BASELINE);
    fill(255, 255, 255, 255);
    text("(" + currentPosX + ", " + currentPosY + ")", 0, height-5);
}

void updateTxReady() {
    textSize(24);
    textAlign(RIGHT, BASELINE);
    fill(255, 255, 255, 255);
    text("Transmitter Status: ", width-textWidth("READY"), height-45);

    if (millis() - lastTx > TX_COOLDOWN) {
        readyToTransmit = true;
        text("Click any empty point to start new transmission", width-5, height-5);
        fill(0, 255, 0, 255);
        text("READY", width-5, height-45);
    } else {
        readyToTransmit = false;
        text("Transmitter still cooling down...", width-5, height-5);
        fill(255, 0, 0, 255);   
        text("WAIT", width-5, height-45);
    }
}