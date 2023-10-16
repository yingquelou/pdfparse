#ifndef PATH_H
#define PATH_H 1
#ifdef __cplusplus
extern "C" {
#endif
char *getCurrent_path();
char *getParentDir(const char *PathArg);
char *createPath(const char *parent, const char *child);
#ifdef __cplusplus
}
#endif
#endif