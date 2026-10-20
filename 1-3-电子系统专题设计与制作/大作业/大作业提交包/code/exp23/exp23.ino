#include <U8g2lib.h>
#include <Servo.h>
#include <OneButton.h>
#include <math.h>

// 引脚定义
#define REV 1560
#define ENA 2
#define ENB 3
#define BUTTON_PIN 4
#define BLUE_PIN 5
#define GREEN_PIN 6
#define BUTTON2_PIN 7
#define BUZZER_PIN 8
#define SERVO_PIN 9
#define RED_PIN 11
#define TRIG_PIN 12
#define ECHO_PIN 13

// 音符定义
#define NOTE_C4  262
#define NOTE_D4  294
#define NOTE_E4  330
#define NOTE_F4  349
#define NOTE_G4  392
#define NOTE_A4  440
#define NOTE_B4  494
#define NOTE_C5  523

// 各模块初始化
U8G2_SH1106_128X64_NONAME_1_HW_I2C u8g2(U8G2_R0, U8X8_PIN_NONE, SCL, SDA);
OneButton button(BUTTON_PIN, true, true);
OneButton button2(BUTTON2_PIN, true, true);
Servo myservo;

// 所需全局变量
const char* menuItems[] = {
  "Rangefinder",
  "Voltage Meter",
  "Oscilloscope",
  "Music Player",
  "Flashlight"
};
long int count=0;  // 电机计数
uint8_t currentstate=0;
// currentstate对应功能：0 开始欢迎 1 菜单 2 测距 3 测电压 4 示波器 5 音乐 6 手电筒
uint8_t functionstate=0;
/* functionstate对应功能：(短横线前数字代表currentstate，后数字代表functionstate)
2-0 测距 2-1 阈值调节
4-0 A0 4-1 A1 4-2 A2 4-3 A3
5-0 第一首 5-1 第二首 5-2 第三首
6-0 LED熄灭 6-1 LED微蓝 6-2 微白 6-3最白 */
uint8_t select=0;  // 用来表示选中的功能序号
uint8_t currentnote=0;  // 用来记录当前播放的音符位置
uint8_t playstate=0;
// playstate对应状态：0 停止 1 音符播放中 2 音符播放毕，即将开启下一音符 3 暂停
unsigned int notestart=0; // 时间戳，用来记录呼吸灯中开始输出该亮度、蜂鸣器开始嘀、红灯输出高电平、或音乐模式中开始播放该音符的时间
unsigned int stoppoint=0; // 时间戳，用来记录音乐模式中暂停的时刻
uint8_t progress=0; // 音乐模式中进度条进度
uint8_t lastprogress=0; // 用来记录上次暂停时的进度条进度
uint8_t currentx=10; // 用来记录目前所处的横坐标位置
uint8_t coordinates[118]={}; // 用来存储清屏之前所有的y轴坐标数据
uint8_t threshold=15; // 测距仪模式的阈值
int brightness=0; // 呼吸灯当前输出亮度
int8_t breathdirection=-1; // 呼吸灯呼吸方向
int interval=1000; // 距离大于阈值时，红灯闪烁和蜂鸣器嘀嘀嘀的间隔
bool ifwarn=false; // 距离大于阈值时，判断此时应闪灯嘀嘀还是不闪不嘀
int animState = 0; // 0 未开始 1 滑入中 2 滑出中 3 完成
int animPos = -50; // 文本的初始位置（屏幕左侧外）
unsigned long animLastUpdate = 0; // 上次动画更新的时间
const int ANIM_SPEED = 20; // 动画速度（毫秒）

// 电机四倍频计数函数1
void count1(){
  if(digitalRead(ENA)==digitalRead(ENB)) count++;
  else count--;
}

// 电机四倍频计数函数2
void count2(){
  if(digitalRead(ENA)==digitalRead(ENB)) count--;
  else count++;
}

// 按钮1双击绑定函数
void doubleclick(){
  Serial.println(F("Button1 Doubleclicked"));
  if(select!=0) currentstate=select+1;
  select=0;
}

// 按钮1长按绑定函数
void longpress(){
  Serial.println(F("Button1 Longpressed"));
  select=0;
  count=0;
  functionstate=0;
  if(currentstate==3||currentstate==0){
    currentstate=1;
  }
  else if(currentstate==2 || currentstate==6){
    currentstate=1;
    breathdirection=-1;
    brightness=0;
    noTone(BUZZER_PIN);
    analogWrite(BLUE_PIN, 0); analogWrite(GREEN_PIN, 0); analogWrite(RED_PIN, 0);
  }
  else if(currentstate==4){
    currentstate=1;
    currentx=10;
  }
  else if(currentstate==5){
    noTone(BUZZER_PIN);
    currentstate=1;
    playstate=0;
  }
}

