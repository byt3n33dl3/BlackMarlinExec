/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#ifndef HC_CPU_CRC32_H
#define HC_CPU_CRC32_H

#include <stdio.h>
#include <errno.h>

int cpu_crc32 (const char *filename, u8 *keytab, const size_t keytabsz);
u32 cpu_crc32_buffer (const u8 *buf, const size_t length);

#endif // HC_CPU_CRC32_H
