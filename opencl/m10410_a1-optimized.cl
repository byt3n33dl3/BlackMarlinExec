/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

//too much register pressure
//#define NEW_SIMD_CODE

#ifdef KERNEL_STATIC
#include M2S(INCLUDE_PATH/inc_vendor.h)
#include M2S(INCLUDE_PATH/inc_types.h)
#include M2S(INCLUDE_PATH/inc_platform.cl)
#include M2S(INCLUDE_PATH/inc_common.cl)
#include M2S(INCLUDE_PATH/inc_simd.cl)
#include M2S(INCLUDE_PATH/inc_hash_md5.cl)
#include M2S(INCLUDE_PATH/inc_cipher_rc4.cl)
#endif

typedef struct pdf
{
  int V;
  int R;
  int P;

  int enc_md;

  u32 id_buf[8];
  u32 u_buf[32];
  u32 o_buf[32];

  int id_len;
  int o_len;
  int u_len;

  u32 rc4key[2];
  u32 rc4data[2];

  int P_minus;

} pdf_t;

KERNEL_FQ void FIXED_THREAD_COUNT(FIXED_LOCAL_SIZE) m10410_m04 (KERN_ATTR_ESALT (pdf_t))
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);

  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  u32 pw_buf0[4];
  u32 pw_buf1[4];

  pw_buf0[0] = pws[gid].i[0];
  pw_buf0[1] = pws[gid].i[1];
  pw_buf0[2] = pws[gid].i[2];
  pw_buf0[3] = pws[gid].i[3];
  pw_buf1[0] = pws[gid].i[4];
  pw_buf1[1] = pws[gid].i[5];
  pw_buf1[2] = pws[gid].i[6];
  pw_buf1[3] = pws[gid].i[7];

  const u32 pw_l_len = pws[gid].pw_len & 63;

  /**
   * constant
   */

  const u32 padding[8] =
  {
    0x5e4ebf28,
    0x418a754e,
    0x564e0064,
    0x0801faff,
    0xb6002e2e,
    0x803e68d0,
    0xfea90c2f,
    0x7a695364
  };

  /**
   * shared
   */

  LOCAL_VK u32 S[64 * FIXED_LOCAL_SIZE];

  /**
   * U_buf
   */

  u32 o_buf[8];

  o_buf[0] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[0];
  o_buf[1] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[1];
  o_buf[2] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[2];
  o_buf[3] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[3];
  o_buf[4] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[4];
  o_buf[5] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[5];
  o_buf[6] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[6];
  o_buf[7] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[7];

  u32 P = esalt_bufs[DIGESTS_OFFSET_HOST].P;

  u32 id_buf[4];

  id_buf[0] = esalt_bufs[DIGESTS_OFFSET_HOST].id_buf[0];
  id_buf[1] = esalt_bufs[DIGESTS_OFFSET_HOST].id_buf[1];
  id_buf[2] = esalt_bufs[DIGESTS_OFFSET_HOST].id_buf[2];
  id_buf[3] = esalt_bufs[DIGESTS_OFFSET_HOST].id_buf[3];

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x pw_r_len = pwlenx_create_combt (combs_buf, il_pos) & 63;

    const u32x pw_len = (pw_l_len + pw_r_len) & 63;

    /**
     * concat password candidate
     */

    u32x wordl0[4] = { 0 };
    u32x wordl1[4] = { 0 };
    u32x wordl2[4] = { 0 };
    u32x wordl3[4] = { 0 };

    wordl0[0] = pw_buf0[0];
    wordl0[1] = pw_buf0[1];
    wordl0[2] = pw_buf0[2];
    wordl0[3] = pw_buf0[3];
    wordl1[0] = pw_buf1[0];
    wordl1[1] = pw_buf1[1];
    wordl1[2] = pw_buf1[2];
    wordl1[3] = pw_buf1[3];

    u32x wordr0[4] = { 0 };
    u32x wordr1[4] = { 0 };
    u32x wordr2[4] = { 0 };
    u32x wordr3[4] = { 0 };

    wordr0[0] = ix_create_combt (combs_buf, il_pos, 0);
    wordr0[1] = ix_create_combt (combs_buf, il_pos, 1);
    wordr0[2] = ix_create_combt (combs_buf, il_pos, 2);
    wordr0[3] = ix_create_combt (combs_buf, il_pos, 3);
    wordr1[0] = ix_create_combt (combs_buf, il_pos, 4);
    wordr1[1] = ix_create_combt (combs_buf, il_pos, 5);
    wordr1[2] = ix_create_combt (combs_buf, il_pos, 6);
    wordr1[3] = ix_create_combt (combs_buf, il_pos, 7);

    if (COMBS_MODE == COMBINATOR_MODE_BASE_LEFT)
    {
      switch_buffer_by_offset_le_VV (wordr0, wordr1, wordr2, wordr3, pw_l_len);
    }
    else
    {
      switch_buffer_by_offset_le_VV (wordl0, wordl1, wordl2, wordl3, pw_r_len);
    }

    u32x w0[4];

    w0[0] = wordl0[0] | wordr0[0];
    w0[1] = wordl0[1] | wordr0[1];
    w0[2] = 0;
    w0[3] = 0;

    /**
     * pdf
     */

    rc4_init_40 (S, w0, lid);

    u32 out[4];

    rc4_next_16 (S, 0, 0, padding, out, lid);

    COMPARE_M_SIMD (out[0], out[1], out[2], out[3]);
  }
}

