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

static const u32   ATTACK_EXEC    = ATTACK_EXEC_OUTSIDE_KERNEL;
static const u32   DGST_POS0      = 0;
static const u32   DGST_POS1      = 1;
static const u32   DGST_POS2      = 2;
static const u32   DGST_POS3      = 3;
static const u32   DGST_SIZE      = DGST_SIZE_8_8;
static const u32   HASH_CATEGORY  = HASH_CATEGORY_OS;
static const char *HASH_NAME      = "sha512crypt $6$, SHA512 (Unix)";
static const u64   KERN_TYPE      = 1800;
static const u32   OPTI_TYPE      = OPTI_TYPE_ZERO_BYTE
                                  | OPTI_TYPE_USES_BITS_64;
static const u64   OPTS_TYPE      = OPTS_TYPE_STOCK_MODULE
                                  | OPTS_TYPE_PT_GENERATE_LE
                                  | OPTS_TYPE_MP_MULTI_DISABLE
                                  | OPTS_TYPE_MAXIMUM_THREADS;
static const u32   SALT_TYPE      = SALT_TYPE_EMBEDDED;
static const char *ST_PASS        = "hashcat";
static const char *ST_HASH        = "$6$72820166$U4DVzpcYxgw7MVVDGGvB2/H5lRistD5.Ah4upwENR5UtffLR4X4SxSzfREv8z6wVl0jRFX40/KnYVvK4829kD1";

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

typedef struct sha512crypt_tmp
{
  u64 l_alt_result[8];
  u64 l_p_bytes[2];
  u64 l_s_bytes[2];

  // pure version

  u32 alt_result[16];
  u32 p_bytes[64];
  u32 s_bytes[64];

} sha512crypt_tmp_t;

static const u32   ROUNDS_SHA512CRYPT    = 5000;
static const char *SIGNATURE_SHA512CRYPT = "$6$";

