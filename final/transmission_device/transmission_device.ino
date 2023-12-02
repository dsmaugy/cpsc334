
#define TRIG_PIN 4
#define ECHO_PIN 5
#define POT_PIN 26

void setup() {
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(POT_PIN, INPUT);

  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    String cmd = Serial.readStringUntil('\n');
    if (cmd != NULL) {
      // process command here
      
    } 
  }

  // explicitly do not send carriage returns
  Serial.print("DIST:" + String(getDistance()) + "\n" );
  Serial.print("POT:" + String(analogRead(POT_PIN)) + "\n");
}

float getDistance() {
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  unsigned long duration = pulseIn(ECHO_PIN, HIGH);
  return ((float) duration / 2) / 29.1;
}
