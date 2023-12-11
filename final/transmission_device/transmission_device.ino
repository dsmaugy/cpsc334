
#define TRIG_PIN 4
#define ECHO_PIN 5
#define POT_PIN 26
#define STATUS_LED 0

#define BUTTON_3 2
#define BUTTON_2 15
#define BUTTON_1 16

#define BUTTON_1_LED 16
#define BUTTON_2_LED 16
#define BUTTON_3_LED 16

enum DeviceState {IDLE, TRANSMIT, DECODE};

DeviceState currState = IDLE;
bool button_1_toggle = false;
bool button_2_toggle = false;
bool button_3_toggle = false;
int button_1_prev = 0;
int button_2_prev = 0;
int button_3_prev = 0;
int button_1_led = LOW;
int button_2_led = LOW;
int button_3_led = LOW;

int currButtonState = 0;
int currLedState = LOW;

const int STATUS_LED_BLINK = 500;
unsigned long lastLedChange = 0;

void setup() {
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(POT_PIN, INPUT);

  pinMode(BUTTON_1, INPUT_PULLUP);
  pinMode(BUTTON_2, INPUT_PULLUP);
  pinMode(BUTTON_3, INPUT_PULLUP);

  Serial.begin(9600);
}

void loop() {
  int button_1_current = digitalRead(BUTTON_1);
  int button_2_current = digitalRead(BUTTON_2);
  int button_3_current = digitalRead(BUTTON_3);

  if (Serial.available()) {
    String cmd = Serial.readStringUntil('\n');
    if (cmd != NULL) {
      // process command here
      if (cmd.equals("IDLE")) {
        currState = IDLE;
      } else if (cmd.equals("TRANSMIT")) {
        currState = TRANSMIT;
      } else if (cmd.equals("DECODE")) {
        currState = DECODE;

        // reset the buttons
        button_1_led = LOW;
        button_2_led = LOW;
        button_3_led = LOW;
        button_1_toggle = LOW;
        button_2_toggle = LOW;
        button_3_toggle = LOW;
      }
    } 
  }

  if (currState == IDLE) {
    currLedState = HIGH;
    button_1_led = LOW;
    button_2_led = LOW;
    button_3_led = LOW;
  } else if (currState == TRANSMIT || currState == DECODE) {
    // explicitly do not send carriage returns
    Serial.print("DIST:" + String(getDistance()) + "\n" );
    Serial.print("POT:" + String(analogRead(POT_PIN)) + "\n");

    int newButtonState = getButtonState();
    if (newButtonState != currButtonState) {
      Serial.print("BUTTON:" + String(newButtonState) + "\n" ); 
      currButtonState = newButtonState;
    }

    if (millis() - lastLedChange > STATUS_LED_BLINK) {
      lastLedChange = millis();
      currLedState = !currLedState;
    }
  }

  digitalWrite(STATUS_LED, currLedState);
  digitalWrite(BUTTON_1_LED, button_1_led);
  digitalWrite(BUTTON_2_LED, button_2_led);
  digitalWrite(BUTTON_3_LED, button_3_led);
}

float getDistance() {
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  unsigned long duration = pulseIn(ECHO_PIN, HIGH);
  return ((float) duration / 2) / 29.1;
}

int getButtonState() {

  if (!button_1_current && button_1_prev != button_1_current) {
    button_1_toggle = !button_1_toggle;
    button_1_led = !button_1_led;
  }

  if (!button_2_current && button_2_prev != button_2_current) {
    button_2_toggle = !button_2_toggle;
    button_2_led = !button_2_led;
  }

  if (!button_3_current && button_3_prev != button_3_current) {
    button_3_toggle = !button_3_toggle;
    button_3_led = !button_3_led;
  }
  button_1_prev = button_1_current;
  button_2_prev = button_2_current;
  button_3_prev = button_3_current;

  int state = 0;
  if (button_1_toggle) {
    state |= 1;
  }
  if (button_2_toggle) {
    state |= 2;
  }
  if (button_3_toggle) {
    state |= 4;
  }

  return state;
}
