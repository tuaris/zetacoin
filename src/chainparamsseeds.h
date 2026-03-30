#ifndef BITCOIN_CHAINPARAMSSEEDS_H
#define BITCOIN_CHAINPARAMSSEEDS_H
/**
 * List of fixed seed nodes for the Zetacoin network
 *
 * Each line contains a BIP155 serialized (networkID, addr, port) tuple.
 * networkID 0x01 = IPv4, addrlen 0x04, then 4 addr bytes, then 2 port bytes (big-endian)
 */
static const uint8_t chainparams_seed_main[] = {
    // 63.247.147.166:17333
    0x01,0x04,0x3f,0xf7,0x93,0xa6,0x43,0xb5,
};
static const uint8_t chainparams_seed_test[] = {
};
static const uint8_t chainparams_seed_testnet4[] = {
};
static const uint8_t chainparams_seed_signet[] = {
};
#endif // BITCOIN_CHAINPARAMSSEEDS_H
