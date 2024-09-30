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
#include M2S(INCLUDE_PATH/inc_hash_sha256.cl)
#endif

DECLSPEC void hmac_sha256_pad (PRIVATE_AS u32x *w0, PRIVATE_AS u32x *w1, PRIVATE_AS u32x *w2, PRIVATE_AS u32x *w3, PRIVATE_AS u32x *ipad, PRIVATE_AS u32x *opad)
{
  w0[0] = w0[0] ^ 0x36363636;
  w0[1] = w0[1] ^ 0x36363636;
  w0[2] = w0[2] ^ 0x36363636;
  w0[3] = w0[3] ^ 0x36363636;
  w1[0] = w1[0] ^ 0x36363636;
  w1[1] = w1[1] ^ 0x36363636;
  w1[2] = w1[2] ^ 0x36363636;
  w1[3] = w1[3] ^ 0x36363636;
  w2[0] = w2[0] ^ 0x36363636;
  w2[1] = w2[1] ^ 0x36363636;
  w2[2] = w2[2] ^ 0x36363636;
  w2[3] = w2[3] ^ 0x36363636;
  w3[0] = w3[0] ^ 0x36363636;
  w3[1] = w3[1] ^ 0x36363636;
  w3[2] = w3[2] ^ 0x36363636;
  w3[3] = w3[3] ^ 0x36363636;

  ipad[0] = SHA256M_A;
  ipad[1] = SHA256M_B;
  ipad[2] = SHA256M_C;
  ipad[3] = SHA256M_D;
  ipad[4] = SHA256M_E;
  ipad[5] = SHA256M_F;
  ipad[6] = SHA256M_G;
  ipad[7] = SHA256M_H;

  sha256_transform_vector (w0, w1, w2, w3, ipad);

  w0[0] = w0[0] ^ 0x6a6a6a6a;
  w0[1] = w0[1] ^ 0x6a6a6a6a;
  w0[2] = w0[2] ^ 0x6a6a6a6a;
  w0[3] = w0[3] ^ 0x6a6a6a6a;
  w1[0] = w1[0] ^ 0x6a6a6a6a;
  w1[1] = w1[1] ^ 0x6a6a6a6a;
  w1[2] = w1[2] ^ 0x6a6a6a6a;
  w1[3] = w1[3] ^ 0x6a6a6a6a;
  w2[0] = w2[0] ^ 0x6a6a6a6a;
  w2[1] = w2[1] ^ 0x6a6a6a6a;
  w2[2] = w2[2] ^ 0x6a6a6a6a;
  w2[3] = w2[3] ^ 0x6a6a6a6a;
  w3[0] = w3[0] ^ 0x6a6a6a6a;
  w3[1] = w3[1] ^ 0x6a6a6a6a;
  w3[2] = w3[2] ^ 0x6a6a6a6a;
  w3[3] = w3[3] ^ 0x6a6a6a6a;

  opad[0] = SHA256M_A;
  opad[1] = SHA256M_B;
  opad[2] = SHA256M_C;
  opad[3] = SHA256M_D;
  opad[4] = SHA256M_E;
  opad[5] = SHA256M_F;
  opad[6] = SHA256M_G;
  opad[7] = SHA256M_H;

  sha256_transform_vector (w0, w1, w2, w3, opad);
}

DECLSPEC void hmac_sha256_run (PRIVATE_AS u32x *w0, PRIVATE_AS u32x *w1, PRIVATE_AS u32x *w2, PRIVATE_AS u32x *w3, PRIVATE_AS u32x *ipad, PRIVATE_AS u32x *opad, PRIVATE_AS u32x *digest)
{
  digest[0] = ipad[0];
  digest[1] = ipad[1];
  digest[2] = ipad[2];
  digest[3] = ipad[3];
  digest[4] = ipad[4];
  digest[5] = ipad[5];
  digest[6] = ipad[6];
  digest[7] = ipad[7];

  sha256_transform_vector (w0, w1, w2, w3, digest);

  w0[0] = digest[0];
  w0[1] = digest[1];
  w0[2] = digest[2];
  w0[3] = digest[3];
  w1[0] = digest[4];
  w1[1] = digest[5];
  w1[2] = digest[6];
  w1[3] = digest[7];
  w2[0] = 0x80000000;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;
  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = (64 + 32) * 8;

  digest[0] = opad[0];
  digest[1] = opad[1];
  digest[2] = opad[2];
  digest[3] = opad[3];
  digest[4] = opad[4];
  digest[5] = opad[5];
  digest[6] = opad[6];
  digest[7] = opad[7];

  sha256_transform_vector (w0, w1, w2, w3, digest);
}

