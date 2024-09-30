/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#ifndef HC_RESTORE_H
#define HC_RESTORE_H

#include <stdio.h>
#include <unistd.h>
#include <errno.h>

#if defined (_WIN)
#include <windows.h>
#include <psapi.h>
#endif // _WIN

#define RESTORE_VERSION_MIN 600
#define RESTORE_VERSION_CUR 611

int cycle_restore (hashcat_ctx_t *hashcat_ctx);

void unlink_restore (hashcat_ctx_t *hashcat_ctx);

int restore_ctx_init (hashcat_ctx_t *hashcat_ctx, int argc, char **argv);

void restore_ctx_destroy (hashcat_ctx_t *hashcat_ctx);

#endif // HC_RESTORE_H
