#define IN1 8
#define IN2 7
#define ENA 3
unsigned int record=0;
unsigned int mode=0;
unsigned int phase=0;
unsigned int value=0;

void setup() {
  Serial.begin(9600);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(ENA, OUTPUT);
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  analogWrite(ENA, 0);
  record=millis();
  Serial.println("电机自动控制启动");
  Serial.println("开始正方向加速");
}

void loop() {
  phase=millis()-record;
  switch(mode){
    case 0:
      if(phase<3000){
        int speed=map(phase, 0, 3000, 0, 255);
        analogWrite(ENA, speed);
        digitalWrite(IN1, HIGH);
        digitalWrite(IN2, LOW);
      }
      else{
        record=millis();
        mode++;
        Serial.println("加速完毕，开始正方向匀速");
      }
      break;
    case 1:
      if(phase<3000) analogWrite(ENA, 255);
      else{
        record=millis();
        mode++;
        analogWrite(ENA, 0);
        Serial.println("换向");
      }
      break;
    case 2:
      if(phase>=500){
        record=millis();
        mode++;
        Serial.println("开始反方向加速");
      }
      break;
    case 3:
      if(phase<3000){
        int speed=map(phase, 0, 3000, 0, 255);
        analogWrite(ENA, speed);
        digitalWrite(IN1, LOW);
        digitalWrite(IN2, HIGH);
      }
      else{
        record=millis();
        mode++;
        Serial.println("加速完毕，开始反方向匀速");
      }
      break;
    case 4:
      if(phase<3000) analogWrite(ENA, 255);
      else{
        record=millis();
        mode++;
        analogWrite(ENA, 0);
        Serial.println("进入串口调试模式");
        Serial.println("请输入占空比(%): ");
      }
      break;
    case 5:
      if(Serial.available()>0){
        String input=Serial.readStringUntil('\n');
        value=input.toInt();
        if(value>=0 && value<=100){
          int pwmvalue = map(value, 0, 100, 0, 255);
          digitalWrite(IN1, HIGH);
          digitalWrite(IN2, LOW);
          analogWrite(ENA, pwmvalue);
          Serial.print("设置占空比为: ");
          Serial.print(value);
          Serial.println("%");
        }
        else Serial.println("Input Error!");
      }
  }
}