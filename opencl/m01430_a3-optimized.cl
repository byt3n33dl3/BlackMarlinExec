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

#define SHA256_STEP_REV(a,b,c,d,e,f,g,h)        \
{                                               \
  u32 t2 = SHA256_S2_S(b) + SHA256_F0o(b,c,d);  \
  u32 t1 = a - t2;                              \
  a = b;                                        \
  b = c;                                        \
  c = d;                                        \
  d = e - t1;                                   \
  e = f;                                        \
  f = g;                                        \
  g = h;                                        \
  h = 0;                                        \
}

DECLSPEC void m01430m (PRIVATE_AS u32 *w, const u32 pw_len, KERN_ATTR_FUNC_VECTOR ())
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

  salt_buf0[0] = salt_bufs[SALT_POS_HOST].salt_buf[ 0];
  salt_buf0[1] = salt_bufs[SALT_POS_HOST].salt_buf[ 1];
  salt_buf0[2] = salt_bufs[SALT_POS_HOST].salt_buf[ 2];
  salt_buf0[3] = salt_bufs[SALT_POS_HOST].salt_buf[ 3];
  salt_buf1[0] = salt_bufs[SALT_POS_HOST].salt_buf[ 4];
  salt_buf1[1] = salt_bufs[SALT_POS_HOST].salt_buf[ 5];
  salt_buf1[2] = salt_bufs[SALT_POS_HOST].salt_buf[ 6];
  salt_buf1[3] = salt_bufs[SALT_POS_HOST].salt_buf[ 7];
  salt_buf2[0] = salt_bufs[SALT_POS_HOST].salt_buf[ 8];
  salt_buf2[1] = salt_bufs[SALT_POS_HOST].salt_buf[ 9];
  salt_buf2[2] = salt_bufs[SALT_POS_HOST].salt_buf[10];
  salt_buf2[3] = salt_bufs[SALT_POS_HOST].salt_buf[11];
  salt_buf3[0] = salt_bufs[SALT_POS_HOST].salt_buf[12];
  salt_buf3[1] = salt_bufs[SALT_POS_HOST].salt_buf[13];
  salt_buf3[2] = salt_bufs[SALT_POS_HOST].salt_buf[14];
  salt_buf3[3] = salt_bufs[SALT_POS_HOST].salt_buf[15];

  switch_buffer_by_offset_le_S (salt_buf0, salt_buf1, salt_buf2, salt_buf3, pw_len);

  w[ 0] |= hc_swap32_S (salt_buf0[0]);
  w[ 1] |= hc_swap32_S (salt_buf0[1]);
  w[ 2] |= hc_swap32_S (salt_buf0[2]);
  w[ 3] |= hc_swap32_S (salt_buf0[3]);
  w[ 4] |= hc_swap32_S (salt_buf1[0]);
  w[ 5] |= hc_swap32_S (salt_buf1[1]);
  w[ 6] |= hc_swap32_S (salt_buf1[2]);
  w[ 7] |= hc_swap32_S (salt_buf1[3]);
  w[ 8] |= hc_swap32_S (salt_buf2[0]);
  w[ 9] |= hc_swap32_S (salt_buf2[1]);
  w[10] |= hc_swap32_S (salt_buf2[2]);
  w[11] |= hc_swap32_S (salt_buf2[3]);
  w[12] |= hc_swap32_S (salt_buf3[0]);
  w[13] |= hc_swap32_S (salt_buf3[1]);
  w[14] |= hc_swap32_S (salt_buf3[2]);
  w[15] |= hc_swap32_S (salt_buf3[3]);

  const u32 salt_len = salt_bufs[SALT_POS_HOST].salt_len;

  const u32 pw_salt_len = pw_len + salt_len;

  w[15] = pw_salt_len * 8;

  /**
   * loop
   */

  u32 w0l = w[0];

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x w0r = words_buf_r[il_pos / VECT_SIZE];

    const u32x w0 = w0l | w0r;

    u32x w0_t = w0;
    u32x w1_t = w[ 1];
    u32x w2_t = w[ 2];
    u32x w3_t = w[ 3];
    u32x w4_t = w[ 4];
    u32x w5_t = w[ 5];
    u32x w6_t = w[ 6];
    u32x w7_t = w[ 7];
    u32x w8_t = w[ 8];
    u32x w9_t = w[ 9];
    u32x wa_t = w[10];
    u32x wb_t = w[11];
    u32x wc_t = w[12];
    u32x wd_t = w[13];
    u32x we_t = w[14];
    u32x wf_t = w[15];

    u32x a = SHA256M_A;
    u32x b = SHA256M_B;
    u32x c = SHA256M_C;
    u32x d = SHA256M_D;
    u32x e = SHA256M_E;
    u32x f = SHA256M_F;
    u32x g = SHA256M_G;
    u32x h = SHA256M_H;

    SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w0_t, SHA256C00);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w1_t, SHA256C01);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, w2_t, SHA256C02);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, w3_t, SHA256C03);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, w4_t, SHA256C04);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, w5_t, SHA256C05);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, w6_t, SHA256C06);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, w7_t, SHA256C07);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w8_t, SHA256C08);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w9_t, SHA256C09);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, wa_t, SHA256C0a);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, wb_t, SHA256C0b);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, wc_t, SHA256C0c);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, wd_t, SHA256C0d);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, we_t, SHA256C0e);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, wf_t, SHA256C0f);

    w0_t = SHA256_EXPAND (we_t, w9_t, w1_t, w0_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w0_t, SHA256C10);
    w1_t = SHA256_EXPAND (wf_t, wa_t, w2_t, w1_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w1_t, SHA256C11);
    w2_t = SHA256_EXPAND (w0_t, wb_t, w3_t, w2_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, w2_t, SHA256C12);
    w3_t = SHA256_EXPAND (w1_t, wc_t, w4_t, w3_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, w3_t, SHA256C13);
    w4_t = SHA256_EXPAND (w2_t, wd_t, w5_t, w4_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, w4_t, SHA256C14);
    w5_t = SHA256_EXPAND (w3_t, we_t, w6_t, w5_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, w5_t, SHA256C15);
    w6_t = SHA256_EXPAND (w4_t, wf_t, w7_t, w6_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, w6_t, SHA256C16);
    w7_t = SHA256_EXPAND (w5_t, w0_t, w8_t, w7_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, w7_t, SHA256C17);
    w8_t = SHA256_EXPAND (w6_t, w1_t, w9_t, w8_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w8_t, SHA256C18);
    w9_t = SHA256_EXPAND (w7_t, w2_t, wa_t, w9_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w9_t, SHA256C19);
    wa_t = SHA256_EXPAND (w8_t, w3_t, wb_t, wa_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, wa_t, SHA256C1a);
    wb_t = SHA256_EXPAND (w9_t, w4_t, wc_t, wb_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, wb_t, SHA256C1b);
    wc_t = SHA256_EXPAND (wa_t, w5_t, wd_t, wc_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, wc_t, SHA256C1c);
    wd_t = SHA256_EXPAND (wb_t, w6_t, we_t, wd_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, wd_t, SHA256C1d);
    we_t = SHA256_EXPAND (wc_t, w7_t, wf_t, we_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, we_t, SHA256C1e);
    wf_t = SHA256_EXPAND (wd_t, w8_t, w0_t, wf_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, wf_t, SHA256C1f);

    w0_t = SHA256_EXPAND (we_t, w9_t, w1_t, w0_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w0_t, SHA256C20);
    w1_t = SHA256_EXPAND (wf_t, wa_t, w2_t, w1_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w1_t, SHA256C21);
    w2_t = SHA256_EXPAND (w0_t, wb_t, w3_t, w2_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, w2_t, SHA256C22);
    w3_t = SHA256_EXPAND (w1_t, wc_t, w4_t, w3_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, w3_t, SHA256C23);
    w4_t = SHA256_EXPAND (w2_t, wd_t, w5_t, w4_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, w4_t, SHA256C24);
    w5_t = SHA256_EXPAND (w3_t, we_t, w6_t, w5_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, w5_t, SHA256C25);
    w6_t = SHA256_EXPAND (w4_t, wf_t, w7_t, w6_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, w6_t, SHA256C26);
    w7_t = SHA256_EXPAND (w5_t, w0_t, w8_t, w7_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, w7_t, SHA256C27);
    w8_t = SHA256_EXPAND (w6_t, w1_t, w9_t, w8_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w8_t, SHA256C28);
    w9_t = SHA256_EXPAND (w7_t, w2_t, wa_t, w9_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w9_t, SHA256C29);
    wa_t = SHA256_EXPAND (w8_t, w3_t, wb_t, wa_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, wa_t, SHA256C2a);
    wb_t = SHA256_EXPAND (w9_t, w4_t, wc_t, wb_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, wb_t, SHA256C2b);
    wc_t = SHA256_EXPAND (wa_t, w5_t, wd_t, wc_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, wc_t, SHA256C2c);
    wd_t = SHA256_EXPAND (wb_t, w6_t, we_t, wd_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, wd_t, SHA256C2d);
    we_t = SHA256_EXPAND (wc_t, w7_t, wf_t, we_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, we_t, SHA256C2e);
    wf_t = SHA256_EXPAND (wd_t, w8_t, w0_t, wf_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, wf_t, SHA256C2f);

    w0_t = SHA256_EXPAND (we_t, w9_t, w1_t, w0_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w0_t, SHA256C30);
    w1_t = SHA256_EXPAND (wf_t, wa_t, w2_t, w1_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w1_t, SHA256C31);
    w2_t = SHA256_EXPAND (w0_t, wb_t, w3_t, w2_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, w2_t, SHA256C32);
    w3_t = SHA256_EXPAND (w1_t, wc_t, w4_t, w3_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, w3_t, SHA256C33);
    w4_t = SHA256_EXPAND (w2_t, wd_t, w5_t, w4_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, w4_t, SHA256C34);
    w5_t = SHA256_EXPAND (w3_t, we_t, w6_t, w5_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, w5_t, SHA256C35);
    w6_t = SHA256_EXPAND (w4_t, wf_t, w7_t, w6_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, w6_t, SHA256C36);
    w7_t = SHA256_EXPAND (w5_t, w0_t, w8_t, w7_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, w7_t, SHA256C37);
    w8_t = SHA256_EXPAND (w6_t, w1_t, w9_t, w8_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w8_t, SHA256C38);
    w9_t = SHA256_EXPAND (w7_t, w2_t, wa_t, w9_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w9_t, SHA256C39);
    wa_t = SHA256_EXPAND (w8_t, w3_t, wb_t, wa_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, wa_t, SHA256C3a);
    wb_t = SHA256_EXPAND (w9_t, w4_t, wc_t, wb_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, wb_t, SHA256C3b);
    wc_t = SHA256_EXPAND (wa_t, w5_t, wd_t, wc_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, wc_t, SHA256C3c);
    wd_t = SHA256_EXPAND (wb_t, w6_t, we_t, wd_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, wd_t, SHA256C3d);
    we_t = SHA256_EXPAND (wc_t, w7_t, wf_t, we_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, we_t, SHA256C3e);
    wf_t = SHA256_EXPAND (wd_t, w8_t, w0_t, wf_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, wf_t, SHA256C3f);

    COMPARE_M_SIMD (d, h, c, g);
  }
}

