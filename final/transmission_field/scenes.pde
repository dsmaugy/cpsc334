
String introText = """Here we go here here we go.
Damn, everything that something made me everything I am
it's true!!
yep yep yep 
bingus 
bongus 
btest
la la l al al
wai ttill i get my money right
ooooh
""";

void drawIntroScreen() {
    drawnElements.add(new MessageBox(width/5, height/5, 0, 3*width/5, 3*height/5, color(132, 132, 132, 120), color(255, 255, 255), introText));
}