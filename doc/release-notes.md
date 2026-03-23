v0.14.0 Release Notes
=====================

Zetacoin Core version v0.14.0 is the first release of the modernized
Zetacoin Core, rebased onto Bitcoin Core 30.2.

Please report bugs using the issue tracker at GitHub:

  <https://github.com/tuaris/zetacoin/issues>

Upgrading from Zetacoin Core v0.13.2.1
=======================================

Shut down the old `zetacoind`. Wait until it has completely shut down, then
replace the binary with the new version. The data directory (`.zetacoin`) is
compatible — no migration is required. The blockchain does not need to be
re-downloaded.

Compatibility
==============

Zetacoin Core is supported and tested on FreeBSD 15.0+, Linux (kernel 3.17+),
macOS 13+, and Windows 10+.

Notable changes
===============

### Modernized codebase

The entire codebase has been rebased from Bitcoin Core 0.13.2 onto Bitcoin
Core 30.2. This brings 10 years of improvements including:

- CMake build system (replaces autotools)
- C++20
- Descriptor wallets with SQLite backend
- Compact block filters (BIP 157/158)
- I2P and CJDNS network support
- AssumeUTXO framework
- Improved peer-to-peer protocol
- Modern RPC interface

### Consensus preserved

All original Zetacoin consensus rules are preserved:

- SHA-256d proof of work
- 30-second block target
- 80-block averaging difficulty adjustment (asymmetric: +1% / -20%)
- 1000 ZET initial block reward, halving every 80,640 blocks
- 1 ZET minimum block reward (perpetual tail emission)
- 200,000,000 ZET maximum money supply
- BIP65 (CHECKLOCKTIMEVERIFY) activation at height 8,570,810
- No hard fork

### Functional testnet and regtest

Zetacoin testnet and regtest networks are now functional with proper
30-second block times and Zetacoin consensus parameters (these were
non-functional in the original v0.13.2.1 release).

### Binary names

- `zetacoind` — daemon
- `zetacoin-cli` — RPC client
- `zetacoin-tx` — transaction utility
- `zetacoin-wallet` — wallet tool
- `zetacoin-util` — general utility

Credits
=======

Zetacoin Core is derived from Bitcoin Core. Thanks to the Bitcoin Core
developers for the upstream codebase.
