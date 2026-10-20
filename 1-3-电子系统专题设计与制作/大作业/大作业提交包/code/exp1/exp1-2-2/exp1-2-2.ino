#include <OneButton.h>
#define BLUE_PIN 3
#define GREEN_PIN 5
#define RED_PIN 9
#define BUTTON_PIN 13
OneButton button(BUTTON_PIN, true, true);
bool state=false;
unsigned long record=0;
unsigned int sequence=0;
long int light=0;
unsigned int duration=25;
int breath_direction=1;

void change(){
  state=!state;
  sequence=0;
  breath_direction=1;
  light=0;
}

void breathinglight(){
  if(millis()-record>duration){
    record=millis();
    light+=breath_direction*5;
    if(light>255){
      breath_direction=-1;
      light=255;
    }
    else if(light<0){
      breath_direction=1;
      light=0;
      sequence+=1;
    }
    if(sequence%3==0) analogWrite(BLUE_PIN, light);
    else if(sequence%3==1) analogWrite(GREEN_PIN, light);
    else analogWrite(RED_PIN, light);
  }
}

void setup() {
  pinMode(BLUE_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(RED_PIN, OUTPUT);
  analogWrite(BLUE_PIN, 0);
  analogWrite(GREEN_PIN, 0);
  analogWrite(RED_PIN, 0);
  button.attachLongPressStart(change);
}

void loop() {
  button.tick();
  if(state) breathinglight();
  else{
    analogWrite(BLUE_PIN, 0);
    analogWrite(GREEN_PIN, 0);
    analogWrite(RED_PIN, 0);
  }
}