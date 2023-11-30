void setup() {
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    String cmd = Serial.readStringUntil('\n');
    if (cmd != NULL) {
      // process command here
    } 
  }
}
