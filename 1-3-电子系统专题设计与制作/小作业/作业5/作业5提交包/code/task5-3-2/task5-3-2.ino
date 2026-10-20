const int BUZZER_PIN = 8;
const float TARGET_FREQ = 440;
const unsigned long DURATION = 5000;
volatile unsigned int ocrValue;
volatile unsigned long startTime;
volatile bool buzzerState = false;

ISR(TIMER1_COMPA_vect) {
  unsigned long currentTime = millis();
  if (currentTime - startTime >= DURATION) {
    TIMSK1 &= ~(1 << OCIE1A);  // 禁用定时器比较中断
    digitalWrite(BUZZER_PIN, LOW);
    return;
  }
  buzzerState = !buzzerState;
  digitalWrite(BUZZER_PIN, buzzerState);
}

void setup() {
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  cli();  // 禁用全局中断
  ocrValue = (unsigned int)(F_CPU / (8.0 * TARGET_FREQ * 2) - 1);
  TCCR1A = 0;
  TCCR1B = 0;
  TCNT1  = 0;
  OCR1A = ocrValue;
  // 开启CTC模式 (比较匹配时计数器清零)
  TCCR1B |= (1 << WGM12);
  // 设置分频为8
  TCCR1B |= (1 << CS11);
  // 启用定时器比较匹配中断
  TIMSK1 |= (1 << OCIE1A);
  startTime = millis();
  sei();  // 启用全局中断
  Serial.begin(9600);
  Serial.print("开始播放440Hz音调, 持续5秒");
}

void loop() {

}