static void sha512crypt_decode (u8 digest[64], const u8 buf[86])
{
  int l;

  l  = itoa64_to_int (buf[ 0]) <<  0;
  l |= itoa64_to_int (buf[ 1]) <<  6;
  l |= itoa64_to_int (buf[ 2]) << 12;
  l |= itoa64_to_int (buf[ 3]) << 18;

  digest[ 0] = (l >> 16) & 0xff;
  digest[21] = (l >>  8) & 0xff;
  digest[42] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[ 4]) <<  0;
  l |= itoa64_to_int (buf[ 5]) <<  6;
  l |= itoa64_to_int (buf[ 6]) << 12;
  l |= itoa64_to_int (buf[ 7]) << 18;

  digest[22] = (l >> 16) & 0xff;
  digest[43] = (l >>  8) & 0xff;
  digest[ 1] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[ 8]) <<  0;
  l |= itoa64_to_int (buf[ 9]) <<  6;
  l |= itoa64_to_int (buf[10]) << 12;
  l |= itoa64_to_int (buf[11]) << 18;

  digest[44] = (l >> 16) & 0xff;
  digest[ 2] = (l >>  8) & 0xff;
  digest[23] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[12]) <<  0;
  l |= itoa64_to_int (buf[13]) <<  6;
  l |= itoa64_to_int (buf[14]) << 12;
  l |= itoa64_to_int (buf[15]) << 18;

  digest[ 3] = (l >> 16) & 0xff;
  digest[24] = (l >>  8) & 0xff;
  digest[45] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[16]) <<  0;
  l |= itoa64_to_int (buf[17]) <<  6;
  l |= itoa64_to_int (buf[18]) << 12;
  l |= itoa64_to_int (buf[19]) << 18;

  digest[25] = (l >> 16) & 0xff;
  digest[46] = (l >>  8) & 0xff;
  digest[ 4] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[20]) <<  0;
  l |= itoa64_to_int (buf[21]) <<  6;
  l |= itoa64_to_int (buf[22]) << 12;
  l |= itoa64_to_int (buf[23]) << 18;

  digest[47] = (l >> 16) & 0xff;
  digest[ 5] = (l >>  8) & 0xff;
  digest[26] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[24]) <<  0;
  l |= itoa64_to_int (buf[25]) <<  6;
  l |= itoa64_to_int (buf[26]) << 12;
  l |= itoa64_to_int (buf[27]) << 18;

  digest[ 6] = (l >> 16) & 0xff;
  digest[27] = (l >>  8) & 0xff;
  digest[48] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[28]) <<  0;
  l |= itoa64_to_int (buf[29]) <<  6;
  l |= itoa64_to_int (buf[30]) << 12;
  l |= itoa64_to_int (buf[31]) << 18;

  digest[28] = (l >> 16) & 0xff;
  digest[49] = (l >>  8) & 0xff;
  digest[ 7] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[32]) <<  0;
  l |= itoa64_to_int (buf[33]) <<  6;
  l |= itoa64_to_int (buf[34]) << 12;
  l |= itoa64_to_int (buf[35]) << 18;

  digest[50] = (l >> 16) & 0xff;
  digest[ 8] = (l >>  8) & 0xff;
  digest[29] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[36]) <<  0;
  l |= itoa64_to_int (buf[37]) <<  6;
  l |= itoa64_to_int (buf[38]) << 12;
  l |= itoa64_to_int (buf[39]) << 18;

  digest[ 9] = (l >> 16) & 0xff;
  digest[30] = (l >>  8) & 0xff;
  digest[51] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[40]) <<  0;
  l |= itoa64_to_int (buf[41]) <<  6;
  l |= itoa64_to_int (buf[42]) << 12;
  l |= itoa64_to_int (buf[43]) << 18;

  digest[31] = (l >> 16) & 0xff;
  digest[52] = (l >>  8) & 0xff;
  digest[10] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[44]) <<  0;
  l |= itoa64_to_int (buf[45]) <<  6;
  l |= itoa64_to_int (buf[46]) << 12;
  l |= itoa64_to_int (buf[47]) << 18;

  digest[53] = (l >> 16) & 0xff;
  digest[11] = (l >>  8) & 0xff;
  digest[32] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[48]) <<  0;
  l |= itoa64_to_int (buf[49]) <<  6;
  l |= itoa64_to_int (buf[50]) << 12;
  l |= itoa64_to_int (buf[51]) << 18;

  digest[12] = (l >> 16) & 0xff;
  digest[33] = (l >>  8) & 0xff;
  digest[54] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[52]) <<  0;
  l |= itoa64_to_int (buf[53]) <<  6;
  l |= itoa64_to_int (buf[54]) << 12;
  l |= itoa64_to_int (buf[55]) << 18;

  digest[34] = (l >> 16) & 0xff;
  digest[55] = (l >>  8) & 0xff;
  digest[13] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[56]) <<  0;
  l |= itoa64_to_int (buf[57]) <<  6;
  l |= itoa64_to_int (buf[58]) << 12;
  l |= itoa64_to_int (buf[59]) << 18;

  digest[56] = (l >> 16) & 0xff;
  digest[14] = (l >>  8) & 0xff;
  digest[35] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[60]) <<  0;
  l |= itoa64_to_int (buf[61]) <<  6;
  l |= itoa64_to_int (buf[62]) << 12;
  l |= itoa64_to_int (buf[63]) << 18;

  digest[15] = (l >> 16) & 0xff;
  digest[36] = (l >>  8) & 0xff;
  digest[57] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[64]) <<  0;
  l |= itoa64_to_int (buf[65]) <<  6;
  l |= itoa64_to_int (buf[66]) << 12;
  l |= itoa64_to_int (buf[67]) << 18;

  digest[37] = (l >> 16) & 0xff;
  digest[58] = (l >>  8) & 0xff;
  digest[16] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[68]) <<  0;
  l |= itoa64_to_int (buf[69]) <<  6;
  l |= itoa64_to_int (buf[70]) << 12;
  l |= itoa64_to_int (buf[71]) << 18;

  digest[59] = (l >> 16) & 0xff;
  digest[17] = (l >>  8) & 0xff;
  digest[38] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[72]) <<  0;
  l |= itoa64_to_int (buf[73]) <<  6;
  l |= itoa64_to_int (buf[74]) << 12;
  l |= itoa64_to_int (buf[75]) << 18;

  digest[18] = (l >> 16) & 0xff;
  digest[39] = (l >>  8) & 0xff;
  digest[60] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[76]) <<  0;
  l |= itoa64_to_int (buf[77]) <<  6;
  l |= itoa64_to_int (buf[78]) << 12;
  l |= itoa64_to_int (buf[79]) << 18;

  digest[40] = (l >> 16) & 0xff;
  digest[61] = (l >>  8) & 0xff;
  digest[19] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[80]) <<  0;
  l |= itoa64_to_int (buf[81]) <<  6;
  l |= itoa64_to_int (buf[82]) << 12;
  l |= itoa64_to_int (buf[83]) << 18;

  digest[62] = (l >> 16) & 0xff;
  digest[20] = (l >>  8) & 0xff;
  digest[41] = (l >>  0) & 0xff;

  l  = itoa64_to_int (buf[84]) <<  0;
  l |= itoa64_to_int (buf[85]) <<  6;

  digest[63] = (l >>  0) & 0xff;
}

