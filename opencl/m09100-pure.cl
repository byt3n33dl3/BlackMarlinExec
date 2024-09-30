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
#include M2S(INCLUDE_PATH/inc_hash_sha1.cl)
#endif

#define COMPARE_S M2S(INCLUDE_PATH/inc_comp_single.cl)
#define COMPARE_M M2S(INCLUDE_PATH/inc_comp_multi.cl)

typedef struct lotus8_tmp
{
  u32 ipad[5];
  u32 opad[5];

  u32 dgst[5];
  u32 out[5];

} lotus8_tmp_t;

CONSTANT_VK u32a bin2asc[256] =
{
  0x00003030, 0x00003130, 0x00003230, 0x00003330, 0x00003430, 0x00003530, 0x00003630, 0x00003730,
  0x00003830, 0x00003930, 0x00004130, 0x00004230, 0x00004330, 0x00004430, 0x00004530, 0x00004630,
  0x00003031, 0x00003131, 0x00003231, 0x00003331, 0x00003431, 0x00003531, 0x00003631, 0x00003731,
  0x00003831, 0x00003931, 0x00004131, 0x00004231, 0x00004331, 0x00004431, 0x00004531, 0x00004631,
  0x00003032, 0x00003132, 0x00003232, 0x00003332, 0x00003432, 0x00003532, 0x00003632, 0x00003732,
  0x00003832, 0x00003932, 0x00004132, 0x00004232, 0x00004332, 0x00004432, 0x00004532, 0x00004632,
  0x00003033, 0x00003133, 0x00003233, 0x00003333, 0x00003433, 0x00003533, 0x00003633, 0x00003733,
  0x00003833, 0x00003933, 0x00004133, 0x00004233, 0x00004333, 0x00004433, 0x00004533, 0x00004633,
  0x00003034, 0x00003134, 0x00003234, 0x00003334, 0x00003434, 0x00003534, 0x00003634, 0x00003734,
  0x00003834, 0x00003934, 0x00004134, 0x00004234, 0x00004334, 0x00004434, 0x00004534, 0x00004634,
  0x00003035, 0x00003135, 0x00003235, 0x00003335, 0x00003435, 0x00003535, 0x00003635, 0x00003735,
  0x00003835, 0x00003935, 0x00004135, 0x00004235, 0x00004335, 0x00004435, 0x00004535, 0x00004635,
  0x00003036, 0x00003136, 0x00003236, 0x00003336, 0x00003436, 0x00003536, 0x00003636, 0x00003736,
  0x00003836, 0x00003936, 0x00004136, 0x00004236, 0x00004336, 0x00004436, 0x00004536, 0x00004636,
  0x00003037, 0x00003137, 0x00003237, 0x00003337, 0x00003437, 0x00003537, 0x00003637, 0x00003737,
  0x00003837, 0x00003937, 0x00004137, 0x00004237, 0x00004337, 0x00004437, 0x00004537, 0x00004637,
  0x00003038, 0x00003138, 0x00003238, 0x00003338, 0x00003438, 0x00003538, 0x00003638, 0x00003738,
  0x00003838, 0x00003938, 0x00004138, 0x00004238, 0x00004338, 0x00004438, 0x00004538, 0x00004638,
  0x00003039, 0x00003139, 0x00003239, 0x00003339, 0x00003439, 0x00003539, 0x00003639, 0x00003739,
  0x00003839, 0x00003939, 0x00004139, 0x00004239, 0x00004339, 0x00004439, 0x00004539, 0x00004639,
  0x00003041, 0x00003141, 0x00003241, 0x00003341, 0x00003441, 0x00003541, 0x00003641, 0x00003741,
  0x00003841, 0x00003941, 0x00004141, 0x00004241, 0x00004341, 0x00004441, 0x00004541, 0x00004641,
  0x00003042, 0x00003142, 0x00003242, 0x00003342, 0x00003442, 0x00003542, 0x00003642, 0x00003742,
  0x00003842, 0x00003942, 0x00004142, 0x00004242, 0x00004342, 0x00004442, 0x00004542, 0x00004642,
  0x00003043, 0x00003143, 0x00003243, 0x00003343, 0x00003443, 0x00003543, 0x00003643, 0x00003743,
  0x00003843, 0x00003943, 0x00004143, 0x00004243, 0x00004343, 0x00004443, 0x00004543, 0x00004643,
  0x00003044, 0x00003144, 0x00003244, 0x00003344, 0x00003444, 0x00003544, 0x00003644, 0x00003744,
  0x00003844, 0x00003944, 0x00004144, 0x00004244, 0x00004344, 0x00004444, 0x00004544, 0x00004644,
  0x00003045, 0x00003145, 0x00003245, 0x00003345, 0x00003445, 0x00003545, 0x00003645, 0x00003745,
  0x00003845, 0x00003945, 0x00004145, 0x00004245, 0x00004345, 0x00004445, 0x00004545, 0x00004645,
  0x00003046, 0x00003146, 0x00003246, 0x00003346, 0x00003446, 0x00003546, 0x00003646, 0x00003746,
  0x00003846, 0x00003946, 0x00004146, 0x00004246, 0x00004346, 0x00004446, 0x00004546, 0x00004646,
};