// 按钮2单击绑定函数
void click2(){
  Serial.println(F("Button2 Clicked"));
  switch(currentstate){
    case 4: functionstate=(functionstate+1)%4; currentx=10; break;
    case 5: 
      if(playstate==0) playstate=2;
      else if(playstate==3){
        playstate=2;
        lastprogress=progress;
      }
      else{
        playstate=3;
        stoppoint=millis();
        noTone(BUZZER_PIN);
        digitalWrite(GREEN_PIN, LOW);
      }
      break;
    case 6: functionstate=(functionstate+1)%4; break;
  }
}

// 按钮2双击绑定函数
void doubleclick2(){
  Serial.println("Button2 Doubleclicked");
  switch(currentstate){
    case 6: functionstate=0; break;
  }
}

// 按钮2长按绑定函数
void longpress2(){
  Serial.println("Button2 Longpressed");
  if(currentstate==2){
    functionstate=(functionstate+1)%2;
    brightness=0;
    breathdirection=-1;
    analogWrite(BLUE_PIN, 0); analogWrite(GREEN_PIN, 0); analogWrite(RED_PIN, 0);
    noTone(BUZZER_PIN);
  }
  if(currentstate==5){
    functionstate=(functionstate+1)%3;
    currentnote=0;
  }
}

// 旋转电机选取状态函数
int calculatestate(){
  float currentangle=fmod((count*360.0)/REV, 360.0);
  if(currentangle<0) currentangle+=360.0;
  if(currentangle<60) return 0;
  else if(currentangle<120) return 1;
  else if(currentangle<180) return 2;
  else if(currentangle<240) return 3;
  else if(currentangle<300) return 4;
  else if(currentangle<=360) return 5;
}

// 绘制实心箭头函数
void drawFilledArrow(int x, int y, int size) {
  u8g2.drawBox(x+size/2, y-1, size/2, 3);
  u8g2.drawTriangle(x, y, x+size/2, y-size/3, x+size/2, y+size/3);
}

// 用超声波模块获取距离（单位：厘米）
double getdistance(){
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  int duration=pulseIn(ECHO_PIN, HIGH, 6000);
  return ((double)duration)*0.034/2;
}

