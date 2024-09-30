/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#ifndef INC_HASH_STREEBOG256_H
#define INC_HASH_STREEBOG256_H

#if   VECT_SIZE == 1
#define BOX(S,n,i)        ((S)[(n)][(i)])

#elif VECT_SIZE == 2
#define BOX(S,n,i) make_u64x ((S)[(n)][(i).s0], (S)[(n)][(i).s1])

#elif VECT_SIZE == 4
#define BOX(S,n,i) make_u64x ((S)[(n)][(i).s0], (S)[(n)][(i).s1], (S)[(n)][(i).s2], (S)[(n)][(i).s3])

#elif VECT_SIZE == 8
#define BOX(S,n,i) make_u64x ((S)[(n)][(i).s0], (S)[(n)][(i).s1], (S)[(n)][(i).s2], (S)[(n)][(i).s3], \
                           (S)[(n)][(i).s4], (S)[(n)][(i).s5], (S)[(n)][(i).s6], (S)[(n)][(i).s7])

#elif VECT_SIZE == 16
#define BOX(S,n,i) make_u64x ((S)[(n)][(i).s0], (S)[(n)][(i).s1], (S)[(n)][(i).s2], (S)[(n)][(i).s3], \
                           (S)[(n)][(i).s4], (S)[(n)][(i).s5], (S)[(n)][(i).s6], (S)[(n)][(i).s7], \
                           (S)[(n)][(i).s8], (S)[(n)][(i).s9], (S)[(n)][(i).sa], (S)[(n)][(i).sb], \
                           (S)[(n)][(i).sc], (S)[(n)][(i).sd], (S)[(n)][(i).se], (S)[(n)][(i).sf])
#endif

#define SBOG_LPSti64                                 \
  BOX (s_sbob_sl64, 0, ((t[0] >> (i * 8)) & 0xff)) ^ \
  BOX (s_sbob_sl64, 1, ((t[1] >> (i * 8)) & 0xff)) ^ \
  BOX (s_sbob_sl64, 2, ((t[2] >> (i * 8)) & 0xff)) ^ \
  BOX (s_sbob_sl64, 3, ((t[3] >> (i * 8)) & 0xff)) ^ \
  BOX (s_sbob_sl64, 4, ((t[4] >> (i * 8)) & 0xff)) ^ \
  BOX (s_sbob_sl64, 5, ((t[5] >> (i * 8)) & 0xff)) ^ \
  BOX (s_sbob_sl64, 6, ((t[6] >> (i * 8)) & 0xff)) ^ \
  BOX (s_sbob_sl64, 7, ((t[7] >> (i * 8)) & 0xff))

typedef struct streebog256_ctx
{
  u64 h[8];
  u64 s[8];
  u64 n[8];

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  int len;

  SHM_TYPE u64a (*s_sbob_sl64)[256];

} streebog256_ctx_t;

typedef struct streebog256_hmac_ctx
{
  streebog256_ctx_t ipad;
  streebog256_ctx_t opad;

} streebog256_hmac_ctx_t;

typedef struct streebog256_ctx_vector
{
  u64x h[8];

  u64x s[8];

  u64x n[8];

  u32x w0[4];
  u32x w1[4];
  u32x w2[4];
  u32x w3[4];

  int len;

  SHM_TYPE u64a (*s_sbob_sl64)[256];

} streebog256_ctx_vector_t;

typedef struct streebog256_hmac_ctx_vector
{
  streebog256_ctx_vector_t ipad;
  streebog256_ctx_vector_t opad;

} streebog256_hmac_ctx_vector_t;

