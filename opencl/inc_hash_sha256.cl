/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#include "inc_vendor.h"
#include "inc_types.h"
#include "inc_platform.h"
#include "inc_common.h"
#include "inc_hash_sha256.h"

CONSTANT_VK u32a k_sha256[64] =
{
  SHA256C00, SHA256C01, SHA256C02, SHA256C03,
  SHA256C04, SHA256C05, SHA256C06, SHA256C07,
  SHA256C08, SHA256C09, SHA256C0a, SHA256C0b,
  SHA256C0c, SHA256C0d, SHA256C0e, SHA256C0f,
  SHA256C10, SHA256C11, SHA256C12, SHA256C13,
  SHA256C14, SHA256C15, SHA256C16, SHA256C17,
  SHA256C18, SHA256C19, SHA256C1a, SHA256C1b,
  SHA256C1c, SHA256C1d, SHA256C1e, SHA256C1f,
  SHA256C20, SHA256C21, SHA256C22, SHA256C23,
  SHA256C24, SHA256C25, SHA256C26, SHA256C27,
  SHA256C28, SHA256C29, SHA256C2a, SHA256C2b,
  SHA256C2c, SHA256C2d, SHA256C2e, SHA256C2f,
  SHA256C30, SHA256C31, SHA256C32, SHA256C33,
  SHA256C34, SHA256C35, SHA256C36, SHA256C37,
  SHA256C38, SHA256C39, SHA256C3a, SHA256C3b,
  SHA256C3c, SHA256C3d, SHA256C3e, SHA256C3f,
};

// important notes on this:
// input buf unused bytes needs to be set to zero
// input buf needs to be in algorithm native byte order (md5 = LE, sha256 = BE, etc)
// input buf needs to be 64 byte aligned when using sha256_update()

DECLSPEC void sha256_transform (PRIVATE_AS const u32 *w0, PRIVATE_AS const u32 *w1, PRIVATE_AS const u32 *w2, PRIVATE_AS const u32 *w3, PRIVATE_AS u32 *digest)
{
  u32 a = digest[0];
  u32 b = digest[1];
  u32 c = digest[2];
  u32 d = digest[3];
  u32 e = digest[4];
  u32 f = digest[5];
  u32 g = digest[6];
  u32 h = digest[7];

  u32 w0_t = w0[0];
  u32 w1_t = w0[1];
  u32 w2_t = w0[2];
  u32 w3_t = w0[3];
  u32 w4_t = w1[0];
  u32 w5_t = w1[1];
  u32 w6_t = w1[2];
  u32 w7_t = w1[3];
  u32 w8_t = w2[0];
  u32 w9_t = w2[1];
  u32 wa_t = w2[2];
  u32 wb_t = w2[3];
  u32 wc_t = w3[0];
  u32 wd_t = w3[1];
  u32 we_t = w3[2];
  u32 wf_t = w3[3];

  #define ROUND_EXPAND_S()                            \
  {                                                   \
    w0_t = SHA256_EXPAND_S (we_t, w9_t, w1_t, w0_t);  \
    w1_t = SHA256_EXPAND_S (wf_t, wa_t, w2_t, w1_t);  \
    w2_t = SHA256_EXPAND_S (w0_t, wb_t, w3_t, w2_t);  \
    w3_t = SHA256_EXPAND_S (w1_t, wc_t, w4_t, w3_t);  \
    w4_t = SHA256_EXPAND_S (w2_t, wd_t, w5_t, w4_t);  \
    w5_t = SHA256_EXPAND_S (w3_t, we_t, w6_t, w5_t);  \
    w6_t = SHA256_EXPAND_S (w4_t, wf_t, w7_t, w6_t);  \
    w7_t = SHA256_EXPAND_S (w5_t, w0_t, w8_t, w7_t);  \
    w8_t = SHA256_EXPAND_S (w6_t, w1_t, w9_t, w8_t);  \
    w9_t = SHA256_EXPAND_S (w7_t, w2_t, wa_t, w9_t);  \
    wa_t = SHA256_EXPAND_S (w8_t, w3_t, wb_t, wa_t);  \
    wb_t = SHA256_EXPAND_S (w9_t, w4_t, wc_t, wb_t);  \
    wc_t = SHA256_EXPAND_S (wa_t, w5_t, wd_t, wc_t);  \
    wd_t = SHA256_EXPAND_S (wb_t, w6_t, we_t, wd_t);  \
    we_t = SHA256_EXPAND_S (wc_t, w7_t, wf_t, we_t);  \
    wf_t = SHA256_EXPAND_S (wd_t, w8_t, w0_t, wf_t);  \
  }

  #define ROUND_STEP_S(i)                                                                   \
  {                                                                                         \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w0_t, k_sha256[i +  0]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w1_t, k_sha256[i +  1]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, w2_t, k_sha256[i +  2]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, w3_t, k_sha256[i +  3]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, w4_t, k_sha256[i +  4]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, w5_t, k_sha256[i +  5]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, w6_t, k_sha256[i +  6]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, w7_t, k_sha256[i +  7]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w8_t, k_sha256[i +  8]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w9_t, k_sha256[i +  9]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, wa_t, k_sha256[i + 10]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, wb_t, k_sha256[i + 11]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, wc_t, k_sha256[i + 12]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, wd_t, k_sha256[i + 13]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, we_t, k_sha256[i + 14]); \
    SHA256_STEP_S (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, wf_t, k_sha256[i + 15]); \
  }

  ROUND_STEP_S (0);

  #ifdef _unroll
  #pragma unroll
  #endif
  for (int i = 16; i < 64; i += 16)
  {
    ROUND_EXPAND_S (); ROUND_STEP_S (i);
  }

  #undef ROUND_EXPAND_S
  #undef ROUND_STEP_S

  digest[0] += a;
  digest[1] += b;
  digest[2] += c;
  digest[3] += d;
  digest[4] += e;
  digest[5] += f;
  digest[6] += g;
  digest[7] += h;
}

DECLSPEC void sha256_init (PRIVATE_AS sha256_ctx_t *ctx)
{
  ctx->h[0] = SHA256M_A;
  ctx->h[1] = SHA256M_B;
  ctx->h[2] = SHA256M_C;
  ctx->h[3] = SHA256M_D;
  ctx->h[4] = SHA256M_E;
  ctx->h[5] = SHA256M_F;
  ctx->h[6] = SHA256M_G;
  ctx->h[7] = SHA256M_H;

  ctx->w0[0] = 0;
  ctx->w0[1] = 0;
  ctx->w0[2] = 0;
  ctx->w0[3] = 0;
  ctx->w1[0] = 0;
  ctx->w1[1] = 0;
  ctx->w1[2] = 0;
  ctx->w1[3] = 0;
  ctx->w2[0] = 0;
  ctx->w2[1] = 0;
  ctx->w2[2] = 0;
  ctx->w2[3] = 0;
  ctx->w3[0] = 0;
  ctx->w3[1] = 0;
  ctx->w3[2] = 0;
  ctx->w3[3] = 0;

  ctx->len = 0;
}

