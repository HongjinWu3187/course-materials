#include "stdio.h"

int fibonacci(int n)
{
    if (n == 0) {   // 基准情形
        return 0;
    } else if (n == 1) {    // 基准情形
        return 1;
    } else {        // 递归情形
        return fibonacci(n-1) + fibonacci(n-2);
    }
}

int main()
{
    int n;

    scanf("%d", &n);
    printf("%d", fibonacci(n));
    return 0;
}

