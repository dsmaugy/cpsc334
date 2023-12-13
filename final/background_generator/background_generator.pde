final int NUM_STARS = 20000;
final int bg_width = 6000;
final int bg_height = 6000;

// background perlin noise
float noiseScale = 1; // 130;
float noiseResolution = 0.003;

void setup() {
    noiseSeed(877241);
    randomSeed(6511);
    noiseDetail(43);


    PGraphics bg = createGraphics(bg_width, bg_height);
    bg.beginDraw();
    bg.loadPixels();

    ArrayList<Integer> clusteredStars = new ArrayList<>();

    for (int i = 0; i < bg_width; i++) {
        for (int j = 0; j < bg_height; j++) {
            float val = noise(i * noiseResolution, j * noiseResolution) * noiseScale;
            int skyVal = color(8, 11, 41);

            if (val < 0.255) {
                skyVal = color(44*(1-val), 3*(1-val), 66*(1-val));
                if (random(1) < 0.006) {
                    clusteredStars.add(i);
                    clusteredStars.add(j);
                }
            }
            bg.pixels[j * bg_width + i] = skyVal;
        }
    }
    bg.updatePixels();
    println("Number of nebula stars: " + clusteredStars.size());

    for (int i = 0; i < NUM_STARS; i++) {
        bg.ellipse(int(random(bg_width)), int(random(bg_height)), int(random(5)), int(random(5)));
    }

    bg.noStroke();
    for (int i = 0; i < clusteredStars.size(); i += 2) {
        bg.ellipse(clusteredStars.get(i), clusteredStars.get(i+1), int(random(3)), int(random(3)));
    }
    bg.endDraw();

    bg.save("background.jpg");
    exit();
}
