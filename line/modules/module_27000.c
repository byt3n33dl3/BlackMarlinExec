/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#include "common.h"
#include "types.h"
#include "modules.h"
#include "bitops.h"
#include "convert.h"
#include "shared.h"
#include "emu_inc_cipher_des.h"
#include "emu_inc_hash_md5.h"

static const u32   ATTACK_EXEC    = ATTACK_EXEC_OUTSIDE_KERNEL;
static const u32   DGST_POS0      = 0;
static const u32   DGST_POS1      = 1;
static const u32   DGST_POS2      = 2;
static const u32   DGST_POS3      = 3;
static const u32   DGST_SIZE      = DGST_SIZE_4_4;
static const u32   HASH_CATEGORY  = HASH_CATEGORY_NETWORK_PROTOCOL;
static const char *HASH_NAME      = "NetNTLMv1 / NetNTLMv1+ESS (NT)";
static const u64   KERN_TYPE      = 27000;
static const u32   OPTI_TYPE      = OPTI_TYPE_ZERO_BYTE;
static const u64   OPTS_TYPE      = OPTS_TYPE_STOCK_MODULE
                                  | OPTS_TYPE_PT_GENERATE_LE
                                  | OPTS_TYPE_PT_ADD80
                                  | OPTS_TYPE_PT_ADDBITS14
                                  | OPTS_TYPE_PT_UTF16LE
                                  | OPTS_TYPE_ST_HEX
                                  | OPTS_TYPE_MAXIMUM_THREADS
                                  | OPTS_TYPE_AUTODETECT_DISABLE;
static const u32   SALT_TYPE      = SALT_TYPE_EMBEDDED;
static const char *ST_PASS        = "b4b9b02e6f09a9bd760f388b67351e2b";
static const char *ST_HASH        = "::5V4T:ada06359242920a500000000000000000000000000000000:0556d5297b5daa70eaffde82ef99293a3f3bb59b7c9704ea:9c23f6c094853920";

typedef struct netntlm
{
  int user_len;
  int domain_len;
  int srvchall_len;
  int clichall_len;

  u32 userdomain_buf[64];
  u32 chall_buf[256];

} netntlm_t;

typedef struct netntlm_tmp
{
  u32 digest_buf[4];

} netntlm_tmp_t;

u32         module_attack_exec    (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return ATTACK_EXEC;     }
u32         module_dgst_pos0      (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return DGST_POS0;       }
u32         module_dgst_pos1      (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return DGST_POS1;       }
u32         module_dgst_pos2      (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return DGST_POS2;       }
u32         module_dgst_pos3      (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return DGST_POS3;       }
u32         module_dgst_size      (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return DGST_SIZE;       }
u32         module_hash_category  (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return HASH_CATEGORY;   }
const char *module_hash_name      (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return HASH_NAME;       }
u64         module_kern_type      (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return KERN_TYPE;       }
u32         module_opti_type      (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return OPTI_TYPE;       }
u64         module_opts_type      (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return OPTS_TYPE;       }
u32         module_salt_type      (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return SALT_TYPE;       }
const char *module_st_hash        (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return ST_HASH;         }
const char *module_st_pass        (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra) { return ST_PASS;         }

u64 module_tmp_size (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra)
{
  const u64 tmp_size = (const u64) sizeof (netntlm_tmp_t);

  return tmp_size;
}

static void transform_netntlmv1_key (const u8 *nthash, u8 *key)
{
  key[0] =                    (nthash[0] >> 0);
  key[1] = (nthash[0] << 7) | (nthash[1] >> 1);
  key[2] = (nthash[1] << 6) | (nthash[2] >> 2);
  key[3] = (nthash[2] << 5) | (nthash[3] >> 3);
  key[4] = (nthash[3] << 4) | (nthash[4] >> 4);
  key[5] = (nthash[4] << 3) | (nthash[5] >> 5);
  key[6] = (nthash[5] << 2) | (nthash[6] >> 6);
  key[7] = (nthash[6] << 1);

  key[0] |= 0x01;
  key[1] |= 0x01;
  key[2] |= 0x01;
  key[3] |= 0x01;
  key[4] |= 0x01;
  key[5] |= 0x01;
  key[6] |= 0x01;
  key[7] |= 0x01;
}

