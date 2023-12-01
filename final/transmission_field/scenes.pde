
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

String txStepsText = """1. Input desired message
2. Choose encoding mode by toggling desired combination of buttons
3. Turn knob to select desired broadcast frequency
4. Adjust hand on side of transmission device to select desired broadcast phase
5. Click TRANSMIT to activate transmission
""";



color accentOne = color(239, 225, 250);
color txScreenColor = color(8, 12, 38, 250);
color mutedGrayColor = color(76, 70, 82, 200);
color transparentColor = color(0, 0, 0, 1); // this is a hack, 0 transparency doesn't work

void drawIntroScreen() {
    currentState = State.INTRO;
    MessageBox introBox = new MessageBox(width/5, height/5, 1, 3*width/5, 3*height/5, color(8, 12, 38, 120), color(255, 255, 255), introText);
    introBox.boxStroke = accentOne;

    MessageBox closeButton = new MessageBox(introBox.x + 20, introBox.y + introBox.height - 60, 2, introBox.width-40, 50, color(80, 12, 38, 120), color(255, 255, 255), "Proceed...");
    closeButton.isClickable = true;
    closeButton.boxStroke = accentOne;
    closeButton.hoverAction = (b1) -> {
        // b1.boxColor = color(200, 200, 200, 180);
        b1.boxColor = accentOne;
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
    
    drawnElements.add(new Box(0, 0, 0, width, height, mutedGrayColor));
    drawnElements.add(introBox);
    drawnElements.add(closeButton);
}

void drawTransmissionScreen() {
    currentState = State.TRANSMIT;
    MessageBox txBox = new MessageBox(width/2, height/2, 100, 4*width/5, 5*height/6, txScreenColor, color(255, 255, 255), "Transmitter v2");
    txBox.boxStroke = accentOne;
    txBox.rectAlign = CENTER;

    CloseButton cb = new CloseButton(txBox.x + txBox.width/2 - 15, txBox.y - txBox.height/2 - 15, 101, 35, 35);
    cb.clickAction = (b1) -> {
        drawnElements.clear();
        currentState = State.NAVIGATE;
    };

    MessageBox txDesc = new MessageBox(txBox.x, txBox.y-txBox.height/2+100, 102, txBox.width, 60, transparentColor, color(255, 255, 255), "Transmission Steps:");
    txDesc.fontSize = 15;
    txDesc.rectAlign = CENTER;

    // debugging color
    // color(255, 0, 160, 10)
    MessageBox txSteps = new MessageBox(txBox.x, txDesc.y+70, 103, txBox.width, 120, transparentColor, color(255, 255, 255), txStepsText);
    txSteps.fontSize = 15;
    txSteps.xAlign = LEFT;
    txSteps.rectAlign = CENTER;

    SensorGauge distGauge = new SensorGauge(width/2, height/2, 104, 196, 90);

    MessageBox entryBox = new MessageBox(txBox.x, txBox.y+40, 105, txBox.width, 80, color(255, 0, 160, 10), color(255, 255, 255), Character.toString('\u1FE0'));
    entryBox.xAlign = LEFT;
    entryBox.rectAlign = CENTER;
    entryBox.fontSize = 17;
    activeTextField = entryBox;

    drawnElements.add(new Box(0, 0, 99, width, height, mutedGrayColor)); // background mute
    drawnElements.add(txBox);
    drawnElements.add(cb);
    drawnElements.add(txDesc);
    drawnElements.add(txSteps);
    drawnElements.add(distGauge);
    drawnElements.add(entryBox);
}