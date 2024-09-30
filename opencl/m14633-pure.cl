/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#define NEW_SIMD_CODE

#ifdef KERNEL_STATIC
#include M2S(INCLUDE_PATH/inc_vendor.h)
#include M2S(INCLUDE_PATH/inc_types.h)
#include M2S(INCLUDE_PATH/inc_platform.cl)
#include M2S(INCLUDE_PATH/inc_common.cl)
#include M2S(INCLUDE_PATH/inc_simd.cl)
#include M2S(INCLUDE_PATH/inc_hash_sha1.cl)
#include M2S(INCLUDE_PATH/inc_hash_sha256.cl)
#include M2S(INCLUDE_PATH/inc_hash_sha512.cl)
#include M2S(INCLUDE_PATH/inc_hash_ripemd160.cl)
#include M2S(INCLUDE_PATH/inc_cipher_twofish.cl)
#endif

#define LUKS_STRIPES    (                                   4000)
#define LUKS_CT_LEN     (                                    512)
#define LUKS_AF_MAX_LEN (HC_LUKS_KEY_SIZE_512 / 8 * LUKS_STRIPES)

typedef enum hc_luks_hash_type
{
  HC_LUKS_HASH_TYPE_SHA1      = 1,
  HC_LUKS_HASH_TYPE_SHA256    = 2,
  HC_LUKS_HASH_TYPE_SHA512    = 3,
  HC_LUKS_HASH_TYPE_RIPEMD160 = 4,
  HC_LUKS_HASH_TYPE_WHIRLPOOL = 5,

} hc_luks_hash_type_t;

typedef enum hc_luks_key_size
{
  HC_LUKS_KEY_SIZE_128 = 128,
  HC_LUKS_KEY_SIZE_256 = 256,
  HC_LUKS_KEY_SIZE_512 = 512,

} hc_luks_key_size_t;

typedef enum hc_luks_cipher_type
{
  HC_LUKS_CIPHER_TYPE_AES     = 1,
  HC_LUKS_CIPHER_TYPE_SERPENT = 2,
  HC_LUKS_CIPHER_TYPE_TWOFISH = 3,

} hc_luks_cipher_type_t;

typedef enum hc_luks_cipher_mode
{
  HC_LUKS_CIPHER_MODE_CBC_ESSIV_SHA256 = 1,
  HC_LUKS_CIPHER_MODE_CBC_PLAIN        = 2,
  HC_LUKS_CIPHER_MODE_CBC_PLAIN64      = 3,
  HC_LUKS_CIPHER_MODE_XTS_PLAIN        = 4,
  HC_LUKS_CIPHER_MODE_XTS_PLAIN64      = 5,

} hc_luks_cipher_mode_t;

typedef struct luks
{
  int hash_type;   // hc_luks_hash_type_t
  int key_size;    // hc_luks_key_size_t
  int cipher_type; // hc_luks_cipher_type_t
  int cipher_mode; // hc_luks_cipher_mode_t

  u32 ct_buf[LUKS_CT_LEN / 4];

  u32 af_buf[LUKS_AF_MAX_LEN / 4];
  u32 af_len;

} luks_t;

typedef struct luks_tmp
{
  u32 ipad32[8];
  u64 ipad64[8];

  u32 opad32[8];
  u64 opad64[8];

  u32 dgst32[32];
  u64 dgst64[16];

  u32 out32[32];
  u64 out64[16];

} luks_tmp_t;

#ifdef KERNEL_STATIC
#include M2S(INCLUDE_PATH/inc_luks_af.cl)
#include M2S(INCLUDE_PATH/inc_luks_essiv.cl)
#include M2S(INCLUDE_PATH/inc_luks_xts.cl)
#include M2S(INCLUDE_PATH/inc_luks_twofish.cl)
#endif

#define COMPARE_S M2S(INCLUDE_PATH/inc_comp_single.cl)
#define COMPARE_M M2S(INCLUDE_PATH/inc_comp_multi.cl)

#define MAX_ENTROPY 7.0

