#define BUZZER_PIN 9
int low_la=440, doo=523, re=587, mi=659, fa=698, so=784, la=880, xi=988, up_do=1046;
unsigned int s=300, n=600, l=1200;
bool played=true;

void play(int Tone, unsigned int len){
  tone(BUZZER_PIN, Tone);
  delay(len);
  noTone(BUZZER_PIN);
  delay(20);
}

void setup() {
  pinMode(BUZZER_PIN, OUTPUT);
}

void loop() {
  delay(1000);
  if(played){
    play(so, n); play(so, s); play(la, s);
    play(re, l);
    play(doo, n); play(doo, s); play(low_la, s);
    play(re, l);
    play(so, n); play(so, n);
    play(la, s); play(up_do, s); play(la, s); play(so, s);
    play(doo, n); play(doo, s); play(low_la, s);
    play(re, l);
    played=false;
  }
  delay(1000);
}