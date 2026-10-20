const int TX_PIN = 2;  // 发送引脚
const int RX_PIN = 3;  // 接收引脚
const long BIT_DELAY = 104;  // 9600波特率对应的位延迟(微秒)

char inputBuffer[64];  // 接收缓冲区
int bufferIndex = 0;   // 缓冲区索引
unsigned long lastSendTime = 0;  // 上次发送时间

void setup() {
  pinMode(TX_PIN, OUTPUT);
  pinMode(RX_PIN, INPUT);
  digitalWrite(TX_PIN, HIGH);  // 空闲状态为高电平
}

void loop() {
  // 尝试接收数据
  int receivedChar = uartReceive();
  if (receivedChar != -1) {
    if (bufferIndex < sizeof(inputBuffer) - 1) {
      inputBuffer[bufferIndex++] = receivedChar;
      
      // 检测到换行符时处理字符串
      if (receivedChar == '\n') {
        inputBuffer[bufferIndex] = '\0';  // 添加字符串结束符
        sendEchoResponse();
        bufferIndex = 0;  // 重置缓冲区
      }
    } else {
      // 缓冲区溢出处理
      bufferIndex = 0;
    }
  }
  
  // 每5秒发送一次时间
  if (millis() - lastSendTime >= 5000) {
    sendTimeData();
    lastSendTime = millis();
  }
}

// UART接收函数
int uartReceive() {
  if (digitalRead(RX_PIN) == HIGH) return -1;  // 无起始位
  
  // 检测到起始位（低电平）
  noInterrupts();  // 禁用中断确保时序准确
  delayMicroseconds(BIT_DELAY / 2);  // 半位延迟采样
  
  // 验证起始位
  if (digitalRead(RX_PIN)) {
    interrupts();
    return -1;
  }
  
  // 读取8位数据
  char data = 0;
  for (int i = 0; i < 8; i++) {
    delayMicroseconds(BIT_DELAY);
    data |= (digitalRead(RX_PIN) << i);
  }
  
  // 等待停止位
  delayMicroseconds(BIT_DELAY);
  interrupts();
  return data;
}

// UART发送单字节
void uartSend(char data) {
  noInterrupts();
  digitalWrite(TX_PIN, LOW);  // 起始位
  delayMicroseconds(BIT_DELAY);
  
  // 发送8位数据
  for (int i = 0; i < 8; i++) {
    digitalWrite(TX_PIN, data & 1);
    data >>= 1;
    delayMicroseconds(BIT_DELAY);
  }
  
  digitalWrite(TX_PIN, HIGH);  // 停止位
  delayMicroseconds(BIT_DELAY);
  interrupts();
}

// 发送字符串
void uartSendString(const char *str) {
  while (*str) {
    uartSend(*str++);
  }
}

// 发送时间信息
void sendTimeData() {
  char timeMsg[32];
  sprintf(timeMsg, "Uptime: %lu ms\n", millis());
  uartSendString(timeMsg);
}

// 发送回显响应
void sendEchoResponse() {
  char response[96];
  sprintf(response, "Echo: %s [Time: %lu ms]\n", inputBuffer, millis());
  uartSendString(response);
}