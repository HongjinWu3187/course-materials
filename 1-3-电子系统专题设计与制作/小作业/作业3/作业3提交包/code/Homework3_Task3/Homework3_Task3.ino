#include <NewPing.h>
#include <OneButton.h>
#define UPBUTTON_PIN 2
#define DOWNBUTTON_PIN 3
#define BLUE_PIN 5
#define GREEN_PIN 6
#define RED_PIN 7
#define ECHO_PIN 11
#define TRIGGER_PIN 12
#define MAX_DISTANCE 200
OneButton upbutton(UPBUTTON_PIN, true, true);
OneButton downbutton(DOWNBUTTON_PIN, true, true);
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);
int threshold=10;
unsigned long last_record=0;
unsigned int redlight=0;
unsigned int length=0;
int redLedState=LOW; 

void upclick(){
  threshold+=1;
  if(threshold<=29){
    Serial.print("Threshold Changed:  ");
    Serial.print(threshold);
    Serial.println("cm");
  }
  else{
    threshold=29;
    Serial.println("Invalid Change: Threshold>=30");
  }
}

void downclick(){
  threshold-=1;
  if(threshold>=1){
    Serial.print("Threshold Changed:  ");
    Serial.print(threshold);
    Serial.println("cm");
  }
  else{
    threshold=1;
    Serial.println("Invalid Change: Threshold<=0");
  }
}

void redblink(unsigned int len){
  digitalWrite(BLUE_PIN, LOW);
  digitalWrite(GREEN_PIN, LOW);
  int interval = map(len, 0, threshold, 50, 500);
  interval = constrain(interval, 50, 500);
  if(millis()-last_record>=interval){
    last_record=millis();
    redLedState=(redLedState==LOW)?HIGH:LOW;
    digitalWrite(RED_PIN, redLedState);
  }
}

void setup() {
  Serial.begin(9600);
  pinMode(BLUE_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(RED_PIN, OUTPUT);
  digitalWrite(GREEN_PIN, LOW);
  digitalWrite(RED_PIN, LOW);
  digitalWrite(BLUE_PIN, LOW);
  upbutton.attachClick(upclick);
  downbutton.attachClick(downclick);
}

void loop() {
  upbutton.tick();
  downbutton.tick();
  length=sonar.ping_cm();
  if(length<=threshold) redblink(length);
  else if(length<=30){
    digitalWrite(GREEN_PIN, LOW);
    digitalWrite(RED_PIN, LOW);
    digitalWrite(BLUE_PIN, HIGH);
  }
  else{
    digitalWrite(BLUE_PIN, LOW);
    digitalWrite(RED_PIN, LOW);
    digitalWrite(GREEN_PIN, HIGH);
  }
  delay(10);
}