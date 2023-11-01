#include <Stepper.h>
#include <ESP32Servo.h>


Servo myservo; // create servo object to control a servo

const int stepsPerRevolution = 2048; // change this to fit the number of steps per revolution

int stepCount = 0; // Variable to keep track of stepper motor steps
int servoAngle = 0; // Variable to store servo angle

// ULN2003 Motor Driver Pins
#define IN1 19
#define IN2 18
#define IN3 5
#define IN4 17

// initialize the stepper library
Stepper myStepper(stepsPerRevolution, IN1, IN3, IN2, IN4);

void setup() {
  // set the speed at 5 rpm
  myStepper.setSpeed(10);


  myservo.attach(26); // attaches the servo on pin 9 to the servo object
  // initialize the serial port
  Serial.begin(9600);
}


void loop() {


  if (stepCount < stepsPerRevolution) { // Adjust this value according to your stepper motor's steps per rotation
    myStepper.step(4);
    stepCount+=4;
  } else {
    // Reset stepper and move the servo
    stepCount = 0;
    servoAngle += 10;

    // If the servo angle is at 180, reset it to 0
    if (servoAngle >= 180) {
      servoAngle = 0;
    }

    // Move the servo to the desired angle
    myservo.write(servoAngle);
    delay(100); // Delay to allow the servo to reach the desired angle
}


  Serial.print("STEP:");
  Serial.println(stepCount);
  Serial.print("SERVO:");
  Serial.println(servoAngle);
}






