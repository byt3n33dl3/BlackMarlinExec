/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

//#define NEW_SIMD_CODE

#ifdef KERNEL_STATIC
#include M2S(INCLUDE_PATH/inc_vendor.h)
#include M2S(INCLUDE_PATH/inc_types.h)
#include M2S(INCLUDE_PATH/inc_platform.cl)
#include M2S(INCLUDE_PATH/inc_common.cl)
#include M2S(INCLUDE_PATH/inc_hash_md5.cl)
#endif

#define COMPARE_S M2S(INCLUDE_PATH/inc_comp_single.cl)
#define COMPARE_M M2S(INCLUDE_PATH/inc_comp_multi.cl)

typedef struct md5crypt_tmp
{
  u32 digest_buf[4];

} md5crypt_tmp_t;

#define md5apr1_magic0 0x72706124u
#define md5apr1_magic1 0x00002431u

KERNEL_FQ void m01600_init (KERN_ATTR_TMPS (md5crypt_tmp_t))
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  /**
   * init
   */

  const u32 pw_len = pws[gid].pw_len;

  u32 w[64] = { 0 };

  for (u32 i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = pws[gid].i[idx];
  }

  const u32 salt_len = salt_bufs[SALT_POS_HOST].salt_len;

  u32 s[64] = { 0 };

  for (u32 i = 0, idx = 0; i < salt_len; i += 4, idx += 1)
  {
    s[idx] = salt_bufs[SALT_POS_HOST].salt_buf[idx];
  }

  /**
   * prepare
   */

  md5_ctx_t md5_ctx1;

  md5_init (&md5_ctx1);

  md5_update (&md5_ctx1, w, pw_len);

  md5_update (&md5_ctx1, s, salt_len);

  md5_update (&md5_ctx1, w, pw_len);

  md5_final (&md5_ctx1);

  u32 final[16] = { 0 };

  final[0] = md5_ctx1.h[0];
  final[1] = md5_ctx1.h[1];
  final[2] = md5_ctx1.h[2];
  final[3] = md5_ctx1.h[3];

  md5_ctx_t md5_ctx;

  md5_init (&md5_ctx);

  md5_update (&md5_ctx, w, pw_len);

  u32 m[16] = { 0 };

  m[0] = md5apr1_magic0;
  m[1] = md5apr1_magic1;

  md5_update (&md5_ctx, m, 6);

  md5_update (&md5_ctx, s, salt_len);

  int pl;

  for (pl = pw_len; pl > 16; pl -= 16)
  {
    md5_update (&md5_ctx, final, 16);
  }

  truncate_block_4x4_le_S (final, pl);

  md5_update (&md5_ctx, final, pl);

  /* Then something really weird... */

  for (int i = pw_len; i != 0; i >>= 1)
  {
    u32 t[16] = { 0 };

    if (i & 1)
    {
      t[0] = 0;
    }
    else
    {
      t[0] = w[0] & 0xff;
    }

    md5_update (&md5_ctx, t, 1);
  }

  md5_final (&md5_ctx);

  tmps[gid].digest_buf[0] = md5_ctx.h[0];
  tmps[gid].digest_buf[1] = md5_ctx.h[1];
  tmps[gid].digest_buf[2] = md5_ctx.h[2];
  tmps[gid].digest_buf[3] = md5_ctx.h[3];
}

KERNEL_FQ void m01600_loop (KERN_ATTR_TMPS (md5crypt_tmp_t))
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  /**
   * init
   */

  const u32 pw_len = pws[gid].pw_len;

  u32 w[64] = { 0 };

  for (u32 i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = pws[gid].i[idx];
  }

  const u32 salt_len = salt_bufs[SALT_POS_HOST].salt_len;

  u32 s[64] = { 0 };

  for (u32 i = 0, idx = 0; i < salt_len; i += 4, idx += 1)
  {
    s[idx] = salt_bufs[SALT_POS_HOST].salt_buf[idx];
  }

  /**
   * digest
   */

  u32 digest[16] = { 0 };

  digest[0] = tmps[gid].digest_buf[0];
  digest[1] = tmps[gid].digest_buf[1];
  digest[2] = tmps[gid].digest_buf[2];
  digest[3] = tmps[gid].digest_buf[3];

  /**
   * loop
   */

  for (u32 i = 0, j = LOOP_POS; i < LOOP_CNT; i++, j++)
  {
    md5_ctx_t md5_ctx;

    md5_init (&md5_ctx);

    if (j & 1)
    {
      md5_update (&md5_ctx, w, pw_len);
    }
    else
    {
      md5_update (&md5_ctx, digest, 16);
    }

    if (j % 3)
    {
      md5_update (&md5_ctx, s, salt_len);
    }

    if (j % 7)
    {
      md5_update (&md5_ctx, w, pw_len);
    }

    if (j & 1)
    {
      md5_update (&md5_ctx, digest, 16);
    }
    else
    {
      md5_update (&md5_ctx, w, pw_len);
    }

    md5_final (&md5_ctx);

    digest[0] = md5_ctx.h[0];
    digest[1] = md5_ctx.h[1];
    digest[2] = md5_ctx.h[2];
    digest[3] = md5_ctx.h[3];
  }

  tmps[gid].digest_buf[0] = digest[0];
  tmps[gid].digest_buf[1] = digest[1];
  tmps[gid].digest_buf[2] = digest[2];
  tmps[gid].digest_buf[3] = digest[3];
}

KERNEL_FQ void m01600_comp (KERN_ATTR_TMPS (md5crypt_tmp_t))
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  const u64 lid = get_local_id (0);

  /**
   * digest
   */

  const u32 r0 = tmps[gid].digest_buf[DGST_R0];
  const u32 r1 = tmps[gid].digest_buf[DGST_R1];
  const u32 r2 = tmps[gid].digest_buf[DGST_R2];
  const u32 r3 = tmps[gid].digest_buf[DGST_R3];

  #define il_pos 0

  #ifdef KERNEL_STATIC
  #include COMPARE_M
  #endif
}
