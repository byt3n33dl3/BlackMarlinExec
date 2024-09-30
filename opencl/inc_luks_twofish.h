/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#ifndef INC_LUKS_TWOFISH_H
#define INC_LUKS_TWOFISH_H

DECLSPEC void twofish128_decrypt_cbc (PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *in, PRIVATE_AS u32 *out, PRIVATE_AS u32 *essiv);
DECLSPEC void twofish256_decrypt_cbc (PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *in, PRIVATE_AS u32 *out, PRIVATE_AS u32 *essiv);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv128 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *out, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv128_mk_sha1 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv128_mk_sha1_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv128_mk_sha256 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv128_mk_sha256_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv128_mk_sha512 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv128_mk_sha512_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv128_mk_ripemd160 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv128_mk_ripemd160_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv256 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *out, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv256_mk_sha1 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv256_mk_sha1_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv256_mk_sha256 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv256_mk_sha256_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv256_mk_sha512 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv256_mk_sha512_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv256_mk_ripemd160 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_essiv256_mk_ripemd160_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain128 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *out, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain128_mk_sha1 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain128_mk_sha1_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain128_mk_sha256 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain128_mk_sha256_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain128_mk_sha512 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain128_mk_sha512_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain128_mk_ripemd160 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain128_mk_ripemd160_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain256 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *out, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain256_mk_sha1 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain256_mk_sha1_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain256_mk_sha256 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain256_mk_sha256_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain256_mk_sha512 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain256_mk_sha512_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain256_mk_ripemd160 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_cbc_plain256_mk_ripemd160_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, const u32 sector);

DECLSPEC void twofish128_decrypt_xts (PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *in, PRIVATE_AS u32 *out, PRIVATE_AS u32 *T);
DECLSPEC void twofish256_decrypt_xts (PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *in, PRIVATE_AS u32 *out, PRIVATE_AS u32 *T);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain256 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *out, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain256_mk_sha1 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain256_mk_sha1_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain256_mk_sha256 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain256_mk_sha256_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain256_mk_sha512 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain256_mk_sha512_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain256_mk_ripemd160 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain256_mk_ripemd160_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain512 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *out, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain512_mk_sha1 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain512_mk_sha1_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain512_mk_sha256 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain512_mk_sha256_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain512_mk_sha512 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain512_mk_sha512_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain512_mk_ripemd160 (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_decrypt_sector_twofish_xts_plain512_mk_ripemd160_final (GLOBAL_AS const u32 *in, PRIVATE_AS u32 *mk, PRIVATE_AS const u32 *sk1, PRIVATE_AS const u32 *lk1, PRIVATE_AS const u32 *sk2, PRIVATE_AS const u32 *lk2, const u32 sector);
DECLSPEC void luks_af_sha1_then_twofish_decrypt (GLOBAL_AS const luks_t *luks_bufs, GLOBAL_AS luks_tmp_t *tmps, PRIVATE_AS u32 *pt_buf);
DECLSPEC void luks_af_sha256_then_twofish_decrypt (GLOBAL_AS const luks_t *luks_bufs, GLOBAL_AS luks_tmp_t *tmps, PRIVATE_AS u32 *pt_buf);
DECLSPEC void luks_af_sha512_then_twofish_decrypt (GLOBAL_AS const luks_t *luks_bufs, GLOBAL_AS luks_tmp_t *tmps, PRIVATE_AS u32 *pt_buf);
DECLSPEC void luks_af_ripemd160_then_twofish_decrypt (GLOBAL_AS const luks_t *luks_bufs, GLOBAL_AS luks_tmp_t *tmps, PRIVATE_AS u32 *pt_buf);

#endif // INC_LUKS_TWOFISH_H
