#!/usr/bin/env bash
#
# check-docs-consistency.sh
#
# 三索引同步检查：确保 docs/ 下每个 .md 文件至少在以下两处被提及：
#   1. README.md（根目录推荐目录或可选扩展表）
#   2. template-mapping.md（归入位置清单）
#
# 也检查 docs/README.md § 2 是否覆盖所有一级目录。
#
# 退出码：
#   0 = 一致
#   1 = 存在缺失引用
#
# 用法：
#   bash scripts/check-docs-consistency.sh

set -uo pipefail
shopt -s nullglob

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

ROOT_README="README.md"
DOCS_README="docs/README.md"
MAPPING="template-mapping.md"

missing=0

echo "==> 检查 docs/ 下的所有 .md 是否在 README.md 和 template-mapping.md 中被提及"

doc_files=()
while IFS= read -r -d '' file; do
  doc_files+=("${file#./docs/}")
done < <(find ./docs -type f -name "*.md" -print0)

count_basename() {
  local target_base="$1"
  local count=0
  local item
  for item in "${doc_files[@]}"; do
    if [ "$(basename "$item")" = "$target_base" ]; then
      count=$((count + 1))
    fi
  done
  printf '%s' "$count"
}

has_doc_reference() {
  local source_file="$1"
  local rel="$2"
  local base="$3"
  local count="$4"

  if grep -Fq "docs/${rel}" "$source_file" 2>/dev/null; then
    return 0
  fi
  if grep -Fq "${rel}" "$source_file" 2>/dev/null; then
    return 0
  fi

  # Filename-only matches are accepted only when the basename is unique under docs/.
  # Otherwise files such as docs/README.md and docs/features/README.md can mask
  # missing directory-specific references.
  if [ "$count" -eq 1 ] && grep -Fq "$base" "$source_file" 2>/dev/null; then
    return 0
  fi

  return 1
}

# 收集 docs/ 下所有 .md 的相对路径（从 docs/ 起算）
for rel in "${doc_files[@]}"; do
  # 跳过模板本身
  case "$rel" in
    *-template.md|ADR-000-template.md) continue ;;
  esac

  base="$(basename "$rel")"
  base_count="$(count_basename "$base")"

  # 在 README.md 中检索文件名或相对路径
  if ! has_doc_reference "$ROOT_README" "$rel" "$base" "$base_count"; then
    echo "  [miss] docs/${rel}  未在 ${ROOT_README} 中出现"
    missing=$((missing + 1))
  fi

  # 在 template-mapping.md 中检索
  if ! has_doc_reference "$MAPPING" "$rel" "$base" "$base_count"; then
    echo "  [miss] docs/${rel}  未在 ${MAPPING} 中出现"
    missing=$((missing + 1))
  fi
done

echo
echo "==> 检查 docs/README.md § 2 是否提到所有一级子目录"
for dir in docs/*/; do
  name="$(basename "$dir")"
  if ! grep -qE "\`?${name}/\`?" "$DOCS_README" 2>/dev/null; then
    echo "  [miss] ${name}/  未在 ${DOCS_README} § 2 目录说明中出现"
    missing=$((missing + 1))
  fi
done

echo
if [ "$missing" -eq 0 ]; then
  echo "OK 三索引一致，无缺失引用。"
  exit 0
else
  echo "FAIL 共发现 ${missing} 处缺失。请同步更新对应索引。"
  exit 1
fi
