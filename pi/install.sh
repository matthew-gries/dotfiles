#!/usr/bin/env bash
set -euo pipefail

pi_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while IFS= read -r spec || [[ -n "$spec" ]]; do
	[[ -z "$spec" || "$spec" =~ ^[[:space:]]*# ]] && continue
	pi install "$spec"
done <"$pi_dir/packages.txt"

pi install "$pi_dir"
