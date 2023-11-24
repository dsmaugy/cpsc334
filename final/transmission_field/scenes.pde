
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
    MessageBox introBox = new MessageBox(width/5, height/5, 1, 3*width/5, 3*height/5, color(8, 12, 38, 120), color(255, 255, 255), introText);
    introBox.boxStroke = color(239, 225, 250);

    MessageBox closeButton = new MessageBox(introBox.x + 20, introBox.y + introBox.height - 60, 2, introBox.width-40, 50, color(80, 12, 38, 120), color(255, 255, 255), "Proceed...");
    closeButton.boxStroke = color(239, 225, 250);
    closeButton.hoverAction = (b1) -> {
        b1.boxColor = color(200, 200, 200);
    };

    drawnElements.add(new Box(0, 0, 0, width, height, color(139, 129, 148, 100)));
    drawnElements.add(introBox);
    drawnElements.add(closeButton);
}