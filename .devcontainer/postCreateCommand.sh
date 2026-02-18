#!/usr/bin/env bash
set -euo pipefail

# One-command lab bring-up: starts services + initializes both databases
bash tools/lab-up.sh

echo "✅ Lab environment ready."
