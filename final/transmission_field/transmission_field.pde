import processing.javafx.*;
import processing.serial.*;

import java.util.TreeSet;
import java.util.HashSet;

String serialPort = "COM3";

final char[] unicodeGroups = {'\u0000', '\u0400', '\u0590', '\u0600', '\u0980', '\u0A80', 
'\u0B80', '\u0E80', '\u1400', '\u1780', '\u0400', '\u20A0', '\u20D0', 
'\u2460', '\u2500', '\u2701', '\u2800', '\u31A0', '\u2190'};

// transmission parameters
final int MAX_FREQ = 200;
final int MIN_FREQ = 1;
final int MIN_DIST = 0;
final int MAX_DIST = 40;
final int MIN_ATTEN = -10;
final int MAX_ATTEN = 10;

// field/window size
final int FIELD_WIDTH = 4000;
final int FIELD_HEIGHT = 4000;
final int FIELD_SCROLL_BORDER = 30; // amount of pixels at the edge to begin scrolling
final int SCROLL_SPEED_BASE = 10;
int MAX_CENTER_X;
int MAX_CENTER_Y;

int currentCenterX = FIELD_WIDTH / 2;
int currentCenterY = FIELD_HEIGHT / 2;
int currentPosX = 0;
int currentPosY = 0;

// each transmission has its own unique Z value
// this is a hack for getting .equals to work on Transmission objects in TreeSet
int totalNumTransmissions = 0;

final int TX_COOLDOWN = 5000; // should be >= 20000 for prod
int lastTx = 0;
boolean readyToTransmit = false; // should be initialized to true for prod

// current transmission variables
int buttonsVal = 0;
int potVal = 0;
float distVal = 0;
Transmission txToSend;

// transmission UI elements to update
TextEntryBox activeTextField = null;
DecodeBox activeDecodeField = null;
SensorGauge activeDistGauge = null;
SensorGauge activePotGauge = null;
ButtonCombo activeButtonCombo = null;

Table txData;

PImage bgImage;
PFont startFont;
PFont terminalFont;
PShape gaugeSvg;

// draw elements in order of Z value, if tie, place smaller elements on top
TreeSet<UIElement> drawnElements = new TreeSet<>();
ArrayList<Transmission> transmissionList = new ArrayList<>(); 
HashSet<String> transmissionNames = new HashSet<>();

Serial esp32;

enum State {
    INTRO, NAVIGATE, TRANSMIT, DECODE, DECODE_DONE;
}

State currentState = State.INTRO;

void setup() {
    // size(512, 512, FX2D);
    fullScreen(FX2D, 1); 
    // noSmooth();
    MAX_CENTER_X = FIELD_WIDTH - width / 2;
    MAX_CENTER_Y = FIELD_HEIGHT - height / 2;

    imageMode(CENTER);
    bgImage = loadImage("resources/background.jpg");
    startFont = createFont("resources/PressStart2P-Regular.ttf", 32);
    terminalFont = createFont("Lucida Console", 32, false);
    // terminalFont = createFont("Bitstream Vera Sans", 32, true);
    gaugeSvg = loadShape("resources/gauge_2.svg");

    loadTxFromCSV();
    drawIntroScreen();

    // esp32 = new Serial(this, serialPort, 9600);
    // esp32.bufferUntil('\n');

    println(sketchPath());
    println(Serial.list());    
    // println(PFont.list());
}

void draw() {
    // set background starfield in relation to larger canvas
    image(bgImage, fieldToSketchX(currentCenterX) , fieldToSketchY(currentCenterY));

    // base UI drawing (don't include in drawnElements for efficiency)
    drawCoordinates();
    updateTxReady();
    
    if (currentState == State.TRANSMIT || currentState == State.DECODE) {
        updateSenorValues();
    }

    if (currentState == State.NAVIGATE) {
        moveBackground();
        currentPosX = sketchToFieldX(mouseX);
        currentPosY = sketchToFieldY(mouseY);
    }

    for (Transmission t : transmissionList) {
        if (t.transmissionVisible() && !drawnElements.contains(t)) {
            drawnElements.add(t);
        } else if (drawnElements.contains(t) && !t.transmissionVisible()) { // smart short circuit for efficiency
            drawnElements.remove(t);
        }
    }

    for (UIElement e : drawnElements) {
        e.drawElement();
    }
}

void moveBackground() {
    if (mouseX < FIELD_SCROLL_BORDER && currentCenterX-width/2 > SCROLL_SPEED_BASE) {
        currentCenterX -= SCROLL_SPEED_BASE;
    } else if (mouseX > width-FIELD_SCROLL_BORDER && currentCenterX + width/2 < FIELD_WIDTH-SCROLL_SPEED_BASE) {
        currentCenterX += SCROLL_SPEED_BASE;
    } 

    if (mouseY < FIELD_SCROLL_BORDER && currentCenterY-height/2 > SCROLL_SPEED_BASE) {
        currentCenterY -= SCROLL_SPEED_BASE;
    } else if (mouseY > height-FIELD_SCROLL_BORDER && currentCenterY+height/2 < FIELD_HEIGHT-SCROLL_SPEED_BASE) {
        currentCenterY += SCROLL_SPEED_BASE;
    }
}

void drawCoordinates() {
    textFont(startFont);
    textSize(28);
    textAlign(LEFT, BASELINE);
    fill(255, 255, 255, 255);
    text("(" + currentPosX + ", " + currentPosY + ")", 0, height-5);
}

void updateTxReady() {
    textAlign(RIGHT, BASELINE);
    fill(255, 255, 255, 255);
    textFont(startFont);
    textSize(24);
    text("Transmitter Status: ", width-textWidth("READY"), height-45);

    if (millis() - lastTx > TX_COOLDOWN) {
        readyToTransmit = true;
        text("Click any empty point to start new transmission", width-5, height-5);
        fill(0, 255, 0, 255);
        text("READY", width-5, height-45);
    } else {
        readyToTransmit = false;
        text("Transmitter still cooling down...", width-5, height-5);
        fill(255, 0, 0, 255);   
        text("WAIT", width-5, height-45);
    }
}

void updateSenorValues() {
    activeDistGauge.setAngle(constrain(map(distVal, MIN_DIST, MAX_DIST, 180, 0), 0, 180));
    activeDistGauge.setValue(getAttenuation(distVal));

    activePotGauge.setAngle(min(map(potVal, 0, 4095, 0, 180), 180));
    activePotGauge.setValue(getFrequency(potVal));
}