#ifndef BARRACUDA_H
#define BARRACUDA_H

#include <sys/types.h>

int nuke(const char* drv, int only_zero, int nreps, int ask_confirm);
int confirm(const char* drv);
void clear_drv(int fd_drv, size_t count, size_t bs, off_t seek_loc);
void rand_drv(int fd_drv, size_t count, size_t bs, off_t seek_loc);

#endif