DECLSPEC void m01430s (PRIVATE_AS u32 *w, const u32 pw_len, KERN_ATTR_FUNC_VECTOR ())
{
  /**
   * modifiers are taken from args
   */

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
   * reverse
   */

  u32 a_rev = digests_buf[DIGESTS_OFFSET_HOST].digest_buf[0];
  u32 b_rev = digests_buf[DIGESTS_OFFSET_HOST].digest_buf[1];
  u32 c_rev = digests_buf[DIGESTS_OFFSET_HOST].digest_buf[2];
  u32 d_rev = digests_buf[DIGESTS_OFFSET_HOST].digest_buf[3];
  u32 e_rev = digests_buf[DIGESTS_OFFSET_HOST].digest_buf[4];
  u32 f_rev = digests_buf[DIGESTS_OFFSET_HOST].digest_buf[5];
  u32 g_rev = digests_buf[DIGESTS_OFFSET_HOST].digest_buf[6];
  u32 h_rev = digests_buf[DIGESTS_OFFSET_HOST].digest_buf[7];

  SHA256_STEP_REV (a_rev, b_rev, c_rev, d_rev, e_rev, f_rev, g_rev, h_rev);
  SHA256_STEP_REV (a_rev, b_rev, c_rev, d_rev, e_rev, f_rev, g_rev, h_rev);
  SHA256_STEP_REV (a_rev, b_rev, c_rev, d_rev, e_rev, f_rev, g_rev, h_rev);
  SHA256_STEP_REV (a_rev, b_rev, c_rev, d_rev, e_rev, f_rev, g_rev, h_rev);

  /**
   * loop
   */

  u32 w0l = w[0];

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x w0r = words_buf_r[il_pos / VECT_SIZE];

    const u32x w0 = w0l | w0r;

    u32x w0_t = w0;
    u32x w1_t = w[ 1];
    u32x w2_t = w[ 2];
    u32x w3_t = w[ 3];
    u32x w4_t = w[ 4];
    u32x w5_t = w[ 5];
    u32x w6_t = w[ 6];
    u32x w7_t = w[ 7];
    u32x w8_t = w[ 8];
    u32x w9_t = w[ 9];
    u32x wa_t = w[10];
    u32x wb_t = w[11];
    u32x wc_t = w[12];
    u32x wd_t = w[13];
    u32x we_t = w[14];
    u32x wf_t = w[15];

    u32x a = SHA256M_A;
    u32x b = SHA256M_B;
    u32x c = SHA256M_C;
    u32x d = SHA256M_D;
    u32x e = SHA256M_E;
    u32x f = SHA256M_F;
    u32x g = SHA256M_G;
    u32x h = SHA256M_H;

    SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w0_t, SHA256C00);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w1_t, SHA256C01);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, w2_t, SHA256C02);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, w3_t, SHA256C03);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, w4_t, SHA256C04);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, w5_t, SHA256C05);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, w6_t, SHA256C06);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, w7_t, SHA256C07);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w8_t, SHA256C08);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w9_t, SHA256C09);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, wa_t, SHA256C0a);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, wb_t, SHA256C0b);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, wc_t, SHA256C0c);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, wd_t, SHA256C0d);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, we_t, SHA256C0e);
    SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, wf_t, SHA256C0f);

    w0_t = SHA256_EXPAND (we_t, w9_t, w1_t, w0_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w0_t, SHA256C10);
    w1_t = SHA256_EXPAND (wf_t, wa_t, w2_t, w1_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w1_t, SHA256C11);
    w2_t = SHA256_EXPAND (w0_t, wb_t, w3_t, w2_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, w2_t, SHA256C12);
    w3_t = SHA256_EXPAND (w1_t, wc_t, w4_t, w3_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, w3_t, SHA256C13);
    w4_t = SHA256_EXPAND (w2_t, wd_t, w5_t, w4_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, w4_t, SHA256C14);
    w5_t = SHA256_EXPAND (w3_t, we_t, w6_t, w5_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, w5_t, SHA256C15);
    w6_t = SHA256_EXPAND (w4_t, wf_t, w7_t, w6_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, w6_t, SHA256C16);
    w7_t = SHA256_EXPAND (w5_t, w0_t, w8_t, w7_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, w7_t, SHA256C17);
    w8_t = SHA256_EXPAND (w6_t, w1_t, w9_t, w8_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w8_t, SHA256C18);
    w9_t = SHA256_EXPAND (w7_t, w2_t, wa_t, w9_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w9_t, SHA256C19);
    wa_t = SHA256_EXPAND (w8_t, w3_t, wb_t, wa_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, wa_t, SHA256C1a);
    wb_t = SHA256_EXPAND (w9_t, w4_t, wc_t, wb_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, wb_t, SHA256C1b);
    wc_t = SHA256_EXPAND (wa_t, w5_t, wd_t, wc_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, wc_t, SHA256C1c);
    wd_t = SHA256_EXPAND (wb_t, w6_t, we_t, wd_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, wd_t, SHA256C1d);
    we_t = SHA256_EXPAND (wc_t, w7_t, wf_t, we_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, we_t, SHA256C1e);
    wf_t = SHA256_EXPAND (wd_t, w8_t, w0_t, wf_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, wf_t, SHA256C1f);

    w0_t = SHA256_EXPAND (we_t, w9_t, w1_t, w0_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w0_t, SHA256C20);
    w1_t = SHA256_EXPAND (wf_t, wa_t, w2_t, w1_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w1_t, SHA256C21);
    w2_t = SHA256_EXPAND (w0_t, wb_t, w3_t, w2_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, w2_t, SHA256C22);
    w3_t = SHA256_EXPAND (w1_t, wc_t, w4_t, w3_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, w3_t, SHA256C23);
    w4_t = SHA256_EXPAND (w2_t, wd_t, w5_t, w4_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, w4_t, SHA256C24);
    w5_t = SHA256_EXPAND (w3_t, we_t, w6_t, w5_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, w5_t, SHA256C25);
    w6_t = SHA256_EXPAND (w4_t, wf_t, w7_t, w6_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, w6_t, SHA256C26);
    w7_t = SHA256_EXPAND (w5_t, w0_t, w8_t, w7_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, w7_t, SHA256C27);
    w8_t = SHA256_EXPAND (w6_t, w1_t, w9_t, w8_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w8_t, SHA256C28);
    w9_t = SHA256_EXPAND (w7_t, w2_t, wa_t, w9_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w9_t, SHA256C29);
    wa_t = SHA256_EXPAND (w8_t, w3_t, wb_t, wa_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, wa_t, SHA256C2a);
    wb_t = SHA256_EXPAND (w9_t, w4_t, wc_t, wb_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, wb_t, SHA256C2b);
    wc_t = SHA256_EXPAND (wa_t, w5_t, wd_t, wc_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, wc_t, SHA256C2c);
    wd_t = SHA256_EXPAND (wb_t, w6_t, we_t, wd_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, wd_t, SHA256C2d);
    we_t = SHA256_EXPAND (wc_t, w7_t, wf_t, we_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, we_t, SHA256C2e);
    wf_t = SHA256_EXPAND (wd_t, w8_t, w0_t, wf_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, wf_t, SHA256C2f);

    w0_t = SHA256_EXPAND (we_t, w9_t, w1_t, w0_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w0_t, SHA256C30);
    w1_t = SHA256_EXPAND (wf_t, wa_t, w2_t, w1_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w1_t, SHA256C31);
    w2_t = SHA256_EXPAND (w0_t, wb_t, w3_t, w2_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, w2_t, SHA256C32);
    w3_t = SHA256_EXPAND (w1_t, wc_t, w4_t, w3_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, w3_t, SHA256C33);
    w4_t = SHA256_EXPAND (w2_t, wd_t, w5_t, w4_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, w4_t, SHA256C34);
    w5_t = SHA256_EXPAND (w3_t, we_t, w6_t, w5_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, w5_t, SHA256C35);
    w6_t = SHA256_EXPAND (w4_t, wf_t, w7_t, w6_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, w6_t, SHA256C36);
    w7_t = SHA256_EXPAND (w5_t, w0_t, w8_t, w7_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, w7_t, SHA256C37);
    w8_t = SHA256_EXPAND (w6_t, w1_t, w9_t, w8_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w8_t, SHA256C38);

    if (MATCHES_NONE_VS (h, d_rev)) continue;

    w9_t = SHA256_EXPAND (w7_t, w2_t, wa_t, w9_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w9_t, SHA256C39);
    wa_t = SHA256_EXPAND (w8_t, w3_t, wb_t, wa_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, wa_t, SHA256C3a);
    wb_t = SHA256_EXPAND (w9_t, w4_t, wc_t, wb_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, wb_t, SHA256C3b);
    wc_t = SHA256_EXPAND (wa_t, w5_t, wd_t, wc_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, wc_t, SHA256C3c);
    wd_t = SHA256_EXPAND (wb_t, w6_t, we_t, wd_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, wd_t, SHA256C3d);
    we_t = SHA256_EXPAND (wc_t, w7_t, wf_t, we_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, we_t, SHA256C3e);
    wf_t = SHA256_EXPAND (wd_t, w8_t, w0_t, wf_t); SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, wf_t, SHA256C3f);

    COMPARE_S_SIMD (d, h, c, g);
  }
}

