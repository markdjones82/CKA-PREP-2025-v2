#!/bin/bash
# ============================================================
# cleanup-question.sh -- Run cleanup for a CKA practice question
#
# Usage:
#   scripts/cleanup-question.sh 5
#   scripts/cleanup-question.sh "Question-5-HPA"
#   scripts/cleanup-question.sh all
# ============================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

resolve_question_dir() {
  local input="$1"
  if [[ -d "$BASE_DIR/$input" ]]; then
    echo "$BASE_DIR/$input"
    return 0
  fi
  if [[ -d "$input" ]]; then
    echo "$input"
    return 0
  fi
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    local match
    match=$(find "$BASE_DIR" -maxdepth 1 -type d -name "Question-${input}-*" | head -1)
    if [[ -n "$match" ]]; then
      echo "$match"
      return 0
    fi
  fi
  if [[ "$input" =~ ^([Ee][Xx][Tt][Rr][Aa]([[:space:]-]*[Cc][Rr][Ee][Dd][Ii][Tt])?|[Ee][Cc])[[:space:]-]*([0-9]+)$ ]]; then
    local extra_match
    extra_match=$(find "$BASE_DIR" -maxdepth 1 -type d -name "Extra-Credit-${BASH_REMATCH[3]}-*" | head -1)
    if [[ -n "$extra_match" ]]; then
      echo "$extra_match"
      return 0
    fi
  fi
  echo ""
  return 1
}

list_all_labs() {
  find "$BASE_DIR" -maxdepth 1 -type d \( -name "Question-*" -o -name "Extra-Credit-*" \) | sort -V
}

run_cleanup() {
  local question_dir="$1"
  local dir_name
  dir_name="$(basename "$question_dir")"
  local cleanup_script="$question_dir/cleanup.bash"

  echo ""
  echo "======================================================"
  echo " Cleaning up: $dir_name"
  echo "======================================================"

  if [[ ! -f "$cleanup_script" ]]; then
    echo "SKIP: no cleanup.bash found for $dir_name"
    return 2
  fi

  chmod +x "$cleanup_script"
  bash "$cleanup_script"
  return $?
}

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/cleanup-question.sh <question-number|question-dir|extra-number|extra-dir|all|all-extra>"
  echo ""
  echo "Examples:"
  echo "  scripts/cleanup-question.sh 5"
  echo "  scripts/cleanup-question.sh Question-5-HPA"
  echo "  scripts/cleanup-question.sh extra-1"
  echo "  scripts/cleanup-question.sh all"
  echo "  scripts/cleanup-question.sh all-extra"
  exit 1
fi

INPUT="$*"

if [[ "$INPUT" == "all" || "$INPUT" == "all-extra" ]]; then
  if [[ "$INPUT" == "all-extra" ]]; then
    echo "Cleaning up all extra credit labs..."
    LABS=$(find "$BASE_DIR" -maxdepth 1 -type d -name "Extra-Credit-*" | sort -V)
  else
    echo "Cleaning up all questions and extra credit labs..."
    LABS=$(list_all_labs)
  fi

  while read -r QUESTION_DIR; do
    [[ -n "$QUESTION_DIR" ]] && run_cleanup "$QUESTION_DIR" || true
  done <<< "$LABS"
  echo ""
  echo "All cleanups complete."
else
  QUESTION_DIR=$(resolve_question_dir "$INPUT")
  if [[ -z "$QUESTION_DIR" ]]; then
    echo "Error: Could not find question directory for '$INPUT'" >&2
    exit 1
  fi
  run_cleanup "$QUESTION_DIR"
fi
