/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#include "inc_vendor.h"
#include "inc_types.h"
#include "inc_platform.h"
#include "inc_common.h"
#include "inc_luks_xts.h"

DECLSPEC void xts_mul2 (PRIVATE_AS u32 *in, PRIVATE_AS u32 *out)
{
  const u32 c = in[3] >> 31;

  out[3] = (in[3] << 1) | (in[2] >> 31);
  out[2] = (in[2] << 1) | (in[1] >> 31);
  out[1] = (in[1] << 1) | (in[0] >> 31);
  out[0] = (in[0] << 1);

  out[0] ^= c * 0x87;
}
