# homebrew-mariadbdump

Homebrew tap providing a standalone `mariadb-dump` (mysqldump-compatible)
client, built from MariaDB source with `-DWITHOUT_SERVER=ON` so only the
dump client binary is installed — no `mariadbd` server daemon, no
`my.cnf`, no background services.

## Install

```sh
brew tap ezintz/mariadbdump
brew install mariadbdump          # latest (currently 11.8.x)
brew install mariadbdump@11.4     # pinned to the 11.4 LTS line
brew install mariadbdump@10.11    # pinned to the 10.11 LTS line
```

## Verifying a bottle's provenance

Every bottle built by `.github/workflows/bottles.yml` is signed with a
[GitHub Artifact Attestation](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds)
(SLSA-style build provenance over Sigstore) as part of the same CI run that
built it. Before trusting a downloaded `.bottle.tar.gz`, verify it was built
by this repo's workflow from a known commit:

```sh
gh attestation verify mariadbdump@11.4--11.4.12.arm64_sequoia.bottle.tar.gz \
  --repo ezintz/homebrew-mariadbdump
```

This confirms the artifact's SHA-256 digest matches a signed provenance
statement published by `ezintz/homebrew-mariadbdump`'s Actions workflow —
i.e. the bytes weren't substituted or built somewhere else. Homebrew
separately verifies the bottle's `sha256` recorded in the formula's
`bottle do` block on every `brew install`, so tampering after that hash was
written would also be caught.

Actions used in the workflow are pinned to commit SHAs (not mutable tags)
and Dependabot opens PRs to bump them — review the diff (new SHA, changed
version comment) before merging, same as any dependency update.

## Adding a new pinned version

1. Find the source tarball and checksum:
   `https://archive.mariadb.org/mariadb-<version>/source/sha256sums.txt`
2. Copy `Formula/mariadbdump@X.Y.rb` for an existing minor line, bump the
   `url`/`sha256`, and adjust the class name (`MariadbdumpAT<XY>`, dots
   removed) and `desc`.
3. `brew install --build-from-source ./Formula/mariadbdump@X.Y.rb` to test
   locally before committing.
