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
#include M2S(INCLUDE_PATH/inc_hash_sha512.cl)
#include M2S(INCLUDE_PATH/inc_cipher_aes.cl)
#endif

typedef struct bitcoin_wallet_tmp
{
  u64  dgst[8];

} bitcoin_wallet_tmp_t;

typedef struct bitcoin_wallet
{
  u32 cry_master_buf[64];
  u32 cry_master_len;

  u32 cry_salt_buf[16];
  u32 cry_salt_len;

} bitcoin_wallet_t;

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

KERNEL_FQ void m11300_init (KERN_ATTR_TMPS_ESALT (bitcoin_wallet_tmp_t, bitcoin_wallet_t))
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  sha512_ctx_t ctx;

  sha512_init (&ctx);

  sha512_update_global_swap (&ctx, pws[gid].i, pws[gid].pw_len);

  sha512_update_global_swap (&ctx, salt_bufs[SALT_POS_HOST].salt_buf, salt_bufs[SALT_POS_HOST].salt_len);

  sha512_final (&ctx);

  tmps[gid].dgst[0] = ctx.h[0];
  tmps[gid].dgst[1] = ctx.h[1];
  tmps[gid].dgst[2] = ctx.h[2];
  tmps[gid].dgst[3] = ctx.h[3];
  tmps[gid].dgst[4] = ctx.h[4];
  tmps[gid].dgst[5] = ctx.h[5];
  tmps[gid].dgst[6] = ctx.h[6];
  tmps[gid].dgst[7] = ctx.h[7];
}

KERNEL_FQ void m11300_loop (KERN_ATTR_TMPS_ESALT (bitcoin_wallet_tmp_t, bitcoin_wallet_t))
{
  const u64 gid = get_global_id (0);

  if ((gid * VECT_SIZE) >= GID_CNT) return;

  u64x t0 = pack64v (tmps, dgst, gid, 0);
  u64x t1 = pack64v (tmps, dgst, gid, 1);
  u64x t2 = pack64v (tmps, dgst, gid, 2);
  u64x t3 = pack64v (tmps, dgst, gid, 3);
  u64x t4 = pack64v (tmps, dgst, gid, 4);
  u64x t5 = pack64v (tmps, dgst, gid, 5);
  u64x t6 = pack64v (tmps, dgst, gid, 6);
  u64x t7 = pack64v (tmps, dgst, gid, 7);

  for (u32 i = 0, j = LOOP_POS; i < LOOP_CNT; i++, j++)
  {
    u32x w0[4];
    u32x w1[4];
    u32x w2[4];
    u32x w3[4];
    u32x w4[4];
    u32x w5[4];
    u32x w6[4];
    u32x w7[4];

    w0[0] = h32_from_64 (t0);
    w0[1] = l32_from_64 (t0);
    w0[2] = h32_from_64 (t1);
    w0[3] = l32_from_64 (t1);
    w1[0] = h32_from_64 (t2);
    w1[1] = l32_from_64 (t2);
    w1[2] = h32_from_64 (t3);
    w1[3] = l32_from_64 (t3);
    w2[0] = h32_from_64 (t4);
    w2[1] = l32_from_64 (t4);
    w2[2] = h32_from_64 (t5);
    w2[3] = l32_from_64 (t5);
    w3[0] = h32_from_64 (t6);
    w3[1] = l32_from_64 (t6);
    w3[2] = h32_from_64 (t7);
    w3[3] = l32_from_64 (t7);
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
    w7[3] = 64 * 8;

    u64x digest[8];

    digest[0] = SHA512M_A;
    digest[1] = SHA512M_B;
    digest[2] = SHA512M_C;
    digest[3] = SHA512M_D;
    digest[4] = SHA512M_E;
    digest[5] = SHA512M_F;
    digest[6] = SHA512M_G;
    digest[7] = SHA512M_H;

    sha512_transform_vector (w0, w1, w2, w3, w4, w5, w6, w7, digest);

    t0 = digest[0];
    t1 = digest[1];
    t2 = digest[2];
    t3 = digest[3];
    t4 = digest[4];
    t5 = digest[5];
    t6 = digest[6];
    t7 = digest[7];
  }

  unpack64v (tmps, dgst, gid, 0, t0);
  unpack64v (tmps, dgst, gid, 1, t1);
  unpack64v (tmps, dgst, gid, 2, t2);
  unpack64v (tmps, dgst, gid, 3, t3);
  unpack64v (tmps, dgst, gid, 4, t4);
  unpack64v (tmps, dgst, gid, 5, t5);
  unpack64v (tmps, dgst, gid, 6, t6);
  unpack64v (tmps, dgst, gid, 7, t7);
}