static void sha512crypt_encode (const u8 digest[64], u8 buf[86])
{
  int l;

  l = (digest[ 0] << 16) | (digest[21] << 8) | (digest[42] << 0);

  buf[ 0] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[ 1] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[ 2] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[ 3] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[22] << 16) | (digest[43] << 8) | (digest[ 1] << 0);

  buf[ 4] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[ 5] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[ 6] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[ 7] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[44] << 16) | (digest[ 2] << 8) | (digest[23] << 0);

  buf[ 8] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[ 9] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[10] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[11] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[ 3] << 16) | (digest[24] << 8) | (digest[45] << 0);

  buf[12] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[13] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[14] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[15] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[25] << 16) | (digest[46] << 8) | (digest[ 4] << 0);

  buf[16] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[17] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[18] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[19] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[47] << 16) | (digest[ 5] << 8) | (digest[26] << 0);

  buf[20] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[21] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[22] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[23] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[ 6] << 16) | (digest[27] << 8) | (digest[48] << 0);

  buf[24] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[25] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[26] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[27] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[28] << 16) | (digest[49] << 8) | (digest[ 7] << 0);

  buf[28] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[29] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[30] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[31] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[50] << 16) | (digest[ 8] << 8) | (digest[29] << 0);

  buf[32] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[33] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[34] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[35] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[ 9] << 16) | (digest[30] << 8) | (digest[51] << 0);

  buf[36] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[37] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[38] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[39] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[31] << 16) | (digest[52] << 8) | (digest[10] << 0);

  buf[40] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[41] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[42] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[43] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[53] << 16) | (digest[11] << 8) | (digest[32] << 0);

  buf[44] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[45] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[46] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[47] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[12] << 16) | (digest[33] << 8) | (digest[54] << 0);

  buf[48] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[49] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[50] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[51] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[34] << 16) | (digest[55] << 8) | (digest[13] << 0);

  buf[52] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[53] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[54] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[55] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[56] << 16) | (digest[14] << 8) | (digest[35] << 0);

  buf[56] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[57] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[58] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[59] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[15] << 16) | (digest[36] << 8) | (digest[57] << 0);

  buf[60] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[61] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[62] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[63] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[37] << 16) | (digest[58] << 8) | (digest[16] << 0);

  buf[64] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[65] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[66] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[67] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[59] << 16) | (digest[17] << 8) | (digest[38] << 0);

  buf[68] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[69] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[70] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[71] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[18] << 16) | (digest[39] << 8) | (digest[60] << 0);

  buf[72] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[73] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[74] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[75] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[40] << 16) | (digest[61] << 8) | (digest[19] << 0);

  buf[76] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[77] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[78] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[79] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l = (digest[62] << 16) | (digest[20] << 8) | (digest[41] << 0);

  buf[80] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[81] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[82] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[83] = int_to_itoa64 (l & 0x3f); //l >>= 6;

  l =                                          (digest[63] << 0);

  buf[84] = int_to_itoa64 (l & 0x3f); l >>= 6;
  buf[85] = int_to_itoa64 (l & 0x3f); //l >>= 6;
}

u32 module_kernel_threads_max (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra)
{
  const u32 kernel_threads_max = 256;

  return kernel_threads_max;
}

bool module_unstable_warning (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra, MAYBE_UNUSED const hc_device_param_t *device_param)
{
  // AMD Radeon Pro W5700X Compute Engine; 1.2 (Apr 22 2021 21:54:44); 11.3.1; 20E241
  if ((device_param->opencl_platform_vendor_id == VENDOR_ID_APPLE) && (device_param->opencl_device_type & CL_DEVICE_TYPE_GPU))
  {
    if (hashconfig->opti_type & OPTI_TYPE_OPTIMIZED_KERNEL)
    {
      return true;
    }
  }

  // AMD Radeon Pro W5700X, Metal.Version.: 261.13, compiler hangs
  if (device_param->is_metal == true)
  {
    if (hashconfig->opti_type & OPTI_TYPE_OPTIMIZED_KERNEL)
    {
      return true;
    }
  }

  return false;
}

char *module_jit_build_options (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra, MAYBE_UNUSED const hashes_t *hashes, MAYBE_UNUSED const hc_device_param_t *device_param)
{
  char *jit_build_options = NULL;

  // Extra treatment for Apple systems
  if (device_param->opencl_platform_vendor_id == VENDOR_ID_APPLE)
  {
    return jit_build_options;
  }

  // HIP
  if (device_param->opencl_device_vendor_id == VENDOR_ID_AMD_USE_HIP)
  {
    hc_asprintf (&jit_build_options, "-fno-unroll-loops");
  }

  // ROCM
  if ((device_param->opencl_device_vendor_id == VENDOR_ID_AMD) && (device_param->has_vperm == true))
  {
    hc_asprintf (&jit_build_options, "-D _unroll");
  }

  return jit_build_options;
}

