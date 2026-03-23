Contributing to Zetacoin Core
=============================

Zetacoin Core is an open source project and contributions are welcome.
This document explains the practical process and guidelines for contributing.

Getting Started
---------------

Before you start contributing, familiarize yourself with the Zetacoin Core build
system and tests. Refer to the documentation in the repository on how to build
Zetacoin Core and how to run the unit tests and functional tests.

  - [Build instructions](doc/build-freebsd.md) (FreeBSD, or see `doc/build-*.md` for other platforms)
  - [Developer notes](doc/developer-notes.md)

Communication Channels
----------------------

Discussion about codebase improvements happens in GitHub issues and pull
requests at <https://github.com/tuaris/zetacoin>.

Contributor Workflow
--------------------

To contribute a patch:

  1. Fork the repository
  1. Create a topic branch
  1. Commit patches
  1. Push changes to your fork
  1. Create a pull request

The project coding conventions in the [developer notes](doc/developer-notes.md)
must be followed.

### Committing Patches

In general, [commits should be atomic](https://en.wikipedia.org/wiki/Atomic_commit#Atomic_commit_convention)
and diffs should be easy to read. Do not mix formatting fixes or code moves
with actual code changes.

Make sure each individual commit builds successfully on its own without
warnings, errors, regressions, or test failures.

Commit messages should consist of a short subject line (50 chars max), a blank
line, and detailed explanatory text as separate paragraph(s). Commit messages
should never contain any `@` mentions.

### Pull Request Titles

The title of the pull request should be prefixed by the component or area that
the pull request affects. Valid areas:

  - `consensus` for changes to consensus critical code
  - `doc` for changes to the documentation
  - `net` or `p2p` for changes to the peer-to-peer network code
  - `rpc`, `rest` or `zmq` for changes to the RPC, REST or ZMQ APIs
  - `wallet` for changes to the wallet code
  - `build` for changes to CMake
  - `test` or `qa` for changes to tests
  - `refactor` for structural changes that do not change behavior

### Consensus Changes

**Important:** Zetacoin has never had a hard fork and the goal is to keep it
that way. Any changes that affect consensus rules require extremely careful
review and must be fully compatible with the existing chain.

Upstream
--------

This codebase is derived from [Bitcoin Core](https://github.com/bitcoin/bitcoin)
(v30.2). When selectively merging upstream improvements, ensure they are
consensus-compatible with Zetacoin's rules.

Copyright
---------

By contributing to this repository, you agree to license your work under the
MIT license unless specified otherwise at the top of the file itself. Any work
contributed where you are not the original author must contain its license
header with the original author(s) and source.