DECLSPEC void m01450m (PRIVATE_AS u32 *w0, PRIVATE_AS u32 *w1, PRIVATE_AS u32 *w2, PRIVATE_AS u32 *w3, const u32 pw_len, KERN_ATTR_FUNC_BASIC ())
{
  /**
   * modifiers are taken from args
   */

  /**
   * salt
   */

  u32 salt_buf0[4];
  u32 salt_buf1[4];
  u32 salt_buf2[4];
  u32 salt_buf3[4];

  salt_buf0[0] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 0]);
  salt_buf0[1] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 1]);
  salt_buf0[2] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 2]);
  salt_buf0[3] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 3]);
  salt_buf1[0] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 4]);
  salt_buf1[1] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 5]);
  salt_buf1[2] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 6]);
  salt_buf1[3] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 7]);
  salt_buf2[0] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 8]);
  salt_buf2[1] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 9]);
  salt_buf2[2] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[10]);
  salt_buf2[3] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[11]);
  salt_buf3[0] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[12]);
  salt_buf3[1] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[13]);
  salt_buf3[2] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[14]);
  salt_buf3[3] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[15]);

  const u32 salt_len = salt_bufs[SALT_POS_HOST].salt_len;

  /**
   * loop
   */

  u32 w0l = w0[0];

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x w0r = ix_create_bft (bfs_buf, il_pos);

    const u32x w0lr = w0l | w0r;

    /**
     * pads
     */

    u32x w0_t[4];
    u32x w1_t[4];
    u32x w2_t[4];
    u32x w3_t[4];

    w0_t[0] = w0lr;
    w0_t[1] = w0[1];
    w0_t[2] = w0[2];
    w0_t[3] = w0[3];
    w1_t[0] = w1[0];
    w1_t[1] = w1[1];
    w1_t[2] = w1[2];
    w1_t[3] = w1[3];
    w2_t[0] = w2[0];
    w2_t[1] = w2[1];
    w2_t[2] = w2[2];
    w2_t[3] = w2[3];
    w3_t[0] = w3[0];
    w3_t[1] = w3[1];
    w3_t[2] = w3[2];
    w3_t[3] = w3[3];

    u32x ipad[8];
    u32x opad[8];

    hmac_sha256_pad (w0_t, w1_t, w2_t, w3_t, ipad, opad);

    w0_t[0] = salt_buf0[0];
    w0_t[1] = salt_buf0[1];
    w0_t[2] = salt_buf0[2];
    w0_t[3] = salt_buf0[3];
    w1_t[0] = salt_buf1[0];
    w1_t[1] = salt_buf1[1];
    w1_t[2] = salt_buf1[2];
    w1_t[3] = salt_buf1[3];
    w2_t[0] = salt_buf2[0];
    w2_t[1] = salt_buf2[1];
    w2_t[2] = salt_buf2[2];
    w2_t[3] = salt_buf2[3];
    w3_t[0] = salt_buf3[0];
    w3_t[1] = salt_buf3[1];
    w3_t[2] = 0;
    w3_t[3] = (64 + salt_len) * 8;

    u32x digest[8];

    hmac_sha256_run (w0_t, w1_t, w2_t, w3_t, ipad, opad, digest);

    COMPARE_M_SIMD (digest[3], digest[7], digest[2], digest[6]);
  }
}

