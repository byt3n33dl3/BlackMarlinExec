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

static const u32   ATTACK_EXEC    = ATTACK_EXEC_INSIDE_KERNEL;
static const u32   DGST_POS0      = 0;
static const u32   DGST_POS1      = 1;
static const u32   DGST_POS2      = 2;
static const u32   DGST_POS3      = 3;
static const u32   DGST_SIZE      = DGST_SIZE_4_4;
static const u32   HASH_CATEGORY  = HASH_CATEGORY_PRIVATE_KEY;
static const char *HASH_NAME      = "RSA/DSA/EC/OpenSSH Private Keys ($6$)";
static const u64   KERN_TYPE      = 22921;
static const u32   OPTI_TYPE      = OPTI_TYPE_ZERO_BYTE;
static const u64   OPTS_TYPE      = OPTS_TYPE_STOCK_MODULE
                                  | OPTS_TYPE_PT_GENERATE_LE
                                  | OPTS_TYPE_SUGGEST_KG
                                  | OPTS_TYPE_MAXIMUM_THREADS;
static const u32   SALT_TYPE      = SALT_TYPE_EMBEDDED;
static const char *ST_PASS        = "hashcat";
static const char *ST_HASH        = "$sshng$6$8$7620048997557487$1224$13517a1204dc69528c474ef5cbb02d548698771f2a607c04ea54eb92f13dedba0f2185d2884b4db0c95ce6432856108ea2db858be443e0f8004ffcd60857e4ff1e42b17f056998ec5f96806a06e39cc6e6d7ef4ce8ae62b57b2ec0d0236c35cf4bc00dd6fda45e4788dcca0f0e44dddae1dad2d6e7b705d076f2f8fc5837eec4a002d9633bcad1f395ca8e85e78459abe293451567494d440c3f087bb7fe4d6588018f92ca327dda514a99d7b4b32434da0e3b1bf9344afb2fe29f8d8315a385fe8b81fd4c202c7d82cd9f0bb1600e59762ab6ea1b42e4e299f0a59ce510767e1e1138453d362d0a1aa6680e86b5aa0bd5c62165f4fe7c2867f9533578085adc36739d6c9cf7b36899aac39dcabac8b39194433423e8e18ba28496bbe14dd01231eb5b091ae9de0f7f9ea714c22edac394077fb758fe496e1880571ade399ac229457ddd98577f8a01a036ad3bc8b03a9fb02e26b4b76f6cb676eabe82d1606fca0c5fca62cd1d82c3df1ed58ab4acd4611b2827ebde722bc05e471a427225818aa36dabf5bf1203ccb0ebc8dec097e49f7f948bfe7b939e6d0ff1125b863c033768f588964f8b77ca1e2425751f873f80e5d6a0671f7860cf4a46533585094726c3afe5f7203fa4a01650fa9839772c713a033139cfc6a6e6f7dc62e5844d4c57ef4fc3321bc85d597a54bd6fe37e9e696cf3b5ec66f55232e0964dc5cf880d8a41a9891150618bd9c088fd9824af0d86f817f2c79429c3d56cd6eb41eb6120f9accc10a863f23a2bb6c57d4bd6193f2283ae0215e2e87e672a8438e2550c044fa9556bdb4afc40d8c2752ffbc6c95571756a3c230bb2fa95f519f8da238ef0857ecf860247a8b26e28269f9bad564e7d8bfba2eac9760b52449251cb35e183f5b309a09071535154c6f1013b58f305b544f3589c9eb0e9ac4267a84374a3eab49c53aa9bedbf97f8f19ebc212d8db74ee03554a3514140667fa4ce8e06aad3f32d1b00015be0e8979fe66736018589beee06d6f318851dbe8d9689e70202185d71fc5e5a3d2996ddb8ae1d7718c49855c6f8c43301e0915f324f30d0d9c6a8504a91ad5a7179aafb87ede58598394949910874850994abe815817359152ff6a7c8cc6f19524dfc5e50ddfd038a2275bf809e3c8f05ed3e3137ebd62d91cd3578533787c3847e3c5e07e5a891480e5ceabcf6c344e7bec8b640ab9a03e90b846b35d2f46ba150accef32d2597b064810b15fd54fca6d2b146feabcd05c0b51617ae95e36f6817a62c3ff42c5c2f6f1d20a8a1fd334d3b7d3f83bba057b79d9b5508bb0cb706ba00acb0ab797401fdcfac80b5b6e38e51aec0b38f33ff4690425ca28d88a2e876591521230150b4e20a4a82e50061cee9c0705100bfe5fdbd8ef27aec20387cf32455ef305bce2a91ae6da91fc41376b97149e9b41c901b24811df9272ff09718923b8d94e8e459a164a22b0eca47653f3efcbf08188c5da78cd9fb9eda1761094f9d8bc3d479e9f40c7d79ebaaba2a5c632329f20a9962040ff8f512b42c5f32a8460d87b8e93c6f980a1562c436eea1c8994fbf671dda3c4ccd3c142acfcdde2ab61227289ad408213ac8e22d9ef487f36925f5ba3b8e7e913d25c4a8592c861d13f03b615bc2760aabc61d68db80d35296a3312fdf4b56c0fbee5ab3fea1cf9caf3960a564046939e8002d2dd909db446d85aeae9dd42a33fe28684f722172e6";

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

