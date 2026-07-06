#!/usr/bin/env bash
#
# check-placeholders.sh
#
# 扫描文档中是否残留未替换的 {{XXX}} 占位符。
#
# 使用场景：
#   - 在**使用本模板的项目**中运行：复制模板后忘记替换的占位符会被发现
#     （主要用途，使用本仓库时请把 docs/ 下的模板全部填完再提交）
#   - 在本模板仓库中运行：预期会有大量命中（docs/ 下每份都是模板），
#     这是正常现象，不代表 bug；只关注 allowlist 之外的误漏即可
#
# 用法：
#   bash scripts/check-placeholders.sh                         # 使用模板后的项目：扫全仓
#   bash scripts/check-placeholders.sh docs/features           # 使用模板后的项目：扫指定目录
#   bash scripts/check-placeholders.sh --mode template          # 本模板仓库：跳过模板源文件，检查 examples 等非模板文档
#
# 退出码：
#   0 = 无残留
#   1 = 存在残留
#
# Allowlist：
#   默认跳过以下文件（它们本身就是模板定义，保留 {{XXX}} 是正确的）：
#     - *-template.md
#     - docs/adr/ADR-000-template.md
#     - docs/style-guide.md（示例中引用了占位符格式）
#     - docs/README.md（示例中引用了占位符格式）
#     - CHANGELOG.md（含版本块占位）

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

TARGET="."
MODE="consumer"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --mode=*)
      MODE="${1#--mode=}"
      shift
      ;;
    *)
      TARGET="$1"
      shift
      ;;
  esac
done

if [ "$MODE" != "consumer" ] && [ "$MODE" != "template" ]; then
  echo "ERROR unknown mode: ${MODE}. Use consumer or template."
  exit 1
fi

# 允许残留占位符的文件（正则匹配相对路径）
ALLOWLIST_RE='(-template\.md$|ADR-000-template\.md$|docs/style-guide\.md$|docs/README\.md$|CHANGELOG\.md$|scripts/check-placeholders\.sh$)'

if [ "$MODE" = "template" ]; then
  ALLOWLIST_RE="(${ALLOWLIST_RE}|^AGENTS\.md$|^CONTRIBUTING\.md$|^README\.md$|^SECURITY\.md$|^template-mapping\.md$|^docs/.*\.md$)"
fi

echo "==> 扫描 ${TARGET} 中残留的 {{XXX}} 占位符"
if [ "$MODE" = "template" ]; then
  echo "    Mode: template，模板源文件已跳过，仍检查 examples 等非模板文档。"
else
  echo "    Mode: consumer，允许残留的模板文件已跳过。"
fi
echo

found=0
while IFS= read -r -d '' file; do
  rel="${file#./}"
  if [[ "$rel" =~ $ALLOWLIST_RE ]]; then
    continue
  fi
  # 匹配 SCREAMING_SNAKE_CASE 的占位符
  if grep -nE '\{\{[A-Z][A-Z0-9_]*\}\}' "$file" > /tmp/check-placeholders-hits.$$; then
    while IFS= read -r hit; do
      echo "  ${rel}: ${hit}"
      found=$((found + 1))
    done < /tmp/check-placeholders-hits.$$
  fi
  rm -f /tmp/check-placeholders-hits.$$
done < <(find "$TARGET" -type f -name "*.md" -print0)

echo
if [ "$found" -eq 0 ]; then
  echo "✅ 无残留占位符。"
  exit 0
else
  echo "❌ 共发现 ${found} 处未替换的占位符。"
  echo "   如果你正在用本模板开发项目，请先替换后再提交。"
  echo "   如果这是本模板仓库自检，请使用 --mode template。"
  exit 1
fi
