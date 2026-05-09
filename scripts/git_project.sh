#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

exec git --git-dir="$repo_root/.git_local" --work-tree="$repo_root" "$@"

