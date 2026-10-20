#include <TimerOne.h>
int ENC_A=2;int ENC_B=3;int cnt=0;float rpm=0;
float err =0,derr=0,dderr=0;float Kp=0.8,Ki=0.3,Kd=0.5;
float goal =100;int pwm=100;

void count1(){
  if(digitalRead(ENC_B)==LOW) cnt++;
  else cnt--;
}

void count2(){
  if(digitalRead(ENC_B)==HIGH) cnt++;
  else cnt--;
}

void count3(){
  if(digitalRead(ENC_A)==HIGH) cnt++;
  else cnt--;
}

void count4(){
  if(digitalRead(ENC_A)==LOW) cnt++;
  else cnt--;
}

int PID(float goal,float now){
  dderr=goal-now-err-derr;
  derr=goal-now-err;
  err=goal-now;
  float dPWM = Ki*(err)+Kp*(derr)+Kd*(dderr);
  return dPWM;
}

int PWM2=6;
int PWM1=5;

void rotate(int v){
  if(v>0){
    analogWrite(PWM1,255-v);digitalWrite(PWM2,1);
  }
  else{
    analogWrite(PWM1,-v);digitalWrite(PWM2,0);
  }
}

inline void cal(){
  rpm=(((float)cnt)/4.0)/13.0*40.0;
  cnt=0;
  pwm+=PID(goal,rpm);
  pwm=(pwm>255)?255:((pwm<-255)?-255:pwm);
  rotate(pwm);
}

void setup(){
  pinMode(PWM1,OUTPUT);
  pinMode(PWM2,OUTPUT);
  analogWrite(PWM2,0);
  analogWrite(PWM1,155);
  pinMode(ENC_A,INPUT);
  pinMode(ENC_B,INPUT);
  Timer1.initialize(50000);
  Timer1.attachInterrupt(cal);
  attachInterrupt(0,count1,RISING);
  attachInterrupt(0,count2,FALLING);
  attachInterrupt(1,count3,RISING);
  attachInterrupt(1,count4,FALLING);
  Serial.begin(9600);
}

void loop(){
  delay(100);
  Serial.print("rpm:");
  Serial.println(rpm);
  Serial.print("pwm:");
  Serial.println(pwm);
  Serial.print("err:");
  Serial.println(err);
}