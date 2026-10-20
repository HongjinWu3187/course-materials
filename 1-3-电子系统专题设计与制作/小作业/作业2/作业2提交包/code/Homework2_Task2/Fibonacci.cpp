#include <Arduino.h>
#include "Fibonacci.h"

int fi(int n){
  if(n==0||n==1) return 1;
  else return fi(n-1)+fi(n-2);
}