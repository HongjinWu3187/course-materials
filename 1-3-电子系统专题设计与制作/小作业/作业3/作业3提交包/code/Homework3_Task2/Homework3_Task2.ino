#include <OneButton.h>
#define BUTTON_PIN 2
#define LIGHT_PIN 10
OneButton button(BUTTON_PIN, true, true);
int current_brightness=0;
bool breathing_state=false;
bool const_state=true;
unsigned long current_time=0;
unsigned long last_record=0;
int breath_direction=1;

void oneclick(){
  const_state=true;
  breathing_state=false;
  switch(current_brightness){
    case 0: current_brightness=30; break;
    case 30: current_brightness=100; break;
    case 100: current_brightness=200; break;
    case 200: current_brightness=0; break;
    default: current_brightness=30;break;
  }
  analogWrite(LIGHT_PIN,current_brightness);
}

void doubleclick(){
  current_brightness=0;
  const_state=true;
  breathing_state=false;
  analogWrite(LIGHT_PIN,current_brightness);
}

void longpress(){
  if(breathing_state){
    breathing_state=false;
    const_state=true;
    current_brightness=0;
  }
  else{
    breathing_state=true;
    const_state=false;
  }
}

void breathinglight(){
  current_time=millis();
  if(current_time-last_record>=30){
    last_record=current_time;
    current_brightness+=5*breath_direction;
    if(current_brightness>255||current_brightness<0){
      breath_direction*=-1;
      current_brightness+=5*breath_direction;
    }
    analogWrite(LIGHT_PIN,current_brightness);
  }
}

void setup() { 
  pinMode(LIGHT_PIN, OUTPUT);
  analogWrite(LIGHT_PIN, 0);
  button.attachClick(oneclick);
  button.attachLongPressStart(longpress);
  button.attachDoubleClick(doubleclick);
} 
 
void loop() {
  button.tick();
  if(breathing_state) breathinglight();
  else analogWrite(LIGHT_PIN,current_brightness);
}