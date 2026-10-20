#include "stdio.h"

int main() {
  int i, j, temp;
  scanf("%d", &i);
  scanf("%d", &j);
  i = -i;
  if(j < 0) j = -j;
  for(temp = 0; temp < j; ++temp) i += 1;
  printf("%d",i);
  return 0;
}
