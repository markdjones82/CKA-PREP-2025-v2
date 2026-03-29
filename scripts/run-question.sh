#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/run-question.sh <question-number|question-dir>" >&2
  echo "Examples:" >&2
  echo "  scripts/run-question.sh 5" >&2
  echo "  scripts/run-question.sh Question-5-HPA" >&2
  exit 1
fi

# If input is just a number, find the matching Question-N- directory
if [[ "$1" =~ ^[0-9]+$ ]]; then
  QUESTION_DIR=$(find "$BASE_DIR" -maxdepth 1 -type d -name "Question-$1-*" | head -1)
  if [[ -z "$QUESTION_DIR" ]]; then
    echo "Error: Question directory for Question-$1 not found" >&2
    exit 1
  fi
else
  # Accept either an absolute path or a name relative to the repo root
  if [[ -d "$BASE_DIR/$*" ]]; then
    QUESTION_DIR="$BASE_DIR/$*"
  else
    QUESTION_DIR="$*"
  fi
fi

if [[ ! -d "$QUESTION_DIR" ]]; then
  echo "Question directory '$QUESTION_DIR' not found" >&2
  exit 1
fi

SETUP="$QUESTION_DIR/LabSetUp.bash"
QUESTION_TEXT="$QUESTION_DIR/Questions.bash"
SOLUTION="$QUESTION_DIR/SolutionNotes.bash"

[[ -f "$SETUP" ]] || { echo "Missing $SETUP" >&2; exit 1; }
[[ -f "$QUESTION_TEXT" ]] || { echo "Missing $QUESTION_TEXT" >&2; exit 1; }

chmod +x "$SETUP"

echo "==> Running lab setup for $QUESTION_DIR"
"$SETUP"

echo
echo "==> Question"
cat "$QUESTION_TEXT"

echo
if [[ -f "$SOLUTION" ]]; then
  echo "Hints: see $SOLUTION"
fi
