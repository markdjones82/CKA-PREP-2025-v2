#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/run-question.sh <question-number|question-dir|extra-number|extra-dir>" >&2
  echo "Examples:" >&2
  echo "  scripts/run-question.sh 5" >&2
  echo "  scripts/run-question.sh Question-5-HPA" >&2
  echo "  scripts/run-question.sh extra-1" >&2
  echo "  scripts/run-question.sh Extra-Credit-1-Broken-API-Server" >&2
  exit 1
fi

resolve_question_dir() {
  local input="$1"

  # Accept either an absolute path or a name relative to the repo root
  if [[ -d "$BASE_DIR/$input" ]]; then
    echo "$BASE_DIR/$input"
    return 0
  fi

  if [[ -d "$input" ]]; then
    echo "$input"
    return 0
  fi

  # Main question by number
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    find "$BASE_DIR" -maxdepth 1 -type d -name "Question-${input}-*" | head -1
    return 0
  fi

  # Extra credit by shorthand: extra-1, extra 1, ec1, ec-1
  if [[ "$input" =~ ^([Ee][Xx][Tt][Rr][Aa]([[:space:]-]*[Cc][Rr][Ee][Dd][Ii][Tt])?|[Ee][Cc])[[:space:]-]*([0-9]+)$ ]]; then
    find "$BASE_DIR" -maxdepth 1 -type d -name "Extra-Credit-${BASH_REMATCH[3]}-*" | head -1
    return 0
  fi

  return 1
}

QUESTION_DIR=$(resolve_question_dir "$*") || QUESTION_DIR=""

if [[ -z "$QUESTION_DIR" ]]; then
  echo "Error: Could not find question directory for '$*'" >&2
  echo "Available main questions and extra credit labs:" >&2
  find "$BASE_DIR" -maxdepth 1 -type d \( -name "Question-*" -o -name "Extra-Credit-*" \) | sort -V | while read -r d; do
    echo "  $(basename "$d")" >&2
  done
  exit 1
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

echo
echo "==> Question"
cat "$QUESTION_TEXT"

echo
if [[ -f "$SOLUTION" ]]; then
  echo "Hints: see $SOLUTION"
fi

echo
echo "==> Running lab setup for $QUESTION_DIR"
"$SETUP"