char *module_jit_build_options (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra, MAYBE_UNUSED const hashes_t *hashes, MAYBE_UNUSED const hc_device_param_t *device_param)
{
  char *jit_build_options = NULL;

  // Extra treatment for Apple systems
  if (device_param->opencl_platform_vendor_id == VENDOR_ID_APPLE)
  {
    return jit_build_options;
  }

  // Intel CPU
  if ((device_param->opencl_device_vendor_id == VENDOR_ID_INTEL_SDK) && (device_param->opencl_device_type & CL_DEVICE_TYPE_CPU))
  {
    hc_asprintf (&jit_build_options, "-D _unroll");
  }

  return jit_build_options;
}

u64 module_esalt_size (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra)
{
  const u64 esalt_size = (const u64) sizeof (netntlm_t);

  return esalt_size;
}

int module_hash_decode (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED void *digest_buf, MAYBE_UNUSED salt_t *salt, MAYBE_UNUSED void *esalt_buf, MAYBE_UNUSED void *hook_salt_buf, MAYBE_UNUSED hashinfo_t *hash_info, const char *line_buf, MAYBE_UNUSED const int line_len)
{
  u32 *digest = (u32 *) digest_buf;

  netntlm_t *netntlm = (netntlm_t *) esalt_buf;

  hc_token_t token;

  memset (&token, 0, sizeof (hc_token_t));

  token.token_cnt  = 6;

  // username
  token.sep[0]     = ':';
  token.len_min[0] = 0;
  token.len_max[0] = 60;
  token.attr[0]    = TOKEN_ATTR_VERIFY_LENGTH;

  // unused
  token.len[1]     = 0;
  token.sep[1]     = ':';
  token.attr[1]    = TOKEN_ATTR_FIXED_LENGTH;

  // domain
  token.sep[2]     = ':';
  token.len_min[2] = 0;
  token.len_max[2] = 45;
  token.attr[2]    = TOKEN_ATTR_VERIFY_LENGTH;

  // lm response
  token.sep[3]     = ':';
  token.len_min[3] = 0;
  token.len_max[3] = 48;
  token.attr[3]    = TOKEN_ATTR_VERIFY_LENGTH
                   | TOKEN_ATTR_VERIFY_HEX;

  // ntlm response
  token.sep[4]     = ':';
  token.len[4]     = 48;
  token.attr[4]    = TOKEN_ATTR_FIXED_LENGTH
                   | TOKEN_ATTR_VERIFY_HEX;

  // challenge
  token.sep[5]     = ':';
  token.len[5]     = 16;
  token.attr[5]    = TOKEN_ATTR_FIXED_LENGTH
                   | TOKEN_ATTR_VERIFY_HEX;

  const int rc_tokenizer = input_tokenizer ((const u8 *) line_buf, line_len, &token);

  if (rc_tokenizer != PARSER_OK) return (rc_tokenizer);

  const u8 *user_pos     = token.buf[0];
  const u8 *domain_pos   = token.buf[2];
  const u8 *srvchall_pos = token.buf[3];
  const u8 *hash_pos     = token.buf[4];
  const u8 *clichall_pos = token.buf[5];

  const int user_len     = token.len[0];
  const int domain_len   = token.len[2];
  const int srvchall_len = token.len[3];
  const int clichall_len = token.len[5];

  /**
   * store some data for later use
   */

  netntlm->user_len     = user_len     * 2;
  netntlm->domain_len   = domain_len   * 2;
  netntlm->srvchall_len = srvchall_len / 2;
  netntlm->clichall_len = clichall_len / 2;

  u8 *userdomain_ptr = (u8 *) netntlm->userdomain_buf;
  u8 *chall_ptr      = (u8 *) netntlm->chall_buf;

  /**
   * handle username and domainname
   */

  for (int i = 0; i < user_len; i++)
  {
    *userdomain_ptr++ = user_pos[i];
    *userdomain_ptr++ = 0;
  }

  for (int i = 0; i < domain_len; i++)
  {
    *userdomain_ptr++ = domain_pos[i];
    *userdomain_ptr++ = 0;
  }

  /**
   * handle server challenge encoding
   */

  for (int i = 0; i < srvchall_len; i += 2)
  {
    const u8 p0 = srvchall_pos[i + 0];
    const u8 p1 = srvchall_pos[i + 1];

    *chall_ptr++ = hex_convert (p1) << 0
                 | hex_convert (p0) << 4;
  }

  /**
   * handle client challenge encoding
   */

  for (int i = 0; i < clichall_len; i += 2)
  {
    const u8 p0 = clichall_pos[i + 0];
    const u8 p1 = clichall_pos[i + 1];

    *chall_ptr++ = hex_convert (p1) << 0
                 | hex_convert (p0) << 4;
  }

  /**
   * store data
   */

  const bool parse_rc = generic_salt_decode (hashconfig, clichall_pos, clichall_len, (u8 *) salt->salt_buf, (int *) &salt->salt_len);

  if (parse_rc == false) return (PARSER_SALT_LENGTH);

  digest[0] = hex_to_u32 (hash_pos +  0);
  digest[1] = hex_to_u32 (hash_pos +  8);
  digest[2] = hex_to_u32 (hash_pos + 16);
  digest[3] = hex_to_u32 (hash_pos + 24);

  /* special case, last 8 byte do not need to be checked since they are brute-forced next */

  u32 digest_tmp[2];

  digest_tmp[0] = hex_to_u32 (hash_pos + 32);
  digest_tmp[1] = hex_to_u32 (hash_pos + 40);

  /* special case 2: ESS */

  if (srvchall_len == 48)
  {
    if ((netntlm->chall_buf[2] == 0) && (netntlm->chall_buf[3] == 0) && (netntlm->chall_buf[4] == 0) && (netntlm->chall_buf[5] == 0))
    {
      u32 w[16] = { 0 };

      w[ 0] = salt->salt_buf[0];
      w[ 1] = salt->salt_buf[1];
      w[ 2] = netntlm->chall_buf[0];
      w[ 3] = netntlm->chall_buf[1];
      w[ 4] = 0x80;
      w[14] = 16 * 8;

      u32 dgst[4] = { 0 };

      dgst[0] = MD5M_A;
      dgst[1] = MD5M_B;
      dgst[2] = MD5M_C;
      dgst[3] = MD5M_D;

      md5_transform (w + 0, w + 4, w + 8, w + 12, dgst);

      salt->salt_buf[0] = dgst[0];
      salt->salt_buf[1] = dgst[1];
    }
  }

  /* precompute netntlmv1 exploit start */

  for (u32 i = 0; i < 0x10000; i++)
  {
    u32 key_md4[2] = { 0 };
    u32 key_des[2] = { 0 };

    key_md4[0] = i;

    transform_netntlmv1_key ((const u8 *) key_md4, (u8 *) key_des);

    u32 Kc[16] = { 0 };
    u32 Kd[16] = { 0 };

    _des_crypt_keysetup (key_des[0], key_des[1], Kc, Kd, (u32 (*)[64]) c_skb);

    u32 data3[2] = { salt->salt_buf[0], salt->salt_buf[1] };

    _des_crypt_encrypt (data3, data3, Kc, Kd, (u32 (*)[64]) c_SPtrans);

    if (data3[0] != digest_tmp[0]) continue;
    if (data3[1] != digest_tmp[1]) continue;

    salt->salt_buf[2] = i;

    salt->salt_len = 24;

    break;
  }

  salt->salt_buf_pc[0] = digest_tmp[0];
  salt->salt_buf_pc[1] = digest_tmp[1];

  /* precompute netntlmv1 exploit stop */

  DES_IP (digest[0], digest[1]);
  DES_IP (digest[2], digest[3]);

  digest[0] = rotr32 (digest[0], 29);
  digest[1] = rotr32 (digest[1], 29);
  digest[2] = rotr32 (digest[2], 29);
  digest[3] = rotr32 (digest[3], 29);

  DES_IP (salt->salt_buf[0], salt->salt_buf[1]);

  salt->salt_buf[0] = rotl32 (salt->salt_buf[0], 3);
  salt->salt_buf[1] = rotl32 (salt->salt_buf[1], 3);

  return (PARSER_OK);
}

