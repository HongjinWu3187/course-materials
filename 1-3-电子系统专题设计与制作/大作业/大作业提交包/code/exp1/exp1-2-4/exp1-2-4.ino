#include <Servo.h>
#define ENA 2
#define ENB 3
#define SERVO_PIN 9

Servo myservo;
const int rev=13*30*4;
long int count=0;
float currentangle=0;
float servoangle=0;

void count1(){
  if(digitalRead(ENA)==digitalRead(ENB)){
    count++;
  }
  else{
    count--;
  }
}

void count2(){
  if(digitalRead(ENA)==digitalRead(ENB)){
    count--;
  }
  else{
    count++;
  }
}

void setup(){
  pinMode(ENA, INPUT);
  pinMode(ENB, INPUT);
  attachInterrupt(0, count1, CHANGE);
  attachInterrupt(1, count2, CHANGE);
  myservo.attach(SERVO_PIN);
  myservo.write(0);
}

void loop(){
  currentangle=fmod((count*360.0)/rev, 360.0);
  if(currentangle<0) currentangle+=360.0;
  servoangle=map(currentangle, 0, 360, 0, 180);
  myservo.write(servoangle);
  delay(50);
}