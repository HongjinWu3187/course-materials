#define BLUE_PIN 3
#define GREEN_PIN 5
#define RED_PIN 9
int light=0;

void setup() {
  pinMode(BLUE_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(RED_PIN, OUTPUT);
  analogWrite(BLUE_PIN, 0);
  analogWrite(GREEN_PIN, 0);
  analogWrite(RED_PIN, 0);
}

void loop() {
  analogWrite(GREEN_PIN, 0);
  analogWrite(RED_PIN, 0);
  for(light=0;light<=255;light+=5){
    analogWrite(BLUE_PIN, light);
    delay(25);
  }
  for(light=255;light>=0;light-=5){
    analogWrite(BLUE_PIN, light);
    delay(25);
  }
  analogWrite(BLUE_PIN, 0);
  analogWrite(RED_PIN, 0);
  for(light=0;light<=255;light+=5){
    analogWrite(GREEN_PIN, light);
    delay(25);
  }
  for(light=255;light>=0;light-=5){
    analogWrite(GREEN_PIN, light);
    delay(25);
  }
  analogWrite(GREEN_PIN, 0);
  analogWrite(BLUE_PIN, 0);
  for(light=0;light<=255;light+=5){
    analogWrite(RED_PIN, light);
    delay(25);
  }
  for(light=255;light>=0;light-=5){
    analogWrite(RED_PIN, light);
    delay(25);
  }
}