u64 module_tmp_size (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra)
{
  const u64 tmp_size = (const u64) sizeof (sha512crypt_tmp_t);

  return tmp_size;
}

u32 module_pw_max (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const user_options_t *user_options, MAYBE_UNUSED const user_options_extra_t *user_options_extra)
{
  const bool optimized_kernel = (hashconfig->opti_type & OPTI_TYPE_OPTIMIZED_KERNEL);

  const u32 pw_max = (optimized_kernel == true) ? 15 : PW_MAX;

  return pw_max;
}

int module_hash_decode (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED void *digest_buf, MAYBE_UNUSED salt_t *salt, MAYBE_UNUSED void *esalt_buf, MAYBE_UNUSED void *hook_salt_buf, MAYBE_UNUSED hashinfo_t *hash_info, const char *line_buf, MAYBE_UNUSED const int line_len)
{
  u64 *digest = (u64 *) digest_buf;

  hc_token_t token;

  memset (&token, 0, sizeof (hc_token_t));

  token.token_cnt  = 3;

  token.signatures_cnt    = 1;
  token.signatures_buf[0] = SIGNATURE_SHA512CRYPT;

  token.len[0]     = 3;
  token.attr[0]    = TOKEN_ATTR_FIXED_LENGTH
                   | TOKEN_ATTR_VERIFY_SIGNATURE;

  token.sep[1]     = '$';
  token.len_min[1] = 0;
  token.len_max[1] = 16;
  token.attr[1]    = TOKEN_ATTR_VERIFY_LENGTH
                   | TOKEN_ATTR_OPTIONAL_ROUNDS;

  token.len[2]     = 86;
  token.attr[2]    = TOKEN_ATTR_FIXED_LENGTH
                   | TOKEN_ATTR_VERIFY_BASE64B;

  const int rc_tokenizer = input_tokenizer ((const u8 *) line_buf, line_len, &token);

  if (rc_tokenizer != PARSER_OK) return (rc_tokenizer);

  salt->salt_iter = ROUNDS_SHA512CRYPT;

  if (token.opt_len != -1)
  {
    salt->salt_iter = hc_strtoul ((const char *) token.opt_buf + 7, NULL, 10); // 7 = "rounds="
  }

  const u8 *salt_pos = token.buf[1];
  const int salt_len = token.len[1];

  const bool parse_rc = generic_salt_decode (hashconfig, salt_pos, salt_len, (u8 *) salt->salt_buf, (int *) &salt->salt_len);

  if (parse_rc == false) return (PARSER_SALT_LENGTH);

  const u8 *hash_pos = token.buf[2];

  sha512crypt_decode ((u8 *) digest, hash_pos);

  return (PARSER_OK);
}

int module_hash_encode (MAYBE_UNUSED const hashconfig_t *hashconfig, MAYBE_UNUSED const void *digest_buf, MAYBE_UNUSED const salt_t *salt, MAYBE_UNUSED const void *esalt_buf, MAYBE_UNUSED const void *hook_salt_buf, MAYBE_UNUSED const hashinfo_t *hash_info, char *line_buf, MAYBE_UNUSED const int line_size)
{
  u8 tmp[100] = { 0 };

  sha512crypt_encode (digest_buf, tmp);

  char tmp_salt[SALT_MAX * 2];

  const int salt_len = generic_salt_encode (hashconfig, (const u8 *) salt->salt_buf, (const int) salt->salt_len, (u8 *) tmp_salt);

  tmp_salt[salt_len] = 0;

  int line_len = 0;

  if (salt->salt_iter == ROUNDS_SHA512CRYPT)
  {
    line_len = snprintf (line_buf, line_size, "$6$%s$%s", tmp_salt, tmp);
  }
  else
  {
    line_len = snprintf (line_buf, line_size, "$6$rounds=%u$%s$%s", salt->salt_iter, tmp_salt, tmp);
  }

  return line_len;
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
  module_ctx->module_esalt_size               = MODULE_DEFAULT;
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
  module_ctx->module_kernel_threads_max       = module_kernel_threads_max;
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
  module_ctx->module_pw_min                   = MODULE_DEFAULT;
  module_ctx->module_salt_max                 = MODULE_DEFAULT;
  module_ctx->module_salt_min                 = MODULE_DEFAULT;
  module_ctx->module_salt_type                = module_salt_type;
  module_ctx->module_separator                = MODULE_DEFAULT;
  module_ctx->module_st_hash                  = module_st_hash;
  module_ctx->module_st_pass                  = module_st_pass;
  module_ctx->module_tmp_size                 = module_tmp_size;
  module_ctx->module_unstable_warning         = module_unstable_warning;
  module_ctx->module_warmup_disable           = MODULE_DEFAULT;
}
