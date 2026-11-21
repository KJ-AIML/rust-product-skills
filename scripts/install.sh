#!/usr/bin/env bash
set -euo pipefail

TARGET="agents"
WORKSPACE_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --workspace)
      WORKSPACE_PATH="${2:-}"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--target antigravity|claude|agents|workspace] [--workspace /path/to/repo]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_SRC="${REPO_ROOT}/skills"

case "${TARGET}" in
  antigravity) DEST_ROOT="${HOME}/.gemini/config/skills" ;;
  claude)      DEST_ROOT="${HOME}/.claude/skills" ;;
  agents)      DEST_ROOT="${HOME}/.agents/skills" ;;
  workspace)
    if [[ -z "${WORKSPACE_PATH}" ]]; then
      echo "Provide --workspace /path/to/repo when using --target workspace." >&2
      exit 1
    fi
    DEST_ROOT="${WORKSPACE_PATH}/.agents/skills"
    ;;
  *)
    echo "Unsupported target: ${TARGET}" >&2
    exit 1
    ;;
esac

mkdir -p "${DEST_ROOT}"

for dir in "${SKILLS_SRC}"/*/; do
  name="$(basename "${dir}")"
  ln -sfn "${dir%/}" "${DEST_ROOT}/${name}"
  echo "Linked ${name} -> ${DEST_ROOT}/${name}"
done