CONSTANT_VK u32a lotus64_table[64] =
{
  '0', '1', '2', '3', '4', '5', '6', '7',
  '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
  'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
  'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
  'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
  'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l',
  'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
  'u', 'v', 'w', 'x', 'y', 'z', '+', '/',
};

CONSTANT_VK u32a lotus_magic_table[256] =
{
  0xbd, 0x56, 0xea, 0xf2, 0xa2, 0xf1, 0xac, 0x2a,
  0xb0, 0x93, 0xd1, 0x9c, 0x1b, 0x33, 0xfd, 0xd0,
  0x30, 0x04, 0xb6, 0xdc, 0x7d, 0xdf, 0x32, 0x4b,
  0xf7, 0xcb, 0x45, 0x9b, 0x31, 0xbb, 0x21, 0x5a,
  0x41, 0x9f, 0xe1, 0xd9, 0x4a, 0x4d, 0x9e, 0xda,
  0xa0, 0x68, 0x2c, 0xc3, 0x27, 0x5f, 0x80, 0x36,
  0x3e, 0xee, 0xfb, 0x95, 0x1a, 0xfe, 0xce, 0xa8,
  0x34, 0xa9, 0x13, 0xf0, 0xa6, 0x3f, 0xd8, 0x0c,
  0x78, 0x24, 0xaf, 0x23, 0x52, 0xc1, 0x67, 0x17,
  0xf5, 0x66, 0x90, 0xe7, 0xe8, 0x07, 0xb8, 0x60,
  0x48, 0xe6, 0x1e, 0x53, 0xf3, 0x92, 0xa4, 0x72,
  0x8c, 0x08, 0x15, 0x6e, 0x86, 0x00, 0x84, 0xfa,
  0xf4, 0x7f, 0x8a, 0x42, 0x19, 0xf6, 0xdb, 0xcd,
  0x14, 0x8d, 0x50, 0x12, 0xba, 0x3c, 0x06, 0x4e,
  0xec, 0xb3, 0x35, 0x11, 0xa1, 0x88, 0x8e, 0x2b,
  0x94, 0x99, 0xb7, 0x71, 0x74, 0xd3, 0xe4, 0xbf,
  0x3a, 0xde, 0x96, 0x0e, 0xbc, 0x0a, 0xed, 0x77,
  0xfc, 0x37, 0x6b, 0x03, 0x79, 0x89, 0x62, 0xc6,
  0xd7, 0xc0, 0xd2, 0x7c, 0x6a, 0x8b, 0x22, 0xa3,
  0x5b, 0x05, 0x5d, 0x02, 0x75, 0xd5, 0x61, 0xe3,
  0x18, 0x8f, 0x55, 0x51, 0xad, 0x1f, 0x0b, 0x5e,
  0x85, 0xe5, 0xc2, 0x57, 0x63, 0xca, 0x3d, 0x6c,
  0xb4, 0xc5, 0xcc, 0x70, 0xb2, 0x91, 0x59, 0x0d,
  0x47, 0x20, 0xc8, 0x4f, 0x58, 0xe0, 0x01, 0xe2,
  0x16, 0x38, 0xc4, 0x6f, 0x3b, 0x0f, 0x65, 0x46,
  0xbe, 0x7e, 0x2d, 0x7b, 0x82, 0xf9, 0x40, 0xb5,
  0x1d, 0x73, 0xf8, 0xeb, 0x26, 0xc7, 0x87, 0x97,
  0x25, 0x54, 0xb1, 0x28, 0xaa, 0x98, 0x9d, 0xa5,
  0x64, 0x6d, 0x7a, 0xd4, 0x10, 0x81, 0x44, 0xef,
  0x49, 0xd6, 0xae, 0x2e, 0xdd, 0x76, 0x5c, 0x2f,
  0xa7, 0x1c, 0xc9, 0x09, 0x69, 0x9a, 0x83, 0xcf,
  0x29, 0x39, 0xb9, 0xe9, 0x4c, 0xff, 0x43, 0xab,
};

