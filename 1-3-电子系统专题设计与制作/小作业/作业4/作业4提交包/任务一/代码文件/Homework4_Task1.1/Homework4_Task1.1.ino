unsigned long last_record=0;
unsigned long current_time=0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  if(Serial.available()>0){
    String input=Serial.readStringUntil('\n');
    input.trim();
    Serial.println("Echo: ");
    Serial.println(input);
    Serial.print("Current Time: ");
    Serial.print(millis());
    Serial.println(" ms");
  }
  current_time=millis();
  if(current_time-last_record>=5000){
    last_record=current_time;
    Serial.print("Time Update: ");
    Serial.print(current_time);
    Serial.println(" ms");
  }
}