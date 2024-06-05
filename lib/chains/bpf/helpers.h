// Copyright 2022 DeChainers
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/*Protocol types according to the standard*/
#define IPPROTO_TCP 6
#define IPPROTO_UDP 17
#define IPPROTO_ICMP 1
#define ETH_P_IP 0x0800

#define ECHO_REQUEST 8
#define ECHO_REPLY  0

/*Ethernet Header => https://github.com/torvalds/linux/blob/master/include/uapi/linux/if_ether.h (slightly different)*/
struct eth_hdr {
    __be64 dst: 48;
    __be64 src: 48;
    __be16 proto;
} __attribute__((packed));

/*Ip Header => https://github.com/torvalds/linux/blob/master/include/uapi/linux/ip.h */
struct iphdr {
#if defined(__LITTLE_ENDIAN_BITFIELD)
    __u8    ihl:4,
        version:4;
#elif defined (__BIG_ENDIAN_BITFIELD)
    __u8    version:4,
        ihl:4;
#else
#error  "Please fix <asm/byteorder.h>"
#endif
    __u8 tos;
    __be16 tot_len;
    __be16 id;
    __be16 frag_off;
    __u8 ttl;
    __u8 protocol;
    __sum16 check;
    __be32 saddr;
    __be32 daddr;
    /*The options start here. */
} __attribute__((packed));

/*TCP Header => https://github.com/torvalds/linux/blob/master/include/uapi/linux/tcp.h */
struct tcphdr {
    __be16 source;
    __be16 dest;
    __be32 seq;
    __be32 ack_seq;
#if defined(__LITTLE_ENDIAN_BITFIELD)
    __u16   res1:4,
        doff:4,
        fin:1,
        syn:1,
        rst:1,
        psh:1,
        ack:1,
        urg:1,
        ece:1,
        cwr:1;
#elif defined(__BIG_ENDIAN_BITFIELD)
    __u16   doff:4,
        res1:4,
        cwr:1,
        ece:1,
        urg:1,
        ack:1,
        psh:1,
        rst:1,
        syn:1,
        fin:1;
#else
#error  "Adjust your <asm/byteorder.h> defines"
#endif
    __be16 window;
    __sum16 check;
    __be16 urg_ptr;
} __attribute__((packed));

/*UDP Header https://github.com/torvalds/linux/blob/master/include/uapi/linux/udp.h */
struct udphdr {
    __be16 source;
    __be16 dest;
    __be16 len;
    __sum16 check;
} __attribute__((packed));

/*ICMP Header https://github.com/torvalds/linux/blob/master/include/uapi/linux/icmp.h*/
struct icmphdr {
    __u8 type;
    __u8 code;
    __sum16 checksum;
    union {
        struct {
            __be16 id;
            __be16 sequence;
        } echo;
        __be32 gateway;
        struct {
            __be16 __unused;
            __be16 mtu;
        } frag;
        __u8 reserved[4];
    } un;
} __attribute__((packed));

// Structure containing packet's metadata
struct pkt_metadata {
  u32 ifindex;           // The interface on which the packet was received.
  u32 length;            // The length of the packet
  u8 ingress;            // The program type ingress/egress
  u8 xdp;                // The program mode xdp/tc
  u16 program_id;        // The id of the calling program
  u16 plugin_id;         // The id of the plugin
  u16 probe_id;          // The id of the probe
} __attribute__((packed));

// Key for the LPM_TRIE maps, implementing the Longest Prefix Match on IP addresses
struct lpm_key {
  u32 netmask_len;       // Length of the netmask
  u32 ip;                // Ip address in network byte order
} __attribute__((packed));

// Struct for logging packets
#define LOG_STRUCT(_level, _msg, ...)                 \
  struct __attribute__((__packed__)) LogMsg {         \
    struct pkt_metadata metadata;                     \
    uint64_t level;                                   \
    uint64_t args[4];                                 \
    char message[sizeof(_msg)];                       \
  } msg_struct = {*md, _level, {__VA_ARGS__}, _msg};

// Table for pushing custom events to userspace via perf buffer
struct log_table_t {
  int key;
  u32 leaf;
  int (*perf_submit) (void *, void *, u32);
  int (*perf_submit_skb) (void *, u32, void *, u32);
  u32 data[0];
};

// Declaring macros for perf buffers (even for perf output)
#define BPF_PERF(ATTR, NAME) __attribute__((section("maps/" ATTR))) struct log_table_t NAME
#define BPF_PERF_SHARED(ATTR, NAME) BPF_PERF(ATTR, NAME); __attribute__((section("maps/export"))) struct log_table_t __##NAME

// Declaring extern log table and control plane table
// previously declared in startup.sh
BPF_PERF("extern", log_buffer);
BPF_PERF("extern", control_plane);

// ########################### NB ########################### 
// * 'dp_log' function helper is added from ebpf.py
// * 'REDIRECT(<interface>) helper is added from ebpf.py

// Helper to send packet to controller
static __always_inline
int pkt_to_controller(struct CTXTYPE *ctx, struct pkt_metadata *md) {
  return control_plane.perf_submit_skb(ctx, md->length, md, sizeof(struct pkt_metadata));
}

// Helper to compute Unix Epoch time
static __always_inline
u64 get_time_epoch(struct CTXTYPE *ctx) {
#ifdef XDP
  return EPOCH_BASE + bpf_ktime_get_ns();
#else
  return ctx->tstamp ? ctx->tstamp : EPOCH_BASE + bpf_ktime_get_ns();
#endif
}

// Helper to get the n° of the 1st bit set to 1
static __always_inline 
int first_bit_set_pos(u64 x)
{
  int bits = 64, num = 64 - 1;
  u64 zero = 0;

  if (x == 0) {
    return 0;
  }
	if (!(x & (~zero << 32))) {
		num -= 32;
		x <<= 32;
	}
	if (!(x & (~zero << (bits-16)))) {
		num -= 16;
		x <<= 16;
	}
	if (!(x & (~zero << (bits-8)))) {
		num -= 8;
		x <<= 8;
	}
	if (!(x & (~zero << (bits-4)))) {
		num -= 4;
		x <<= 4;
	}
	if (!(x & (~zero << (bits-2)))) {
		num -= 2;
		x <<= 2;
	}
	if (!(x & (~zero << (bits-1))))
		num -= 1;
	return 64 - num - 1;
}