#define uint_to_hex_upper8(i) l_bin2asc[(i)]

#define BOX1(S,i) (S)[(i)]

DECLSPEC void lotus_mix (PRIVATE_AS u32 *in, SHM_TYPE const u32 *s_lotus_magic_table)
{
  u8 p = 0;

  for (int i = 0; i < 18; i++)
  {
    u8 s = 48;

    for (int j = 0; j < 12; j++)
    {
      u32 tmp_in  = in[j];
      u32 tmp_out = 0;

      p = (p + s--); p = (u8) (tmp_in >>  0) ^ BOX1 (s_lotus_magic_table, p); tmp_out |= (u32) p <<  0;
      p = (p + s--); p = (u8) (tmp_in >>  8) ^ BOX1 (s_lotus_magic_table, p); tmp_out |= (u32) p <<  8;
      p = (p + s--); p = (u8) (tmp_in >> 16) ^ BOX1 (s_lotus_magic_table, p); tmp_out |= (u32) p << 16;
      p = (p + s--); p = (u8) (tmp_in >> 24) ^ BOX1 (s_lotus_magic_table, p); tmp_out |= (u32) p << 24;

      in[j] = tmp_out;
    }
  }
}

DECLSPEC void lotus_transform_password (PRIVATE_AS const u32 *in, PRIVATE_AS u32 *out, SHM_TYPE const u32 *s_lotus_magic_table)
{
  u8 t = (u8) (out[3] >> 24);

  u8 c;

  #ifdef _unroll
  #pragma unroll
  #endif
  for (int i = 0; i < 4; i++)
  {
    t ^= (u8) (in[i] >>  0); c = BOX1 (s_lotus_magic_table, t); out[i] ^= (u32) c <<  0; t = (u8) (out[i] >>  0);
    t ^= (u8) (in[i] >>  8); c = BOX1 (s_lotus_magic_table, t); out[i] ^= (u32) c <<  8; t = (u8) (out[i] >>  8);
    t ^= (u8) (in[i] >> 16); c = BOX1 (s_lotus_magic_table, t); out[i] ^= (u32) c << 16; t = (u8) (out[i] >> 16);
    t ^= (u8) (in[i] >> 24); c = BOX1 (s_lotus_magic_table, t); out[i] ^= (u32) c << 24; t = (u8) (out[i] >> 24);
  }
}

DECLSPEC void pad (PRIVATE_AS u32 *w, const u32 len)
{
  const u32 val = 16 - len;

  const u32 mask1 = val << 24;

  const u32 mask2 = val << 16
                  | val << 24;

  const u32 mask3 = val <<  8
                  | val << 16
                  | val << 24;

  const u32 mask4 = val <<  0
                  | val <<  8
                  | val << 16
                  | val << 24;

  switch (len)
  {
    case  0:  w[0]  = mask4;
              w[1]  = mask4;
              w[2]  = mask4;
              w[3]  = mask4;
              break;
    case  1:  w[0] |= mask3;
              w[1]  = mask4;
              w[2]  = mask4;
              w[3]  = mask4;
              break;
    case  2:  w[0] |= mask2;
              w[1]  = mask4;
              w[2]  = mask4;
              w[3]  = mask4;
              break;
    case  3:  w[0] |= mask1;
              w[1]  = mask4;
              w[2]  = mask4;
              w[3]  = mask4;
              break;
    case  4:  w[1]  = mask4;
              w[2]  = mask4;
              w[3]  = mask4;
              break;
    case  5:  w[1] |= mask3;
              w[2]  = mask4;
              w[3]  = mask4;
              break;
    case  6:  w[1] |= mask2;
              w[2]  = mask4;
              w[3]  = mask4;
              break;
    case  7:  w[1] |= mask1;
              w[2]  = mask4;
              w[3]  = mask4;
              break;
    case  8:  w[2]  = mask4;
              w[3]  = mask4;
              break;
    case  9:  w[2] |= mask3;
              w[3]  = mask4;
              break;
    case 10:  w[2] |= mask2;
              w[3]  = mask4;
              break;
    case 11:  w[2] |= mask1;
              w[3]  = mask4;
              break;
    case 12:  w[3]  = mask4;
              break;
    case 13:  w[3] |= mask3;
              break;
    case 14:  w[3] |= mask2;
              break;
    case 15:  w[3] |= mask1;
              break;
  }
}

