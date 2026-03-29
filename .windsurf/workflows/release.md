---
description: Cut a new Zetacoin Core release (version bump, RC tags, final tag, port update)
---

# Zetacoin Core Release Workflow

## 1. Prepare the release on master

- Bump version in `CMakeLists.txt`:
  - `CLIENT_VERSION_MAJOR`, `CLIENT_VERSION_MINOR`, `CLIENT_VERSION_BUILD`
  - Set `CLIENT_VERSION_IS_RELEASE` to `"true"`
- Update `doc/man/*.1` man pages if needed
- Commit and push to master

## 2. Create a Release Candidate tag

```bash
git tag -a v{VERSION}-rc1 -m "Zetacoin Core {VERSION} Release Candidate 1"
git push origin v{VERSION}-rc1
git push pacyworld v{VERSION}-rc1
```

This triggers the GitHub Actions release workflow which builds:
- **Linux x86_64**: tar.gz with Qt GUI (native build)
- **macOS ARM64**: tar.gz with Qt GUI (native build)  
- **Windows x86_64**: zip + NSIS installer (cross-compiled from Linux via mingw-w64 + depends/)

## 3. Validate the RC build

Wait for GitHub Actions to complete, then verify:

- [ ] All 3 platform archives are on the GitHub release page
- [ ] Windows NSIS installer (`*-win64-setup.exe`) is present
- [ ] Windows binaries launch correctly (test `zetacoin-qt.exe`)
- [ ] No "pre-release test build" warning in the GUI
- [ ] Branding is correct (Zetacoin, ZET units, zetacoin: URIs, Zatoshi User Agent)
- [ ] `zetacoind --version` shows correct version and "Zatoshi" User Agent

If issues are found:
- Fix on master
- Delete the RC tag and release:
  ```bash
  git tag -d v{VERSION}-rc1
  git push origin :refs/tags/v{VERSION}-rc1
  # Delete the GitHub release via API or web UI
  ```
- Increment RC number and re-tag: `v{VERSION}-rc2`, etc.

## 4. Create the final release tag

Only after the RC is validated:

```bash
git tag -a v{VERSION} -m "Zetacoin Core {VERSION}"
git push origin v{VERSION}
git push pacyworld v{VERSION}
```

Wait for the release build to complete and verify the installer is on the release page.

## 5. Clean up RC tags and releases

```bash
# Delete RC tags
git tag -d v{VERSION}-rc1
git push origin :refs/tags/v{VERSION}-rc1

# Delete RC GitHub releases via API
curl -X DELETE "https://api.github.com/repos/tuaris/zetacoin/releases/{RC_RELEASE_ID}" \
  -H "Authorization: token $(grep password ~/.netrc | awk 'NR==1{print $2}')"
```

## 6. Update FreeBSD port distinfo

**IMPORTANT: Only do this after the final tag is stable and the release build is verified.**

```bash
cd /path/to/deluxe/ports/tree/net-p2p/zetacoin
make makesum BATCH=yes
```

This fetches the tarball (`tuaris-zetacoin-v{VERSION}_GH0.tar.gz`) and regenerates `distinfo`.

The port uses `USE_GITHUB=yes` with `GH_ACCOUNT=tuaris`, so the distfile naming is handled automatically by the ports framework.

## 7. Create port PR and test

```bash
git checkout -b zetacoin-{VERSION}
git add net-p2p/zetacoin/distinfo
git commit -m "net-p2p/zetacoin: update to {VERSION}"
git push origin zetacoin-{VERSION}
```

Create PR on git.morante.net, then trigger poudriere testport:
- Test `net-p2p/zetacoin-daemon` on 150amd64
- Test `net-p2p/zetacoin-utils` on 150amd64
- Test `net-p2p/zetacoin` (Qt GUI) on 150amd64

## 8. Merge port PR and sync extra_ports

After poudriere passes:
1. Merge the port PR to deluxe master
2. Sync extra_ports repo:
   ```bash
   cd /path/to/extra_ports
   for port in net-p2p/zetacoin net-p2p/zetacoin-daemon net-p2p/zetacoin-utils; do
     rm -rf "$port"
     cp -R "/path/to/deluxe/$port" "$port"
   done
   git add -A && git commit -m "net-p2p/zetacoin*: update to {VERSION}" && git push
   ```
3. Trigger extra-ports overlay build on Jenkins

## Key Files

- **Version**: `CMakeLists.txt` (CLIENT_VERSION_*, CLIENT_VERSION_IS_RELEASE)
- **CI workflow**: `.github/workflows/release.yml` (builds on `v*` tags)
- **CI tests**: `.github/workflows/ci.yml` (runs on pushes/PRs)
- **Port master**: deluxe tree `net-p2p/zetacoin/Makefile`
- **Port slaves**: `net-p2p/zetacoin-daemon/Makefile`, `net-p2p/zetacoin-utils/Makefile`
- **Extra ports**: `extra_ports/net-p2p/zetacoin*/`

## Remotes

- **GitHub**: `origin` → https://github.com/tuaris/zetacoin
- **Pacyworld**: `pacyworld` → https://pacyworld.dev/zetacoin/zetacoin
- Tags must be pushed to both remotes
