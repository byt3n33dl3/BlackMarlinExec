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
#include M2S(INCLUDE_PATH/inc_simd.cl)
#include M2S(INCLUDE_PATH/inc_hash_sha256.cl)
#endif

#define COMPARE_S M2S(INCLUDE_PATH/inc_comp_single.cl)
#define COMPARE_M M2S(INCLUDE_PATH/inc_comp_multi.cl)

typedef struct qnx_sha256_tmp
{
  sha256_ctx_t sha256_ctx;

} qnx_sha256_tmp_t;

KERNEL_FQ void m19100_init (KERN_ATTR_TMPS (qnx_sha256_tmp_t))
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  /**
   * init
   */

  sha256_ctx_t sha256_ctx;

  sha256_init (&sha256_ctx);

  sha256_update_global_swap (&sha256_ctx, salt_bufs[SALT_POS_HOST].salt_buf, salt_bufs[SALT_POS_HOST].salt_len);

  sha256_update_global_swap (&sha256_ctx, pws[gid].i, pws[gid].pw_len);

  tmps[gid].sha256_ctx = sha256_ctx;
}

KERNEL_FQ void m19100_loop (KERN_ATTR_TMPS (qnx_sha256_tmp_t))
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  sha256_ctx_t sha256_ctx = tmps[gid].sha256_ctx;

  for (u32 i = 0; i < LOOP_CNT; i++)
  {
    sha256_update_global_swap (&sha256_ctx, pws[gid].i, pws[gid].pw_len);
  }

  tmps[gid].sha256_ctx = sha256_ctx;
}

KERNEL_FQ void m19100_comp (KERN_ATTR_TMPS (qnx_sha256_tmp_t))
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);

  if (gid >= GID_CNT) return;

  sha256_ctx_t sha256_ctx = tmps[gid].sha256_ctx;

  sha256_final (&sha256_ctx);

  const u32 r0 = hc_swap32_S (sha256_ctx.h[0]);
  const u32 r1 = hc_swap32_S (sha256_ctx.h[1]);
  const u32 r2 = hc_swap32_S (sha256_ctx.h[2]);
  const u32 r3 = hc_swap32_S (sha256_ctx.h[3]);

  #define il_pos 0

  #ifdef KERNEL_STATIC
  #include COMPARE_M
  #endif
}
