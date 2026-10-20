#include "stdio.h"  

int main() {  
    FILE *infile ,*outfile;  
    int i;  
    int *buffer;  
    buffer = new int[2];  
    infile = fopen("a.in", "rb");  
    fread(buffer, 4, 2, infile);  
    fclose(infile);  
    outfile = fopen("a.out", "wb");  
    fwrite(buffer, 4, 2, outfile);  
    fclose(outfile);  
    scanf("%d", &i);  
    i = i + 10;
    printf("%d", i);  
    return 0;
}  