DECLSPEC void mdtransform_norecalc (PRIVATE_AS u32 *state, PRIVATE_AS const u32 *block, SHM_TYPE const u32 *s_lotus_magic_table)
{
  u32 x[12];

  x[ 0] = state[0];
  x[ 1] = state[1];
  x[ 2] = state[2];
  x[ 3] = state[3];
  x[ 4] = block[0];
  x[ 5] = block[1];
  x[ 6] = block[2];
  x[ 7] = block[3];
  x[ 8] = state[0] ^ block[0];
  x[ 9] = state[1] ^ block[1];
  x[10] = state[2] ^ block[2];
  x[11] = state[3] ^ block[3];

  lotus_mix (x, s_lotus_magic_table);

  state[0] = x[0];
  state[1] = x[1];
  state[2] = x[2];
  state[3] = x[3];
}

DECLSPEC void mdtransform (PRIVATE_AS u32 *state, PRIVATE_AS u32 *checksum, PRIVATE_AS const u32 *block, SHM_TYPE const u32 *s_lotus_magic_table)
{
  mdtransform_norecalc (state, block, s_lotus_magic_table);

  lotus_transform_password (block, checksum, s_lotus_magic_table);
}

DECLSPEC void domino_big_md (PRIVATE_AS const u32 *saved_key, const u32 size, PRIVATE_AS u32 *state, SHM_TYPE const u32 *s_lotus_magic_table)
{
  u32 checksum[4];

  checksum[0] = 0;
  checksum[1] = 0;
  checksum[2] = 0;
  checksum[3] = 0;

  u32 block[4];

  block[0] = 0;
  block[1] = 0;
  block[2] = 0;
  block[3] = 0;

  u32 curpos;
  u32 idx;

  for (curpos = 0, idx = 0; curpos + 16 < size; curpos += 16, idx += 4)
  {
    block[0] = saved_key[idx + 0];
    block[1] = saved_key[idx + 1];
    block[2] = saved_key[idx + 2];
    block[3] = saved_key[idx + 3];

    mdtransform (state, checksum, block, s_lotus_magic_table);
  }

  block[0] = saved_key[idx + 0];
  block[1] = saved_key[idx + 1];
  block[2] = saved_key[idx + 2];
  block[3] = saved_key[idx + 3];

  mdtransform (state, checksum, block, s_lotus_magic_table);

  mdtransform_norecalc (state, checksum, s_lotus_magic_table);
}

DECLSPEC void base64_encode (PRIVATE_AS u8 *base64_hash, const u32 len, PRIVATE_AS const u8 *base64_plain)
{
  PRIVATE_AS u8 *out_ptr = (PRIVATE_AS u8 *) base64_hash;
  PRIVATE_AS u8 *in_ptr  = (PRIVATE_AS u8 *) base64_plain;

  u32 i;

  for (i = 0; i < len; i += 3)
  {
    const u8 out_val0 = lotus64_table [                            ((in_ptr[0] >> 2) & 0x3f)];
    const u8 out_val1 = lotus64_table [((in_ptr[0] << 4) & 0x30) | ((in_ptr[1] >> 4) & 0x0f)];
    const u8 out_val2 = lotus64_table [((in_ptr[1] << 2) & 0x3c) | ((in_ptr[2] >> 6) & 0x03)];
    const u8 out_val3 = lotus64_table [                            ((in_ptr[2] >> 0) & 0x3f)];

    out_ptr[0] = out_val0 & 0x7f;
    out_ptr[1] = out_val1 & 0x7f;
    out_ptr[2] = out_val2 & 0x7f;
    out_ptr[3] = out_val3 & 0x7f;

    in_ptr  += 3;
    out_ptr += 4;
  }
}

