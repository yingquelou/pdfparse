#include <stdio.h>
#include <tgmath.h>
void printComplex(complex z)
{
    printf("%.1lf+%.1lfi", creal(z), cimag(z));
}
void checkCosComplex(double a, double b)
{
    complex z = a + b * I;
    printComplex(cos(z));
    printf("<-->");
    printComplex(cos(a) * cosh(b) - I * sin(a) * sinh(b));
}
int main(int argc, char **argv,char **env)
{ 
    double PI = acos(-1), a = 1, b = 1;
    checkCosComplex(a, b);
    printf(env[0]);
    return 0;
}
