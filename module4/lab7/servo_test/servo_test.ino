#include <Servo.h>

Servo myservo;  // create servo object to control a servo

int potpin = 0;  // analog pin used to connect the potentiometer
int val;    // variable to read the value from the analog pin
int servoVal = 0;

bool increasing = true;

void setup() {
  Serial.begin(9600);
  myservo.attach(13);  // attaches the servo on pin 9 to the servo object
  myservo.write(100);
}

void loop() {
  // val = analogRead(potpin);            // reads the value of the potentiometer (value between 0 and 1023)
  // val = map(val, 0, 1023, 0, 180);     // scale it to use it with the servo (value between 0 and 180)
                  
  if (increasing) {
    if (servoVal >= 180) {
      increasing = false;
      servoVal = 180;
    } else {
      servoVal += 5;
    }
  } else {
    if (servoVal <= 0) {
      increasing = true;
      servoVal = 0;
    } else {
      servoVal -= 5;
    }
  }

  // servoVal = 100;
  myservo.write(servoVal); 
  Serial.println(myservo.read());
  delay(1000);                           // waits for the servo to get there
}