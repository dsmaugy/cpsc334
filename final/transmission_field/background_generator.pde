final int NUM_STARS = 10000;

void generate_background(int bg_width, int bg_height) {
    noiseSeed(877241);
    randomSeed(6511);
    PGraphics bg = createGraphics(bg_width, bg_height);
    bg.beginDraw();

    bg.loadPixels();
    for (int i = 0; i < bg_width; i++) {
        for (int j = 0; j < bg_height; j++) {
            float val = noise(i * noiseResolution, j * noiseResolution) * noiseScale;
            int skyVal = color(0, 0, 0);

            if (val < 0.25)
                skyVal = color(44*(1-val), 3*(1-val), 66*(1-val));
            bg.pixels[j * bg_width + i] = skyVal;
        }
    }
    bg.updatePixels();

    for (int i = 0; i < NUM_STARS; i++) {
        bg.ellipse(int(random(bg_width)), int(random(bg_height)), int(random(5)), int(random(5)));
    }
    bg.endDraw();

    bg.save("background.jpg");
}