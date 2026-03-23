Zetacoin Core
=============

Setup
---------------------
Zetacoin Core connects to the Zetacoin peer-to-peer network to download and fully validate blocks and transactions. The full blockchain requires approximately 10 GB of disk space (with compression). Synchronization from genesis takes several hours due to the 18+ million blocks at 30-second intervals.

Running
---------------------
The following are some helpful notes on how to run Zetacoin Core on your native platform.

### Unix / FreeBSD

Unpack the files into a directory and run:

- `bin/zetacoin-qt` (GUI) or
- `bin/zetacoind` (headless)
- `bin/zetacoin` (wrapper command)

The `zetacoin` command supports subcommands like `zetacoin gui`, `zetacoin node`, and `zetacoin rpc` exposing different functionality. Subcommands can be listed with `zetacoin help`.

### Windows

Unpack the files into a directory, and then run zetacoin-qt.exe.

### macOS

Drag Zetacoin Core to your applications folder, and then run Zetacoin Core.

### Need Help?

* File an issue on [GitHub](https://github.com/tuaris/zetacoin/issues).

Building
---------------------
The following are developer notes on how to build Zetacoin Core on your native platform. They are not complete guides, but include notes on the necessary libraries, compile flags, etc.

- [Dependencies](dependencies.md)
- [FreeBSD Build Notes](build-freebsd.md)
- [Unix Build Notes](build-unix.md)
- [macOS Build Notes](build-osx.md)
- [Windows Build Notes](build-windows-msvc.md)
- [OpenBSD Build Notes](build-openbsd.md)
- [NetBSD Build Notes](build-netbsd.md)

Development
---------------------
The Zetacoin repo's [root README](/README.md) contains relevant information on the development process and automated testing.

- [Developer Notes](developer-notes.md)
- [Productivity Notes](productivity.md)
- [Release Process](release-process.md)
- [JSON-RPC Interface](JSON-RPC-interface.md)
- [Unauthenticated REST Interface](REST-interface.md)
- [BIPS](bips.md)
- [Dnsseed Policy](dnsseed-policy.md)
- [Benchmarking](benchmarking.md)
- [Internal Design Docs](design/)

### Miscellaneous
- [Assets Attribution](assets-attribution.md)
- [zetacoin.conf Configuration File](zetacoin-conf.md)
- [CJDNS Support](cjdns.md)
- [Files](files.md)
- [Fuzz-testing](fuzzing.md)
- [I2P Support](i2p.md)
- [Init Scripts (systemd/upstart/openrc)](init.md)
- [Managing Wallets](managing-wallets.md)
- [P2P bad ports definition and list](p2p-bad-ports.md)
- [PSBT support](psbt.md)
- [Reduce Memory](reduce-memory.md)
- [Reduce Traffic](reduce-traffic.md)
- [Tor Support](tor.md)
- [Transaction Relay Policy](policy/README.md)
- [ZMQ](zmq.md)

License
---------------------
Distributed under the [MIT software license](/COPYING).
