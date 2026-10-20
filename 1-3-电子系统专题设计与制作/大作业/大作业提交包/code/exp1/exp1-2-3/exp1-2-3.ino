#include <OneButton.h>
#include <U8g2lib.h>
#include <Wire.h>

#define BUTTON1_PIN 2
#define BUTTON2_PIN 7
OneButton button1(BUTTON1_PIN, true, true);
OneButton button2(BUTTON2_PIN, true, true);

U8G2_SH1106_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, U8X8_PIN_NONE, SCL, SDA);
int target=100;
int width=u8g2.getStrWidth("100");
char str[12]="";

void upclick(){
  target++;
  snprintf(str, sizeof(str), "%d", target);
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_helvB08_tf);
  u8g2.drawStr(0, 20, "The number changed:");
  u8g2.drawStr((128-width)/2-8, 40, str);
  u8g2.sendBuffer();
}

void downclick(){
  target--;
  snprintf(str, sizeof(str), "%d", target);
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_helvB08_tf);
  u8g2.drawStr(0, 20, "The number changed:");
  u8g2.drawStr((128-width)/2-8, 40, str);
  u8g2.sendBuffer();
}

void setup(){
  button1.attachClick(upclick);
  button2.attachClick(downclick);
  u8g2.begin();
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_helvB08_tf);
  u8g2.drawStr(0, 20, "The initial number:");
  u8g2.drawStr((128-width)/2-8, 40, "100");
  u8g2.sendBuffer();
}

void loop(){
  button1.tick();
  button2.tick();
}