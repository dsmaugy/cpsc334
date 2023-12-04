
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
4. Adjust hand on side of transmission device to adjust signal attenuation
5. Click TRANSMIT to activate transmission
""";


// color(0, 0, 0);
color accentOne = color(239, 225, 250);
color txScreenColor =  color(8, 12, 38, 250);
color mutedGrayColor = color(76, 70, 82, 200);
color transparentColor = color(0, 0, 0, 1); // this is a hack, 0 transparency doesn't work

void drawIntroScreen() {
    currentState = State.INTRO;
    MessageBox introBox = new MessageBox(width/2, height/2, 1, 3*width/5, 3*height/5, color(8, 12, 38, 120), color(255, 255, 255), introText);
    introBox.boxStroke = accentOne;

    MessageBox closeButton = new MessageBox(introBox.x, introBox.y + introBox.height/2 - 60, 2, introBox.width-40, 50, color(80, 12, 38, 120), color(255, 255, 255), "Proceed...");
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
    
    drawnElements.add(new Box(width/2, height/2, 0, width, height, mutedGrayColor));
    drawnElements.add(introBox);
    drawnElements.add(closeButton);
}

void drawTransmissionScreen() {
    currentState = State.TRANSMIT;
    MessageBox txBox = new MessageBox(width/2, height/2, 100, 4*width/5, 7*height/8, txScreenColor, color(255, 0, 0), "Transmitter v2");
    txBox.boxStroke = accentOne;

    // txBox.y - txBox.height/2 - 15
    CloseButton cb = new CloseButton(txBox.x + txBox.width/2, txBox.y - txBox.height/2, 101, 35, 35);
    cb.clickAction = (b1) -> {
        drawnElements.clear();
        currentState = State.NAVIGATE;
    };

    MessageBox txDesc = new MessageBox(txBox.x, txBox.y-txBox.height/2+100, 102, txBox.width, 60, transparentColor, color(255, 255, 255), "Transmission Steps:");
    txDesc.fontSize = 15;

    // debugging color
    // color(255, 0, 160, 10)
    MessageBox txSteps = new MessageBox(txBox.x, txDesc.y+70, 103, txBox.width, 120, transparentColor, color(255, 255, 255), txStepsText);
    txSteps.fontSize = 15;
    txSteps.xAlign = LEFT;

    SensorGauge distGauge = new SensorGauge(width/2, txSteps.y+txSteps.height+55, 104, 196, 90, "Signal Attenuator", "dB");
    SensorGauge potGauge = new SensorGauge(3*width/4, txSteps.y+txSteps.height+55, 105, 196, 90, "Signal Frequency", "kHz");
    ButtonCombo buttonDisp = new ButtonCombo(width/4, txSteps.y+txSteps.height+55, 106, 370, 80);
    activeDistGauge = distGauge;
    activePotGauge = potGauge;
    activeButtonCombo = buttonDisp;

    char[] testChars = {'\u288B'+5, '\u14D9', '\u146F', '\u13B2', '\u1306', '\u11DD', '\u10BE', 
        '\u1029', '\u0FA7', '\u0E84', '\u0E01', '\u0DDC', '\u0B1E', '\u0992', '\u071C', 
        '\uF9AE', '\uF9B5', '\uF9C6', '\uF9BF', '\uFDFB', '\u231A'};
    TextEntryBox entryBox = new TextEntryBox(txBox.x, txBox.y+190, 107, txBox.width-8, 400, color(10, 19, 10, 250), color(0, 255, 0), new String(testChars));
    entryBox.textFont = terminalFont;
    entryBox.xAlign = LEFT;
    entryBox.fontSize = 17;
    entryBox.boxStroke = color(124, 116, 118, 49);
    activeTextField = entryBox;

    MessageBox transmitButton = new MessageBox(width/2, ((txBox.y+txBox.height/2) + (entryBox.y + entryBox.height/2))/2, // halfway between terminal and box end
        108, 300, 35, color(20, 255, 20, 180), color(255, 255, 255), "TRANSMIT");
    transmitButton.fontSize = 20;
    transmitButton.isClickable = true;
    transmitButton.boxStroke = accentOne;
    transmitButton.clickAction = (b1) -> {
        println("Transmission submitted!");
        drawnElements.clear();
        drawTransmissionTransition();
    };
    transmitButton.hoverAction = (b1) -> {
        b1.boxColor = accentOne;
        b1.textColor = color(0, 0, 0);
    };
    transmitButton.leaveAction = (b1) -> {
        b1.boxColor = color(20, 255, 20, 180);
        b1.textColor = color(255, 255, 255);
    };

    drawnElements.add(new Box(width/2, height/2, 99, width, height, mutedGrayColor)); // background mute
    drawnElements.add(txBox);
    drawnElements.add(cb);
    drawnElements.add(txDesc);
    drawnElements.add(txSteps);
    drawnElements.add(distGauge);
    drawnElements.add(potGauge);
    drawnElements.add(buttonDisp);
    drawnElements.add(entryBox);
    drawnElements.add(transmitButton);
}

void drawTransmissionTransition() {

    MessageBox loadingBox = new MessageBox(width/2, height/2, 200, 2*height/5, 2*height/5, txScreenColor, color(255, 255, 255), "Submitting Transmission");
    loadingBox.boxStroke = accentOne;

    MessageBox closeButton = new MessageBox(loadingBox.x, loadingBox.y + loadingBox.height/2 - 60, 203, loadingBox.width-40, 40, color(80, 12, 38, 120), color(255, 255, 255), "Continue");
    closeButton.isClickable = true;
    closeButton.boxStroke = accentOne;
    closeButton.hoverAction = (b1) -> {
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


    LoadingAnimation dots = new LoadingAnimation(width/2, height/2, 201, 100, 20, 5000);    // TODO: change transmisison speed
    dots.onDone = (e) -> {
        drawnElements.add(closeButton);
        lastTx = millis();
    };

    drawnElements.add(new Box(width/2, height/2, 99, width, height, mutedGrayColor)); // background mute
    drawnElements.add(loadingBox);
    drawnElements.add(dots);
}