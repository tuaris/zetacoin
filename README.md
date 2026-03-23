Zetacoin Core integration/staging tree
======================================

https://www.getzetacoin.com

What is Zetacoin?
-----------------

Zetacoin is a peer-to-peer digital currency that enables instant payments to
anyone, anywhere in the world. Zetacoin uses peer-to-peer technology to operate
with no central authority: managing transactions and issuing money are carried
out collectively by the network.

Zetacoin Core is the reference implementation that connects to the Zetacoin
network to download and fully validate blocks and transactions. It also
includes a wallet and graphical user interface, which can be optionally built.

### Key Parameters

| Parameter | Value |
|---|---|
| Algorithm | SHA-256d |
| Block time | 30 seconds |
| Block reward | 1 ZET (perpetual tail emission) |
| Halving interval | 80,640 blocks |
| Max supply | 200,000,000 ZET |
| Default port | 17333 |
| RPC port | 17335 |
| Address prefix | Z (base58 prefix 80) |

### History

Zetacoin was launched on August 3, 2013. The chain has never had a hard fork.
This codebase is a modernization of the original Zetacoin Core (v0.13.2.1),
rebased onto Bitcoin Core 30.2 while preserving all original consensus rules.

Further information is available in the [doc folder](/doc).

License
-------

Zetacoin Core is released under the terms of the MIT license. See [COPYING](COPYING) for more
information or see https://opensource.org/license/MIT.

Development Process
-------------------

The `master` branch is regularly built (see `doc/build-*.md` for instructions)
and tested, but it is not guaranteed to be completely stable.
[Tags](https://github.com/tuaris/zetacoin/tags) are created regularly to
indicate new official, stable release versions of Zetacoin Core.

The contribution workflow is described in [CONTRIBUTING.md](CONTRIBUTING.md)
and useful hints for developers can be found in [doc/developer-notes.md](doc/developer-notes.md).

Building
--------

See platform-specific build instructions:

- [FreeBSD](doc/build-freebsd.md)
- [Linux](doc/build-unix.md)
- [macOS](doc/build-osx.md)
- [Windows](doc/build-windows.md)

Testing
-------

### Automated Testing

Developers are strongly encouraged to write [unit tests](src/test/README.md) for new code, and to
submit new unit tests for old code. Unit tests can be compiled and run
(assuming they weren't disabled during the generation of the build system) with: `ctest`. Further details on running
and extending unit tests can be found in [/src/test/README.md](/src/test/README.md).

There are also [regression and integration tests](/test), written
in Python.
These tests can be run (if the [test dependencies](/test) are installed) with: `build/test/functional/test_runner.py`
(assuming `build` is your build directory).

### Manual Quality Assurance (QA) Testing

Changes should be tested by somebody other than the developer who wrote the
code. This is especially important for large or high-risk changes. It is useful
to add a test plan to the pull request description if testing the changes is
not straightforward.

Upstream
--------

This codebase is derived from [Bitcoin Core](https://github.com/bitcoin/bitcoin)
(v30.2). Upstream improvements may be selectively merged when appropriate and
consensus-compatible.
