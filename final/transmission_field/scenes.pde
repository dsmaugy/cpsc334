
String introText = """Welcome to Sonderful Transmissions""";

String introDesc = """



- Navigate around the starfield with the computer mouse
- Click on any empty space to start a new transmission
- Click on any existing transmission to attempt to decode
- Use the attached transmission device for both transmitting and decoding
- The three parameters to control are:
    1. Encoding Method
    2. Broadcast frequency
    3. Broadcast attenuation


Be thoughtful.
What should the universe hear from you?
What do you wish to listen to?
""";

String txStepsText = """1. Input desired message
2. Choose encoding mode by toggling desired combination of buttons
3. Turn knob to select desired broadcast frequency
4. Adjust hand on side of transmission device to adjust signal attenuation
5. Click TRANSMIT to activate transmission
""";

String decodeTxSteps = """1. Choose the right encoding mode to make the text visible 
2. Adjust the signal attenuation to get the right set of characters
3. Adjust the broadcast frequency to put the characters in the right order
4. When all parameters are correct, hit CAPTURE to download message to the terminal 
""";


// color(0, 0, 0);
color accentOne = color(239, 225, 250);
color txScreenColor =  color(8, 12, 38, 250);
color mutedGrayColor = color(76, 70, 82, 200);
color transparentColor = color(0, 0, 0, 1); // this is a hack, 0 transparency doesn't work

void drawIntroScreen() {
    currentState = State.INTRO;
    MessageBox introBox = new MessageBox(width/2, height/2, 2, 3*width/5, 3*height/5, color(8, 12, 38, 120), color(0, 255, 0), introText);
    introBox.boxStroke = accentOne;

    MessageBox introBoxDesc = new MessageBox(width/2, height/2, 3, 3*width/5, 3*height/5, transparentColor, color(255, 255, 255), introDesc);
    introBoxDesc.fontSize = 20;
    introBoxDesc.xAlign = LEFT;

    MessageBox closeButton = new MessageBox(introBox.x, introBox.y + introBox.height/2 - 60, 4, introBox.width-40, 50, color(80, 12, 38, 120), color(255, 255, 255), "Proceed...");
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
        switchToNavigate();
    };
    
    drawnElements.add(new Box(width/2, height/2, 1, width, height, mutedGrayColor));
    drawnElements.add(introBox);
    drawnElements.add(closeButton);
    drawnElements.add(introBoxDesc);
}

void drawTransmissionScreen() {
    currentState = State.TRANSMIT;
    esp32.write("TRANSMIT\n");
    txToSend = new Transmission(getNewTxName(), currentPosX, currentPosY, "", 0, 0, 0);

    MessageBox txBox = new MessageBox(width/2, height/2, 100, 4*width/5, 7*height/8, txScreenColor, color(255, 0, 0), "Transmitter v2");
    txBox.boxStroke = accentOne;

    CloseButton cb = new CloseButton(txBox.x + txBox.width/2, txBox.y - txBox.height/2, 101, 35, 35);
    cb.clickAction = (b1) -> {
        drawnElements.clear();
        switchToNavigate();
    };

    MessageBox txDesc = new MessageBox(txBox.x, txBox.y-txBox.height/2+100, 102, txBox.width, 60, transparentColor, color(255, 255, 255), "Transmission Steps:");
    txDesc.fontSize = 17;

    // debugging color
    // color(255, 0, 160, 10)
    MessageBox txSteps = new MessageBox(txBox.x, txDesc.y+70, 103, txBox.width, 120, transparentColor, color(255, 255, 255), txStepsText);
    txSteps.fontSize = 16;
    txSteps.xAlign = LEFT;

    SensorGauge distGauge = new SensorGauge(width/2, txSteps.y+txSteps.height+55, 104, 196, 90, "Signal Attenuator", "dB");
    SensorGauge potGauge = new SensorGauge(3*width/4, txSteps.y+txSteps.height+55, 105, 196, 90, "Signal Frequency", "kHz");
    ButtonCombo buttonDisp = new ButtonCombo(width/4, txSteps.y+txSteps.height+55, 106, 370, 80);
    activeDistGauge = distGauge;
    activePotGauge = potGauge;
    activeButtonCombo = buttonDisp;

    TextEntryBox entryBox = new TextEntryBox(txBox.x, txBox.y+190, 107, txBox.width-8, 400, color(10, 19, 10, 250), color(0, 255, 0), "");
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
        txToSend.updateMsg(entryBox.getText());
        txToSend.buttonCombo = buttonsVal;
        txToSend.txPot = potVal;
        txToSend.txDist = distVal;
        transmissionNames.add(txToSend.name);
        transmissionList.add(txToSend);
        println("Transmission submitted!: " + txToSend.toString());

        drawnElements.clear();
        drawTransmissionTransition(txToSend);
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

void drawTransmissionTransition(Transmission tx) {

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
        switchToNavigate();
    };


    LoadingAnimation dots = new LoadingAnimation(width/2, height/2, 201, 100, 20, 5000);    // TODO: change transmisison speed
    dots.onDone = (e) -> {
        printTxToReceipt(txToSend, false);
        writeTxToCSV(txToSend);
        delay(1300);
        drawnElements.add(closeButton);
        lastTx = millis();
    };

    drawnElements.add(new Box(width/2, height/2, 99, width, height, mutedGrayColor)); // background mute
    drawnElements.add(loadingBox);
    drawnElements.add(dots);
}

