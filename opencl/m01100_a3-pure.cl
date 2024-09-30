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
#include M2S(INCLUDE_PATH/inc_hash_md4.cl)
#endif

KERNEL_FQ void m01100_mxx (KERN_ATTR_VECTOR ())
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  /**
   * base
   */

  const u32 pw_len = pws[gid].pw_len;

  u32x w[64] = { 0 };

  for (u32 i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = pws[gid].i[idx];
  }

  const u32 salt_len = salt_bufs[SALT_POS_HOST].salt_len;

  u32x s[64] = { 0 };

  for (u32 i = 0, idx = 0; i < salt_len; i += 4, idx += 1)
  {
    s[idx] = salt_bufs[SALT_POS_HOST].salt_buf[idx];
  }

  /**
   * loop
   */

  u32x w0l = w[0];

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x w0r = words_buf_r[il_pos / VECT_SIZE];

    const u32x w0 = w0l | w0r;

    w[0] = w0;

    #if VECT_SIZE == 1

    md4_ctx_t ctx0;

    md4_init (&ctx0);

    md4_update_utf16le (&ctx0, w, pw_len);

    md4_final (&ctx0);

    md4_ctx_t ctx;

    md4_init (&ctx);

    ctx.w0[0] = ctx0.h[0];
    ctx.w0[1] = ctx0.h[1];
    ctx.w0[2] = ctx0.h[2];
    ctx.w0[3] = ctx0.h[3];

    ctx.len = 16;

    md4_update_utf16le (&ctx, s, salt_len);

    md4_final (&ctx);

    #else

    md4_ctx_vector_t ctx0;

    md4_init_vector (&ctx0);

    md4_update_vector_utf16le (&ctx0, w, pw_len);

    md4_final_vector (&ctx0);

    md4_ctx_vector_t ctx;

    md4_init_vector (&ctx);

    ctx.w0[0] = ctx0.h[0];
    ctx.w0[1] = ctx0.h[1];
    ctx.w0[2] = ctx0.h[2];
    ctx.w0[3] = ctx0.h[3];

    ctx.len = 16;

    md4_update_vector_utf16le (&ctx, s, salt_len);

    md4_final_vector (&ctx);

    #endif

    const u32x r0 = ctx.h[DGST_R0];
    const u32x r1 = ctx.h[DGST_R1];
    const u32x r2 = ctx.h[DGST_R2];
    const u32x r3 = ctx.h[DGST_R3];

    COMPARE_M_SIMD (r0, r1, r2, r3);
  }
}

KERNEL_FQ void m01100_sxx (KERN_ATTR_VECTOR ())
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

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
   * base
   */

  const u32 pw_len = pws[gid].pw_len;

  u32x w[64] = { 0 };

  for (u32 i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = pws[gid].i[idx];
  }

  const u32 salt_len = salt_bufs[SALT_POS_HOST].salt_len;

  u32x s[64] = { 0 };

  for (u32 i = 0, idx = 0; i < salt_len; i += 4, idx += 1)
  {
    s[idx] = salt_bufs[SALT_POS_HOST].salt_buf[idx];
  }

  /**
   * loop
   */

  u32x w0l = w[0];

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x w0r = words_buf_r[il_pos / VECT_SIZE];

    const u32x w0 = w0l | w0r;

    w[0] = w0;

    #if VECT_SIZE == 1

    md4_ctx_t ctx0;

    md4_init (&ctx0);

    md4_update_utf16le (&ctx0, w, pw_len);

    md4_final (&ctx0);

    md4_ctx_t ctx;

    md4_init (&ctx);

    ctx.w0[0] = ctx0.h[0];
    ctx.w0[1] = ctx0.h[1];
    ctx.w0[2] = ctx0.h[2];
    ctx.w0[3] = ctx0.h[3];

    ctx.len = 16;

    md4_update_utf16le (&ctx, s, salt_len);

    md4_final (&ctx);

    #else

    md4_ctx_vector_t ctx0;

    md4_init_vector (&ctx0);

    md4_update_vector_utf16le (&ctx0, w, pw_len);

    md4_final_vector (&ctx0);

    md4_ctx_vector_t ctx;

    md4_init_vector (&ctx);

    ctx.w0[0] = ctx0.h[0];
    ctx.w0[1] = ctx0.h[1];
    ctx.w0[2] = ctx0.h[2];
    ctx.w0[3] = ctx0.h[3];

    ctx.len = 16;

    md4_update_vector_utf16le (&ctx, s, salt_len);

    md4_final_vector (&ctx);

    #endif

    const u32x r0 = ctx.h[DGST_R0];
    const u32x r1 = ctx.h[DGST_R1];
    const u32x r2 = ctx.h[DGST_R2];
    const u32x r3 = ctx.h[DGST_R3];

    COMPARE_S_SIMD (r0, r1, r2, r3);
  }
}