KERNEL_FQ void m11300_comp (KERN_ATTR_TMPS_ESALT (bitcoin_wallet_tmp_t, bitcoin_wallet_t))
{
  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * aes shared
   */

  #ifdef REAL_SHM

  LOCAL_VK u32 s_td0[256];
  LOCAL_VK u32 s_td1[256];
  LOCAL_VK u32 s_td2[256];
  LOCAL_VK u32 s_td3[256];
  LOCAL_VK u32 s_td4[256];

  LOCAL_VK u32 s_te0[256];
  LOCAL_VK u32 s_te1[256];
  LOCAL_VK u32 s_te2[256];
  LOCAL_VK u32 s_te3[256];
  LOCAL_VK u32 s_te4[256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_td0[i] = td0[i];
    s_td1[i] = td1[i];
    s_td2[i] = td2[i];
    s_td3[i] = td3[i];
    s_td4[i] = td4[i];

    s_te0[i] = te0[i];
    s_te1[i] = te1[i];
    s_te2[i] = te2[i];
    s_te3[i] = te3[i];
    s_te4[i] = te4[i];
  }

  SYNC_THREADS ();

  #else

  CONSTANT_AS u32a *s_td0 = td0;
  CONSTANT_AS u32a *s_td1 = td1;
  CONSTANT_AS u32a *s_td2 = td2;
  CONSTANT_AS u32a *s_td3 = td3;
  CONSTANT_AS u32a *s_td4 = td4;

  CONSTANT_AS u32a *s_te0 = te0;
  CONSTANT_AS u32a *s_te1 = te1;
  CONSTANT_AS u32a *s_te2 = te2;
  CONSTANT_AS u32a *s_te3 = te3;
  CONSTANT_AS u32a *s_te4 = te4;

  #endif

  if (gid >= GID_CNT) return;

  /**
   * real code
   */

  u64 dgst[8];

  dgst[0] = tmps[gid].dgst[0];
  dgst[1] = tmps[gid].dgst[1];
  dgst[2] = tmps[gid].dgst[2];
  dgst[3] = tmps[gid].dgst[3];
  dgst[4] = tmps[gid].dgst[4];
  dgst[5] = tmps[gid].dgst[5];
  dgst[6] = tmps[gid].dgst[6];
  dgst[7] = tmps[gid].dgst[7];

  u32 key[8];

  key[0] = h32_from_64_S (dgst[0]);
  key[1] = l32_from_64_S (dgst[0]);
  key[2] = h32_from_64_S (dgst[1]);
  key[3] = l32_from_64_S (dgst[1]);
  key[4] = h32_from_64_S (dgst[2]);
  key[5] = l32_from_64_S (dgst[2]);
  key[6] = h32_from_64_S (dgst[3]);
  key[7] = l32_from_64_S (dgst[3]);

  const u32 digest_pos = LOOP_POS;

  const u32 digest_cur = DIGESTS_OFFSET_HOST + digest_pos;

  #define KEYLEN 60

  u32 ks[KEYLEN];

  AES256_set_decrypt_key (ks, key, s_te0, s_te1, s_te2, s_te3, s_td0, s_td1, s_td2, s_td3);

  u32 i = esalt_bufs[digest_cur].cry_master_len - 32;

  u32 iv[4];

  iv[0] = hc_swap32_S (esalt_bufs[digest_cur].cry_master_buf[(i / 4) + 0]);
  iv[1] = hc_swap32_S (esalt_bufs[digest_cur].cry_master_buf[(i / 4) + 1]);
  iv[2] = hc_swap32_S (esalt_bufs[digest_cur].cry_master_buf[(i / 4) + 2]);
  iv[3] = hc_swap32_S (esalt_bufs[digest_cur].cry_master_buf[(i / 4) + 3]);

  i += 16;

  u32 data[4];

  data[0] = hc_swap32_S (esalt_bufs[digest_cur].cry_master_buf[(i / 4) + 0]);
  data[1] = hc_swap32_S (esalt_bufs[digest_cur].cry_master_buf[(i / 4) + 1]);
  data[2] = hc_swap32_S (esalt_bufs[digest_cur].cry_master_buf[(i / 4) + 2]);
  data[3] = hc_swap32_S (esalt_bufs[digest_cur].cry_master_buf[(i / 4) + 3]);

  u32 out[4];

  AES256_decrypt (ks, data, out, s_td0, s_td1, s_td2, s_td3, s_td4);

  out[0] ^= iv[0];
  out[1] ^= iv[1];
  out[2] ^= iv[2];
  out[3] ^= iv[3];

  u32 pad = 0;

  if (esalt_bufs[digest_cur].cry_salt_len != 18)
  {
    /* most wallets */
    pad = 0x10101010;

    if (out[0] != pad) return;
    if (out[1] != pad) return;
  }
  else
  {
    /* Nexus legacy wallet */
    pad = 0x08080808;
  }

  if (out[2] == pad && out[3] == pad)
  {
    if (hc_atomic_inc (&hashes_shown[digest_cur]) == 0)
    {
      mark_hash (plains_buf, d_return_buf, SALT_POS_HOST, DIGESTS_CNT, digest_pos, digest_cur, gid, 0, 0, 0);
    }
  }
}