void openTransmission(Transmission t) {
    currentState = State.DECODE;
    esp32.write("DECODE\n");

    MessageBox decodeBox = new MessageBox(width/2, height/2, 300, 4*width/5, 7*height/8, txScreenColor, color(255, 0, 0), "Receiver v2");
    decodeBox.boxStroke = accentOne;

    CloseButton cb = new CloseButton(decodeBox.x + decodeBox.width/2, decodeBox.y - decodeBox.height/2, 301, 35, 35);
    cb.clickAction = (b1) -> {
        drawnElements.clear();
        switchToNavigate();
    };

    MessageBox decodeDesc = new MessageBox(decodeBox.x, decodeBox.y-decodeBox.height/2+100, 302, decodeBox.width, 60, transparentColor, color(255, 255, 255), "Decoding Steps:");
    decodeDesc.fontSize = 17;

    // debugging color
    MessageBox decodeSteps = new MessageBox(decodeBox.x, decodeDesc.y+70, 303, decodeBox.width, 120, transparentColor, color(255, 255, 255), decodeTxSteps);
    decodeSteps.fontSize = 16;
    decodeSteps.xAlign = LEFT;

    SensorGauge distGauge = new SensorGauge(width/2, decodeSteps.y+decodeSteps.height+55, 304, 196, 90, "Signal Attenuator", "dB");
    SensorGauge potGauge = new SensorGauge(3*width/4, decodeSteps.y+decodeSteps.height+55, 305, 196, 90, "Signal Frequency", "kHz");
    ButtonCombo buttonDisp = new ButtonCombo(width/4, decodeSteps.y+decodeSteps.height+55, 306, 370, 80);
    activeDistGauge = distGauge;
    activePotGauge = potGauge;
    activeButtonCombo = buttonDisp;

    MessageBox captureButton = new MessageBox(width/2, ((decodeBox.y+decodeBox.height/2) + (decodeBox.y+190 + 200))/2, // halfway between terminal and box end
        308, 300, 35, color(24, 31, 23), color(100, 100, 100), "CAPTURE");
    captureButton.fontSize = 20;
    captureButton.isClickable = false;
    captureButton.boxStroke = color(63, 62, 60);
    captureButton.clickAction = (b1) -> {
        if (b1.isClickable) {
            drawnElements.clear();
            currentState = State.DECODE_DONE;
            decodeDone(t);
        }
    };
    captureButton.hoverAction = (b1) -> {
        if (b1.isClickable) {
            b1.boxColor = accentOne;
            b1.textColor = color(0, 0, 0);
        }
    };
    captureButton.leaveAction = (b1) -> {
        if (b1.isClickable) {
            b1.boxColor = color(20, 255, 20, 180);
            b1.textColor = color(255, 255, 255);
        } else {
            b1.boxColor = color(24, 31, 23);
            b1.textColor = color(100, 100, 100);
        }
    };

    DecodeBox decodeTextBox = new DecodeBox(decodeBox.x, decodeBox.y+190, 307, decodeBox.width-8, 400, color(10, 19, 10, 250), color(0, 255, 0), t, captureButton);
    decodeTextBox.textFont = terminalFont;
    decodeTextBox.xAlign = CENTER;
    decodeTextBox.yAlign = CENTER;
    decodeTextBox.fontSize = 17;
    decodeTextBox.boxStroke = color(124, 116, 118, 49);
    activeDecodeField = decodeTextBox;

    drawnElements.add(new Box(width/2, height/2, 99, width, height, mutedGrayColor)); // background mute
    drawnElements.add(decodeBox);
    drawnElements.add(cb);
    drawnElements.add(distGauge);
    drawnElements.add(potGauge);
    drawnElements.add(buttonDisp);
    drawnElements.add(decodeDesc);
    drawnElements.add(decodeSteps);
    drawnElements.add(decodeTextBox);
    drawnElements.add(captureButton);
}