typedef struct pem
{
  u32 data_buf[16384];
  int data_len;

  int cipher;

} pem_t;

static const char *SIGNATURE_SSHNG = "$sshng$";

u64 module_esalt_size (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra)
{
  const u64 esalt_size = (const u64) sizeof (pem_t);

  return esalt_size;
}

int module_hash_decode (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED void *digest_buf, MAYBE_UNUSED salt_t *salt, MAYBE_UNUSED void *esalt_buf, MAYBE_UNUSED void *hook_salt_buf, MAYBE_UNUSED hashinfo_t *hash_info, const char *line_buf, MAYBE_UNUSED const int line_len)
{
  u32 *digest = (u32 *) digest_buf;

  pem_t *pem = (pem_t *) esalt_buf;

  hc_token_t token;

  memset (&token, 0, sizeof (hc_token_t));

  token.token_cnt  = 6;

  token.signatures_cnt    = 1;
  token.signatures_buf[0] = SIGNATURE_SSHNG;

  token.len[0]     = 7;
  token.attr[0]    = TOKEN_ATTR_FIXED_LENGTH
                   | TOKEN_ATTR_VERIFY_SIGNATURE;

  token.sep[1]     = '$';
  token.len[1]     = 1;
  token.attr[1]    = TOKEN_ATTR_FIXED_LENGTH
                   | TOKEN_ATTR_VERIFY_DIGIT;

  token.sep[2]     = '$';
  token.len[2]     = 1;
  token.attr[2]    = TOKEN_ATTR_FIXED_LENGTH
                   | TOKEN_ATTR_VERIFY_DIGIT;

  token.sep[3]     = '$';
  token.len[3]     = 16;
  token.attr[3]    = TOKEN_ATTR_FIXED_LENGTH
                   | TOKEN_ATTR_VERIFY_HEX;

  token.sep[4]     = '$';
  token.len_min[4] = 1;
  token.len_max[4] = 8;
  token.attr[4]    = TOKEN_ATTR_VERIFY_LENGTH
                   | TOKEN_ATTR_VERIFY_DIGIT;

  token.sep[5]     = '$';
  token.len_min[5] = 64;    // 64 = minimum size (32 byte) to avoid out of boundary read in kernel
  token.len_max[5] = 65536; // 65536 = maximum asn.1 size fitting into 2 byte length integer
  token.attr[5]    = TOKEN_ATTR_VERIFY_LENGTH
                   | TOKEN_ATTR_VERIFY_HEX;

  const int rc_tokenizer = input_tokenizer ((const u8 *) line_buf, line_len, &token);

  if (rc_tokenizer != PARSER_OK) return (rc_tokenizer);

  // cipher

  const u8 *cipher_pos = token.buf[1];

  int cipher = hc_strtoul ((const char *) cipher_pos, NULL, 10);

  if (cipher != 6) return (PARSER_CIPHER);

  pem->cipher = cipher;

  // IV length

  const u8 *iv_len_verify_pos = token.buf[2];

  const int iv_len_verify = hc_strtoul ((const char *) iv_len_verify_pos, NULL, 10);

  if (iv_len_verify != 8) return (PARSER_SALT_LENGTH);

  // IV buffer

  const u8 *iv_pos = token.buf[3];
  const int iv_len = token.len[3];

  if (iv_len != 16) return (PARSER_SALT_LENGTH);

  salt->salt_buf[0] = hex_to_u32 (iv_pos +  0);
  salt->salt_buf[1] = hex_to_u32 (iv_pos +  8);

  salt->salt_len = 8;

  // data length

  const u8 *data_len_verify_pos = token.buf[4];

  const int data_len_verify = hc_strtoul ((const char *) data_len_verify_pos, NULL, 10);

  // data

  const u8 *data_pos = token.buf[5];
  const int data_len = token.len[5];

  pem->data_len = hex_decode (data_pos, data_len, (u8 *) pem->data_buf);

  if (data_len_verify != pem->data_len) return (PARSER_HASH_LENGTH);

  // data has to be a multiple of cipher block size

  if (pem->data_len % 8) return (PARSER_HASH_LENGTH);

  // hash

  digest[0] = pem->data_buf[0];
  digest[1] = pem->data_buf[1];
  digest[2] = pem->data_buf[2];
  digest[3] = pem->data_buf[3];

  return (PARSER_OK);
}

