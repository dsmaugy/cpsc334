
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

void setup() {
    size(512, 512);
    // fullScreen(P2D);
    MAX_CENTER_X = FIELD_WIDTH - width / 2;
    MAX_CENTER_Y = FIELD_HEIGHT - height / 2;
    bgImage = loadImage("background.jpg");
    imageMode(CENTER);
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

    fill(121, 7, 235, 150);
    rect(30, 30, 160, 160);

    moveBackground();
}


void moveBackground() {
    if (mouseX < FIELD_SCROLL_BORDER && currentCenterX-width/2 > SCROLL_SPEED_BASE) {
        // currentCenterX -= int(SCROLL_SPEED_BASE*((FIELD_SCROLL_BORDER-mouseX)/FIELD_SCROLL_BORDER));
        currentCenterX -= SCROLL_SPEED_BASE;
    } else if (mouseX > width-FIELD_SCROLL_BORDER && currentCenterX + width/2 < FIELD_WIDTH-SCROLL_SPEED_BASE) {
        // currentCenterX += int(SCROLL_SPEED_BASE*((mouseX - (width - FIELD_SCROLL_BORDER)) / FIELD_SCROLL_BORDER));
        currentCenterX += SCROLL_SPEED_BASE;
    } 

    if (mouseY < FIELD_SCROLL_BORDER && currentCenterY-height/2 > SCROLL_SPEED_BASE) {
        // currentCenterY -= int(SCROLL_SPEED_BASE*((FIELD_SCROLL_BORDER-mouseY)/FIELD_SCROLL_BORDER));
        currentCenterY -= SCROLL_SPEED_BASE;
    } else if (mouseY > height-FIELD_SCROLL_BORDER && currentCenterY+height/2 < FIELD_HEIGHT-SCROLL_SPEED_BASE) {
        // currentCenterY += int(SCROLL_SPEED_BASE*((mouseY - (height - FIELD_SCROLL_BORDER)) / FIELD_SCROLL_BORDER));
        currentCenterY += SCROLL_SPEED_BASE;
    }
}