DECLSPEC void m01450s (PRIVATE_AS u32 *w0, PRIVATE_AS u32 *w1, PRIVATE_AS u32 *w2, PRIVATE_AS u32 *w3, const u32 pw_len, KERN_ATTR_FUNC_BASIC ())
{
  /**
   * modifiers are taken from args
   */

  /**
   * salt
   */

  u32 salt_buf0[4];
  u32 salt_buf1[4];
  u32 salt_buf2[4];
  u32 salt_buf3[4];

  salt_buf0[0] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 0]);
  salt_buf0[1] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 1]);
  salt_buf0[2] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 2]);
  salt_buf0[3] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 3]);
  salt_buf1[0] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 4]);
  salt_buf1[1] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 5]);
  salt_buf1[2] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 6]);
  salt_buf1[3] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 7]);
  salt_buf2[0] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 8]);
  salt_buf2[1] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[ 9]);
  salt_buf2[2] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[10]);
  salt_buf2[3] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[11]);
  salt_buf3[0] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[12]);
  salt_buf3[1] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[13]);
  salt_buf3[2] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[14]);
  salt_buf3[3] = hc_swap32_S (salt_bufs[SALT_POS_HOST].salt_buf[15]);

  const u32 salt_len = salt_bufs[SALT_POS_HOST].salt_len;

  /**
   * digest
   */

  const u32 search[4] =
  {
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R0],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R1],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R2],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R3]
  };

  /**
   * loop
   */

  u32 w0l = w0[0];

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x w0r = ix_create_bft (bfs_buf, il_pos);

    const u32x w0lr = w0l | w0r;

    /**
     * pads
     */

    u32x w0_t[4];
    u32x w1_t[4];
    u32x w2_t[4];
    u32x w3_t[4];

    w0_t[0] = w0lr;
    w0_t[1] = w0[1];
    w0_t[2] = w0[2];
    w0_t[3] = w0[3];
    w1_t[0] = w1[0];
    w1_t[1] = w1[1];
    w1_t[2] = w1[2];
    w1_t[3] = w1[3];
    w2_t[0] = w2[0];
    w2_t[1] = w2[1];
    w2_t[2] = w2[2];
    w2_t[3] = w2[3];
    w3_t[0] = w3[0];
    w3_t[1] = w3[1];
    w3_t[2] = w3[2];
    w3_t[3] = w3[3];

    u32x ipad[8];
    u32x opad[8];

    hmac_sha256_pad (w0_t, w1_t, w2_t, w3_t, ipad, opad);

    w0_t[0] = salt_buf0[0];
    w0_t[1] = salt_buf0[1];
    w0_t[2] = salt_buf0[2];
    w0_t[3] = salt_buf0[3];
    w1_t[0] = salt_buf1[0];
    w1_t[1] = salt_buf1[1];
    w1_t[2] = salt_buf1[2];
    w1_t[3] = salt_buf1[3];
    w2_t[0] = salt_buf2[0];
    w2_t[1] = salt_buf2[1];
    w2_t[2] = salt_buf2[2];
    w2_t[3] = salt_buf2[3];
    w3_t[0] = salt_buf3[0];
    w3_t[1] = salt_buf3[1];
    w3_t[2] = 0;
    w3_t[3] = (64 + salt_len) * 8;

    u32x digest[8];

    hmac_sha256_run (w0_t, w1_t, w2_t, w3_t, ipad, opad, digest);

    COMPARE_S_SIMD (digest[3], digest[7], digest[2], digest[6]);
  }
}

KERNEL_FQ void m01450_m04 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = 0;
  w1[1] = 0;
  w1[2] = 0;
  w1[3] = 0;

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01450m (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ void m01450_m08 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01450m (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ void m01450_m16 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = pws[gid].i[ 8];
  w2[1] = pws[gid].i[ 9];
  w2[2] = pws[gid].i[10];
  w2[3] = pws[gid].i[11];

  u32 w3[4];

  w3[0] = pws[gid].i[12];
  w3[1] = pws[gid].i[13];
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01450m (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ void m01450_s04 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = 0;
  w1[1] = 0;
  w1[2] = 0;
  w1[3] = 0;

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01450s (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ void m01450_s08 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01450s (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ void m01450_s16 (KERN_ATTR_BASIC ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = pws[gid].i[ 8];
  w2[1] = pws[gid].i[ 9];
  w2[2] = pws[gid].i[10];
  w2[3] = pws[gid].i[11];

  u32 w3[4];

  w3[0] = pws[gid].i[12];
  w3[1] = pws[gid].i[13];
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01450s (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}
