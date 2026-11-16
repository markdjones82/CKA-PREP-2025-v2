#!/bin/bash
# setup_question.sh — one-shot setup of any CKA-PREP-2025-v2 lab question.
#
# Killercoda one-liner (paste into the playground terminal):
#   curl -fsSL https://raw.githubusercontent.com/markdjones82/CKA-PREP-2025-v2/custom-main/scripts/setup_question.sh | bash -s -- 15
#
# From inside a local clone:
#   ./scripts/setup_question.sh 15
#
# After solving, validate with:
#   scripts/validate-question.sh 15   (from ~/CKA-PREP-2025-v2)
set -euo pipefail

REPO_URL="https://github.com/markdjones82/CKA-PREP-2025-v2.git"
REPO_DIR="${CKA_PREP_DIR:-$HOME/CKA-PREP-2025-v2}"

Q="${1:-}"
if [[ -z "$Q" ]]; then
  echo "Usage: scripts/setup_question.sh <question-number|Question-dir>" >&2
  echo "Example: scripts/setup_question.sh 15    # Question-15-Etcd-Fix" >&2
  exit 1
fi

# If this script is running from inside a repo checkout, use it directly.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""
if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/scripts/run-question.sh" ]]; then
  REPO_DIR="$SCRIPT_DIR"
elif [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/run-question.sh" ]]; then
  REPO_DIR="$(dirname "$SCRIPT_DIR")"
elif [[ -f "$PWD/scripts/run-question.sh" ]]; then
  REPO_DIR="$PWD"
fi

# Otherwise clone the repo (or update an existing clone).
if [[ ! -f "$REPO_DIR/scripts/run-question.sh" ]]; then
  if [[ -d "$REPO_DIR/.git" ]]; then
    echo "==> Updating existing clone at $REPO_DIR"
    git -C "$REPO_DIR" pull --ff-only || true
  else
    echo "==> Cloning $REPO_URL -> $REPO_DIR"
    git clone --depth 1 "$REPO_URL" "$REPO_DIR"
  fi
fi

cd "$REPO_DIR"
echo "==> Setting up question: $Q"
exec scripts/run-question.sh "$Q"
