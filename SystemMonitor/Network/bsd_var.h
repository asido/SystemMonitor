//
//  bsd_var.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#ifndef ActivityMonitor___bsd_structs_h
#define ActivityMonitor___bsd_structs_h

/*
 * We re-define a bunch of varibles and structures which exist in UNIX headers,
 * but are not available on iOS. The returned data types by system calls match
 * these definitions.
 */

// <netinet/tcp_fsm.h>
#define TCPS_CLOSED         0   // Closed.
#define TCPS_LISTEN         1   // Listening for connection.
#define TCPS_SYN_SENT       2   // Active, have sent syn.
#define TCPS_SYN_RECEIVED   3   // Have send and received syn.
// States < TCPS_ESTABLISHED are those where connections not established.
#define TCPS_ESTABLISHED    4   // Established.
#define TCPS_CLOSE_WAIT     5   // rcvd fin, waiting for cose.

char *tcpstates[] = {
    "CLOSED",
    "LISTEN",
    "SYN_SENT",
    "SYN_RCVD",
    "ESTABLISHED",
    "CLOSE_WAIT",
    "FIN_WAIT_1",
    "CLOSING",
    "LAST_ACK",
    "FIN_WAIT_2",
    "TIME_WAIT"
};


// <sys/socketvar.h>
#define XSO_SOCKET  0x001
#define XSO_RCVBUF  0x002
#define XSO_SNDBUF  0x004
#define XSO_STATS   0x008
#define XSO_INPCB   0x010
#define XSO_TCPCB   0x020

#define ALL_XGN_KIND_INP    (XSO_SOCKET | XSO_RCVBUF | XSO_SNDBUF | XSO_STATS | XSO_INPCB)
#define ALL_XGN_KIND_TCP    (ALL_XGN_KIND_INP | XSO_TCPCB)

#ifdef __arm64__
typedef SInt32   inp_gen_t;
#else
typedef u_quad_t inp_gen_t;
#endif
typedef u_quad_t so_gen_t;

struct xsocket_n {
    UInt32      xso_len;    // Length of this structure.
    UInt32      xso_kind;   // XSO_SOCKET
    UInt32      xso_so;     // Makes a convenient handle.
    SInt16      so_type;
    UInt32      so_options;
    SInt16      so_linger;
    SInt16      so_state;
    UInt64      so_pcb;     // Another convenient handle.
    SInt32      xso_protocol;
    SInt32      xso_family;
    SInt16      so_qlen;
    SInt16      so_incqlen;
    SInt16      so_qlimit;
    SInt16      so_timeo;
    UInt16      so_error;
    pid_t       so_pgid;
    UInt32      so_oobmark;
    uid_t       so_uid;     // XXX
};

struct xsockbuf_n {
    UInt32      xsb_len;    // Length of this structure.
    UInt32      xsb_kind;   // XSO_RCVBUF or XSO_SNDBUF.
    UInt32      sb_cc;
    UInt32      sb_hiwat;
    UInt32      sb_mbcnt;
    UInt32      sb_mbmax;
    SInt32      sb_lowat;
    SInt16      sb_flags;
    SInt16      sb_timeo;
};

struct data_stats {
    UInt64      rxpackets;
    UInt64      rxbytes;
    UInt64      txpackets;
    UInt64      txbytes;
};

struct xsockstat_n {
    UInt32      xst_len;    // Length of this structure.
    UInt32      xst_kind;   // XSO_STATS
#define SO_TC_STATS_MAX 4
    struct data_stats   xst_tc_stats[SO_TC_STATS_MAX];
};

// <netinet/in_pcb.h>
struct xinpgen {
    UInt32   xig_len;    // Length of this structure.
    UInt32       xig_count;  // Number of PCBs at this time.
    inp_gen_t   xig_gen;    // Generation count at this time.
    so_gen_t    xig_sogen;  // Socket generation count at this time.
};

struct in_addr_4in6 {
    UInt32       ia46_pad32[3];
    struct in_addr  ia46_addr4;
};