DECLSPEC void lotus6_base64_encode (PRIVATE_AS u8 *base64_hash, const u32 salt0, const u32 salt1, const u32 a, const u32 b, const u32 c)
{
  u8 tmp[24]; // size 22 (=pw_len) is needed but base64 needs size divisible by 4

  /*
   * Copy $salt.$digest to a tmp buffer
   */

  u8 base64_plain[16];

  base64_plain[ 0] = unpack_v8a_from_v32_S (salt0);
  base64_plain[ 1] = unpack_v8b_from_v32_S (salt0);
  base64_plain[ 2] = unpack_v8c_from_v32_S (salt0);
  base64_plain[ 3] = unpack_v8d_from_v32_S (salt0);
  base64_plain[ 3] -= -4; // dont ask!
  base64_plain[ 4] = unpack_v8a_from_v32_S (salt1);
  base64_plain[ 5] = unpack_v8a_from_v32_S (a);
  base64_plain[ 6] = unpack_v8b_from_v32_S (a);
  base64_plain[ 7] = unpack_v8c_from_v32_S (a);
  base64_plain[ 8] = unpack_v8d_from_v32_S (a);
  base64_plain[ 9] = unpack_v8a_from_v32_S (b);
  base64_plain[10] = unpack_v8b_from_v32_S (b);
  base64_plain[11] = unpack_v8c_from_v32_S (b);
  base64_plain[12] = unpack_v8d_from_v32_S (b);
  base64_plain[13] = unpack_v8a_from_v32_S (c);
  base64_plain[14] = unpack_v8b_from_v32_S (c);
  base64_plain[15] = unpack_v8c_from_v32_S (c);

  /*
   * base64 encode the $salt.$digest string
   */

  base64_encode (tmp + 2, 14, base64_plain);

  base64_hash[ 0] = '(';
  base64_hash[ 1] = 'G';
  base64_hash[ 2] = tmp[ 2];
  base64_hash[ 3] = tmp[ 3];
  base64_hash[ 4] = tmp[ 4];
  base64_hash[ 5] = tmp[ 5];
  base64_hash[ 6] = tmp[ 6];
  base64_hash[ 7] = tmp[ 7];
  base64_hash[ 8] = tmp[ 8];
  base64_hash[ 9] = tmp[ 9];
  base64_hash[10] = tmp[10];
  base64_hash[11] = tmp[11];
  base64_hash[12] = tmp[12];
  base64_hash[13] = tmp[13];
  base64_hash[14] = tmp[14];
  base64_hash[15] = tmp[15];
  base64_hash[16] = tmp[16];
  base64_hash[17] = tmp[17];
  base64_hash[18] = tmp[18];
  base64_hash[19] = tmp[19];
  base64_hash[20] = tmp[20];
  base64_hash[21] = ')';
}

DECLSPEC void hmac_sha1_run_V (PRIVATE_AS u32x *w0, PRIVATE_AS u32x *w1, PRIVATE_AS u32x *w2, PRIVATE_AS u32x *w3, PRIVATE_AS u32x *ipad, PRIVATE_AS u32x *opad, PRIVATE_AS u32x *digest)
{
  digest[0] = ipad[0];
  digest[1] = ipad[1];
  digest[2] = ipad[2];
  digest[3] = ipad[3];
  digest[4] = ipad[4];

  sha1_transform_vector (w0, w1, w2, w3, digest);

  w0[0] = digest[0];
  w0[1] = digest[1];
  w0[2] = digest[2];
  w0[3] = digest[3];
  w1[0] = digest[4];
  w1[1] = 0x80000000;
  w1[2] = 0;
  w1[3] = 0;
  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;
  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = (64 + 20) * 8;

  digest[0] = opad[0];
  digest[1] = opad[1];
  digest[2] = opad[2];
  digest[3] = opad[3];
  digest[4] = opad[4];

  sha1_transform_vector (w0, w1, w2, w3, digest);
}

