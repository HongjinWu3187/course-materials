#include <Servo.h>
#include <math.h>
#define LED1_PIN 3
#define LED2_PIN 11
#define SERVO_PIN 6
Servo myservo;
float phase=0;
float cosvalue=0;
float shifted_cosvalue=0;

void setup() {
  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  myservo.attach(SERVO_PIN);
  myservo.write(180);
}

void loop() {
  phase=(millis()%2000)/2000.0;
  cosvalue=1+cos(2*PI*phase);
  shifted_cosvalue=1+cos(2*PI*phase+PI/2);
  analogWrite(LED1_PIN, (int)(100*cosvalue));
  analogWrite(LED2_PIN, (int)(100*shifted_cosvalue));
  myservo.write((int)(90*cosvalue));
  delay(10);
}