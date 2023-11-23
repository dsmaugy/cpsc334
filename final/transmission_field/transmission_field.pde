
// background perlin noise
float noiseScale = 1; // 130;
float noiseResolution = 0.03;

// field/window size
final int FIELD_WIDTH = 4000;
final int FIELD_HEIGHT = 4000;
final int FIELD_SCROLL_BORDER = 30; // amount of pixels at the edge to begin scrolling
final int SCROLL_SPEED_BASE = 10;
int MAX_CENTER_X;
int MAX_CENTER_Y;

int currentCenterX = FIELD_WIDTH / 2;
int currentCenterY = FIELD_HEIGHT / 2;

PImage bgImage;

void setup() {
    size(1920, 1080);
    MAX_CENTER_X = FIELD_WIDTH - width / 2;
    MAX_CENTER_Y = FIELD_HEIGHT - height / 2;
    // fullscreen
    bgImage = loadImage("background.jpg");
    imageMode(CENTER);
    // generate_background(FIELD_WIDTH, FIELD_HEIGHT);
}

void draw() {
    moveBackground();
    image(bgImage, currentCenterX, currentCenterY);
}

void mouseMoved() {

}

void moveBackground() {
    if (mouseX < FIELD_SCROLL_BORDER && currentCenterX-width/2 > 0) {
        // currentCenterX -= int(SCROLL_SPEED_BASE*((FIELD_SCROLL_BORDER-mouseX)/FIELD_SCROLL_BORDER));
        currentCenterX -= SCROLL_SPEED_BASE;
    } else if (mouseX > width-FIELD_SCROLL_BORDER && currentCenterX + width/2 < FIELD_WIDTH) {
        // currentCenterX += int(SCROLL_SPEED_BASE*((mouseX - (width - FIELD_SCROLL_BORDER)) / FIELD_SCROLL_BORDER));
        currentCenterX += SCROLL_SPEED_BASE;
    } 

    if (mouseY < FIELD_SCROLL_BORDER && currentCenterY-height/2 > 0) {
        // currentCenterY -= int(SCROLL_SPEED_BASE*((FIELD_SCROLL_BORDER-mouseY)/FIELD_SCROLL_BORDER));
        currentCenterY -= SCROLL_SPEED_BASE;
    } else if (mouseY > height-FIELD_SCROLL_BORDER && currentCenterY+height/2 < FIELD_HEIGHT) {
        // currentCenterY += int(SCROLL_SPEED_BASE*((mouseY - (height - FIELD_SCROLL_BORDER)) / FIELD_SCROLL_BORDER));
        currentCenterY += SCROLL_SPEED_BASE;
    }
}