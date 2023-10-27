#include "main.h"
// #include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
cJSON *cJSON_ParseFromFile(const char *fileName)
{
    FILE *file = fopen(fileName, "rb");
    cJSON *json = NULL;
    if (file)
    {
        if (fseek(file, 0, SEEK_END))
            return json;
        long length = ftell(file);
        if (length == -1l)
            return json;
        char *buffer = malloc(length + 1);
        if (buffer)
        {
            rewind(file);
            fread(buffer, 1, length, file);
            fclose(file);
            buffer[length] = '\0';
            json = cJSON_Parse(buffer);
            free(buffer);
        }
    }
    return json;
}
int main(int argc, char const *argv[])
{
    cJSON *config = cJSON_ParseFromFile("parseconfig.json");
    char *fileName = NULL, *cache = NULL;
    if (cJSON_IsObject(config))
    {
        cJSON *source;
        if (cJSON_HasObjectItem(config, "source"))
        {
            cJSON *source = cJSON_GetObjectItem(config, "source");
            if (cJSON_IsString(source))
                fileName = cJSON_GetStringValue(source);
        }
        if (cJSON_HasObjectItem(config, "dest"))
        {
            cJSON *dest = cJSON_GetObjectItem(config, "dest");
            if (cJSON_IsString(dest))
                cache = cJSON_GetStringValue(dest);
        }
    }
    if (pdf(fileName, cache))
        perror("please create 'parseconfig.json',it must have the key 'sourse',and maybe have the key 'dest'");
    return 0;
}