KERNEL_FQ void m01430_m04 (KERN_ATTR_VECTOR ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = 0;
  w[ 5] = 0;
  w[ 6] = 0;
  w[ 7] = 0;
  w[ 8] = 0;
  w[ 9] = 0;
  w[10] = 0;
  w[11] = 0;
  w[12] = 0;
  w[13] = 0;
  w[14] = 0;
  w[15] = pws[gid].i[15];

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01430m (w, pw_len, pws, rules_buf, combs_buf, words_buf_r, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ void m01430_m08 (KERN_ATTR_VECTOR ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = pws[gid].i[ 4];
  w[ 5] = pws[gid].i[ 5];
  w[ 6] = pws[gid].i[ 6];
  w[ 7] = pws[gid].i[ 7];
  w[ 8] = 0;
  w[ 9] = 0;
  w[10] = 0;
  w[11] = 0;
  w[12] = 0;
  w[13] = 0;
  w[14] = 0;
  w[15] = pws[gid].i[15];

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01430m (w, pw_len, pws, rules_buf, combs_buf, words_buf_r, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ void m01430_m16 (KERN_ATTR_VECTOR ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = pws[gid].i[ 4];
  w[ 5] = pws[gid].i[ 5];
  w[ 6] = pws[gid].i[ 6];
  w[ 7] = pws[gid].i[ 7];
  w[ 8] = pws[gid].i[ 8];
  w[ 9] = pws[gid].i[ 9];
  w[10] = pws[gid].i[10];
  w[11] = pws[gid].i[11];
  w[12] = pws[gid].i[12];
  w[13] = pws[gid].i[13];
  w[14] = pws[gid].i[14];
  w[15] = pws[gid].i[15];

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01430m (w, pw_len, pws, rules_buf, combs_buf, words_buf_r, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ void m01430_s04 (KERN_ATTR_VECTOR ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = 0;
  w[ 5] = 0;
  w[ 6] = 0;
  w[ 7] = 0;
  w[ 8] = 0;
  w[ 9] = 0;
  w[10] = 0;
  w[11] = 0;
  w[12] = 0;
  w[13] = 0;
  w[14] = 0;
  w[15] = pws[gid].i[15];

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01430s (w, pw_len, pws, rules_buf, combs_buf, words_buf_r, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ void m01430_s08 (KERN_ATTR_VECTOR ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = pws[gid].i[ 4];
  w[ 5] = pws[gid].i[ 5];
  w[ 6] = pws[gid].i[ 6];
  w[ 7] = pws[gid].i[ 7];
  w[ 8] = 0;
  w[ 9] = 0;
  w[10] = 0;
  w[11] = 0;
  w[12] = 0;
  w[13] = 0;
  w[14] = 0;
  w[15] = pws[gid].i[15];

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01430s (w, pw_len, pws, rules_buf, combs_buf, words_buf_r, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}

KERNEL_FQ void m01430_s16 (KERN_ATTR_VECTOR ())
{
  /**
   * base
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);
  const u64 lsz = get_local_size (0);

  if (gid >= GID_CNT) return;

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = pws[gid].i[ 4];
  w[ 5] = pws[gid].i[ 5];
  w[ 6] = pws[gid].i[ 6];
  w[ 7] = pws[gid].i[ 7];
  w[ 8] = pws[gid].i[ 8];
  w[ 9] = pws[gid].i[ 9];
  w[10] = pws[gid].i[10];
  w[11] = pws[gid].i[11];
  w[12] = pws[gid].i[12];
  w[13] = pws[gid].i[13];
  w[14] = pws[gid].i[14];
  w[15] = pws[gid].i[15];

  const u32 pw_len = pws[gid].pw_len & 63;

  /**
   * main
   */

  m01430s (w, pw_len, pws, rules_buf, combs_buf, words_buf_r, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_extra0_buf, d_extra1_buf, d_extra2_buf, d_extra3_buf, kernel_param, gid, lid, lsz);
}
