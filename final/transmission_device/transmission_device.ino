
#define TRIG_PIN 4
#define ECHO_PIN 5
#define POT_PIN 26

#define BUTTON_3 2
#define BUTTON_2 15
#define BUTTON_1 16

enum DeviceState {IDLE, TRANSMIT, DECODE};
DeviceState currState = IDLE;
bool button_1_toggle = false;
bool button_2_toggle = false;
bool button_3_toggle = false;
int button_1_prev = 0;
int button_2_prev = 0;
int button_3_prev = 0;

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
      
    } 
  }
  
  if (!button_1_current && button_1_prev != button_1_current) {
    button_1_toggle = !button_1_toggle;
  }

  if (!button_2_current && button_2_prev != button_2_current) {
    button_2_toggle = !button_2_toggle;
  }

  if (!button_3_current && button_3_prev != button_3_current) {
    button_3_toggle = !button_3_toggle;
  }
  button_1_prev = button_1_current;
  button_2_prev = button_2_current;
  button_3_prev = button_3_current;
  
  // explicitly do not send carriage returns
  // Serial.print("DIST:" + String(getDistance()) + "\n" );
  // Serial.print("POT:" + String(analogRead(POT_PIN)) + "\n");
  Serial.print("BUTTON:" + String(getButtonState()) + "\n" );
}

float getDistance() {
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  unsigned long duration = pulseIn(ECHO_PIN, HIGH);
  return ((float) duration / 2) / 29.1;
}

int getButtonState() {
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