int module_hash_encode (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const void *digest_buf, MAYBE_UNUSED const salt_t *salt, MAYBE_UNUSED const void *esalt_buf, MAYBE_UNUSED const void *hook_salt_buf, MAYBE_UNUSED const hashinfo_t *hash_info, char *line_buf, MAYBE_UNUSED const int line_size)
{
  const pem_t *pem = (const pem_t *) esalt_buf;

  u8 *out_buf = (u8 *) line_buf;

  int out_len = 0;

  out_len = snprintf ((char *) out_buf, line_size, "%s%d$8$%08x%08x$%d$",
    SIGNATURE_SSHNG,
    pem->cipher,
    byte_swap_32 (salt->salt_buf[0]),
    byte_swap_32 (salt->salt_buf[1]),
    pem->data_len);

  out_len += hex_encode ((const u8 *) pem->data_buf, pem->data_len, out_buf + out_len);

  return out_len;
}

void module_init (module_ctx_t *module_ctx)
{
  module_ctx->module_context_size             = MODULE_CONTEXT_SIZE_CURRENT;
  module_ctx->module_interface_version        = MODULE_INTERFACE_VERSION_CURRENT;

  module_ctx->module_attack_exec              = module_attack_exec;
  module_ctx->module_benchmark_esalt          = MODULE_DEFAULT;
  module_ctx->module_benchmark_hook_salt      = MODULE_DEFAULT;
  module_ctx->module_benchmark_mask           = MODULE_DEFAULT;
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
  module_ctx->module_jit_build_options        = MODULE_DEFAULT;
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
  module_ctx->module_pw_max                   = MODULE_DEFAULT;
  module_ctx->module_pw_min                   = MODULE_DEFAULT;
  module_ctx->module_salt_max                 = MODULE_DEFAULT;
  module_ctx->module_salt_min                 = MODULE_DEFAULT;
  module_ctx->module_salt_type                = module_salt_type;
  module_ctx->module_separator                = MODULE_DEFAULT;
  module_ctx->module_st_hash                  = module_st_hash;
  module_ctx->module_st_pass                  = module_st_pass;
  module_ctx->module_tmp_size                 = MODULE_DEFAULT;
  module_ctx->module_unstable_warning         = MODULE_DEFAULT;
  module_ctx->module_warmup_disable           = MODULE_DEFAULT;
}
