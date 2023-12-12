void mouseMoved() {
    boolean onClickableElement = false;
    boolean hoveredElementToggled = false; // so we don't double hover
    
    for (UIElement e : drawnElements.descendingSet()) {
        if (e.pointInsideElement(mouseX, mouseY) && !hoveredElementToggled) {

            if (e.isClickable) {
                onClickableElement = true;
            }

            if (e.hoverJustEntered) {
                e.onEnter();
            }
            e.onHover();
            hoveredElementToggled = true;
        } else if (e.hoverIn) {
            e.onLeave();
        }
    }

    if (onClickableElement) {
        cursor(HAND);
    } else {
        cursor(ARROW);
    }
}

void mousePressed() {
    boolean clickedOnElement = false;
    for (UIElement e : drawnElements.descendingSet()) {
        if (e.pointInsideElement(mouseX, mouseY) && e.isClickable) {
            clickedOnElement = true;
            e.onClick();
            break;
        }
    }

    if (!clickedOnElement && currentState == State.NAVIGATE) {
        drawTransmissionScreen();
    }
}

void keyTyped() {
    if (currentState == State.TRANSMIT && activeTextField != null) {
        if (key == BACKSPACE) {
            if (activeTextField.text.length() > 0)
                activeTextField.removeChar(); 
        } else {
            activeTextField.addChar(key);
        }   
    } else if (currentState == State.DECODE && activeDecodeField != null) {
        if (key == 'k') {
            distVal += -1;
        } else if (key == 'l') {
            distVal += 1;
        } else if(key == 'o') {
            potVal += -30;
        } else if (key == 'p') {
            potVal += 30;
        }
    } else if (currentState == State.NAVIGATE && key == 'r') {
        drawIntroScreen();
    }
}

void serialEvent(Serial p) {
    String e = p.readString();
    if (e.startsWith("DIST:")) {
        distVal = int(e.substring(5, e.length()-1));
    } else if (e.startsWith("POT:")) {
        potVal = int(e.substring(4, e.length()-1));
    } else if (e.startsWith("BUTTON:")) {
        buttonsVal = int(e.substring(7, e.length()-1));
    }
}