void setup() {
  Serial.begin(9600);
  pinMode(ENA, INPUT_PULLUP);
  pinMode(ENB, INPUT_PULLUP);
  pinMode(BLUE_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(RED_PIN, OUTPUT);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  analogWrite(BLUE_PIN, 0);
  analogWrite(GREEN_PIN, 0);
  analogWrite(RED_PIN, 0);
  attachInterrupt(0, count1, CHANGE);
  attachInterrupt(1, count2, CHANGE);
  button.attachDoubleClick(doubleclick);
  button.attachLongPressStart(longpress);
  button2.attachClick(click2);
  button2.attachDoubleClick(doubleclick2);
  button2.attachLongPressStart(longpress2);
  u8g2.begin();
  u8g2.setFont(u8g2_font_7x14_tf);
  u8g2.setFontRefHeightExtendedText();
  u8g2.setDrawColor(1);
  u8g2.setFontPosTop();
  myservo.attach(SERVO_PIN);
  myservo.write(10);
  Serial.println(F("System Begin"));
}

void loop() {
  if(currentstate==1) select=calculatestate();
  button.tick();
  button2.tick();
  switch(currentstate){
    case 0: displaystartup(); break;
    case 1: displaymenu(); break;
    case 2: rangefinder(); break;
    case 3: voltage(); break;
    case 4: oscilloscope(); break;
    case 5: music(); break;
    case 6: flashlight(); break;
  }
  delay(10);
}

void displaystartup(){
  int textWidth=u8g2.getStrWidth("HELLO");
  unsigned long currentTime=millis();
  if(currentTime-animLastUpdate<ANIM_SPEED) return;
  animLastUpdate=currentTime;
  if(animState==0){
    animState=1;
    animPos=-textWidth;
  }
  else if(animState==1){
    animPos+=5;
    if(animPos>=(128-textWidth)/2){
      animState=2;
    }
  }
  else if(animState==2){
    animPos+=5;
    if(animPos>128){
      animState=3;
      animPos=-textWidth;
    }
  }
  else if(animState==3){
    animState=0;
    return;
  }
  u8g2.firstPage();
  do{
    u8g2.setFont(u8g2_font_unifont_tr);
    u8g2.drawStr(animPos, 20, "HELLO");
  } while (u8g2.nextPage());
}

void displaymenu(){
  u8g2.firstPage();
  do{
    u8g2.setFont(u8g2_font_unifont_tr);
    int textWidth=u8g2.getStrWidth("MENU");
    u8g2.drawStr((128-textWidth)/2, 0, "MENU");
    button.tick();
    for(int i=0; i<=4; i++){
      u8g2.drawStr(4, 12+i*10, menuItems[i]);
      button.tick();
    }
    if(select!=0) drawFilledArrow(112, 19+(select-1)*10, 10);
    button.tick();
  } while(u8g2.nextPage());
}

void rangefinder(){
  double distancevalue=getdistance();
  char distancenumber[3]="";
  char thresholdnumber[3]="";
  float currentangle=0;
  if(functionstate){
    currentangle=(count*360.0)/REV;
    if(threshold>=10 && threshold<=50){
      threshold=15+floor(currentangle/30);
      if(threshold<10) threshold=10;
      else if(threshold>50) threshold=50;
    }
    if(millis()-notestart>5){
      if(brightness==0 || brightness==100) breathdirection=-1*breathdirection;
      brightness=brightness+breathdirection*5;
    }
    analogWrite(BLUE_PIN, brightness);
  }
  else{
    if(distancevalue<threshold){
      analogWrite(GREEN_PIN, 0);
      interval=map(distancevalue, 0, threshold, 50, 2000);
      if(millis()-notestart>=interval){
        if(ifwarn){
          digitalWrite(RED_PIN, HIGH); tone(BUZZER_PIN, NOTE_A4, interval);
        }
        else{
          analogWrite(RED_PIN, 0); noTone(BUZZER_PIN);
        }
        notestart=millis();
        ifwarn=!ifwarn;
      }
    }
    else{
      noTone(BUZZER_PIN);
      analogWrite(RED_PIN, 0);
      analogWrite(GREEN_PIN, 200);
    }
  }
  if(distancevalue>0 && distancevalue<=1.0) dtostrf(distancevalue, 4, 2, distancenumber);
  else if(distancevalue<=10.0) dtostrf(distancevalue, 3, 1, distancenumber);
  else if(distancevalue<=100.0) dtostrf(distancevalue, 2, 0, distancenumber);
  snprintf(thresholdnumber, sizeof(thresholdnumber), "%d", threshold);
  u8g2.firstPage();
  do{
    u8g2.setFont(u8g2_font_unifont_tr);
    int textWidth=u8g2.getStrWidth("Rangefinder");
    u8g2.drawStr((128-textWidth)/2, 0, "Rangefinder");
    textWidth=u8g2.getStrWidth(distancenumber);
    u8g2.drawStr((128-textWidth)/2-12, 25, distancenumber);
    u8g2.drawStr(70, 25, "cm");
    u8g2.drawStr(0, 50, thresholdnumber);
    u8g2.drawStr(30, 50, "cm");
  } while(u8g2.nextPage());
}


void voltage() {
  float voltagevalue = analogRead(A0)*5.0/1023.0;
  int servoangle=map(analogRead(A0), 0, 1023, 10, 170);
  myservo.write(servoangle);
  char voltagenumber[6] = "";
  dtostrf(voltagevalue, 4, 2, voltagenumber);
  u8g2.firstPage();
  do {
    u8g2.setFont(u8g2_font_unifont_tr);
    int textWidth = u8g2.getStrWidth("Voltage Meter");
    u8g2.drawStr((128-textWidth) / 2, 0, "Voltage Meter");
    textWidth=u8g2.getStrWidth(voltagenumber);
    u8g2.drawStr((128-textWidth)/2-6, 18, voltagenumber);
    u8g2.drawStr((128+textWidth)/2+2, 18, "V");
    int centerX=64;
    int centerY=60;  // 表盘中心位置
    int radius=25;   // 表盘半径
    u8g2.drawCircle(centerX, centerY, radius, U8G2_DRAW_ALL);
    for (int i=0; i<=10; i++){
      float angle = map(i, 0, 10, 210, 330)*PI/180.0;
      int x1=centerX+(radius-5)*cos(angle);
      int y1=centerY+(radius-5)*sin(angle);
      int x2=centerX+radius*cos(angle);
      int y2=centerY+radius*sin(angle);
      u8g2.drawLine(x1, y1, x2, y2);
    }
    u8g2.setFont(u8g2_font_5x7_tr);
    u8g2.drawStr(centerX-30, centerY-15, "0");
    u8g2.drawStr(centerX+30, centerY-15, "5");
    float angle=map(voltagevalue, 0, 5, 210, 330)*PI/180.0;
    int pointerX=centerX+(radius-5)*cos(angle);
    int pointerY=centerY+(radius-5)*sin(angle);
    u8g2.drawLine(centerX, centerY, pointerX, pointerY);
    u8g2.drawDisc(centerX, centerY, 2);
  } while (u8g2.nextPage());
}

void oscilloscope(){
  int readvoltage=analogRead(A0);
  int temp1; int temp2;
  char *channel="";
  switch(functionstate){
    case 0: channel="A0"; readvoltage=analogRead(A0); break;
    case 1: channel="A1"; readvoltage=analogRead(A1); break;
    case 2: channel="A2"; readvoltage=analogRead(A2); break;
    case 3: channel="A3"; readvoltage=analogRead(A3); break;
  }
  int yvalue=map(readvoltage, 0, 1023, 40, 16);
  coordinates[currentx-10]=yvalue;
  temp1=coordinates[currentx-11]; temp2=coordinates[currentx-10];
  u8g2.firstPage();
  do{
    u8g2.setFont(u8g2_font_unifont_tr);
    int textWidth=u8g2.getStrWidth("Oscilloscope");
    u8g2.drawStr((128-textWidth)/2, 0, "Oscilloscope");
    textWidth=u8g2.getStrWidth(channel);
    u8g2.drawStr((128-textWidth)/2, 50, channel);
    u8g2.drawLine(10, 16, 10, 63);
    u8g2.drawLine(0, 40, 127, 40);
    u8g2.drawLine(10, 16, 8, 18); u8g2.drawLine(10, 16, 12, 18);
    u8g2.drawLine(127, 40, 125, 38); u8g2.drawLine(127, 40, 125, 42);
    for(int i=11; i<=currentx; i++){
      u8g2.drawLine(i-1, coordinates[i-11], i, coordinates[i-10]);
    }
  } while(u8g2.nextPage());
  currentx=10+(currentx-9)%118;
  delay(10);
}

void music(){
  int melody0[7]={NOTE_C4, NOTE_C4, NOTE_G4, NOTE_G4, NOTE_A4, NOTE_A4, NOTE_G4}; uint8_t len0=7;
  int melody1[8]={NOTE_E4, NOTE_E4, NOTE_F4, NOTE_G4, NOTE_G4, NOTE_F4, NOTE_E4, NOTE_D4}; uint8_t len1=8;
  int melody2[8]={NOTE_C4, NOTE_D4, NOTE_E4, NOTE_C4, NOTE_C4, NOTE_D4, NOTE_E4, NOTE_C4}; uint8_t len2=8;
  int *melody; uint8_t len=0;
  switch(functionstate){
    case 0: melody=melody0; len=len0; break;
    case 1: melody=melody1; len=len1; break;
    case 2: melody=melody2; len=len2; break;
  }
  if(playstate==1){
    if(millis()-notestart>=600){
      currentnote++; playstate=2;
    }
    if(millis()-notestart>=200){
      digitalWrite(GREEN_PIN, LOW);
    }
  }
  if(playstate==2){
    if(currentnote>=len){
      playstate=0;
      currentnote=0;
      functionstate=(functionstate+1)%3;
      lastprogress=0;
      return;
    }
    tone(BUZZER_PIN, melody[currentnote], 600);
    digitalWrite(GREEN_PIN, HIGH);
    notestart=millis();
    playstate=1;
  }
  if(playstate==3) progress=map(currentnote*600+(stoppoint-notestart), 0, len*600, 0, 100);
  else progress=map(currentnote*600+(millis()-notestart), 0, len*600, 0, 100);
  u8g2.firstPage();
  do{
    u8g2.setFont(u8g2_font_unifont_tr);
    int textWidth=u8g2.getStrWidth("Music Player");
    u8g2.drawStr((128-textWidth)/2, 0, "Music Player");
    if(playstate!=0){
      switch(functionstate){
        case 0: u8g2.drawStr(0, 20, "1. Little Star"); break;
        case 1: u8g2.drawStr(0, 20, "2. Ode to Joy"); break;
        case 2: u8g2.drawStr(0, 20, "3. Two Tigers"); break;
      }
      u8g2.drawFrame(12, 40, 104, 15);
      if(playstate==3) u8g2.drawBox(14, 42, progress, 11);
      else{
        if(progress>lastprogress) u8g2.drawBox(14, 42, progress, 11);
        else u8g2.drawBox(14, 42, lastprogress, 11);
      }
    }
  } while(u8g2.nextPage());
}

void flashlight(){
  u8g2.firstPage();
  do{
    u8g2.setFont(u8g2_font_unifont_tr);
    int textWidth=u8g2.getStrWidth("Flashlight");
    u8g2.drawStr((128-textWidth)/2, 0, "Flashlight");
    button2.tick();
  } while(u8g2.nextPage());
  switch(functionstate){
    case 0: analogWrite(BLUE_PIN, 0); analogWrite(GREEN_PIN, 0); analogWrite(RED_PIN, 0); break;
    case 1: analogWrite(BLUE_PIN, 50); analogWrite(GREEN_PIN, 0); analogWrite(RED_PIN, 0); break;
    case 2: analogWrite(BLUE_PIN, 50); analogWrite(GREEN_PIN, 50); analogWrite(RED_PIN, 50); break;
    case 3: analogWrite(BLUE_PIN, 255); analogWrite(GREEN_PIN, 255); analogWrite(RED_PIN, 255); break;
  }
}