int module_hash_encode (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const void *digest_buf, MAYBE_UNUSED const salt_t *salt, MAYBE_UNUSED const void *esalt_buf, MAYBE_UNUSED const void *hook_salt_buf, MAYBE_UNUSED const hashinfo_t *hash_info, char *line_buf, MAYBE_UNUSED const int line_size)
{
  const u32 *digest = (const u32 *) digest_buf;

  const netntlm_t *netntlm = (const netntlm_t *) esalt_buf;

  // we can not change anything in the original buffer, otherwise destroying sorting
  // therefore create some local buffer

  u32 tmp[4];

  tmp[0] = digest[0];
  tmp[1] = digest[1];
  tmp[2] = digest[2];
  tmp[3] = digest[3];

  tmp[0] = rotl32 (tmp[0], 29);
  tmp[1] = rotl32 (tmp[1], 29);
  tmp[2] = rotl32 (tmp[2], 29);
  tmp[3] = rotl32 (tmp[3], 29);

  DES_FP (tmp[1], tmp[0]);
  DES_FP (tmp[3], tmp[2]);

  u8 *out_buf = (u8 *) line_buf;

  int out_len = 0;

  const u8 *ptr = (const u8 *) netntlm->userdomain_buf;

  for (int i = 0; i < netntlm->user_len; i += 2)
  {
    out_buf[out_len++] = ptr[i];
  }

  out_buf[out_len++] = ':';
  out_buf[out_len++] = ':';

  ptr += netntlm->user_len;

  for (int i = 0; i < netntlm->domain_len; i += 2)
  {
    out_buf[out_len++] = ptr[i];
  }

  out_buf[out_len++] = ':';

  ptr = (const u8 *) netntlm->chall_buf;

  for (int i = 0; i < netntlm->srvchall_len; i++)
  {
    u8_to_hex (ptr[i], out_buf + out_len); out_len += 2;
  }

  out_buf[out_len++] = ':';

  u32_to_hex (tmp[0], out_buf + out_len); out_len += 8;
  u32_to_hex (tmp[1], out_buf + out_len); out_len += 8;
  u32_to_hex (tmp[2], out_buf + out_len); out_len += 8;
  u32_to_hex (tmp[3], out_buf + out_len); out_len += 8;

  u32_to_hex (salt->salt_buf_pc[0], out_buf + out_len); out_len += 8;
  u32_to_hex (salt->salt_buf_pc[1], out_buf + out_len); out_len += 8;

  out_buf[out_len++] = ':';

  ptr += netntlm->srvchall_len;

  for (int i = 0; i < netntlm->clichall_len; i++)
  {
    u8_to_hex (ptr[i], out_buf + out_len); out_len += 2;
  }

  return out_len;
}