struct xinpcb_n {
    UInt32   xi_len;     // Length of this structure.
    UInt32   xi_kind;    // XSO_INPCB
    UInt64   xi_inpp;
    UInt16     inp_fport;  // Foreign port.
    UInt16     inp_lport;  // Local port.
    UInt64   inp_ppcb;   // Pointer to per-protocol PCB.
    inp_gen_t   inp_gencnt; // Generation count of this instance.
    SInt32         inp_flags;  // Generic IP/datagram flags.
    UInt32   inp_flow;
    UInt8      inp_vflag;
    UInt8      inp_ip_ttl; // Time to live.
    UInt8      inp_ip_p;   // Protocol.
    union {
        struct  in_addr_4in6    inp46_foreign;
        struct  in6_addr        inp6_foreign;
    } inp_dependfaddr;
    union {
        struct  in_addr_4in6    inp46_local;
        struct  in6_addr        inp6_local;
    } inp_dependladdr;
    struct {
        UInt8  inp4_ip_tos; // Type of service.
    } inp_depend4;
    struct {
        UInt8    inp6_hlim;
        SInt32         inp6_cksum;
        UInt16     inp6_ifindex;
        SInt16       inp6_hops;
    } inp_depend6;
    UInt32   inp_flowhash;
};
// These defines are for use with the inpcb.
#define INP_IPV4        0x1
#define INP_IPV6        0x2
#define inp_faddr       inp_dependfaddr.inp46_foreign.ia46_addr4
#define inp_laddr       inp_dependladdr.inp46_local.ia46_addr4
#define inp_route       inp_dependroute.inp4_route
#define inp_ip_tos      inp_depend4.inp4_ip_tos
#define inp_options     inp_depend4.inp4_options
#define inp_moptions    inp_depend4.inp4_moptions
#define in6p_faddr      inp_dependfaddr.inp6_foreign
#define in6p_laddr      inp_dependladdr_inp6_local
#define in6p_route      inp_dependroute.inp6_route
#define in6p_ip6_hlim   inp_depend6.inp6_hlim
#define in6p_hops       inp_depend6.inp6_hops   // Default hop limit.
#define in6p_ip6_nxt    inp_ip_p
#define in6p_flowinfo   inp_flow
#define in6p_vflag      inp_vflag
#define in6p_options    inp_depend6.inp6_options
#define in6p_outputopts inp_depend6.inp6_outputopts
#define in6p_moptions   inp_depend6.inp6_moptions
#define in6p_icmp6filt  inp_depend6.inp6_icmp6filt
#define in6p_cksum      inp_depend6.inp6_cksum
#define in6p_ifindex    inp_depend6.inp6_ifindex
#define in6p_flags      inp_flags       // For KAME src sync over BSD*'s
#define in6p_socket     inp_socket      // For KAME src sync over BSD*'s
#define in6p_lport      inp_lport       // For KAME src sync over BSD*'s
#define in6p_fport      inp_fport       // For KAME src sync over BSD*'s
#define in6p_ppcb       inp_ppcb        // For KAME src sync over BSD*'s
#define in6p_state      inp_state       // For KAME src sync over BSD*'s
#define in6p_wantcnt    inp_wantcnt     // For KAME src sync over BSD*'s
#define in6p_last_outif inp_last_outif  // For KAME src sync over BSD*'s


// <netinet/tcp_var.h>
#define TF_NEEDSYN  0x00400
#define TF_NEEDFIN  0x00800

struct xtcpcb_n {
    UInt32       xt_len;
    UInt32       xt_kind;                    // XSO_TCPCB
    
    UInt64       t_segq;
    SInt32             t_dupacks;                  // Consecutive dup acks recd.
    
#define TCPT_NTIMERS_EXT 4                  // <netinet/tcp_timer.h>
    SInt32             t_timer[TCPT_NTIMERS_EXT];  // TCP timers.
#undef TCPT_NTIMERS_EXT
    
    SInt32             t_state;                    // State of this connection.
    UInt32           t_flags;
    
    SInt32             t_force;
    
    tcp_seq         snd_una;                    // Send unacknowledged.
    tcp_seq         snd_max;                    // Highest sequence number sent used to recognize retransmits.
    
    tcp_seq         snd_next;                   // Send next.
    tcp_seq         snd_up;                     // Send urgent pointer.
    
    tcp_seq         snd_wl1;                    // Window update seg seq number.
    tcp_seq         snd_wl2;                    // Window update seg ack number.
    tcp_seq         iss;                        // Initial send sequence number.
    tcp_seq         irs;                        // Initial receive sequence number.
    
    tcp_seq         rcv_nxt;                    // Receive next.
    tcp_seq         rcv_adv;                    // Advertised window.
    UInt32       rcv_wnd;                    // Receive window.
    tcp_seq         rcv_up;                     // Receive urgent pointer.
    
    UInt32       snd_wnd;                    // Send window.
    UInt32       snd_cwnd;                   // Congestion-controlled window.
    UInt32       snd_ssthresh;               // snd_cwnd size threshold for slow start exponential to linear switch.
    
    UInt32           t_maxopd;                   // mss plus option.
    
    UInt32       t_rcvtime;                  // Time at which a packet was received.
    UInt32       t_starttime;                // Time connection was established.
    SInt32             t_rtttime;                  // Round trip time.
    tcp_seq         t_rtseq;                    // Sequence number being timed.
    
    SInt32             t_rxtcur;                   // Current retransmit value (ticks).
    UInt32           t_maxseg;                   // Maximum segment size.
    SInt32             t_srtt;                     // Smoothed round-trip time.
    SInt32             t_rttvar;                   // Variance in round-trip time.
    
    SInt32             t_rxtshift;                 // log(2) of rexmt exp. backoff.
    UInt32           t_rttmin;                   // Minimum rtt allowed.
    UInt32       t_rttupdated;               // Number of times rtt sampled.
    UInt32       max_sndwnd;                 // Largest window peer has offered.
    
    SInt32             t_softerror;                // Possible error not yet reported.
    // Out-of-band data
    SInt8            t_oobflags;                 // Have some.
    SInt8            t_iobc;                     // Input character.
    UInt8          snd_scale;                  // Window scaling for send window.
    UInt8          rcv_scale;                  // Window scaling for recv window.
    UInt8          request_r_scale;            // Pending window scaling.
    UInt8          requested_s_scale;
    UInt32       ts_recent;                  // Timestamp echo data.
    
    UInt32       ts_recent_age;              // When last updated.
    tcp_seq         last_ack_sent;
    // RFC 1644 variables.
    tcp_cc          cc_send;                    // Send connection count.
    tcp_cc          cc_recv;                    // Receive connection count.
    tcp_seq         snd_recover;                // For use in fast recovery.
    // Experimental.
    UInt32       snd_cwnd_prev;              // cwnd prior to retransmit.
    UInt32       snd_ssthresh_prev;          // ssthresh prior to rentransmit.
    UInt32       t_badrxtwin;                // Window for retransmit recovery.
};

struct xgen_n {
    UInt32   xgn_len;    // Length of this structure.
    UInt32   xgn_kind;   // Number of PCBs at this time.
};

#endif