DECLSPEC void sha256_update_64 (PRIVATE_AS sha256_ctx_t *ctx, PRIVATE_AS u32 *w0, PRIVATE_AS u32 *w1, PRIVATE_AS u32 *w2, PRIVATE_AS u32 *w3, const int len)
{
  if (len == 0) return;

  const int pos = ctx->len & 63;

  ctx->len += len;

  if (pos == 0)
  {
    ctx->w0[0] = w0[0];
    ctx->w0[1] = w0[1];
    ctx->w0[2] = w0[2];
    ctx->w0[3] = w0[3];
    ctx->w1[0] = w1[0];
    ctx->w1[1] = w1[1];
    ctx->w1[2] = w1[2];
    ctx->w1[3] = w1[3];
    ctx->w2[0] = w2[0];
    ctx->w2[1] = w2[1];
    ctx->w2[2] = w2[2];
    ctx->w2[3] = w2[3];
    ctx->w3[0] = w3[0];
    ctx->w3[1] = w3[1];
    ctx->w3[2] = w3[2];
    ctx->w3[3] = w3[3];

    if (len == 64)
    {
      sha256_transform (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

      ctx->w0[0] = 0;
      ctx->w0[1] = 0;
      ctx->w0[2] = 0;
      ctx->w0[3] = 0;
      ctx->w1[0] = 0;
      ctx->w1[1] = 0;
      ctx->w1[2] = 0;
      ctx->w1[3] = 0;
      ctx->w2[0] = 0;
      ctx->w2[1] = 0;
      ctx->w2[2] = 0;
      ctx->w2[3] = 0;
      ctx->w3[0] = 0;
      ctx->w3[1] = 0;
      ctx->w3[2] = 0;
      ctx->w3[3] = 0;
    }
  }
  else
  {
    if ((pos + len) < 64)
    {
      switch_buffer_by_offset_be_S (w0, w1, w2, w3, pos);

      ctx->w0[0] |= w0[0];
      ctx->w0[1] |= w0[1];
      ctx->w0[2] |= w0[2];
      ctx->w0[3] |= w0[3];
      ctx->w1[0] |= w1[0];
      ctx->w1[1] |= w1[1];
      ctx->w1[2] |= w1[2];
      ctx->w1[3] |= w1[3];
      ctx->w2[0] |= w2[0];
      ctx->w2[1] |= w2[1];
      ctx->w2[2] |= w2[2];
      ctx->w2[3] |= w2[3];
      ctx->w3[0] |= w3[0];
      ctx->w3[1] |= w3[1];
      ctx->w3[2] |= w3[2];
      ctx->w3[3] |= w3[3];
    }
    else
    {
      u32 c0[4] = { 0 };
      u32 c1[4] = { 0 };
      u32 c2[4] = { 0 };
      u32 c3[4] = { 0 };

      switch_buffer_by_offset_carry_be_S (w0, w1, w2, w3, c0, c1, c2, c3, pos);

      ctx->w0[0] |= w0[0];
      ctx->w0[1] |= w0[1];
      ctx->w0[2] |= w0[2];
      ctx->w0[3] |= w0[3];
      ctx->w1[0] |= w1[0];
      ctx->w1[1] |= w1[1];
      ctx->w1[2] |= w1[2];
      ctx->w1[3] |= w1[3];
      ctx->w2[0] |= w2[0];
      ctx->w2[1] |= w2[1];
      ctx->w2[2] |= w2[2];
      ctx->w2[3] |= w2[3];
      ctx->w3[0] |= w3[0];
      ctx->w3[1] |= w3[1];
      ctx->w3[2] |= w3[2];
      ctx->w3[3] |= w3[3];

      sha256_transform (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

      ctx->w0[0] = c0[0];
      ctx->w0[1] = c0[1];
      ctx->w0[2] = c0[2];
      ctx->w0[3] = c0[3];
      ctx->w1[0] = c1[0];
      ctx->w1[1] = c1[1];
      ctx->w1[2] = c1[2];
      ctx->w1[3] = c1[3];
      ctx->w2[0] = c2[0];
      ctx->w2[1] = c2[1];
      ctx->w2[2] = c2[2];
      ctx->w2[3] = c2[3];
      ctx->w3[0] = c3[0];
      ctx->w3[1] = c3[1];
      ctx->w3[2] = c3[2];
      ctx->w3[3] = c3[3];
    }
  }
}

DECLSPEC void sha256_update (PRIVATE_AS sha256_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    sha256_update_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  sha256_update_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sha256_update_swap (PRIVATE_AS sha256_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    w0[0] = hc_swap32_S (w0[0]);
    w0[1] = hc_swap32_S (w0[1]);
    w0[2] = hc_swap32_S (w0[2]);
    w0[3] = hc_swap32_S (w0[3]);
    w1[0] = hc_swap32_S (w1[0]);
    w1[1] = hc_swap32_S (w1[1]);
    w1[2] = hc_swap32_S (w1[2]);
    w1[3] = hc_swap32_S (w1[3]);
    w2[0] = hc_swap32_S (w2[0]);
    w2[1] = hc_swap32_S (w2[1]);
    w2[2] = hc_swap32_S (w2[2]);
    w2[3] = hc_swap32_S (w2[3]);
    w3[0] = hc_swap32_S (w3[0]);
    w3[1] = hc_swap32_S (w3[1]);
    w3[2] = hc_swap32_S (w3[2]);
    w3[3] = hc_swap32_S (w3[3]);

    sha256_update_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  w0[0] = hc_swap32_S (w0[0]);
  w0[1] = hc_swap32_S (w0[1]);
  w0[2] = hc_swap32_S (w0[2]);
  w0[3] = hc_swap32_S (w0[3]);
  w1[0] = hc_swap32_S (w1[0]);
  w1[1] = hc_swap32_S (w1[1]);
  w1[2] = hc_swap32_S (w1[2]);
  w1[3] = hc_swap32_S (w1[3]);
  w2[0] = hc_swap32_S (w2[0]);
  w2[1] = hc_swap32_S (w2[1]);
  w2[2] = hc_swap32_S (w2[2]);
  w2[3] = hc_swap32_S (w2[3]);
  w3[0] = hc_swap32_S (w3[0]);
  w3[1] = hc_swap32_S (w3[1]);
  w3[2] = hc_swap32_S (w3[2]);
  w3[3] = hc_swap32_S (w3[3]);

  sha256_update_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sha256_update_utf16le (PRIVATE_AS sha256_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  if (hc_enc_scan (w, len))
  {
    hc_enc_t hc_enc;

    hc_enc_init (&hc_enc);

    while (hc_enc_has_next (&hc_enc, len))
    {
      u32 enc_buf[16] = { 0 };

      const int enc_len = hc_enc_next (&hc_enc, w, len, 256, enc_buf, sizeof (enc_buf));

      if (enc_len == -1)
      {
        ctx->len = -1;

        return;
      }

      sha256_update_64 (ctx, enc_buf + 0, enc_buf + 4, enc_buf + 8, enc_buf + 12, enc_len);
    }

    return;
  }

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le_S (w1, w2, w3);
    make_utf16le_S (w0, w0, w1);

    sha256_update_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le_S (w1, w2, w3);
  make_utf16le_S (w0, w0, w1);

  sha256_update_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sha256_update_utf16le_swap (PRIVATE_AS sha256_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  if (hc_enc_scan (w, len))
  {
    hc_enc_t hc_enc;

    hc_enc_init (&hc_enc);

    while (hc_enc_has_next (&hc_enc, len))
    {
      u32 enc_buf[16] = { 0 };

      const int enc_len = hc_enc_next (&hc_enc, w, len, 256, enc_buf, sizeof (enc_buf));

      if (enc_len == -1)
      {
        ctx->len = -1;

        return;
      }

      enc_buf[ 0] = hc_swap32_S (enc_buf[ 0]);
      enc_buf[ 1] = hc_swap32_S (enc_buf[ 1]);
      enc_buf[ 2] = hc_swap32_S (enc_buf[ 2]);
      enc_buf[ 3] = hc_swap32_S (enc_buf[ 3]);
      enc_buf[ 4] = hc_swap32_S (enc_buf[ 4]);
      enc_buf[ 5] = hc_swap32_S (enc_buf[ 5]);
      enc_buf[ 6] = hc_swap32_S (enc_buf[ 6]);
      enc_buf[ 7] = hc_swap32_S (enc_buf[ 7]);
      enc_buf[ 8] = hc_swap32_S (enc_buf[ 8]);
      enc_buf[ 9] = hc_swap32_S (enc_buf[ 9]);
      enc_buf[10] = hc_swap32_S (enc_buf[10]);
      enc_buf[11] = hc_swap32_S (enc_buf[11]);
      enc_buf[12] = hc_swap32_S (enc_buf[12]);
      enc_buf[13] = hc_swap32_S (enc_buf[13]);
      enc_buf[14] = hc_swap32_S (enc_buf[14]);
      enc_buf[15] = hc_swap32_S (enc_buf[15]);

      sha256_update_64 (ctx, enc_buf + 0, enc_buf + 4, enc_buf + 8, enc_buf + 12, enc_len);
    }

    return;
  }

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le_S (w1, w2, w3);
    make_utf16le_S (w0, w0, w1);

    w0[0] = hc_swap32_S (w0[0]);
    w0[1] = hc_swap32_S (w0[1]);
    w0[2] = hc_swap32_S (w0[2]);
    w0[3] = hc_swap32_S (w0[3]);
    w1[0] = hc_swap32_S (w1[0]);
    w1[1] = hc_swap32_S (w1[1]);
    w1[2] = hc_swap32_S (w1[2]);
    w1[3] = hc_swap32_S (w1[3]);
    w2[0] = hc_swap32_S (w2[0]);
    w2[1] = hc_swap32_S (w2[1]);
    w2[2] = hc_swap32_S (w2[2]);
    w2[3] = hc_swap32_S (w2[3]);
    w3[0] = hc_swap32_S (w3[0]);
    w3[1] = hc_swap32_S (w3[1]);
    w3[2] = hc_swap32_S (w3[2]);
    w3[3] = hc_swap32_S (w3[3]);

    sha256_update_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le_S (w1, w2, w3);
  make_utf16le_S (w0, w0, w1);

  w0[0] = hc_swap32_S (w0[0]);
  w0[1] = hc_swap32_S (w0[1]);
  w0[2] = hc_swap32_S (w0[2]);
  w0[3] = hc_swap32_S (w0[3]);
  w1[0] = hc_swap32_S (w1[0]);
  w1[1] = hc_swap32_S (w1[1]);
  w1[2] = hc_swap32_S (w1[2]);
  w1[3] = hc_swap32_S (w1[3]);
  w2[0] = hc_swap32_S (w2[0]);
  w2[1] = hc_swap32_S (w2[1]);
  w2[2] = hc_swap32_S (w2[2]);
  w2[3] = hc_swap32_S (w2[3]);
  w3[0] = hc_swap32_S (w3[0]);
  w3[1] = hc_swap32_S (w3[1]);
  w3[2] = hc_swap32_S (w3[2]);
  w3[3] = hc_swap32_S (w3[3]);

  sha256_update_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sha256_update_global (PRIVATE_AS sha256_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    sha256_update_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  sha256_update_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sha256_update_global_swap (PRIVATE_AS sha256_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    w0[0] = hc_swap32_S (w0[0]);
    w0[1] = hc_swap32_S (w0[1]);
    w0[2] = hc_swap32_S (w0[2]);
    w0[3] = hc_swap32_S (w0[3]);
    w1[0] = hc_swap32_S (w1[0]);
    w1[1] = hc_swap32_S (w1[1]);
    w1[2] = hc_swap32_S (w1[2]);
    w1[3] = hc_swap32_S (w1[3]);
    w2[0] = hc_swap32_S (w2[0]);
    w2[1] = hc_swap32_S (w2[1]);
    w2[2] = hc_swap32_S (w2[2]);
    w2[3] = hc_swap32_S (w2[3]);
    w3[0] = hc_swap32_S (w3[0]);
    w3[1] = hc_swap32_S (w3[1]);
    w3[2] = hc_swap32_S (w3[2]);
    w3[3] = hc_swap32_S (w3[3]);

    sha256_update_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  w0[0] = hc_swap32_S (w0[0]);
  w0[1] = hc_swap32_S (w0[1]);
  w0[2] = hc_swap32_S (w0[2]);
  w0[3] = hc_swap32_S (w0[3]);
  w1[0] = hc_swap32_S (w1[0]);
  w1[1] = hc_swap32_S (w1[1]);
  w1[2] = hc_swap32_S (w1[2]);
  w1[3] = hc_swap32_S (w1[3]);
  w2[0] = hc_swap32_S (w2[0]);
  w2[1] = hc_swap32_S (w2[1]);
  w2[2] = hc_swap32_S (w2[2]);
  w2[3] = hc_swap32_S (w2[3]);
  w3[0] = hc_swap32_S (w3[0]);
  w3[1] = hc_swap32_S (w3[1]);
  w3[2] = hc_swap32_S (w3[2]);
  w3[3] = hc_swap32_S (w3[3]);

  sha256_update_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sha256_update_global_utf16le (PRIVATE_AS sha256_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  if (hc_enc_scan_global (w, len))
  {
    hc_enc_t hc_enc;

    hc_enc_init (&hc_enc);

    while (hc_enc_has_next (&hc_enc, len))
    {
      u32 enc_buf[16] = { 0 };

      const int enc_len = hc_enc_next_global (&hc_enc, w, len, 256, enc_buf, sizeof (enc_buf));

      if (enc_len == -1)
      {
        ctx->len = -1;

        return;
      }

      sha256_update_64 (ctx, enc_buf + 0, enc_buf + 4, enc_buf + 8, enc_buf + 12, enc_len);
    }

    return;
  }

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le_S (w1, w2, w3);
    make_utf16le_S (w0, w0, w1);

    sha256_update_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le_S (w1, w2, w3);
  make_utf16le_S (w0, w0, w1);

  sha256_update_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sha256_update_global_utf16le_swap (PRIVATE_AS sha256_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  if (hc_enc_scan_global (w, len))
  {
    hc_enc_t hc_enc;

    hc_enc_init (&hc_enc);

    while (hc_enc_has_next (&hc_enc, len))
    {
      u32 enc_buf[16] = { 0 };

      const int enc_len = hc_enc_next_global (&hc_enc, w, len, 256, enc_buf, sizeof (enc_buf));

      if (enc_len == -1)
      {
        ctx->len = -1;

        return;
      }

      enc_buf[ 0] = hc_swap32_S (enc_buf[ 0]);
      enc_buf[ 1] = hc_swap32_S (enc_buf[ 1]);
      enc_buf[ 2] = hc_swap32_S (enc_buf[ 2]);
      enc_buf[ 3] = hc_swap32_S (enc_buf[ 3]);
      enc_buf[ 4] = hc_swap32_S (enc_buf[ 4]);
      enc_buf[ 5] = hc_swap32_S (enc_buf[ 5]);
      enc_buf[ 6] = hc_swap32_S (enc_buf[ 6]);
      enc_buf[ 7] = hc_swap32_S (enc_buf[ 7]);
      enc_buf[ 8] = hc_swap32_S (enc_buf[ 8]);
      enc_buf[ 9] = hc_swap32_S (enc_buf[ 9]);
      enc_buf[10] = hc_swap32_S (enc_buf[10]);
      enc_buf[11] = hc_swap32_S (enc_buf[11]);
      enc_buf[12] = hc_swap32_S (enc_buf[12]);
      enc_buf[13] = hc_swap32_S (enc_buf[13]);
      enc_buf[14] = hc_swap32_S (enc_buf[14]);
      enc_buf[15] = hc_swap32_S (enc_buf[15]);

      sha256_update_64 (ctx, enc_buf + 0, enc_buf + 4, enc_buf + 8, enc_buf + 12, enc_len);
    }

    return;
  }

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le_S (w1, w2, w3);
    make_utf16le_S (w0, w0, w1);

    w0[0] = hc_swap32_S (w0[0]);
    w0[1] = hc_swap32_S (w0[1]);
    w0[2] = hc_swap32_S (w0[2]);
    w0[3] = hc_swap32_S (w0[3]);
    w1[0] = hc_swap32_S (w1[0]);
    w1[1] = hc_swap32_S (w1[1]);
    w1[2] = hc_swap32_S (w1[2]);
    w1[3] = hc_swap32_S (w1[3]);
    w2[0] = hc_swap32_S (w2[0]);
    w2[1] = hc_swap32_S (w2[1]);
    w2[2] = hc_swap32_S (w2[2]);
    w2[3] = hc_swap32_S (w2[3]);
    w3[0] = hc_swap32_S (w3[0]);
    w3[1] = hc_swap32_S (w3[1]);
    w3[2] = hc_swap32_S (w3[2]);
    w3[3] = hc_swap32_S (w3[3]);

    sha256_update_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le_S (w1, w2, w3);
  make_utf16le_S (w0, w0, w1);

  w0[0] = hc_swap32_S (w0[0]);
  w0[1] = hc_swap32_S (w0[1]);
  w0[2] = hc_swap32_S (w0[2]);
  w0[3] = hc_swap32_S (w0[3]);
  w1[0] = hc_swap32_S (w1[0]);
  w1[1] = hc_swap32_S (w1[1]);
  w1[2] = hc_swap32_S (w1[2]);
  w1[3] = hc_swap32_S (w1[3]);
  w2[0] = hc_swap32_S (w2[0]);
  w2[1] = hc_swap32_S (w2[1]);
  w2[2] = hc_swap32_S (w2[2]);
  w2[3] = hc_swap32_S (w2[3]);
  w3[0] = hc_swap32_S (w3[0]);
  w3[1] = hc_swap32_S (w3[1]);
  w3[2] = hc_swap32_S (w3[2]);
  w3[3] = hc_swap32_S (w3[3]);

  sha256_update_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sha256_final (PRIVATE_AS sha256_ctx_t *ctx)
{
  const int pos = ctx->len & 63;

  append_0x80_4x4_S (ctx->w0, ctx->w1, ctx->w2, ctx->w3, pos ^ 3);

  if (pos >= 56)
  {
    sha256_transform (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

    ctx->w0[0] = 0;
    ctx->w0[1] = 0;
    ctx->w0[2] = 0;
    ctx->w0[3] = 0;
    ctx->w1[0] = 0;
    ctx->w1[1] = 0;
    ctx->w1[2] = 0;
    ctx->w1[3] = 0;
    ctx->w2[0] = 0;
    ctx->w2[1] = 0;
    ctx->w2[2] = 0;
    ctx->w2[3] = 0;
    ctx->w3[0] = 0;
    ctx->w3[1] = 0;
    ctx->w3[2] = 0;
    ctx->w3[3] = 0;
  }

  ctx->w3[2] = 0;
  ctx->w3[3] = ctx->len * 8;

  sha256_transform (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);
}

// sha256_hmac

DECLSPEC void sha256_hmac_init_64 (PRIVATE_AS sha256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w0, PRIVATE_AS const u32 *w1, PRIVATE_AS const u32 *w2, PRIVATE_AS const u32 *w3)
{
  u32 a0[4];
  u32 a1[4];
  u32 a2[4];
  u32 a3[4];

  // ipad

  a0[0] = w0[0] ^ 0x36363636;
  a0[1] = w0[1] ^ 0x36363636;
  a0[2] = w0[2] ^ 0x36363636;
  a0[3] = w0[3] ^ 0x36363636;
  a1[0] = w1[0] ^ 0x36363636;
  a1[1] = w1[1] ^ 0x36363636;
  a1[2] = w1[2] ^ 0x36363636;
  a1[3] = w1[3] ^ 0x36363636;
  a2[0] = w2[0] ^ 0x36363636;
  a2[1] = w2[1] ^ 0x36363636;
  a2[2] = w2[2] ^ 0x36363636;
  a2[3] = w2[3] ^ 0x36363636;
  a3[0] = w3[0] ^ 0x36363636;
  a3[1] = w3[1] ^ 0x36363636;
  a3[2] = w3[2] ^ 0x36363636;
  a3[3] = w3[3] ^ 0x36363636;

  sha256_init (&ctx->ipad);

  sha256_update_64 (&ctx->ipad, a0, a1, a2, a3, 64);

  // opad

  u32 b0[4];
  u32 b1[4];
  u32 b2[4];
  u32 b3[4];

  b0[0] = w0[0] ^ 0x5c5c5c5c;
  b0[1] = w0[1] ^ 0x5c5c5c5c;
  b0[2] = w0[2] ^ 0x5c5c5c5c;
  b0[3] = w0[3] ^ 0x5c5c5c5c;
  b1[0] = w1[0] ^ 0x5c5c5c5c;
  b1[1] = w1[1] ^ 0x5c5c5c5c;
  b1[2] = w1[2] ^ 0x5c5c5c5c;
  b1[3] = w1[3] ^ 0x5c5c5c5c;
  b2[0] = w2[0] ^ 0x5c5c5c5c;
  b2[1] = w2[1] ^ 0x5c5c5c5c;
  b2[2] = w2[2] ^ 0x5c5c5c5c;
  b2[3] = w2[3] ^ 0x5c5c5c5c;
  b3[0] = w3[0] ^ 0x5c5c5c5c;
  b3[1] = w3[1] ^ 0x5c5c5c5c;
  b3[2] = w3[2] ^ 0x5c5c5c5c;
  b3[3] = w3[3] ^ 0x5c5c5c5c;

  sha256_init (&ctx->opad);

  sha256_update_64 (&ctx->opad, b0, b1, b2, b3, 64);
}

DECLSPEC void sha256_hmac_init (PRIVATE_AS sha256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  if (len > 64)
  {
    sha256_ctx_t tmp;

    sha256_init (&tmp);

    sha256_update (&tmp, w, len);

    sha256_final (&tmp);

    w0[0] = tmp.h[0];
    w0[1] = tmp.h[1];
    w0[2] = tmp.h[2];
    w0[3] = tmp.h[3];
    w1[0] = tmp.h[4];
    w1[1] = tmp.h[5];
    w1[2] = tmp.h[6];
    w1[3] = tmp.h[7];
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;
  }
  else
  {
    w0[0] = w[ 0];
    w0[1] = w[ 1];
    w0[2] = w[ 2];
    w0[3] = w[ 3];
    w1[0] = w[ 4];
    w1[1] = w[ 5];
    w1[2] = w[ 6];
    w1[3] = w[ 7];
    w2[0] = w[ 8];
    w2[1] = w[ 9];
    w2[2] = w[10];
    w2[3] = w[11];
    w3[0] = w[12];
    w3[1] = w[13];
    w3[2] = w[14];
    w3[3] = w[15];
  }

  sha256_hmac_init_64 (ctx, w0, w1, w2, w3);
}

DECLSPEC void sha256_hmac_init_swap (PRIVATE_AS sha256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  if (len > 64)
  {
    sha256_ctx_t tmp;

    sha256_init (&tmp);

    sha256_update_swap (&tmp, w, len);

    sha256_final (&tmp);

    w0[0] = tmp.h[0];
    w0[1] = tmp.h[1];
    w0[2] = tmp.h[2];
    w0[3] = tmp.h[3];
    w1[0] = tmp.h[4];
    w1[1] = tmp.h[5];
    w1[2] = tmp.h[6];
    w1[3] = tmp.h[7];
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;
  }
  else
  {
    w0[0] = hc_swap32_S (w[ 0]);
    w0[1] = hc_swap32_S (w[ 1]);
    w0[2] = hc_swap32_S (w[ 2]);
    w0[3] = hc_swap32_S (w[ 3]);
    w1[0] = hc_swap32_S (w[ 4]);
    w1[1] = hc_swap32_S (w[ 5]);
    w1[2] = hc_swap32_S (w[ 6]);
    w1[3] = hc_swap32_S (w[ 7]);
    w2[0] = hc_swap32_S (w[ 8]);
    w2[1] = hc_swap32_S (w[ 9]);
    w2[2] = hc_swap32_S (w[10]);
    w2[3] = hc_swap32_S (w[11]);
    w3[0] = hc_swap32_S (w[12]);
    w3[1] = hc_swap32_S (w[13]);
    w3[2] = hc_swap32_S (w[14]);
    w3[3] = hc_swap32_S (w[15]);
  }

  sha256_hmac_init_64 (ctx, w0, w1, w2, w3);
}

DECLSPEC void sha256_hmac_init_global (PRIVATE_AS sha256_hmac_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  if (len > 64)
  {
    sha256_ctx_t tmp;

    sha256_init (&tmp);

    sha256_update_global (&tmp, w, len);

    sha256_final (&tmp);

    w0[0] = tmp.h[0];
    w0[1] = tmp.h[1];
    w0[2] = tmp.h[2];
    w0[3] = tmp.h[3];
    w1[0] = tmp.h[4];
    w1[1] = tmp.h[5];
    w1[2] = tmp.h[6];
    w1[3] = tmp.h[7];
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;
  }
  else
  {
    w0[0] = w[ 0];
    w0[1] = w[ 1];
    w0[2] = w[ 2];
    w0[3] = w[ 3];
    w1[0] = w[ 4];
    w1[1] = w[ 5];
    w1[2] = w[ 6];
    w1[3] = w[ 7];
    w2[0] = w[ 8];
    w2[1] = w[ 9];
    w2[2] = w[10];
    w2[3] = w[11];
    w3[0] = w[12];
    w3[1] = w[13];
    w3[2] = w[14];
    w3[3] = w[15];
  }

  sha256_hmac_init_64 (ctx, w0, w1, w2, w3);
}

DECLSPEC void sha256_hmac_init_global_swap (PRIVATE_AS sha256_hmac_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  if (len > 64)
  {
    sha256_ctx_t tmp;

    sha256_init (&tmp);

    sha256_update_global_swap (&tmp, w, len);

    sha256_final (&tmp);

    w0[0] = tmp.h[0];
    w0[1] = tmp.h[1];
    w0[2] = tmp.h[2];
    w0[3] = tmp.h[3];
    w1[0] = tmp.h[4];
    w1[1] = tmp.h[5];
    w1[2] = tmp.h[6];
    w1[3] = tmp.h[7];
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;
  }
  else
  {
    w0[0] = hc_swap32_S (w[ 0]);
    w0[1] = hc_swap32_S (w[ 1]);
    w0[2] = hc_swap32_S (w[ 2]);
    w0[3] = hc_swap32_S (w[ 3]);
    w1[0] = hc_swap32_S (w[ 4]);
    w1[1] = hc_swap32_S (w[ 5]);
    w1[2] = hc_swap32_S (w[ 6]);
    w1[3] = hc_swap32_S (w[ 7]);
    w2[0] = hc_swap32_S (w[ 8]);
    w2[1] = hc_swap32_S (w[ 9]);
    w2[2] = hc_swap32_S (w[10]);
    w2[3] = hc_swap32_S (w[11]);
    w3[0] = hc_swap32_S (w[12]);
    w3[1] = hc_swap32_S (w[13]);
    w3[2] = hc_swap32_S (w[14]);
    w3[3] = hc_swap32_S (w[15]);
  }

  sha256_hmac_init_64 (ctx, w0, w1, w2, w3);
}

DECLSPEC void sha256_hmac_update_64 (PRIVATE_AS sha256_hmac_ctx_t *ctx, PRIVATE_AS u32 *w0, PRIVATE_AS u32 *w1, PRIVATE_AS u32 *w2, PRIVATE_AS u32 *w3, const int len)
{
  sha256_update_64 (&ctx->ipad, w0, w1, w2, w3, len);
}

DECLSPEC void sha256_hmac_update (PRIVATE_AS sha256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  sha256_update (&ctx->ipad, w, len);
}

DECLSPEC void sha256_hmac_update_swap (PRIVATE_AS sha256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  sha256_update_swap (&ctx->ipad, w, len);
}

DECLSPEC void sha256_hmac_update_utf16le (PRIVATE_AS sha256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  sha256_update_utf16le (&ctx->ipad, w, len);
}

DECLSPEC void sha256_hmac_update_utf16le_swap (PRIVATE_AS sha256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len)
{
  sha256_update_utf16le_swap (&ctx->ipad, w, len);
}

DECLSPEC void sha256_hmac_update_global (PRIVATE_AS sha256_hmac_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  sha256_update_global (&ctx->ipad, w, len);
}

DECLSPEC void sha256_hmac_update_global_swap (PRIVATE_AS sha256_hmac_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  sha256_update_global_swap (&ctx->ipad, w, len);
}

DECLSPEC void sha256_hmac_update_global_utf16le (PRIVATE_AS sha256_hmac_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  sha256_update_global_utf16le (&ctx->ipad, w, len);
}

DECLSPEC void sha256_hmac_update_global_utf16le_swap (PRIVATE_AS sha256_hmac_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len)
{
  sha256_update_global_utf16le_swap (&ctx->ipad, w, len);
}

DECLSPEC void sha256_hmac_final (PRIVATE_AS sha256_hmac_ctx_t *ctx)
{
  sha256_final (&ctx->ipad);

  ctx->opad.w0[0] = ctx->ipad.h[0];
  ctx->opad.w0[1] = ctx->ipad.h[1];
  ctx->opad.w0[2] = ctx->ipad.h[2];
  ctx->opad.w0[3] = ctx->ipad.h[3];
  ctx->opad.w1[0] = ctx->ipad.h[4];
  ctx->opad.w1[1] = ctx->ipad.h[5];
  ctx->opad.w1[2] = ctx->ipad.h[6];
  ctx->opad.w1[3] = ctx->ipad.h[7];
  ctx->opad.w2[0] = 0;
  ctx->opad.w2[1] = 0;
  ctx->opad.w2[2] = 0;
  ctx->opad.w2[3] = 0;
  ctx->opad.w3[0] = 0;
  ctx->opad.w3[1] = 0;
  ctx->opad.w3[2] = 0;
  ctx->opad.w3[3] = 0;

  ctx->opad.len += 32;

  sha256_final (&ctx->opad);
}

// while input buf can be a vector datatype, the length of the different elements can not

DECLSPEC void sha256_transform_vector (PRIVATE_AS const u32x *w0, PRIVATE_AS const u32x *w1, PRIVATE_AS const u32x *w2, PRIVATE_AS const u32x *w3, PRIVATE_AS u32x *digest)
{
  u32x a = digest[0];
  u32x b = digest[1];
  u32x c = digest[2];
  u32x d = digest[3];
  u32x e = digest[4];
  u32x f = digest[5];
  u32x g = digest[6];
  u32x h = digest[7];

  u32x w0_t = w0[0];
  u32x w1_t = w0[1];
  u32x w2_t = w0[2];
  u32x w3_t = w0[3];
  u32x w4_t = w1[0];
  u32x w5_t = w1[1];
  u32x w6_t = w1[2];
  u32x w7_t = w1[3];
  u32x w8_t = w2[0];
  u32x w9_t = w2[1];
  u32x wa_t = w2[2];
  u32x wb_t = w2[3];
  u32x wc_t = w3[0];
  u32x wd_t = w3[1];
  u32x we_t = w3[2];
  u32x wf_t = w3[3];

  #define ROUND_EXPAND()                            \
  {                                                 \
    w0_t = SHA256_EXPAND (we_t, w9_t, w1_t, w0_t);  \
    w1_t = SHA256_EXPAND (wf_t, wa_t, w2_t, w1_t);  \
    w2_t = SHA256_EXPAND (w0_t, wb_t, w3_t, w2_t);  \
    w3_t = SHA256_EXPAND (w1_t, wc_t, w4_t, w3_t);  \
    w4_t = SHA256_EXPAND (w2_t, wd_t, w5_t, w4_t);  \
    w5_t = SHA256_EXPAND (w3_t, we_t, w6_t, w5_t);  \
    w6_t = SHA256_EXPAND (w4_t, wf_t, w7_t, w6_t);  \
    w7_t = SHA256_EXPAND (w5_t, w0_t, w8_t, w7_t);  \
    w8_t = SHA256_EXPAND (w6_t, w1_t, w9_t, w8_t);  \
    w9_t = SHA256_EXPAND (w7_t, w2_t, wa_t, w9_t);  \
    wa_t = SHA256_EXPAND (w8_t, w3_t, wb_t, wa_t);  \
    wb_t = SHA256_EXPAND (w9_t, w4_t, wc_t, wb_t);  \
    wc_t = SHA256_EXPAND (wa_t, w5_t, wd_t, wc_t);  \
    wd_t = SHA256_EXPAND (wb_t, w6_t, we_t, wd_t);  \
    we_t = SHA256_EXPAND (wc_t, w7_t, wf_t, we_t);  \
    wf_t = SHA256_EXPAND (wd_t, w8_t, w0_t, wf_t);  \
  }

  #define ROUND_STEP(i)                                                                   \
  {                                                                                       \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w0_t, k_sha256[i +  0]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w1_t, k_sha256[i +  1]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, w2_t, k_sha256[i +  2]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, w3_t, k_sha256[i +  3]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, w4_t, k_sha256[i +  4]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, w5_t, k_sha256[i +  5]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, w6_t, k_sha256[i +  6]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, w7_t, k_sha256[i +  7]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, a, b, c, d, e, f, g, h, w8_t, k_sha256[i +  8]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, h, a, b, c, d, e, f, g, w9_t, k_sha256[i +  9]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, g, h, a, b, c, d, e, f, wa_t, k_sha256[i + 10]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, f, g, h, a, b, c, d, e, wb_t, k_sha256[i + 11]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, e, f, g, h, a, b, c, d, wc_t, k_sha256[i + 12]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, d, e, f, g, h, a, b, c, wd_t, k_sha256[i + 13]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, c, d, e, f, g, h, a, b, we_t, k_sha256[i + 14]); \
    SHA256_STEP (SHA256_F0o, SHA256_F1o, b, c, d, e, f, g, h, a, wf_t, k_sha256[i + 15]); \
  }

  ROUND_STEP (0);

  #ifdef _unroll
  #pragma unroll
  #endif
  for (int i = 16; i < 64; i += 16)
  {
    ROUND_EXPAND (); ROUND_STEP (i);
  }

  #undef ROUND_EXPAND
  #undef ROUND_STEP

  digest[0] += a;
  digest[1] += b;
  digest[2] += c;
  digest[3] += d;
  digest[4] += e;
  digest[5] += f;
  digest[6] += g;
  digest[7] += h;
}

DECLSPEC void sha256_init_vector (PRIVATE_AS sha256_ctx_vector_t *ctx)
{
  ctx->h[0] = SHA256M_A;
  ctx->h[1] = SHA256M_B;
  ctx->h[2] = SHA256M_C;
  ctx->h[3] = SHA256M_D;
  ctx->h[4] = SHA256M_E;
  ctx->h[5] = SHA256M_F;
  ctx->h[6] = SHA256M_G;
  ctx->h[7] = SHA256M_H;

  ctx->w0[0] = 0;
  ctx->w0[1] = 0;
  ctx->w0[2] = 0;
  ctx->w0[3] = 0;
  ctx->w1[0] = 0;
  ctx->w1[1] = 0;
  ctx->w1[2] = 0;
  ctx->w1[3] = 0;
  ctx->w2[0] = 0;
  ctx->w2[1] = 0;
  ctx->w2[2] = 0;
  ctx->w2[3] = 0;
  ctx->w3[0] = 0;
  ctx->w3[1] = 0;
  ctx->w3[2] = 0;
  ctx->w3[3] = 0;

  ctx->len = 0;
}

DECLSPEC void sha256_init_vector_from_scalar (PRIVATE_AS sha256_ctx_vector_t *ctx, PRIVATE_AS sha256_ctx_t *ctx0)
{
  ctx->h[0] = ctx0->h[0];
  ctx->h[1] = ctx0->h[1];
  ctx->h[2] = ctx0->h[2];
  ctx->h[3] = ctx0->h[3];
  ctx->h[4] = ctx0->h[4];
  ctx->h[5] = ctx0->h[5];
  ctx->h[6] = ctx0->h[6];
  ctx->h[7] = ctx0->h[7];

  ctx->w0[0] = ctx0->w0[0];
  ctx->w0[1] = ctx0->w0[1];
  ctx->w0[2] = ctx0->w0[2];
  ctx->w0[3] = ctx0->w0[3];
  ctx->w1[0] = ctx0->w1[0];
  ctx->w1[1] = ctx0->w1[1];
  ctx->w1[2] = ctx0->w1[2];
  ctx->w1[3] = ctx0->w1[3];
  ctx->w2[0] = ctx0->w2[0];
  ctx->w2[1] = ctx0->w2[1];
  ctx->w2[2] = ctx0->w2[2];
  ctx->w2[3] = ctx0->w2[3];
  ctx->w3[0] = ctx0->w3[0];
  ctx->w3[1] = ctx0->w3[1];
  ctx->w3[2] = ctx0->w3[2];
  ctx->w3[3] = ctx0->w3[3];

  ctx->len = ctx0->len;
}

DECLSPEC void sha256_update_vector_64 (PRIVATE_AS sha256_ctx_vector_t *ctx, PRIVATE_AS u32x *w0, PRIVATE_AS u32x *w1, PRIVATE_AS u32x *w2, PRIVATE_AS u32x *w3, const int len)
{
  if (len == 0) return;

  const int pos = ctx->len & 63;

  ctx->len += len;

  if (pos == 0)
  {
    ctx->w0[0] = w0[0];
    ctx->w0[1] = w0[1];
    ctx->w0[2] = w0[2];
    ctx->w0[3] = w0[3];
    ctx->w1[0] = w1[0];
    ctx->w1[1] = w1[1];
    ctx->w1[2] = w1[2];
    ctx->w1[3] = w1[3];
    ctx->w2[0] = w2[0];
    ctx->w2[1] = w2[1];
    ctx->w2[2] = w2[2];
    ctx->w2[3] = w2[3];
    ctx->w3[0] = w3[0];
    ctx->w3[1] = w3[1];
    ctx->w3[2] = w3[2];
    ctx->w3[3] = w3[3];

    if (len == 64)
    {
      sha256_transform_vector (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

      ctx->w0[0] = 0;
      ctx->w0[1] = 0;
      ctx->w0[2] = 0;
      ctx->w0[3] = 0;
      ctx->w1[0] = 0;
      ctx->w1[1] = 0;
      ctx->w1[2] = 0;
      ctx->w1[3] = 0;
      ctx->w2[0] = 0;
      ctx->w2[1] = 0;
      ctx->w2[2] = 0;
      ctx->w2[3] = 0;
      ctx->w3[0] = 0;
      ctx->w3[1] = 0;
      ctx->w3[2] = 0;
      ctx->w3[3] = 0;
    }
  }
  else
  {
    if ((pos + len) < 64)
    {
      switch_buffer_by_offset_be (w0, w1, w2, w3, pos);

      ctx->w0[0] |= w0[0];
      ctx->w0[1] |= w0[1];
      ctx->w0[2] |= w0[2];
      ctx->w0[3] |= w0[3];
      ctx->w1[0] |= w1[0];
      ctx->w1[1] |= w1[1];
      ctx->w1[2] |= w1[2];
      ctx->w1[3] |= w1[3];
      ctx->w2[0] |= w2[0];
      ctx->w2[1] |= w2[1];
      ctx->w2[2] |= w2[2];
      ctx->w2[3] |= w2[3];
      ctx->w3[0] |= w3[0];
      ctx->w3[1] |= w3[1];
      ctx->w3[2] |= w3[2];
      ctx->w3[3] |= w3[3];
    }
    else
    {
      u32x c0[4] = { 0 };
      u32x c1[4] = { 0 };
      u32x c2[4] = { 0 };
      u32x c3[4] = { 0 };

      switch_buffer_by_offset_carry_be (w0, w1, w2, w3, c0, c1, c2, c3, pos);

      ctx->w0[0] |= w0[0];
      ctx->w0[1] |= w0[1];
      ctx->w0[2] |= w0[2];
      ctx->w0[3] |= w0[3];
      ctx->w1[0] |= w1[0];
      ctx->w1[1] |= w1[1];
      ctx->w1[2] |= w1[2];
      ctx->w1[3] |= w1[3];
      ctx->w2[0] |= w2[0];
      ctx->w2[1] |= w2[1];
      ctx->w2[2] |= w2[2];
      ctx->w2[3] |= w2[3];
      ctx->w3[0] |= w3[0];
      ctx->w3[1] |= w3[1];
      ctx->w3[2] |= w3[2];
      ctx->w3[3] |= w3[3];

      sha256_transform_vector (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

      ctx->w0[0] = c0[0];
      ctx->w0[1] = c0[1];
      ctx->w0[2] = c0[2];
      ctx->w0[3] = c0[3];
      ctx->w1[0] = c1[0];
      ctx->w1[1] = c1[1];
      ctx->w1[2] = c1[2];
      ctx->w1[3] = c1[3];
      ctx->w2[0] = c2[0];
      ctx->w2[1] = c2[1];
      ctx->w2[2] = c2[2];
      ctx->w2[3] = c2[3];
      ctx->w3[0] = c3[0];
      ctx->w3[1] = c3[1];
      ctx->w3[2] = c3[2];
      ctx->w3[3] = c3[3];
    }
  }
}

DECLSPEC void sha256_update_vector (PRIVATE_AS sha256_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    sha256_update_vector_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  sha256_update_vector_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sha256_update_vector_swap (PRIVATE_AS sha256_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 64; pos1 += 64, pos4 += 16)
  {
    w0[0] = w[pos4 +  0];
    w0[1] = w[pos4 +  1];
    w0[2] = w[pos4 +  2];
    w0[3] = w[pos4 +  3];
    w1[0] = w[pos4 +  4];
    w1[1] = w[pos4 +  5];
    w1[2] = w[pos4 +  6];
    w1[3] = w[pos4 +  7];
    w2[0] = w[pos4 +  8];
    w2[1] = w[pos4 +  9];
    w2[2] = w[pos4 + 10];
    w2[3] = w[pos4 + 11];
    w3[0] = w[pos4 + 12];
    w3[1] = w[pos4 + 13];
    w3[2] = w[pos4 + 14];
    w3[3] = w[pos4 + 15];

    w0[0] = hc_swap32 (w0[0]);
    w0[1] = hc_swap32 (w0[1]);
    w0[2] = hc_swap32 (w0[2]);
    w0[3] = hc_swap32 (w0[3]);
    w1[0] = hc_swap32 (w1[0]);
    w1[1] = hc_swap32 (w1[1]);
    w1[2] = hc_swap32 (w1[2]);
    w1[3] = hc_swap32 (w1[3]);
    w2[0] = hc_swap32 (w2[0]);
    w2[1] = hc_swap32 (w2[1]);
    w2[2] = hc_swap32 (w2[2]);
    w2[3] = hc_swap32 (w2[3]);
    w3[0] = hc_swap32 (w3[0]);
    w3[1] = hc_swap32 (w3[1]);
    w3[2] = hc_swap32 (w3[2]);
    w3[3] = hc_swap32 (w3[3]);

    sha256_update_vector_64 (ctx, w0, w1, w2, w3, 64);
  }

  w0[0] = w[pos4 +  0];
  w0[1] = w[pos4 +  1];
  w0[2] = w[pos4 +  2];
  w0[3] = w[pos4 +  3];
  w1[0] = w[pos4 +  4];
  w1[1] = w[pos4 +  5];
  w1[2] = w[pos4 +  6];
  w1[3] = w[pos4 +  7];
  w2[0] = w[pos4 +  8];
  w2[1] = w[pos4 +  9];
  w2[2] = w[pos4 + 10];
  w2[3] = w[pos4 + 11];
  w3[0] = w[pos4 + 12];
  w3[1] = w[pos4 + 13];
  w3[2] = w[pos4 + 14];
  w3[3] = w[pos4 + 15];

  w0[0] = hc_swap32 (w0[0]);
  w0[1] = hc_swap32 (w0[1]);
  w0[2] = hc_swap32 (w0[2]);
  w0[3] = hc_swap32 (w0[3]);
  w1[0] = hc_swap32 (w1[0]);
  w1[1] = hc_swap32 (w1[1]);
  w1[2] = hc_swap32 (w1[2]);
  w1[3] = hc_swap32 (w1[3]);
  w2[0] = hc_swap32 (w2[0]);
  w2[1] = hc_swap32 (w2[1]);
  w2[2] = hc_swap32 (w2[2]);
  w2[3] = hc_swap32 (w2[3]);
  w3[0] = hc_swap32 (w3[0]);
  w3[1] = hc_swap32 (w3[1]);
  w3[2] = hc_swap32 (w3[2]);
  w3[3] = hc_swap32 (w3[3]);

  sha256_update_vector_64 (ctx, w0, w1, w2, w3, len - pos1);
}

DECLSPEC void sha256_update_vector_utf16le (PRIVATE_AS sha256_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le (w1, w2, w3);
    make_utf16le (w0, w0, w1);

    sha256_update_vector_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le (w1, w2, w3);
  make_utf16le (w0, w0, w1);

  sha256_update_vector_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sha256_update_vector_utf16le_swap (PRIVATE_AS sha256_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16le (w1, w2, w3);
    make_utf16le (w0, w0, w1);

    w0[0] = hc_swap32 (w0[0]);
    w0[1] = hc_swap32 (w0[1]);
    w0[2] = hc_swap32 (w0[2]);
    w0[3] = hc_swap32 (w0[3]);
    w1[0] = hc_swap32 (w1[0]);
    w1[1] = hc_swap32 (w1[1]);
    w1[2] = hc_swap32 (w1[2]);
    w1[3] = hc_swap32 (w1[3]);
    w2[0] = hc_swap32 (w2[0]);
    w2[1] = hc_swap32 (w2[1]);
    w2[2] = hc_swap32 (w2[2]);
    w2[3] = hc_swap32 (w2[3]);
    w3[0] = hc_swap32 (w3[0]);
    w3[1] = hc_swap32 (w3[1]);
    w3[2] = hc_swap32 (w3[2]);
    w3[3] = hc_swap32 (w3[3]);

    sha256_update_vector_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16le (w1, w2, w3);
  make_utf16le (w0, w0, w1);

  w0[0] = hc_swap32 (w0[0]);
  w0[1] = hc_swap32 (w0[1]);
  w0[2] = hc_swap32 (w0[2]);
  w0[3] = hc_swap32 (w0[3]);
  w1[0] = hc_swap32 (w1[0]);
  w1[1] = hc_swap32 (w1[1]);
  w1[2] = hc_swap32 (w1[2]);
  w1[3] = hc_swap32 (w1[3]);
  w2[0] = hc_swap32 (w2[0]);
  w2[1] = hc_swap32 (w2[1]);
  w2[2] = hc_swap32 (w2[2]);
  w2[3] = hc_swap32 (w2[3]);
  w3[0] = hc_swap32 (w3[0]);
  w3[1] = hc_swap32 (w3[1]);
  w3[2] = hc_swap32 (w3[2]);
  w3[3] = hc_swap32 (w3[3]);

  sha256_update_vector_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sha256_update_vector_utf16beN (PRIVATE_AS sha256_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  int pos1;
  int pos4;

  for (pos1 = 0, pos4 = 0; pos1 < len - 32; pos1 += 32, pos4 += 8)
  {
    w0[0] = w[pos4 + 0];
    w0[1] = w[pos4 + 1];
    w0[2] = w[pos4 + 2];
    w0[3] = w[pos4 + 3];
    w1[0] = w[pos4 + 4];
    w1[1] = w[pos4 + 5];
    w1[2] = w[pos4 + 6];
    w1[3] = w[pos4 + 7];

    make_utf16beN (w1, w2, w3);
    make_utf16beN (w0, w0, w1);

    sha256_update_vector_64 (ctx, w0, w1, w2, w3, 32 * 2);
  }

  w0[0] = w[pos4 + 0];
  w0[1] = w[pos4 + 1];
  w0[2] = w[pos4 + 2];
  w0[3] = w[pos4 + 3];
  w1[0] = w[pos4 + 4];
  w1[1] = w[pos4 + 5];
  w1[2] = w[pos4 + 6];
  w1[3] = w[pos4 + 7];

  make_utf16beN (w1, w2, w3);
  make_utf16beN (w0, w0, w1);

  sha256_update_vector_64 (ctx, w0, w1, w2, w3, (len - pos1) * 2);
}

DECLSPEC void sha256_final_vector (PRIVATE_AS sha256_ctx_vector_t *ctx)
{
  const int pos = ctx->len & 63;

  append_0x80_4x4 (ctx->w0, ctx->w1, ctx->w2, ctx->w3, pos ^ 3);

  if (pos >= 56)
  {
    sha256_transform_vector (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);

    ctx->w0[0] = 0;
    ctx->w0[1] = 0;
    ctx->w0[2] = 0;
    ctx->w0[3] = 0;
    ctx->w1[0] = 0;
    ctx->w1[1] = 0;
    ctx->w1[2] = 0;
    ctx->w1[3] = 0;
    ctx->w2[0] = 0;
    ctx->w2[1] = 0;
    ctx->w2[2] = 0;
    ctx->w2[3] = 0;
    ctx->w3[0] = 0;
    ctx->w3[1] = 0;
    ctx->w3[2] = 0;
    ctx->w3[3] = 0;
  }

  ctx->w3[2] = 0;
  ctx->w3[3] = ctx->len * 8;

  sha256_transform_vector (ctx->w0, ctx->w1, ctx->w2, ctx->w3, ctx->h);
}

// HMAC + Vector

DECLSPEC void sha256_hmac_init_vector_64 (PRIVATE_AS sha256_hmac_ctx_vector_t *ctx, PRIVATE_AS const u32x *w0, PRIVATE_AS const u32x *w1, PRIVATE_AS const u32x *w2, PRIVATE_AS const u32x *w3)
{
  u32x a0[4];
  u32x a1[4];
  u32x a2[4];
  u32x a3[4];

  // ipad

  a0[0] = w0[0] ^ 0x36363636;
  a0[1] = w0[1] ^ 0x36363636;
  a0[2] = w0[2] ^ 0x36363636;
  a0[3] = w0[3] ^ 0x36363636;
  a1[0] = w1[0] ^ 0x36363636;
  a1[1] = w1[1] ^ 0x36363636;
  a1[2] = w1[2] ^ 0x36363636;
  a1[3] = w1[3] ^ 0x36363636;
  a2[0] = w2[0] ^ 0x36363636;
  a2[1] = w2[1] ^ 0x36363636;
  a2[2] = w2[2] ^ 0x36363636;
  a2[3] = w2[3] ^ 0x36363636;
  a3[0] = w3[0] ^ 0x36363636;
  a3[1] = w3[1] ^ 0x36363636;
  a3[2] = w3[2] ^ 0x36363636;
  a3[3] = w3[3] ^ 0x36363636;

  sha256_init_vector (&ctx->ipad);

  sha256_update_vector_64 (&ctx->ipad, a0, a1, a2, a3, 64);

  // opad

  u32x b0[4];
  u32x b1[4];
  u32x b2[4];
  u32x b3[4];

  b0[0] = w0[0] ^ 0x5c5c5c5c;
  b0[1] = w0[1] ^ 0x5c5c5c5c;
  b0[2] = w0[2] ^ 0x5c5c5c5c;
  b0[3] = w0[3] ^ 0x5c5c5c5c;
  b1[0] = w1[0] ^ 0x5c5c5c5c;
  b1[1] = w1[1] ^ 0x5c5c5c5c;
  b1[2] = w1[2] ^ 0x5c5c5c5c;
  b1[3] = w1[3] ^ 0x5c5c5c5c;
  b2[0] = w2[0] ^ 0x5c5c5c5c;
  b2[1] = w2[1] ^ 0x5c5c5c5c;
  b2[2] = w2[2] ^ 0x5c5c5c5c;
  b2[3] = w2[3] ^ 0x5c5c5c5c;
  b3[0] = w3[0] ^ 0x5c5c5c5c;
  b3[1] = w3[1] ^ 0x5c5c5c5c;
  b3[2] = w3[2] ^ 0x5c5c5c5c;
  b3[3] = w3[3] ^ 0x5c5c5c5c;

  sha256_init_vector (&ctx->opad);

  sha256_update_vector_64 (&ctx->opad, b0, b1, b2, b3, 64);
}

DECLSPEC void sha256_hmac_init_vector (PRIVATE_AS sha256_hmac_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  if (len > 64)
  {
    sha256_ctx_vector_t tmp;

    sha256_init_vector (&tmp);

    sha256_update_vector (&tmp, w, len);

    sha256_final_vector (&tmp);

    w0[0] = tmp.h[0];
    w0[1] = tmp.h[1];
    w0[2] = tmp.h[2];
    w0[3] = tmp.h[3];
    w1[0] = tmp.h[4];
    w1[1] = tmp.h[5];
    w1[2] = tmp.h[6];
    w1[3] = tmp.h[7];
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;
  }
  else
  {
    w0[0] = w[ 0];
    w0[1] = w[ 1];
    w0[2] = w[ 2];
    w0[3] = w[ 3];
    w1[0] = w[ 4];
    w1[1] = w[ 5];
    w1[2] = w[ 6];
    w1[3] = w[ 7];
    w2[0] = w[ 8];
    w2[1] = w[ 9];
    w2[2] = w[10];
    w2[3] = w[11];
    w3[0] = w[12];
    w3[1] = w[13];
    w3[2] = w[14];
    w3[3] = w[15];
  }

  sha256_hmac_init_vector_64 (ctx, w0, w1, w2, w3);
}

DECLSPEC void sha256_hmac_update_vector_64 (PRIVATE_AS sha256_hmac_ctx_vector_t *ctx, PRIVATE_AS u32x *w0, PRIVATE_AS u32x *w1, PRIVATE_AS u32x *w2, PRIVATE_AS u32x *w3, const int len)
{
  sha256_update_vector_64 (&ctx->ipad, w0, w1, w2, w3, len);
}

DECLSPEC void sha256_hmac_update_vector (PRIVATE_AS sha256_hmac_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len)
{
  sha256_update_vector (&ctx->ipad, w, len);
}

DECLSPEC void sha256_hmac_final_vector (PRIVATE_AS sha256_hmac_ctx_vector_t *ctx)
{
  sha256_final_vector (&ctx->ipad);

  ctx->opad.w0[0] = ctx->ipad.h[0];
  ctx->opad.w0[1] = ctx->ipad.h[1];
  ctx->opad.w0[2] = ctx->ipad.h[2];
  ctx->opad.w0[3] = ctx->ipad.h[3];
  ctx->opad.w1[0] = ctx->ipad.h[4];
  ctx->opad.w1[1] = ctx->ipad.h[5];
  ctx->opad.w1[2] = ctx->ipad.h[6];
  ctx->opad.w1[3] = ctx->ipad.h[7];
  ctx->opad.w2[0] = 0;
  ctx->opad.w2[1] = 0;
  ctx->opad.w2[2] = 0;
  ctx->opad.w2[3] = 0;
  ctx->opad.w3[0] = 0;
  ctx->opad.w3[1] = 0;
  ctx->opad.w3[2] = 0;
  ctx->opad.w3[3] = 0;

  ctx->opad.len += 32;

  sha256_final_vector (&ctx->opad);
}
