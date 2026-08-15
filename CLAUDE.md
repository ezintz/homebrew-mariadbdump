# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Homebrew tap (`ezintz/homebrew-mariadbdump`) that packages a standalone
`mariadb-dump` (mysqldump-compatible) client built from MariaDB source with
`-DWITHOUT_SERVER=ON`. Only the dump client is installed — no `mariadbd`
server daemon, no `my.cnf`, no background services. There is no application
code here, only Homebrew formulae and the CI/automation that builds and
maintains them.

## Repo layout

- `Formula/mariadbdump.rb` — unversioned formula, tracks the latest release (currently 11.8.x).
- `Formula/mariadbdump@11.4.rb`, `@10.11.rb` — pinned to specific LTS lines, `keg_only :versioned_formula`.
- `.github/workflows/bottles.yml` — builds bottles (arm64_sequoia, x86_64_linux) on push to `main` touching `Formula/**.rb`, or via manual dispatch. No x86_64 macOS bottle: GitHub retired Intel-based macOS hosted runners. Relies on `Homebrew/actions/setup-homebrew` auto-tapping this repo (name matches `owner/homebrew-*`) rather than checking it out manually — that action wipes and replaces `$GITHUB_WORKSPACE` itself, so don't reintroduce a separate `actions/checkout` step in these jobs without accounting for that. Merges bottle hashes into the formula, commits `[ci]`, pushes, publishes bottle tarballs to the rolling `bottles` GitHub Release, then generates SLSA3 build provenance.
- `.github/workflows/bump-versions.yml` — weekly cron (Mon 06:00 UTC) + manual dispatch; runs the bump script and opens a PR if any formula has a newer patch available.
- `.github/scripts/bump-mariadb-versions.sh` — checks `archive.mariadb.org` for newer patch releases *within each formula's existing major.minor line* and rewrites `url`/`sha256` in place. Never moves a formula across LTS lines.
- `.github/dependabot.yml` — keeps pinned Action SHAs current.

## Working with formulae

All formulae share the same `install`/`test` shape:

```ruby
def install
  args = std_cmake_args + %w[
    -DWITHOUT_SERVER=ON
    -DWITH_UNIT_TESTS=OFF
    -DCOMPILATION_COMMENT=Homebrew-Standalone
  ]
  system "cmake", "-S", ".", "-B", "build", *args
  system "cmake", "--build", "build", "--target", "mariadb-dump"
  bin.install "build/client/mariadb-dump"
  bin.install_symlink "mariadb-dump" => "mysqldump"
end

test do
  assert_match version.to_s, shell_output("#{bin}/mariadb-dump --version")
end
```

Keep this shape consistent across formulae when editing one.

### Adding a new pinned LTS version

1. Find the source tarball and checksum at
   `https://archive.mariadb.org/mariadb-<version>/source/sha256sums.txt`.
2. Copy `Formula/mariadbdump@X.Y.rb` from an existing minor line, bump
   `url`/`sha256`, and adjust the class name (`MariadbdumpAT<XY>`, dots
   removed) and `desc`.
3. Test locally before committing: `brew install --build-from-source ./Formula/mariadbdump@X.Y.rb`.

### Patch-version bumps

Handled automatically by `bump-versions.yml`/`bump-mariadb-versions.sh` —
don't hand-edit patch versions unless testing the script itself. Moving a
formula to a different LTS line (e.g. `@11.4` → tracking 11.8) is always a
deliberate manual edit, never automated.

## CI/provenance conventions

- Actions in workflows are pinned to commit SHAs, not mutable tags (Dependabot bumps them via PR — review the diff, not just merge).
- Exception: `provenance` job in `bottles.yml` pins `slsa-framework/slsa-github-generator` to a floating `vX.Y.Z` tag intentionally — the generator verifies its own tag internally and a SHA pin breaks it.
- Every bottle is attested with GitHub Artifact Attestation (SLSA-style provenance over Sigstore) as part of the same CI run that built it; verify with `gh attestation verify <bottle> --repo ezintz/homebrew-mariadbdump`.

## Local testing

There's no separate test suite — the formula's own `test do` block
(`mariadb-dump --version`) is the test, run via `brew install
--build-from-source` / `brew test`.