DECLSPEC void hmac_sha512_run_V (PRIVATE_AS u32x *w0, PRIVATE_AS u32x *w1, PRIVATE_AS u32x *w2, PRIVATE_AS u32x *w3, PRIVATE_AS u32x *w4, PRIVATE_AS u32x *w5, PRIVATE_AS u32x *w6, PRIVATE_AS u32x *w7, PRIVATE_AS u64x *ipad, PRIVATE_AS u64x *opad, PRIVATE_AS u64x *digest)
{
  digest[0] = ipad[0];
  digest[1] = ipad[1];
  digest[2] = ipad[2];
  digest[3] = ipad[3];
  digest[4] = ipad[4];
  digest[5] = ipad[5];
  digest[6] = ipad[6];
  digest[7] = ipad[7];

  sha512_transform_vector (w0, w1, w2, w3, w4, w5, w6, w7, digest);

  w0[0] = h32_from_64 (digest[0]);
  w0[1] = l32_from_64 (digest[0]);
  w0[2] = h32_from_64 (digest[1]);
  w0[3] = l32_from_64 (digest[1]);
  w1[0] = h32_from_64 (digest[2]);
  w1[1] = l32_from_64 (digest[2]);
  w1[2] = h32_from_64 (digest[3]);
  w1[3] = l32_from_64 (digest[3]);
  w2[0] = h32_from_64 (digest[4]);
  w2[1] = l32_from_64 (digest[4]);
  w2[2] = h32_from_64 (digest[5]);
  w2[3] = l32_from_64 (digest[5]);
  w3[0] = h32_from_64 (digest[6]);
  w3[1] = l32_from_64 (digest[6]);
  w3[2] = h32_from_64 (digest[7]);
  w3[3] = l32_from_64 (digest[7]);
  w4[0] = 0x80000000;
  w4[1] = 0;
  w4[2] = 0;
  w4[3] = 0;
  w5[0] = 0;
  w5[1] = 0;
  w5[2] = 0;
  w5[3] = 0;
  w6[0] = 0;
  w6[1] = 0;
  w6[2] = 0;
  w6[3] = 0;
  w7[0] = 0;
  w7[1] = 0;
  w7[2] = 0;
  w7[3] = (128 + 64) * 8;

  digest[0] = opad[0];
  digest[1] = opad[1];
  digest[2] = opad[2];
  digest[3] = opad[3];
  digest[4] = opad[4];
  digest[5] = opad[5];
  digest[6] = opad[6];
  digest[7] = opad[7];

  sha512_transform_vector (w0, w1, w2, w3, w4, w5, w6, w7, digest);
}

KERNEL_FQ void m14633_init (KERN_ATTR_TMPS_ESALT (luks_tmp_t, luks_t))
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  sha512_hmac_ctx_t sha512_hmac_ctx;

  sha512_hmac_init_global_swap (&sha512_hmac_ctx, pws[gid].i, pws[gid].pw_len);

  tmps[gid].ipad64[0] = sha512_hmac_ctx.ipad.h[0];
  tmps[gid].ipad64[1] = sha512_hmac_ctx.ipad.h[1];
  tmps[gid].ipad64[2] = sha512_hmac_ctx.ipad.h[2];
  tmps[gid].ipad64[3] = sha512_hmac_ctx.ipad.h[3];
  tmps[gid].ipad64[4] = sha512_hmac_ctx.ipad.h[4];
  tmps[gid].ipad64[5] = sha512_hmac_ctx.ipad.h[5];
  tmps[gid].ipad64[6] = sha512_hmac_ctx.ipad.h[6];
  tmps[gid].ipad64[7] = sha512_hmac_ctx.ipad.h[7];

  tmps[gid].opad64[0] = sha512_hmac_ctx.opad.h[0];
  tmps[gid].opad64[1] = sha512_hmac_ctx.opad.h[1];
  tmps[gid].opad64[2] = sha512_hmac_ctx.opad.h[2];
  tmps[gid].opad64[3] = sha512_hmac_ctx.opad.h[3];
  tmps[gid].opad64[4] = sha512_hmac_ctx.opad.h[4];
  tmps[gid].opad64[5] = sha512_hmac_ctx.opad.h[5];
  tmps[gid].opad64[6] = sha512_hmac_ctx.opad.h[6];
  tmps[gid].opad64[7] = sha512_hmac_ctx.opad.h[7];

  sha512_hmac_update_global_swap (&sha512_hmac_ctx, salt_bufs[DIGESTS_OFFSET_HOST].salt_buf, salt_bufs[SALT_POS_HOST].salt_len);

  const u32 key_size = esalt_bufs[DIGESTS_OFFSET_HOST].key_size;

  for (u32 i = 0, j = 1; i < ((key_size / 8) / 4); i += 16, j += 1)
  {
    sha512_hmac_ctx_t sha512_hmac_ctx2 = sha512_hmac_ctx;

    u32 w0[4];
    u32 w1[4];
    u32 w2[4];
    u32 w3[4];
    u32 w4[4];
    u32 w5[4];
    u32 w6[4];
    u32 w7[4];

    w0[0] = j;
    w0[1] = 0;
    w0[2] = 0;
    w0[3] = 0;
    w1[0] = 0;
    w1[1] = 0;
    w1[2] = 0;
    w1[3] = 0;
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;
    w4[0] = 0;
    w4[1] = 0;
    w4[2] = 0;
    w4[3] = 0;
    w5[0] = 0;
    w5[1] = 0;
    w5[2] = 0;
    w5[3] = 0;
    w6[0] = 0;
    w6[1] = 0;
    w6[2] = 0;
    w6[3] = 0;
    w7[0] = 0;
    w7[1] = 0;
    w7[2] = 0;
    w7[3] = 0;

    sha512_hmac_update_128 (&sha512_hmac_ctx2, w0, w1, w2, w3, w4, w5, w6, w7, 4);

    sha512_hmac_final (&sha512_hmac_ctx2);

    tmps[gid].dgst64[i + 0] = sha512_hmac_ctx2.opad.h[0];
    tmps[gid].dgst64[i + 1] = sha512_hmac_ctx2.opad.h[1];
    tmps[gid].dgst64[i + 2] = sha512_hmac_ctx2.opad.h[2];
    tmps[gid].dgst64[i + 3] = sha512_hmac_ctx2.opad.h[3];
    tmps[gid].dgst64[i + 4] = sha512_hmac_ctx2.opad.h[4];
    tmps[gid].dgst64[i + 5] = sha512_hmac_ctx2.opad.h[5];
    tmps[gid].dgst64[i + 6] = sha512_hmac_ctx2.opad.h[6];
    tmps[gid].dgst64[i + 7] = sha512_hmac_ctx2.opad.h[7];

    tmps[gid].out64[i + 0] = tmps[gid].dgst64[i + 0];
    tmps[gid].out64[i + 1] = tmps[gid].dgst64[i + 1];
    tmps[gid].out64[i + 2] = tmps[gid].dgst64[i + 2];
    tmps[gid].out64[i + 3] = tmps[gid].dgst64[i + 3];
    tmps[gid].out64[i + 4] = tmps[gid].dgst64[i + 4];
    tmps[gid].out64[i + 5] = tmps[gid].dgst64[i + 5];
    tmps[gid].out64[i + 6] = tmps[gid].dgst64[i + 6];
    tmps[gid].out64[i + 7] = tmps[gid].dgst64[i + 7];
  }
}

