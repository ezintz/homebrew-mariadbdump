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

## Adding a new pinned version

1. Find the source tarball and checksum:
   `https://archive.mariadb.org/mariadb-<version>/source/sha256sums.txt`
2. Copy `Formula/mariadbdump@X.Y.rb` for an existing minor line, bump the
   `url`/`sha256`, and adjust the class name (`MariadbdumpAT<XY>`, dots
   removed) and `desc`.
3. `brew install --build-from-source ./Formula/mariadbdump@X.Y.rb` to test
   locally before committing.
