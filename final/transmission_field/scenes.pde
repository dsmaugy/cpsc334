
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
    currentState = State.INTRO;
    MessageBox introBox = new MessageBox(width/5, height/5, 1, 3*width/5, 3*height/5, color(8, 12, 38, 120), color(255, 255, 255), introText);
    introBox.boxStroke = color(239, 225, 250);

    MessageBox closeButton = new MessageBox(introBox.x + 20, introBox.y + introBox.height - 60, 2, introBox.width-40, 50, color(80, 12, 38, 120), color(255, 255, 255), "Proceed...");
    closeButton.isClickable = true;
    closeButton.boxStroke = color(239, 225, 250);
    closeButton.hoverAction = (b1) -> {
        b1.boxColor = color(200, 200, 200, 180);
        b1.textColor = color(0, 0, 0);
    };
    closeButton.leaveAction = (b1) -> {
        b1.boxColor = color(80, 12, 38, 120);
        b1.textColor = color(255, 255, 255);
    };
    closeButton.clickAction = (b1) -> {
        drawnElements.clear();
        currentState = State.NAVIGATE;
    };
    
    drawnElements.add(new Box(0, 0, 0, width, height, color(76, 70, 82, 200)));
    drawnElements.add(introBox);
    drawnElements.add(closeButton);
}