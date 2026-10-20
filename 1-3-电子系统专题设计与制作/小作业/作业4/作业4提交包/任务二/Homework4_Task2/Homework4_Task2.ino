#include <Wire.h>
#include <Adafruit_SSD1306.h>
#include <Adafruit_GFX.h>
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
String inputString = "";
bool stringComplete = false;

void setup() {
  Serial.begin(9600);
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("OLED init failed");
    while(1);
  }
  displayWelcome();
  Serial.println("System ready. Enter text to display on OLED.");
}

void loop() {
  if (stringComplete) {
    displayMessage(inputString);
    inputString = "";
    stringComplete = false;
  }
}

void serialEvent() {
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    if (inChar == '\n') {
      stringComplete = true;
    } 
    else if (inChar != '\r') {
      inputString += inChar;
    }
  }
}

void displayWelcome() {
  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  int16_t x, y;
  uint16_t w, h;
  display.getTextBounds("WELCOME", 0, 0, &x, &y, &w, &h);
  uint8_t displayX = (SCREEN_WIDTH - w) / 2;
  uint8_t displayY = (SCREEN_HEIGHT - h) / 2;
  display.setCursor(displayX, displayY);
  display.print("WELCOME");
  display.display();
  delay(2000);
}

void displayMessage(String message) {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.print("Received: ");
  display.setTextSize(2);
  int yPos = 20;
  int charWidth = 12;
  String currentLine = "";
  for (int i=0; i<message.length(); i++) {
    char c = message[i];
    if (c == '\n' || currentLine.length() * charWidth > SCREEN_WIDTH - 10) {
      display.setCursor(0, yPos);
      display.print(currentLine);
      currentLine = "";
      yPos += 20;
      if (yPos > SCREEN_HEIGHT - 10) break;
    }
    if (c != '\n' && c != '\r') {
      currentLine += c;
    }
  }
  if (currentLine.length() > 0 && yPos <= SCREEN_HEIGHT - 10) {
    display.setCursor(0, yPos);
    display.print(currentLine);
  }
  display.display();
}