u32 module_pw_max (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra)
{
  const u32 pw_max = 32; // Length of a NT hash

  return pw_max;
}

u32 module_pw_min (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra)
{
  const u32 pw_min = 32; // Length of a NT hash

  return pw_min;
}

const char *module_benchmark_mask (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra)
{
 const char *mask = "?a?a?a?a?a?a?a?axxxxxxxxxxxxxxxx";
 return mask;
}

void module_init (module_ctx_t *module_ctx)
{
  module_ctx->module_context_size             = MODULE_CONTEXT_SIZE_CURRENT;
  module_ctx->module_interface_version        = MODULE_INTERFACE_VERSION_CURRENT;

  module_ctx->module_attack_exec              = module_attack_exec;
  module_ctx->module_benchmark_esalt          = MODULE_DEFAULT;
  module_ctx->module_benchmark_hook_salt      = MODULE_DEFAULT;
  module_ctx->module_benchmark_mask           = module_benchmark_mask;
  module_ctx->module_benchmark_charset        = MODULE_DEFAULT;
  module_ctx->module_benchmark_salt           = MODULE_DEFAULT;
  module_ctx->module_build_plain_postprocess  = MODULE_DEFAULT;
  module_ctx->module_deep_comp_kernel         = MODULE_DEFAULT;
  module_ctx->module_deprecated_notice        = MODULE_DEFAULT;
  module_ctx->module_dgst_pos0                = module_dgst_pos0;
  module_ctx->module_dgst_pos1                = module_dgst_pos1;
  module_ctx->module_dgst_pos2                = module_dgst_pos2;
  module_ctx->module_dgst_pos3                = module_dgst_pos3;
  module_ctx->module_dgst_size                = module_dgst_size;
  module_ctx->module_dictstat_disable         = MODULE_DEFAULT;
  module_ctx->module_esalt_size               = module_esalt_size;
  module_ctx->module_extra_buffer_size        = MODULE_DEFAULT;
  module_ctx->module_extra_tmp_size           = MODULE_DEFAULT;
  module_ctx->module_extra_tuningdb_block     = MODULE_DEFAULT;
  module_ctx->module_forced_outfile_format    = MODULE_DEFAULT;
  module_ctx->module_hash_binary_count        = MODULE_DEFAULT;
  module_ctx->module_hash_binary_parse        = MODULE_DEFAULT;
  module_ctx->module_hash_binary_save         = MODULE_DEFAULT;
  module_ctx->module_hash_decode_postprocess  = MODULE_DEFAULT;
  module_ctx->module_hash_decode_potfile      = MODULE_DEFAULT;
  module_ctx->module_hash_decode_zero_hash    = MODULE_DEFAULT;
  module_ctx->module_hash_decode              = module_hash_decode;
  module_ctx->module_hash_encode_status       = MODULE_DEFAULT;
  module_ctx->module_hash_encode_potfile      = MODULE_DEFAULT;
  module_ctx->module_hash_encode              = module_hash_encode;
  module_ctx->module_hash_init_selftest       = MODULE_DEFAULT;
  module_ctx->module_hash_mode                = MODULE_DEFAULT;
  module_ctx->module_hash_category            = module_hash_category;
  module_ctx->module_hash_name                = module_hash_name;
  module_ctx->module_hashes_count_min         = MODULE_DEFAULT;
  module_ctx->module_hashes_count_max         = MODULE_DEFAULT;
  module_ctx->module_hlfmt_disable            = MODULE_DEFAULT;
  module_ctx->module_hook_extra_param_size    = MODULE_DEFAULT;
  module_ctx->module_hook_extra_param_init    = MODULE_DEFAULT;
  module_ctx->module_hook_extra_param_term    = MODULE_DEFAULT;
  module_ctx->module_hook12                   = MODULE_DEFAULT;
  module_ctx->module_hook23                   = MODULE_DEFAULT;
  module_ctx->module_hook_salt_size           = MODULE_DEFAULT;
  module_ctx->module_hook_size                = MODULE_DEFAULT;
  module_ctx->module_jit_build_options        = module_jit_build_options;
  module_ctx->module_jit_cache_disable        = MODULE_DEFAULT;
  module_ctx->module_kernel_accel_max         = MODULE_DEFAULT;
  module_ctx->module_kernel_accel_min         = MODULE_DEFAULT;
  module_ctx->module_kernel_loops_max         = MODULE_DEFAULT;
  module_ctx->module_kernel_loops_min         = MODULE_DEFAULT;
  module_ctx->module_kernel_threads_max       = MODULE_DEFAULT;
  module_ctx->module_kernel_threads_min       = MODULE_DEFAULT;
  module_ctx->module_kern_type                = module_kern_type;
  module_ctx->module_kern_type_dynamic        = MODULE_DEFAULT;
  module_ctx->module_opti_type                = module_opti_type;
  module_ctx->module_opts_type                = module_opts_type;
  module_ctx->module_outfile_check_disable    = MODULE_DEFAULT;
  module_ctx->module_outfile_check_nocomp     = MODULE_DEFAULT;
  module_ctx->module_potfile_custom_check     = MODULE_DEFAULT;
  module_ctx->module_potfile_disable          = MODULE_DEFAULT;
  module_ctx->module_potfile_keep_all_hashes  = MODULE_DEFAULT;
  module_ctx->module_pwdump_column            = MODULE_DEFAULT;
  module_ctx->module_pw_max                   = module_pw_max;
  module_ctx->module_pw_min                   = module_pw_min;
  module_ctx->module_salt_max                 = MODULE_DEFAULT;
  module_ctx->module_salt_min                 = MODULE_DEFAULT;
  module_ctx->module_salt_type                = module_salt_type;
  module_ctx->module_separator                = MODULE_DEFAULT;
  module_ctx->module_st_hash                  = module_st_hash;
  module_ctx->module_st_pass                  = module_st_pass;
  module_ctx->module_tmp_size                 = module_tmp_size;
  module_ctx->module_unstable_warning         = MODULE_DEFAULT;
  module_ctx->module_warmup_disable           = MODULE_DEFAULT;
}