KERNEL_FQ void m14633_loop (KERN_ATTR_TMPS_ESALT (luks_tmp_t, luks_t))
{
  const u64 gid = get_global_id (0);

  if ((gid * VECT_SIZE) >= GID_CNT) return;

  u64x ipad[8];
  u64x opad[8];

  ipad[0] = pack64v (tmps, ipad64, gid, 0);
  ipad[1] = pack64v (tmps, ipad64, gid, 1);
  ipad[2] = pack64v (tmps, ipad64, gid, 2);
  ipad[3] = pack64v (tmps, ipad64, gid, 3);
  ipad[4] = pack64v (tmps, ipad64, gid, 4);
  ipad[5] = pack64v (tmps, ipad64, gid, 5);
  ipad[6] = pack64v (tmps, ipad64, gid, 6);
  ipad[7] = pack64v (tmps, ipad64, gid, 7);

  opad[0] = pack64v (tmps, opad64, gid, 0);
  opad[1] = pack64v (tmps, opad64, gid, 1);
  opad[2] = pack64v (tmps, opad64, gid, 2);
  opad[3] = pack64v (tmps, opad64, gid, 3);
  opad[4] = pack64v (tmps, opad64, gid, 4);
  opad[5] = pack64v (tmps, opad64, gid, 5);
  opad[6] = pack64v (tmps, opad64, gid, 6);
  opad[7] = pack64v (tmps, opad64, gid, 7);

  u32 key_size = esalt_bufs[DIGESTS_OFFSET_HOST].key_size;

  for (u32 i = 0; i < ((key_size / 8) / 4); i += 16)
  {
    u64x dgst[8];
    u64x out[8];

    dgst[0] = pack64v (tmps, dgst64, gid, i + 0);
    dgst[1] = pack64v (tmps, dgst64, gid, i + 1);
    dgst[2] = pack64v (tmps, dgst64, gid, i + 2);
    dgst[3] = pack64v (tmps, dgst64, gid, i + 3);
    dgst[4] = pack64v (tmps, dgst64, gid, i + 4);
    dgst[5] = pack64v (tmps, dgst64, gid, i + 5);
    dgst[6] = pack64v (tmps, dgst64, gid, i + 6);
    dgst[7] = pack64v (tmps, dgst64, gid, i + 7);

    out[0] = pack64v (tmps, out64, gid, i + 0);
    out[1] = pack64v (tmps, out64, gid, i + 1);
    out[2] = pack64v (tmps, out64, gid, i + 2);
    out[3] = pack64v (tmps, out64, gid, i + 3);
    out[4] = pack64v (tmps, out64, gid, i + 4);
    out[5] = pack64v (tmps, out64, gid, i + 5);
    out[6] = pack64v (tmps, out64, gid, i + 6);
    out[7] = pack64v (tmps, out64, gid, i + 7);

    for (u32 j = 0; j < LOOP_CNT; j++)
    {
      u32x w0[4];
      u32x w1[4];
      u32x w2[4];
      u32x w3[4];
      u32x w4[4];
      u32x w5[4];
      u32x w6[4];
      u32x w7[4];

      w0[0] = h32_from_64 (dgst[0]);
      w0[1] = l32_from_64 (dgst[0]);
      w0[2] = h32_from_64 (dgst[1]);
      w0[3] = l32_from_64 (dgst[1]);
      w1[0] = h32_from_64 (dgst[2]);
      w1[1] = l32_from_64 (dgst[2]);
      w1[2] = h32_from_64 (dgst[3]);
      w1[3] = l32_from_64 (dgst[3]);
      w2[0] = h32_from_64 (dgst[4]);
      w2[1] = l32_from_64 (dgst[4]);
      w2[2] = h32_from_64 (dgst[5]);
      w2[3] = l32_from_64 (dgst[5]);
      w3[0] = h32_from_64 (dgst[6]);
      w3[1] = l32_from_64 (dgst[6]);
      w3[2] = h32_from_64 (dgst[7]);
      w3[3] = l32_from_64 (dgst[7]);
      w4[0] = 0x80000000;
      w4[1] = 0;
      w4[2] = 0;
      w4[3] = 0;
      w5[0] = 0;
      w5[1] = 0;
      w5[2] = 0;
      w5[3] = 0;
      w6[0] = 0;
      w6[1] = 0;
      w6[2] = 0;
      w6[3] = 0;
      w7[0] = 0;
      w7[1] = 0;
      w7[2] = 0;
      w7[3] = (128 + 64) * 8;

      hmac_sha512_run_V (w0, w1, w2, w3, w4, w5, w6, w7, ipad, opad, dgst);

      out[0] ^= dgst[0];
      out[1] ^= dgst[1];
      out[2] ^= dgst[2];
      out[3] ^= dgst[3];
      out[4] ^= dgst[4];
      out[5] ^= dgst[5];
      out[6] ^= dgst[6];
      out[7] ^= dgst[7];
    }

    unpack64v (tmps, dgst64, gid, i + 0, dgst[0]);
    unpack64v (tmps, dgst64, gid, i + 1, dgst[1]);
    unpack64v (tmps, dgst64, gid, i + 2, dgst[2]);
    unpack64v (tmps, dgst64, gid, i + 3, dgst[3]);
    unpack64v (tmps, dgst64, gid, i + 4, dgst[4]);
    unpack64v (tmps, dgst64, gid, i + 5, dgst[5]);
    unpack64v (tmps, dgst64, gid, i + 6, dgst[6]);
    unpack64v (tmps, dgst64, gid, i + 7, dgst[7]);

    unpack64v (tmps, out64, gid, i + 0, out[0]);
    unpack64v (tmps, out64, gid, i + 1, out[1]);
    unpack64v (tmps, out64, gid, i + 2, out[2]);
    unpack64v (tmps, out64, gid, i + 3, out[3]);
    unpack64v (tmps, out64, gid, i + 4, out[4]);
    unpack64v (tmps, out64, gid, i + 5, out[5]);
    unpack64v (tmps, out64, gid, i + 6, out[6]);
    unpack64v (tmps, out64, gid, i + 7, out[7]);
  }
}

KERNEL_FQ void m14633_comp (KERN_ATTR_TMPS_ESALT (luks_tmp_t, luks_t))
{
  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  // decrypt AF with first pbkdf2 result
  // merge AF to masterkey
  // decrypt first payload sector with masterkey

  u32 pt_buf[128];

  luks_af_sha512_then_twofish_decrypt (&esalt_bufs[DIGESTS_OFFSET_HOST], &tmps[gid], pt_buf);

  // check entropy

  const float entropy = hc_get_entropy (pt_buf, 128);

  if (entropy < MAX_ENTROPY)
  {
    if (hc_atomic_inc (&hashes_shown[DIGESTS_OFFSET_HOST]) == 0)
    {
      mark_hash (plains_buf, d_return_buf, SALT_POS_HOST, DIGESTS_CNT, 0, DIGESTS_OFFSET_HOST + 0, gid, 0, 0, 0);
    }
  }
}
