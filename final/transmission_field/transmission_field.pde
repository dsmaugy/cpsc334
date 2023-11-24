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

PImage bgImage;
PFont startFont;

TreeSet<UIElement> drawnElements = new TreeSet<>((e1, e2) -> e1.z - e2.z);

enum State {
    INTRO, NAVIGATE;
}

State currentState = State.INTRO;

void setup() {
    size(512, 512, P2D);
    // fullScreen(P2D);
    MAX_CENTER_X = FIELD_WIDTH - width / 2;
    MAX_CENTER_Y = FIELD_HEIGHT - height / 2;

    bgImage = loadImage("resources/background.jpg");
    startFont = createFont("resources/PressStart2P-Regular.ttf", 32);

    imageMode(CENTER);
    drawIntroScreen();
}

void draw() {
    // set background starfield in relation to larger canvas
    image(bgImage, (width/2) + ((FIELD_WIDTH/2) - currentCenterX) , (height/2) + ((FIELD_HEIGHT/2) - currentCenterY));

    // create coordinate text
    textSize(28);
    textAlign(LEFT, BASELINE);
    fill(255, 255, 255, 255);
    text("(" + currentPosX + ", " + currentPosY + ")", 0, height-5);

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

    for (UIElement e : drawnElements.descendingSet()) {
        if (e.pointInsideElement(mouseX, mouseY)) {

            if (e.isClickable) {
                onClickableElement = true;
            }

            if (e.hoverJustEntered) {
                e.onEnter();
            }
            e.onHover();
            break;
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
    for (UIElement e : drawnElements.descendingSet()) {
        if (e.pointInsideElement(mouseX, mouseY)) {
            e.onClick();
            break;
        }
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