KERNEL_FQ void m09100_init (KERN_ATTR_TMPS (lotus8_tmp_t))
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * sbox
   */

  #ifdef REAL_SHM

  LOCAL_VK u32 s_lotus_magic_table[256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_lotus_magic_table[i] = lotus_magic_table[i];
  }

  LOCAL_VK u32 l_bin2asc[256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    l_bin2asc[i] = bin2asc[i];
  }

  SYNC_THREADS ();

  #else

  CONSTANT_AS u32a *s_lotus_magic_table = lotus_magic_table;

  CONSTANT_AS u32a *l_bin2asc = bin2asc;

  #endif

  if (gid >= GID_CNT) return;

  /**
   * base
   */

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

  /**
   * pad
   */

  u32 pw_len = pws[gid].pw_len;

  if (pw_len < 16)
  {
    pad (&w[ 0], pw_len & 0xf);
  }
  else if (pw_len < 32)
  {
    pad (&w[ 4], pw_len & 0xf);
  }
  else if (pw_len < 48)
  {
    pad (&w[ 8], pw_len & 0xf);
  }
  else if (pw_len < 64)
  {
    pad (&w[12], pw_len & 0xf);
  }

  /**
   * salt
   */

  u32 salt_buf0[4];

  salt_buf0[0] = salt_bufs[SALT_POS_HOST].salt_buf[ 0];
  salt_buf0[1] = salt_bufs[SALT_POS_HOST].salt_buf[ 1];
  salt_buf0[2] = salt_bufs[SALT_POS_HOST].salt_buf[ 2];
  salt_buf0[3] = salt_bufs[SALT_POS_HOST].salt_buf[ 3];

  const u32 salt0 = salt_buf0[0];
  const u32 salt1 = (salt_buf0[1] & 0xff) | ('(' << 8);

  /**
   * Lotus 6 hash - SEC_pwddigest_V2
   */

  u32 w_tmp[16];

  w_tmp[ 0] = w[ 0];
  w_tmp[ 1] = w[ 1];
  w_tmp[ 2] = w[ 2];
  w_tmp[ 3] = w[ 3];
  w_tmp[ 4] = w[ 4];
  w_tmp[ 5] = w[ 5];
  w_tmp[ 6] = w[ 6];
  w_tmp[ 7] = w[ 7];
  w_tmp[ 8] = w[ 8];
  w_tmp[ 9] = w[ 9];
  w_tmp[10] = w[10];
  w_tmp[11] = w[11];
  w_tmp[12] = w[12];
  w_tmp[13] = w[13];
  w_tmp[14] = w[14];
  w_tmp[15] = w[15];

  u32 state[4];

  state[0] = 0;
  state[1] = 0;
  state[2] = 0;
  state[3] = 0;

  domino_big_md (w_tmp, pw_len, state, s_lotus_magic_table);

  const u32 w0_t = uint_to_hex_upper8 ((state[0] >>  0) & 255) <<  0
                 | uint_to_hex_upper8 ((state[0] >>  8) & 255) << 16;
  const u32 w1_t = uint_to_hex_upper8 ((state[0] >> 16) & 255) <<  0
                 | uint_to_hex_upper8 ((state[0] >> 24) & 255) << 16;
  const u32 w2_t = uint_to_hex_upper8 ((state[1] >>  0) & 255) <<  0
                 | uint_to_hex_upper8 ((state[1] >>  8) & 255) << 16;
  const u32 w3_t = uint_to_hex_upper8 ((state[1] >> 16) & 255) <<  0
                 | uint_to_hex_upper8 ((state[1] >> 24) & 255) << 16;
  const u32 w4_t = uint_to_hex_upper8 ((state[2] >>  0) & 255) <<  0
                 | uint_to_hex_upper8 ((state[2] >>  8) & 255) << 16;
  const u32 w5_t = uint_to_hex_upper8 ((state[2] >> 16) & 255) <<  0
                 | uint_to_hex_upper8 ((state[2] >> 24) & 255) << 16;
  const u32 w6_t = uint_to_hex_upper8 ((state[3] >>  0) & 255) <<  0
                 | uint_to_hex_upper8 ((state[3] >>  8) & 255) << 16;

  const u32 pade = 0x0e0e0e0e;

  w_tmp[ 0] = salt0;
  w_tmp[ 1] = salt1      | w0_t << 16;
  w_tmp[ 2] = w0_t >> 16 | w1_t << 16;
  w_tmp[ 3] = w1_t >> 16 | w2_t << 16;
  w_tmp[ 4] = w2_t >> 16 | w3_t << 16;
  w_tmp[ 5] = w3_t >> 16 | w4_t << 16;
  w_tmp[ 6] = w4_t >> 16 | w5_t << 16;
  w_tmp[ 7] = w5_t >> 16 | w6_t << 16;
  w_tmp[ 8] = w6_t >> 16 | pade << 16;
  w_tmp[ 9] = pade;
  w_tmp[10] = pade;
  w_tmp[11] = pade;
  w_tmp[12] = 0;
  w_tmp[13] = 0;
  w_tmp[14] = 0;
  w_tmp[15] = 0;

  state[0] = 0;
  state[1] = 0;
  state[2] = 0;
  state[3] = 0;

  domino_big_md (w_tmp, 34, state, s_lotus_magic_table);

  u32 a = state[0];
  u32 b = state[1];
  u32 c = state[2];

  /**
   * Base64 encode
   */

  pw_len = 22;

  u8 base64_hash[22];

  lotus6_base64_encode (base64_hash, salt_buf0[0], salt_buf0[1], a, b, c);

  /**
   * PBKDF2 - HMACSHA1 - 1st iteration
   */

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  w0[0] = (base64_hash[ 0] << 24) | (base64_hash[ 1] << 16) | (base64_hash[ 2] << 8) | base64_hash[ 3];
  w0[1] = (base64_hash[ 4] << 24) | (base64_hash[ 5] << 16) | (base64_hash[ 6] << 8) | base64_hash[ 7];
  w0[2] = (base64_hash[ 8] << 24) | (base64_hash[ 9] << 16) | (base64_hash[10] << 8) | base64_hash[11];
  w0[3] = (base64_hash[12] << 24) | (base64_hash[13] << 16) | (base64_hash[14] << 8) | base64_hash[15];
  w1[0] = (base64_hash[16] << 24) | (base64_hash[17] << 16) | (base64_hash[18] << 8) | base64_hash[19];
  w1[1] = (base64_hash[20] << 24) | (base64_hash[21] << 16);
  w1[2] = 0;
  w1[3] = 0;
  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;
  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  sha1_hmac_ctx_t sha1_hmac_ctx;

  sha1_hmac_init_64 (&sha1_hmac_ctx, w0, w1, w2, w3);

  tmps[gid].ipad[0] = sha1_hmac_ctx.ipad.h[0];
  tmps[gid].ipad[1] = sha1_hmac_ctx.ipad.h[1];
  tmps[gid].ipad[2] = sha1_hmac_ctx.ipad.h[2];
  tmps[gid].ipad[3] = sha1_hmac_ctx.ipad.h[3];
  tmps[gid].ipad[4] = sha1_hmac_ctx.ipad.h[4];

  tmps[gid].opad[0] = sha1_hmac_ctx.opad.h[0];
  tmps[gid].opad[1] = sha1_hmac_ctx.opad.h[1];
  tmps[gid].opad[2] = sha1_hmac_ctx.opad.h[2];
  tmps[gid].opad[3] = sha1_hmac_ctx.opad.h[3];
  tmps[gid].opad[4] = sha1_hmac_ctx.opad.h[4];

  sha1_hmac_update_global_swap (&sha1_hmac_ctx, salt_bufs[SALT_POS_HOST].salt_buf, salt_bufs[SALT_POS_HOST].salt_len);

  for (u32 i = 0, j = 1; i < 2; i += 5, j += 1)
  {
    sha1_hmac_ctx_t sha1_hmac_ctx2 = sha1_hmac_ctx;

    w0[0] = j;
    w0[1] = 0;
    w0[2] = 0;
    w0[3] = 0;
    w1[0] = 0;
    w1[1] = 0;
    w1[2] = 0;
    w1[3] = 0;
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;

    sha1_hmac_update_64 (&sha1_hmac_ctx2, w0, w1, w2, w3, 4);

    sha1_hmac_final (&sha1_hmac_ctx2);

    tmps[gid].dgst[i + 0] = sha1_hmac_ctx2.opad.h[0];
    tmps[gid].dgst[i + 1] = sha1_hmac_ctx2.opad.h[1];
    tmps[gid].dgst[i + 2] = sha1_hmac_ctx2.opad.h[2];
    tmps[gid].dgst[i + 3] = sha1_hmac_ctx2.opad.h[3];
    tmps[gid].dgst[i + 4] = sha1_hmac_ctx2.opad.h[4];

    tmps[gid].out[i + 0] = tmps[gid].dgst[i + 0];
    tmps[gid].out[i + 1] = tmps[gid].dgst[i + 1];
    tmps[gid].out[i + 2] = tmps[gid].dgst[i + 2];
    tmps[gid].out[i + 3] = tmps[gid].dgst[i + 3];
    tmps[gid].out[i + 4] = tmps[gid].dgst[i + 4];
  }
}

