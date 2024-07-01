#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <linux/fs.h>

#include <unistd.h>
#include <fcntl.h>

#include "barracuda.h"
#include "colors.h"


int nuke(const char* drv, int only_zero, int nreps, int ask_confirm)
{
    int fd_drv = open(drv, O_RDWR);

    /* Stats */
    struct stat drv_stat;
    unsigned long nblocks_drv = 0;
    long long bytes_drv = 0;

    /* Optimal block size */
    size_t bs = 0;

    if (fd_drv == -1) {
        perror(drv);
        return -1;
    }

    int r_drv = ioctl(fd_drv, BLKGETSIZE, &nblocks_drv);

    if (r_drv == -1) {
        perror(drv);
        return -1;
    }

    fstat(fd_drv, &drv_stat);
    bs = drv_stat.st_blksize;
    bytes_drv = 512 * nblocks_drv;

    int cnfrm = 1;

    if (ask_confirm == 1) {
        cnfrm = confirm(drv);
    }

    if (cnfrm) {
        /* Location to seek to */
        off_t seek_loc = 0;
        for (int i = 0; i < nreps; i++) {
            if (nreps != 1) {
                printf(B_CYAN "STAGE %d:\n" RESET, i + 1);
            }
            clear_drv (fd_drv, bytes_drv, bs, seek_loc);

            if (!only_zero) {
                rand_drv (fd_drv, bytes_drv, bs, seek_loc);
                clear_drv (fd_drv, bytes_drv, bs, seek_loc);
            }
        }
    } else {
        printf("Aborted.\n");
    }

    return 0;
}

int confirm(const char* drv)
{
    printf(B_RED "WARNING: " WHITE "The contents of '%s' "
           B_RED "CANNOT BE RECOVERED " WHITE "after this operation\n\
         and all data on this device will be " B_RED "PERMENANTLY DELETED!\n\n" RESET, drv);

    printf("Do you " B_WHITE "STILL" WHITE " want to continue? [" B_RED "yes" WHITE "/" B_GREEN "NO" RESET "] ");

    char response[512];
    fgets(response, 512, stdin);

    if (strcmp(response, "yes\n") == 0) {
        return 1;
    }

    return 0;
}

void clear_drv(int fd_drv, size_t count, size_t bs, off_t seek_loc)
{
    lseek(fd_drv, seek_loc, SEEK_SET);
    /*
        Number of bytes written, is
        used to calculate the percentage of
        progress
    */
    long double nbytes_written = 0;

    /* Buffer to store 0's to be written */
    char buf[bs];

    memset(buf, 0, sizeof(buf));

    while (nbytes_written != count) {
        int ret = write(fd_drv, buf, bs);

        if (ret == -1) {
            perror("");
            exit(EXIT_FAILURE);
        }

        long double percent = (nbytes_written/count) * 100;

        /* Hide cursor */
        fputs("\e[?25l", stdout);

        printf("\tClearing %ld byte(s). [%.2Lf%%]\r", count, percent);
        fflush(stdout);

        /* Show cursor */
        fputs("\e[?25h", stdout);

        nbytes_written += bs;
    }
    printf("\n");
}

void rand_drv(int fd_drv, size_t count, size_t bs, off_t seek_loc)
{
    lseek(fd_drv, seek_loc, SEEK_SET);
    /* Same as clear_drv() */
    long double nbytes_written = 0;

    /* Buffer to store random bytes */
    char buf[bs];

    while (nbytes_written != count) {
        for (int i = 0; i < bs; i++) {
            buf[i] = rand() % 256;
        }

        int ret = write(fd_drv, buf, bs);

        if (ret == -1) {
            perror("");
            exit(EXIT_FAILURE);
        }

        long double percent = (nbytes_written/count) * 100;

        fputs("\e[?25l", stdout);

        printf("\tWriting %ld random byte(s). [%.2Lf%%]\r", count, percent);
        fflush(stdout);

        fputs("\e[?25h", stdout);

        nbytes_written += bs;
    }
    printf("\n");
}
