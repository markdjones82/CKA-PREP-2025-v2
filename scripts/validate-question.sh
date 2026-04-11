#!/bin/bash
# ============================================================
# validate-question.sh - Run validation for a CKA practice question
#
# Usage:
#   scripts/validate-question.sh "Question-5 HPA"
#   scripts/validate-question.sh 5
#   scripts/validate-question.sh all
# ============================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# -- colour helpers -------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No colour

# -- resolve question directory from number or name -----------
resolve_question_dir() {
  local input="$1"

  # If it's already a valid directory path, use it
  if [[ -d "$BASE_DIR/$input" ]]; then
    echo "$BASE_DIR/$input"
    return 0
  fi

  # If input is a number, find the matching Question-N directory (hyphenated)
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    local match
    match=$(find "$BASE_DIR" -maxdepth 1 -type d -name "Question-${input}-*" | head -1)
    if [[ -n "$match" ]]; then
      echo "$match"
      return 0
    fi
  fi

  # Extra credit by shorthand: extra-1, extra 1, ec1, ec-1
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

# -- run validation for a single question ---------------------
run_validation() {
  local question_dir="$1"
  local dir_name
  dir_name="$(basename "$question_dir")"
  local validate_script="$question_dir/validate.bash"

  if [[ ! -f "$validate_script" ]]; then
    echo -e "${YELLOW}SKIP: ${dir_name} - no validate.bash found${NC}"
    return 2
  fi

  echo ""
  echo -e "${CYAN}==========================================================${NC}"
  echo -e "${CYAN} Validating: ${dir_name}${NC}"
  echo -e "${CYAN}==========================================================${NC}"

  chmod +x "$validate_script"
  bash "$validate_script"
  return $?
}

# -- main -----------------------------------------------------
if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/validate-question.sh <question-number|question-dir|extra-number|extra-dir|all|all-extra>"
  echo ""
  echo "Examples:"
  echo "  scripts/validate-question.sh 5                  # validate Question 5 (HPA)"
  echo "  scripts/validate-question.sh \"Question-5 HPA\"   # same, using directory name"
  echo "  scripts/validate-question.sh extra-1            # validate Extra Credit 1"
  echo "  scripts/validate-question.sh all                # validate all questions and extra credit labs"
  echo "  scripts/validate-question.sh all-extra          # validate only extra credit labs"
  exit 1
fi

INPUT="$*"
TOTAL_QUESTIONS=0
PASSED_QUESTIONS=0
FAILED_QUESTIONS=0
SKIPPED_QUESTIONS=0

if [[ "$INPUT" == "all" || "$INPUT" == "all-extra" ]]; then
  echo -e "${CYAN}+==========================================================+${NC}"
  if [[ "$INPUT" == "all-extra" ]]; then
    echo -e "${CYAN}|      CKA Practice Extra Credit - Full Validation       |${NC}"
  else
    echo -e "${CYAN}|   CKA Practice Questions + Extra Credit Validation    |${NC}"
  fi
  echo -e "${CYAN}+==========================================================+${NC}"

  if [[ "$INPUT" == "all-extra" ]]; then
    LABS=$(find "$BASE_DIR" -maxdepth 1 -type d -name "Extra-Credit-*" | sort -V)
  else
    LABS=$(list_all_labs)
  fi

  while read -r QUESTION_DIR; do
    [[ -z "$QUESTION_DIR" ]] && continue

    TOTAL_QUESTIONS=$((TOTAL_QUESTIONS + 1))
    run_validation "$QUESTION_DIR"
    rc=$?
    if [[ $rc -eq 0 ]]; then
      PASSED_QUESTIONS=$((PASSED_QUESTIONS + 1))
    elif [[ $rc -eq 2 ]]; then
      SKIPPED_QUESTIONS=$((SKIPPED_QUESTIONS + 1))
    else
      FAILED_QUESTIONS=$((FAILED_QUESTIONS + 1))
    fi
  done <<< "$LABS"

  echo ""
  echo -e "${CYAN}==========================================================${NC}"
  echo -e "${CYAN} Summary${NC}"
  echo -e "${CYAN}==========================================================${NC}"
  echo -e "  ${GREEN}Passed:  $PASSED_QUESTIONS${NC}"
  echo -e "  ${RED}Failed:  $FAILED_QUESTIONS${NC}"
  echo -e "  ${YELLOW}Skipped: $SKIPPED_QUESTIONS${NC}"
  echo -e "  Total:   $TOTAL_QUESTIONS"
  echo ""

  if [[ $FAILED_QUESTIONS -gt 0 ]]; then
    exit 1
  fi
else
  QUESTION_DIR=$(resolve_question_dir "$INPUT")
  if [[ -z "$QUESTION_DIR" ]]; then
    echo -e "${RED}Error: Could not find question directory for '$INPUT'${NC}" >&2
    echo "Available questions and extra credit labs:"
    list_all_labs | while read -r d; do
      echo "  $(basename "$d")"
    done
    exit 1
  fi

  run_validation "$QUESTION_DIR"
  exit $?
fi