KERNEL_FQ void FIXED_THREAD_COUNT(FIXED_LOCAL_SIZE) m10410_m08 (KERN_ATTR_ESALT (pdf_t))
{
}

KERNEL_FQ void FIXED_THREAD_COUNT(FIXED_LOCAL_SIZE) m10410_m16 (KERN_ATTR_ESALT (pdf_t))
{
}

KERNEL_FQ void FIXED_THREAD_COUNT(FIXED_LOCAL_SIZE) m10410_s04 (KERN_ATTR_ESALT (pdf_t))
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);

  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  u32 pw_buf0[4];
  u32 pw_buf1[4];

  pw_buf0[0] = pws[gid].i[0];
  pw_buf0[1] = pws[gid].i[1];
  pw_buf0[2] = pws[gid].i[2];
  pw_buf0[3] = pws[gid].i[3];
  pw_buf1[0] = pws[gid].i[4];
  pw_buf1[1] = pws[gid].i[5];
  pw_buf1[2] = pws[gid].i[6];
  pw_buf1[3] = pws[gid].i[7];

  const u32 pw_l_len = pws[gid].pw_len & 63;

  /**
   * constant
   */

  const u32 padding[8] =
  {
    0x5e4ebf28,
    0x418a754e,
    0x564e0064,
    0x0801faff,
    0xb6002e2e,
    0x803e68d0,
    0xfea90c2f,
    0x7a695364
  };

  /**
   * shared
   */

  LOCAL_VK u32 S[64 * FIXED_LOCAL_SIZE];

  /**
   * U_buf
   */

  u32 o_buf[8];

  o_buf[0] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[0];
  o_buf[1] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[1];
  o_buf[2] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[2];
  o_buf[3] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[3];
  o_buf[4] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[4];
  o_buf[5] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[5];
  o_buf[6] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[6];
  o_buf[7] = esalt_bufs[DIGESTS_OFFSET_HOST].o_buf[7];

  u32 P = esalt_bufs[DIGESTS_OFFSET_HOST].P;

  u32 id_buf[4];

  id_buf[0] = esalt_bufs[DIGESTS_OFFSET_HOST].id_buf[0];
  id_buf[1] = esalt_bufs[DIGESTS_OFFSET_HOST].id_buf[1];
  id_buf[2] = esalt_bufs[DIGESTS_OFFSET_HOST].id_buf[2];
  id_buf[3] = esalt_bufs[DIGESTS_OFFSET_HOST].id_buf[3];

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

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x pw_r_len = pwlenx_create_combt (combs_buf, il_pos) & 63;

    const u32x pw_len = (pw_l_len + pw_r_len) & 63;

    /**
     * concat password candidate
     */

    u32x wordl0[4] = { 0 };
    u32x wordl1[4] = { 0 };
    u32x wordl2[4] = { 0 };
    u32x wordl3[4] = { 0 };

    wordl0[0] = pw_buf0[0];
    wordl0[1] = pw_buf0[1];
    wordl0[2] = pw_buf0[2];
    wordl0[3] = pw_buf0[3];
    wordl1[0] = pw_buf1[0];
    wordl1[1] = pw_buf1[1];
    wordl1[2] = pw_buf1[2];
    wordl1[3] = pw_buf1[3];

    u32x wordr0[4] = { 0 };
    u32x wordr1[4] = { 0 };
    u32x wordr2[4] = { 0 };
    u32x wordr3[4] = { 0 };

    wordr0[0] = ix_create_combt (combs_buf, il_pos, 0);
    wordr0[1] = ix_create_combt (combs_buf, il_pos, 1);
    wordr0[2] = ix_create_combt (combs_buf, il_pos, 2);
    wordr0[3] = ix_create_combt (combs_buf, il_pos, 3);
    wordr1[0] = ix_create_combt (combs_buf, il_pos, 4);
    wordr1[1] = ix_create_combt (combs_buf, il_pos, 5);
    wordr1[2] = ix_create_combt (combs_buf, il_pos, 6);
    wordr1[3] = ix_create_combt (combs_buf, il_pos, 7);

    if (COMBS_MODE == COMBINATOR_MODE_BASE_LEFT)
    {
      switch_buffer_by_offset_le_VV (wordr0, wordr1, wordr2, wordr3, pw_l_len);
    }
    else
    {
      switch_buffer_by_offset_le_VV (wordl0, wordl1, wordl2, wordl3, pw_r_len);
    }

    u32x w0[4];

    w0[0] = wordl0[0] | wordr0[0];
    w0[1] = wordl0[1] | wordr0[1];
    w0[2] = 0;
    w0[3] = 0;

    /**
     * pdf
     */

    rc4_init_40 (S, w0, lid);

    u32 out[4];

    rc4_next_16 (S, 0, 0, padding, out, lid);

    COMPARE_S_SIMD (out[0], out[1], out[2], out[3]);
  }
}

KERNEL_FQ void FIXED_THREAD_COUNT(FIXED_LOCAL_SIZE) m10410_s08 (KERN_ATTR_ESALT (pdf_t))
{
}

KERNEL_FQ void FIXED_THREAD_COUNT(FIXED_LOCAL_SIZE) m10410_s16 (KERN_ATTR_ESALT (pdf_t))
{
}
