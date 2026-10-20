#include <U8g2lib.h>
#include <Wire.h>
#define ENA 2
#define ENB 3

U8G2_SH1106_128X64_NONAME_1_HW_I2C u8g2(U8G2_R0, U8X8_PIN_NONE, SCL, SDA);
const int rev=13*30*4;
long int count=0;
float currentangle=0;
int progress=0;
char angstr[10]="";
char prostr[10]="";

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
  u8g2.begin();
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_7x14_tf);
  u8g2.setFontRefHeightExtendedText();
  u8g2.setDrawColor(1);
  u8g2.setFontPosTop();
}

void loop(){
  currentangle=fmod((count*360.0)/rev, 360.0);
  if(currentangle<0) currentangle+=360.0;
  progress=map(currentangle, 0, 360, 0, 100);
  dtostrf(currentangle, 5, 1, angstr);
  sprintf(prostr, "%d%%", progress);
  u8g2.firstPage();
  do{
    u8g2.setFont(u8g2_font_7x14B_tf);
    u8g2.drawStr(0, 0, "Angle Indicator:");
    u8g2.setFont(u8g2_font_10x20_tf);
    u8g2.drawStr(15, 20, angstr);
    u8g2.drawStr(75, 20, "deg");
    u8g2.drawFrame(12, 45, 104, 15);
    u8g2.drawBox(14, 47, progress, 11);
  } while(u8g2.nextPage());
}