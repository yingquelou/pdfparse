#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define BUFFERSIZE 1024
static char buffer[BUFFERSIZE + 1];
int seekSteam(FILE *f)
{
    size_t ct = 0;
    char *pos = NULL;
    long offset = 0;
    while ((ct = fread(buffer, 1, BUFFERSIZE, f)) > 0)
    {
        if (pos = strstr(buffer, "stream"))
        {
            offset = ct - (pos - buffer) - 6;
            fseek(f, -offset, SEEK_CUR);
            return 1;
        }
    }
    return 0;
}
char *storeStreamToFile(FILE *f, FILE *to)
{
    size_t ct = 0;
    char *pos = NULL;
    long length = 0;
    while ((ct = fread(buffer, 1, BUFFERSIZE, f)) > 0)
    {
        if (pos = strstr(buffer, "endstream"))
        {
            length = pos - buffer;
            fwrite(buffer, 1, length, to);
            length = ct - length - 9;
            fseek(f, -length, SEEK_CUR);
            break;
        }
        else
            fwrite(buffer, 1, ct, to);
    }
}
static char *dir = NULL;
void init()
{
    dir = getenv("userprofile");
}
void configTmpFile()
{

    strcpy(buffer, dir);
    strcat(buffer, "\\storeStreamDir");
    char *tmpName = tmpnam(NULL);
    strcat(buffer, tmpName);
    strcat(buffer, "stream.txt");
}
void test()
{
    FILE *testin = fopen("E:\\desktop\\test1.pdf", "rb"), *to = NULL;
    seekSteam(testin);
    while (seekSteam(testin))
    {
        configTmpFile();
        if (to = fopen(buffer, "w"))
        {
            storeStreamToFile(testin, to);
            fclose(to);
        }
    }
    fclose(testin);
}
int main(int argc, char const *argv[])
{
    init();
    test();
    return 0;
}