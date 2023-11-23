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
int currentPosX, currentPosY;

PImage bgImage;

TreeSet<UIElement> drawnElements = new TreeSet<>((e1, e2) -> e1.z - e2.z);


void setup() {
    size(512, 512, P2D);
    // fullScreen(P2D);
    MAX_CENTER_X = FIELD_WIDTH - width / 2;
    MAX_CENTER_Y = FIELD_HEIGHT - height / 2;

    bgImage = loadImage("background.jpg");
    imageMode(CENTER);

    // drawnElements.add(new Box(30, 30, 1, 160, 160, color(121, 7, 235, 255)));
    // drawnElements.add(new Box(60, 60, 2, 160, 160, color(120, 7, 5, 255)));
    // drawnElements.add(new CloseButton(320, 320, 3, 32, 32, () -> println("yippeee")));

    drawIntroScreen();
}

void draw() {
    currentPosX = (mouseX - (width/2)) + currentCenterX;
    currentPosY = (mouseY - (height/2)) + currentCenterY;

    // set background starfield in relation to larger canvas
    image(bgImage, (width/2) + ((FIELD_WIDTH/2) - currentCenterX) , (height/2) + ((FIELD_HEIGHT/2) - currentCenterY));

    // create coordinate text
    textSize(28);
    fill(255, 255, 255, 255);
    text("(" + currentPosX + ", " + currentPosY + ")", 0, height-5);

    for (UIElement e : drawnElements) {
        e.drawElement();
    }

    moveBackground();
}

void mouseMoved() {
    boolean onClickableElement = false;

    for (UIElement e : drawnElements.descendingSet()) {
        if (e.pointInsideElement(mouseX, mouseY)) {

            if (e.isClickable) {
                onClickableElement = true;
            }
            e.onHover();
            break;
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