KERNEL_FQ void m09100_loop (KERN_ATTR_TMPS (lotus8_tmp_t))
{
  const u64 gid = get_global_id (0);

  if ((gid * VECT_SIZE) >= GID_CNT) return;

  u32x ipad[5];
  u32x opad[5];

  ipad[0] = packv (tmps, ipad, gid, 0);
  ipad[1] = packv (tmps, ipad, gid, 1);
  ipad[2] = packv (tmps, ipad, gid, 2);
  ipad[3] = packv (tmps, ipad, gid, 3);
  ipad[4] = packv (tmps, ipad, gid, 4);

  opad[0] = packv (tmps, opad, gid, 0);
  opad[1] = packv (tmps, opad, gid, 1);
  opad[2] = packv (tmps, opad, gid, 2);
  opad[3] = packv (tmps, opad, gid, 3);
  opad[4] = packv (tmps, opad, gid, 4);

  for (u32 i = 0; i < 2; i += 5)
  {
    u32x dgst[5];
    u32x out[5];

    dgst[0] = packv (tmps, dgst, gid, i + 0);
    dgst[1] = packv (tmps, dgst, gid, i + 1);
    dgst[2] = packv (tmps, dgst, gid, i + 2);
    dgst[3] = packv (tmps, dgst, gid, i + 3);
    dgst[4] = packv (tmps, dgst, gid, i + 4);

    out[0] = packv (tmps, out, gid, i + 0);
    out[1] = packv (tmps, out, gid, i + 1);
    out[2] = packv (tmps, out, gid, i + 2);
    out[3] = packv (tmps, out, gid, i + 3);
    out[4] = packv (tmps, out, gid, i + 4);

    for (u32 j = 0; j < LOOP_CNT; j++)
    {
      u32x w0[4];
      u32x w1[4];
      u32x w2[4];
      u32x w3[4];

      w0[0] = dgst[0];
      w0[1] = dgst[1];
      w0[2] = dgst[2];
      w0[3] = dgst[3];
      w1[0] = dgst[4];
      w1[1] = 0x80000000;
      w1[2] = 0;
      w1[3] = 0;
      w2[0] = 0;
      w2[1] = 0;
      w2[2] = 0;
      w2[3] = 0;
      w3[0] = 0;
      w3[1] = 0;
      w3[2] = 0;
      w3[3] = (64 + 20) * 8;

      hmac_sha1_run_V (w0, w1, w2, w3, ipad, opad, dgst);

      out[0] ^= dgst[0];
      out[1] ^= dgst[1];
      out[2] ^= dgst[2];
      out[3] ^= dgst[3];
      out[4] ^= dgst[4];
    }

    unpackv (tmps, dgst, gid, i + 0, dgst[0]);
    unpackv (tmps, dgst, gid, i + 1, dgst[1]);
    unpackv (tmps, dgst, gid, i + 2, dgst[2]);
    unpackv (tmps, dgst, gid, i + 3, dgst[3]);
    unpackv (tmps, dgst, gid, i + 4, dgst[4]);

    unpackv (tmps, out, gid, i + 0, out[0]);
    unpackv (tmps, out, gid, i + 1, out[1]);
    unpackv (tmps, out, gid, i + 2, out[2]);
    unpackv (tmps, out, gid, i + 3, out[3]);
    unpackv (tmps, out, gid, i + 4, out[4]);
  }
}

KERNEL_FQ void m09100_comp (KERN_ATTR_TMPS (lotus8_tmp_t))
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  const u64 lid = get_local_id (0);

  /**
   * digest
   */

  const u32 r0 = tmps[gid].out[DGST_R0];
  const u32 r1 = tmps[gid].out[DGST_R1];
  const u32 r2 = 0;
  const u32 r3 = 0;

  #define il_pos 0

  #ifdef KERNEL_STATIC
  #include COMPARE_M
  #endif
}