DECLSPEC void streebog256_init (PRIVATE_AS streebog256_ctx_t *ctx, SHM_TYPE u64a (*s_sbob_sl64)[256]);
DECLSPEC void streebog256_add (PRIVATE_AS u64 *x, PRIVATE_AS const u64 *y);
DECLSPEC void streebog256_g (PRIVATE_AS u64 *h, PRIVATE_AS const u64 *n, PRIVATE_AS const u64 *m, SHM_TYPE u64a (*s_sbob_sl64)[256]);
DECLSPEC void streebog256_transform (PRIVATE_AS streebog256_ctx_t *ctx, PRIVATE_AS const u32 *w0, PRIVATE_AS const u32 *w1, PRIVATE_AS const u32 *w2, PRIVATE_AS const u32 *w3);
DECLSPEC void streebog256_update_64 (PRIVATE_AS streebog256_ctx_t *ctx, PRIVATE_AS u32 *w0, PRIVATE_AS u32 *w1, PRIVATE_AS u32 *w2, PRIVATE_AS u32 *w3, const int len);
DECLSPEC void streebog256_update (PRIVATE_AS streebog256_ctx_t *ctx, PRIVATE_AS const u32 *w, int len);
DECLSPEC void streebog256_update_swap (PRIVATE_AS streebog256_ctx_t *ctx, PRIVATE_AS const u32 *w, int len);
DECLSPEC void streebog256_update_global_swap (PRIVATE_AS streebog256_ctx_t *ctx, GLOBAL_AS const u32 *w, int len);
DECLSPEC void streebog256_final (PRIVATE_AS streebog256_ctx_t *ctx);
DECLSPEC void streebog256_hmac_init_64 (PRIVATE_AS streebog256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w0, PRIVATE_AS const u32 *w1, PRIVATE_AS const u32 *w2, PRIVATE_AS const u32 *w3, SHM_TYPE u64a (*s_sbob_sl64)[256]);
DECLSPEC void streebog256_hmac_init (PRIVATE_AS streebog256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len, SHM_TYPE u64a (*s_sbob_sl64)[256]);
DECLSPEC void streebog256_hmac_init_swap (PRIVATE_AS streebog256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len, SHM_TYPE u64a (*s_sbob_sl64)[256]);
DECLSPEC void streebog256_hmac_update_64 (PRIVATE_AS streebog256_hmac_ctx_t *ctx, PRIVATE_AS u32 *w0, PRIVATE_AS u32 *w1, PRIVATE_AS u32 *w2, PRIVATE_AS u32 *w3, const int len);
DECLSPEC void streebog256_hmac_update (PRIVATE_AS streebog256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len);
DECLSPEC void streebog256_hmac_update_swap (PRIVATE_AS streebog256_hmac_ctx_t *ctx, PRIVATE_AS const u32 *w, const int len);
DECLSPEC void streebog256_hmac_update_global_swap (PRIVATE_AS streebog256_hmac_ctx_t *ctx, GLOBAL_AS const u32 *w, const int len);
DECLSPEC void streebog256_hmac_final (PRIVATE_AS streebog256_hmac_ctx_t *ctx);
DECLSPEC void streebog256_init_vector (PRIVATE_AS streebog256_ctx_vector_t *ctx, SHM_TYPE u64a (*s_sbob_sl64)[256]);
DECLSPEC void streebog256_add_vector (PRIVATE_AS u64x *x, PRIVATE_AS const u64x *y);
DECLSPEC void streebog256_g_vector (PRIVATE_AS u64x *h, PRIVATE_AS const u64x *n, PRIVATE_AS const u64x *m, SHM_TYPE u64a (*s_sbob_sl64)[256]);
DECLSPEC void streebog256_transform_vector (PRIVATE_AS streebog256_ctx_vector_t *ctx, PRIVATE_AS const u32x *w0, PRIVATE_AS const u32x *w1, PRIVATE_AS const u32x *w2, PRIVATE_AS const u32x *w3);
DECLSPEC void streebog256_update_vector_64 (PRIVATE_AS streebog256_ctx_vector_t *ctx, PRIVATE_AS u32x *w0, PRIVATE_AS u32x *w1, PRIVATE_AS u32x *w2, PRIVATE_AS u32x *w3, const int len);
DECLSPEC void streebog256_update_vector (PRIVATE_AS streebog256_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, int len);
DECLSPEC void streebog256_update_vector_swap (PRIVATE_AS streebog256_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, int len);
DECLSPEC void streebog256_final_vector (PRIVATE_AS streebog256_ctx_vector_t *ctx);
DECLSPEC void streebog256_hmac_init_vector_64 (PRIVATE_AS streebog256_hmac_ctx_vector_t *ctx, PRIVATE_AS const u32x *w0, PRIVATE_AS const u32x *w1, PRIVATE_AS const u32x *w2, PRIVATE_AS const u32x *w3, SHM_TYPE u64a (*s_sbob_sl64)[256]);
DECLSPEC void streebog256_hmac_init_vector (PRIVATE_AS streebog256_hmac_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len, SHM_TYPE u64a (*s_sbob_sl64)[256]);
DECLSPEC void streebog256_hmac_init_vector_swap (PRIVATE_AS streebog256_hmac_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len, SHM_TYPE u64a (*s_sbob_sl64)[256]);
DECLSPEC void streebog256_hmac_update_vector (PRIVATE_AS streebog256_hmac_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len);
DECLSPEC void streebog256_hmac_update_vector_swap (PRIVATE_AS streebog256_hmac_ctx_vector_t *ctx, PRIVATE_AS const u32x *w, const int len);
DECLSPEC void streebog256_hmac_final_vector (PRIVATE_AS streebog256_hmac_ctx_vector_t *ctx);

#endif // INC_HASH_STREEBOG256_H
