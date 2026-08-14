#!/usr/bin/env bash
# Checks archive.mariadb.org for newer patch releases within each formula's
# existing major.minor line and rewrites url/sha256 in place. Never jumps a
# formula to a different major.minor line (e.g. @11.4 never becomes 11.8) —
# that stays a manual edit, since bumping LTS lines is a deliberate choice.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
formula_dir="$repo_root/Formula"
index="$(curl -sL https://archive.mariadb.org/)"
changed=0

for formula_file in "$formula_dir"/mariadbdump*.rb; do
  current_version="$(grep -m1 -oE 'mariadb-[0-9]+\.[0-9]+\.[0-9]+/source/mariadb-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' "$formula_file" \
    | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  if [ -z "$current_version" ]; then
    echo "skip $formula_file: could not parse current version"
    continue
  fi
  minor_track="${current_version%.*}"

  latest_version="$(echo "$index" \
    | grep -oE "mariadb-${minor_track//./\\.}\.[0-9]+" \
    | sed 's/mariadb-//' \
    | sort -t. -k1,1n -k2,2n -k3,3n \
    | tail -1)"

  if [ -z "$latest_version" ]; then
    echo "skip $formula_file: no releases found for $minor_track line"
    continue
  fi

  if [ "$latest_version" = "$current_version" ]; then
    echo "up to date: $formula_file ($current_version)"
    continue
  fi

  sha256="$(curl -sL "https://archive.mariadb.org/mariadb-$latest_version/source/sha256sums.txt" | awk '{print $1}')"
  if [ -z "$sha256" ]; then
    echo "skip $formula_file: could not fetch sha256 for $latest_version"
    continue
  fi

  sed -i.bak \
    -e "s|archive.mariadb.org/mariadb-${current_version}/|archive.mariadb.org/mariadb-${latest_version}/|" \
    -e "s|mariadb-${current_version}\.tar\.gz|mariadb-${latest_version}.tar.gz|" \
    -e "s|sha256 \"[0-9a-f]\{64\}\"|sha256 \"${sha256}\"|" \
    "$formula_file"
  rm -f "$formula_file.bak"

  echo "bumped $(basename "$formula_file"): $current_version -> $latest_version"
  changed=1
done

if [ "$changed" -eq 0 ]; then
  echo "No formulae needed a version bump."
fi