void decodeDone(Transmission t) {
    MessageBox outerBox = new MessageBox(width/2, height/2, 400, 4*width/5, 5*height/8, txScreenColor, color(219, 219, 0), "Capturing Transmission...");
    outerBox.boxStroke = accentOne;

    MessageBoxAnimated displayBox = new MessageBoxAnimated(outerBox.x, outerBox.y-65, 401, outerBox.width-8, 400, t.msg);
    displayBox.textFont = terminalFont;
    displayBox.xAlign = CENTER;
    displayBox.yAlign = CENTER;
    displayBox.fontSize = 17;
    displayBox.boxStroke = color(124, 116, 118, 49);

    MessageBox printQuery = new MessageBox(outerBox.x, displayBox.y + displayBox.height/2 + 40, 404, outerBox.width, 35, transparentColor, color(255, 255, 25), "Obtain Physical Certificate of Receival?");

    MessageBox yesButton = new MessageBox((outerBox.x - outerBox.width/2) + (outerBox.width/3), (outerBox.y + outerBox.height/2) - 60,
        402, 200, 35, color(0, 255, 0), color(255, 255, 255), "YES");
    yesButton.boxStroke = accentOne;
    yesButton.isClickable = true;
    yesButton.hoverAction = (b1) -> {
        b1.boxColor = accentOne;
        b1.textColor = color(0, 0, 0);
    };
    yesButton.leaveAction = (b1) -> {
        b1.boxColor = color(0, 255, 0);
        b1.textColor = color(255, 255, 255);
    };
    yesButton.clickAction = (b1) -> {
        drawnElements.clear();
        switchToNavigate();
        printTxToReceipt(t, true);
    };

    MessageBox noButton = new MessageBox((outerBox.x - outerBox.width/2) + (2*outerBox.width/3), yesButton.y,
        403, 200, 35, color(255, 0, 0), color(255, 255, 255), "NO");
    noButton.boxStroke = accentOne;
    noButton.isClickable = true;
    noButton.hoverAction = (b1) -> {
        b1.boxColor = accentOne;
        b1.textColor = color(0, 0, 0);
    };
    noButton.leaveAction = (b1) -> {
        b1.boxColor = color(255, 0, 0);
        b1.textColor = color(255, 255, 255);
    };
    noButton.clickAction = (b1) -> {
        drawnElements.clear();
        switchToNavigate();
    };

    displayBox.onDone = (b1) -> {
        drawnElements.add(yesButton);
        drawnElements.add(noButton);
        drawnElements.add(printQuery);

        outerBox.text = "Receive Successful!";
        outerBox.textColor = color(0, 255, 0);
    };

    drawnElements.add(new Box(width/2, height/2, 99, width, height, mutedGrayColor)); // background mute
    drawnElements.add(outerBox);
    drawnElements.add(displayBox);
}