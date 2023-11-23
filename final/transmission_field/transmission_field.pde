
// background perlin noise
float noiseScale = 1; // 130;
float noiseResolution = 0.03;

// field/window size
final int FIELD_WIDTH = 2000;
final int FIELD_HEIGHT = 2000;
final int FIELD_SCROLL_BORDER = 30; // amount of pixels at the edge to begin scrolling
final int SCROLL_SPEED_BASE = 10;
int currentCenterX = FIELD_WIDTH / 2;
int currentCenterY = FIELD_HEIGHT / 2;


final int NUM_STARS = 1000;
ArrayList<Star> stars = new ArrayList<>();

void setup() {
    size(512, 512);
    noiseSeed(877241);
    randomSeed(6511);

    for (int i = 0; i < NUM_STARS; i++) {
        Star star = new Star(int(random(width)), int(random(height)), int(random(5)), int(random(5)));
        stars.add(star);
    }
}

void draw() {
    loadPixels();
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            int xCoord = i - (width / 2) + currentCenterX;
            int yCoord = j - (height / 2) + currentCenterY;
            float val = noise(xCoord * noiseResolution, yCoord * noiseResolution) * noiseScale;
            int skyVal = color(0, 0, 0);

            if (val < 0.25)
                skyVal = color(44*(1-val), 3*(1-val), 66*(1-val));
            pixels[j * width + i] = skyVal;
        }
    }
    updatePixels();

    for (Star star : stars) {
        ellipse(star.x, star.y, star.width, star.height);
    }

    moveBackground();
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