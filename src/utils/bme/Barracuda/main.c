/* main.c */

/* Nuke: A program to completely wipe drives of its contents, by writing
 * zeroes and random bytes */

/*
 *    Copyright (C) 2020 Jithin Renji
 *
 *    This file is part of Nuke.
 *
 *    Nuke is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Nuke is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Nuke.  If not, see <https://www.gnu.org/licenses/>.
 */

#ifndef linux
    #error "Nuke is currently only supported on Linux."
#endif

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

#include <getopt.h>

#include "colors.h"
#include "nuke.h"

void usage(const char* progname);
void version(const char* progname);


int main(int argc, char** argv)
{
    if (argc < 2) {
        usage(argv[0]);
        exit(EXIT_FAILURE);
    } else {
        struct option long_opt[] = {
            {"zero",        no_argument,            0, 'z'},
            {"repeat",      required_argument,      0, 'n'},
            {"yes",         no_argument,            0, 'Y'},
            {"help",        no_argument,            0, 'h'},
            {"version",     no_argument,            0, 'V'},
            {0,             0,                      0,  0}
        };

        int opt_index = 0;

        int opt = 0;

        /* If set, don't write random bytes */
        int only_zero = 0;

        /* Number of times to repeat the procedure */
        int nreps = 1;

        /* If unset, don't ask for confirmation */
        int ask_confirm = 1;

        while ((opt = getopt_long(argc, argv, "z0n:YhV", long_opt,
                &opt_index)) != -1) {
            switch (opt) {
            case '0':
            case 'z':
                only_zero = 1;
                break;
            case 'n':
                nreps = atoi(optarg);
                break;
            case 'Y':
                ask_confirm = 0;
                break;
            case 'h':
                usage(argv[0]);
                exit(EXIT_SUCCESS);

            case 'V':
                version(argv[0]);
                exit(EXIT_SUCCESS);

            case '?':
                exit(EXIT_FAILURE);
            default:
                break;
            }
        }

        char** drvs = argv + optind;

        if (only_zero == 1 && argc < 3) {
            printf("Please specify at least one drive.\n");
            exit(EXIT_FAILURE);
        }

        printf("List of drives to be nuked:\n");

        while (*drvs != NULL) {
            printf(B_GREEN "\t%s\n" RESET, *drvs);
            ++drvs;
        }
        printf("\n");
        drvs = argv + optind;

        srand(time(NULL));
        while (*drvs != NULL) {
            int ret = nuke(*drvs, only_zero, nreps, ask_confirm);
            if (ret == -1) {
                exit(EXIT_FAILURE);
            }
            ++drvs;
        }
    }

    return 0;
}

void usage(const char* progname)
{
    printf("Usage: %s <drive 1> [drive 2] ...\n\n", progname);

    printf("Destroy the contents of a drive/drives.\n\n");

    printf("Options:\n"
           "\t-z, -0, --zero\tDon't write random bytes to drive\n"
           "\t-n, --repeat\tNumber of times to repeat the process (defaults to 1)\n"
           "\t-Y, --yes\tDon't ask for confirmation " B_WHITE "(NOT RECOMMENDED!)\n" RESET
           "\t-h, --help\tDisplay this help and exit\n"
           "\t-v, --version\tDisplay version information and exit\n\n"
           "Examples:\n"
           "\tnuke /dev/sdb\n"
           "\tnuke /dev/sdb /dev/sdc\n"
           "\tnuke -z /dev/sdb\n"
           "\tnuke -n 2 /dev/sdb\n\n");

    printf("NOTE: This program requires root privileges to run.\n");
}

void version(const char* progname)
{
    printf(
"%s v0.1\n"
"Copyright (C) 2020 Jithin Renji.\n"
"License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n"
"This is free software: you are free to change and redistribute it.\n"
"There is NO WARRANTY, to the extent permitted by law.\n\n"

"Written by Jithin Renji\n", progname
    );
}
