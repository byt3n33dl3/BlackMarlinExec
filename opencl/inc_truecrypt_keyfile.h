/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#ifndef INC_TRUECRYPT_KEYFILE_H
#define INC_TRUECRYPT_KEYFILE_H

DECLSPEC u32 u8add (const u32 a, const u32 b);
DECLSPEC u32 hc_apply_keyfile_tc (PRIVATE_AS u32 *w, const int pw_len, const GLOBAL_AS tc_t *tc);

#endif // INC_TRUECRYPT_KEYFILE_H
