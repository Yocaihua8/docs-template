#!/usr/bin/env bash

set -u
set -o pipefail
set -f

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -P "$SCRIPT_DIR/.." && pwd)"
SCAFFOLD_ROOT="$REPO_ROOT/scaffold"

TARGET=""
PROJECT_NAME=""
OWNER=""
CURRENT_DATE=""
DRY_RUN=0
REQUIRE_COMPLETE=0
LIST_PROFILES=0
LIST_PACKS=0
SHOW_HELP=0
PROFILE_ARGS=()
INCLUDE_ARGS=()
EXCLUDE_ARGS=()
SET_ARGS=()
TMP_ROOT=""
CREATED_TARGET=0
CREATED_FILES=()

die() {
  local code="$1"
  shift
  printf 'ERROR[%s] %s\n' "$code" "$*" >&2
  exit "$code"
}

cleanup() {
  if [ -n "$TMP_ROOT" ] && [ -d "$TMP_ROOT" ]; then
    rm -rf "$TMP_ROOT"
  fi
}
trap cleanup EXIT HUP INT TERM

usage() {
  cat <<'EOF'
Usage:
  bash scripts/init-docs.sh \
    --target <directory> --project-name <name> --owner <owner> \
    --profile <personal|commercial|open-source>[,<profile>...] \
    [--include-pack <pack>[,<pack>...]] [--exclude-pack <pack>[,<pack>...]] \
    [--date YYYY-MM-DD] [--set KEY=VALUE] [--dry-run] [--require-complete]

Discovery:
  bash scripts/init-docs.sh --list-profiles
  bash scripts/init-docs.sh --list-packs

Safety:
  The initializer never overwrites a different existing file and has no force mode.
EOF
}

need_value() {
  if [ "$#" -lt 2 ] || [ -z "$2" ]; then
    die 2 "Option requires a value: $1"
  fi
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      need_value "$@"; TARGET="$2"; shift 2 ;;
    --target=*) TARGET="${1#*=}"; shift ;;
    --project-name)
      need_value "$@"; PROJECT_NAME="$2"; shift 2 ;;
    --project-name=*) PROJECT_NAME="${1#*=}"; shift ;;
    --owner)
      need_value "$@"; OWNER="$2"; shift 2 ;;
    --owner=*) OWNER="${1#*=}"; shift ;;
    --date)
      need_value "$@"; CURRENT_DATE="$2"; shift 2 ;;
    --date=*) CURRENT_DATE="${1#*=}"; shift ;;
    --profile)
      need_value "$@"; PROFILE_ARGS[${#PROFILE_ARGS[@]}]="$2"; shift 2 ;;
    --profile=*) PROFILE_ARGS[${#PROFILE_ARGS[@]}]="${1#*=}"; shift ;;
    --include-pack)
      need_value "$@"; INCLUDE_ARGS[${#INCLUDE_ARGS[@]}]="$2"; shift 2 ;;
    --include-pack=*) INCLUDE_ARGS[${#INCLUDE_ARGS[@]}]="${1#*=}"; shift ;;
    --exclude-pack)
      need_value "$@"; EXCLUDE_ARGS[${#EXCLUDE_ARGS[@]}]="$2"; shift 2 ;;
    --exclude-pack=*) EXCLUDE_ARGS[${#EXCLUDE_ARGS[@]}]="${1#*=}"; shift ;;
    --set)
      need_value "$@"; SET_ARGS[${#SET_ARGS[@]}]="$2"; shift 2 ;;
    --set=*) SET_ARGS[${#SET_ARGS[@]}]="${1#*=}"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --require-complete) REQUIRE_COMPLETE=1; shift ;;
    --list-profiles) LIST_PROFILES=1; shift ;;
    --list-packs) LIST_PACKS=1; shift ;;
    --help|-h) SHOW_HELP=1; shift ;;
    *) die 2 "Unknown option: $1" ;;
  esac
done

PROFILES_TSV="$SCAFFOLD_ROOT/profiles.tsv"
PACKS_TSV="$SCAFFOLD_ROOT/packs.tsv"
FILES_TSV="$SCAFFOLD_ROOT/files.tsv"
PLACEHOLDERS_TSV="$SCAFFOLD_ROOT/placeholders.tsv"

require_manifest() {
  [ -f "$1" ] || die 4 "Manifest file does not exist: $1"
}
require_manifest "$PROFILES_TSV"
require_manifest "$PACKS_TSV"
require_manifest "$FILES_TSV"
require_manifest "$PLACEHOLDERS_TSV"
require_manifest "$SCAFFOLD_ROOT/VERSION"

validate_header() {
  local path="$1"
  local expected="$2"
  local actual
  IFS= read -r actual < "$path" || die 4 "Manifest file is empty: $path"
  actual="${actual%$'\r'}"
  [ "$actual" = "$expected" ] || die 4 "Manifest header mismatch in $path"
}
validate_header "$PROFILES_TSV" $'profile\tpacks\tdescription'
validate_header "$PACKS_TSV" $'pack\trequires\tdescription'
validate_header "$FILES_TSV" $'source\tdestination\tpacks\tmode\tconflict\tplaceholder_policy\tindex_group\tdescription'
validate_header "$PLACEHOLDERS_TSV" $'token\trequired\tpacks\tprofiles\tdefault\ttbd\tdescription'

validate_column_count() {
  local path="$1"
  local expected="$2"
  awk -F '\t' -v expected="$expected" '
    NF != expected { printf "bad row %d: expected %d columns, got %d\n", NR, expected, NF > "/dev/stderr"; exit 1 }
  ' "$path" || die 4 "Manifest row has the wrong number of columns: $path"
}
validate_column_count "$PROFILES_TSV" 3
validate_column_count "$PACKS_TSV" 3
validate_column_count "$FILES_TSV" 8
validate_column_count "$PLACEHOLDERS_TSV" 7

if [ "$SHOW_HELP" -eq 1 ]; then usage; exit 0; fi
if [ "$LIST_PROFILES" -eq 1 ]; then
  awk -F '\t' 'NR > 1 { sub(/\r$/, "", $3); print $1 "\t" $2 "\t" $3 }' "$PROFILES_TSV"
  exit 0
fi
if [ "$LIST_PACKS" -eq 1 ]; then
  awk -F '\t' 'NR > 1 { sub(/\r$/, "", $3); print $1 "\t" $2 "\t" $3 }' "$PACKS_TSV"
  exit 0
fi

[ -n "$TARGET" ] || die 2 "--target is required."
[ -n "$PROJECT_NAME" ] || die 2 "--project-name is required."
[ -n "$OWNER" ] || die 2 "--owner is required."
[ "${#PROFILE_ARGS[@]}" -gt 0 ] || die 2 "At least one --profile is required."

case "$PROJECT_NAME$OWNER" in
  *$'\t'*|*$'\r'*|*$'\n'*) die 2 "Project name or owner contains a forbidden control character." ;;
esac

if [ -z "$CURRENT_DATE" ]; then
  CURRENT_DATE="$(date '+%Y-%m-%d')" || die 5 "Could not determine the current date."
fi
if ! printf '%s\n' "$CURRENT_DATE" | awk '
  function leap(y) { return (y % 400 == 0 || (y % 4 == 0 && y % 100 != 0)) }
  BEGIN { ok = 0 }
  /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ {
    y = substr($0,1,4) + 0; m = substr($0,6,2) + 0; d = substr($0,9,2) + 0
    days[1]=31; days[2]=28+leap(y); days[3]=31; days[4]=30; days[5]=31; days[6]=30
    days[7]=31; days[8]=31; days[9]=30; days[10]=31; days[11]=30; days[12]=31
    if (m >= 1 && m <= 12 && d >= 1 && d <= days[m]) ok = 1
  }
  END { exit(ok ? 0 : 1) }
'; then
  die 2 "Date must be a real calendar date in YYYY-MM-DD format."
fi

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/docs-template-init.XXXXXX")" || die 5 "Could not create a temporary directory."
SELECTED_PROFILES="$TMP_ROOT/selected-profiles.txt"
SELECTED_PACKS="$TMP_ROOT/selected-packs.txt"
EXCLUDED_PACKS="$TMP_ROOT/excluded-packs.txt"
CUSTOM_VALUES="$TMP_ROOT/custom-values.tsv"
APPLICABLE_KEYS="$TMP_ROOT/applicable-keys.txt"
REPLACEMENTS="$TMP_ROOT/replacements.tsv"
SELECTED_ROWS="$TMP_ROOT/selected-rows.usv"
UNRESOLVED="$TMP_ROOT/unresolved.tsv"
ACTIONS="$TMP_ROOT/actions.tsv"
OUTPUTS="$TMP_ROOT/outputs.tsv"
STAGING_ROOT="$TMP_ROOT/stage"
mkdir -p "$STAGING_ROOT" || die 5 "Could not create the staging directory."
: > "$SELECTED_PROFILES"
: > "$SELECTED_PACKS"
: > "$EXCLUDED_PACKS"
: > "$CUSTOM_VALUES"
: > "$APPLICABLE_KEYS"
: > "$REPLACEMENTS"
: > "$SELECTED_ROWS"
: > "$UNRESOLVED"
: > "$ACTIONS"
: > "$OUTPUTS"

lower_ascii() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
upper_ascii() { printf '%s' "$1" | tr '[:lower:]' '[:upper:]'; }

set_has() { grep -Fqx "$2" "$1" 2>/dev/null; }
set_add() {
  if ! set_has "$1" "$2"; then printf '%s\n' "$2" >> "$1"; fi
}

ALL_PROFILES_MATCH=";$(awk -F '\t' 'NR > 1 { printf "%s;", tolower($1) }' "$PROFILES_TSV")"
ALL_PACKS_MATCH=";$(awk -F '\t' 'NR > 1 { printf "%s;", tolower($1) }' "$PACKS_TSV")"
match_has() { case "$1" in *";$2;"*) return 0 ;; *) return 1 ;; esac; }
profile_exists() { match_has "$ALL_PROFILES_MATCH" "$1"; }
pack_exists() { match_has "$ALL_PACKS_MATCH" "$1"; }
profile_packs() { awk -F '\t' -v key="$1" 'NR > 1 && tolower($1) == key { print $2; found=1 } END { exit(found ? 0 : 1) }' "$PROFILES_TSV"; }
pack_requires() { awk -F '\t' -v key="$1" 'NR > 1 && tolower($1) == key { print $2; found=1 } END { exit(found ? 0 : 1) }' "$PACKS_TSV"; }

split_cli_values() {
  printf '%s' "$1" | tr ',;' '\n\n' | awk 'NF { gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print tolower($0) }'
}
split_manifest_values() {
  if [ -n "$1" ]; then printf '%s\n' "$1" | tr ';' '\n'; fi
}

for raw in "${PROFILE_ARGS[@]}"; do
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    profile_exists "$name" || die 2 "Unknown profile: $name"
    set_add "$SELECTED_PROFILES" "$name"
  done < <(split_cli_values "$raw")
done
[ -s "$SELECTED_PROFILES" ] || die 2 "At least one --profile is required."

for raw in "${EXCLUDE_ARGS[@]}"; do
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    pack_exists "$name" || die 2 "Unknown excluded pack: $name"
    [ "$name" != "core" ] || die 2 "The core pack cannot be excluded."
    set_add "$EXCLUDED_PACKS" "$name"
  done < <(split_cli_values "$raw")
done

while IFS= read -r profile_name; do
  packs="$(profile_packs "$profile_name")" || die 4 "Profile is missing from profiles.tsv: $profile_name"
  while IFS= read -r pack_name; do
    [ -n "$pack_name" ] || continue
    pack_name="$(lower_ascii "$pack_name")"
    pack_exists "$pack_name" || die 4 "Profile '$profile_name' references unknown pack '$pack_name'."
    set_add "$SELECTED_PACKS" "$pack_name"
  done < <(split_manifest_values "$packs")
done < "$SELECTED_PROFILES"

for raw in "${INCLUDE_ARGS[@]}"; do
  while IFS= read -r pack_name; do
    [ -n "$pack_name" ] || continue
    pack_exists "$pack_name" || die 2 "Unknown included pack: $pack_name"
    set_has "$EXCLUDED_PACKS" "$pack_name" && die 2 "Pack '$pack_name' is both included and excluded."
    set_add "$SELECTED_PACKS" "$pack_name"
  done < <(split_cli_values "$raw")
done

if [ -s "$EXCLUDED_PACKS" ]; then
  while IFS= read -r excluded; do
    grep -Fvx "$excluded" "$SELECTED_PACKS" > "$SELECTED_PACKS.next" || true
    mv "$SELECTED_PACKS.next" "$SELECTED_PACKS" || die 5 "Could not update the selected pack set."
  done < "$EXCLUDED_PACKS"
fi
set_add "$SELECTED_PACKS" "core"

changed=1
while [ "$changed" -eq 1 ]; do
  changed=0
  cp "$SELECTED_PACKS" "$SELECTED_PACKS.snapshot" || die 5 "Could not expand pack dependencies."
  while IFS= read -r pack_name; do
    requires="$(pack_requires "$pack_name")" || die 4 "Selected pack is missing from packs.tsv: $pack_name"
    while IFS= read -r required_pack; do
      [ -n "$required_pack" ] || continue
      required_pack="$(lower_ascii "$required_pack")"
      pack_exists "$required_pack" || die 4 "Pack '$pack_name' requires unknown pack '$required_pack'."
      set_has "$EXCLUDED_PACKS" "$required_pack" && die 2 "Pack '$pack_name' requires excluded pack '$required_pack'."
      if ! set_has "$SELECTED_PACKS" "$required_pack"; then
        set_add "$SELECTED_PACKS" "$required_pack"
        changed=1
      fi
    done < <(split_manifest_values "$requires")
  done < "$SELECTED_PACKS.snapshot"
done
LC_ALL=C sort -u "$SELECTED_PROFILES" -o "$SELECTED_PROFILES"
LC_ALL=C sort -u "$SELECTED_PACKS" -o "$SELECTED_PACKS"
SELECTED_PROFILES_MATCH=";$(awk '{ printf "%s;", $0 }' "$SELECTED_PROFILES")"
SELECTED_PACKS_MATCH=";$(awk '{ printf "%s;", $0 }' "$SELECTED_PACKS")"

validate_github_owner() {
  local value="$1" specification account team
  [[ "$value" == @* ]] || return 1
  specification="${value#@}"
  account="${specification%%/*}"
  [ ${#account} -ge 1 ] && [ ${#account} -le 39 ] || return 1
  [[ "$account" =~ ^[A-Za-z0-9]+(-[A-Za-z0-9]+)*$ ]] || return 1
  if [[ "$specification" == */* ]]; then
    team="${specification#*/}"
    [[ "$team" != */* ]] || return 1
    [[ "$team" =~ ^[A-Za-z0-9]([A-Za-z0-9_.-]*[A-Za-z0-9])?$ ]] || return 1
  fi
  return 0
}

for entry in "${SET_ARGS[@]}"; do
  case "$entry" in *=*) ;; *) die 2 "--set must use KEY=VALUE: $entry" ;; esac
  key="${entry%%=*}"
  value="${entry#*=}"
  key="$(upper_ascii "$(printf '%s' "$key" | awk '{$1=$1; print}')")"
  [[ "$key" =~ ^[A-Z][A-Z0-9_]*$ ]] || die 2 "Invalid --set key: $key"
  [ -n "$value" ] || die 2 "Value for '$key' must not be empty."
  case "$value" in *$'\t'*|*$'\r'*|*$'\n'*) die 2 "Value for '$key' contains a forbidden control character." ;; esac
  case "$key" in PROJECT_NAME|OWNER|CURRENT_DATE) die 2 "Use the dedicated option instead of --set for $key." ;; esac
  if [ "$key" = "GITHUB_OWNER" ] && ! validate_github_owner "$value"; then
    die 2 "GITHUB_OWNER must be @user or @organization/team; the account part must be 1-39 alphanumeric characters with single internal hyphens."
  fi
  if awk -F '\t' -v key="$key" '$1 == key { found=1 } END { exit(found ? 0 : 1) }' "$CUSTOM_VALUES"; then
    old_value="$(awk -F '\t' -v key="$key" '$1 == key { sub(/^[^\t]*\t/, ""); print; exit }' "$CUSTOM_VALUES")"
    [ "$old_value" = "$value" ] || die 2 "Conflicting values were supplied for $key."
  else
    printf '%s\t%s\n' "$key" "$value" >> "$CUSTOM_VALUES"
  fi
done

filter_matches() {
  local list="$1"
  local set_file="$2"
  local match_string
  local item
  local IFS=';'
  [ -z "$list" ] && return 0
  if [ "$set_file" = "$SELECTED_PACKS" ]; then match_string="$SELECTED_PACKS_MATCH"
  else match_string="$SELECTED_PROFILES_MATCH"
  fi
  for item in $list; do
    [ "$item" = "*" ] && return 0
    match_has "$match_string" "$item" && return 0
  done
  return 1
}

validate_filter_members() {
  local list="$1"
  local kind="$2"
  local item
  local IFS=';'
  [ -z "$list" ] && return 0
  for item in $list; do
    [ "$item" = "*" ] && continue
    if [ "$kind" = "pack" ]; then pack_exists "$item" || die 4 "Unknown pack '$item' in placeholders.tsv."
    else profile_exists "$item" || die 4 "Unknown profile '$item' in placeholders.tsv."
    fi
  done
}

US=$'\034'
APPLICABLE_KEYS_MATCH=";"
while IFS="$US" read -r token required packs profiles default_value tbd_value description; do
  token="${token%$'\r'}"; description="${description%$'\r'}"
  [ "$required" = "true" ] || [ "$required" = "false" ] || die 4 "Invalid required value '$required' in placeholders.tsv."
  [[ "$token" =~ ^\{\{[A-Z][A-Z0-9_]*\}\}$ ]] || die 4 "Invalid placeholder token in placeholders.tsv: $token"
  validate_filter_members "$packs" "pack"
  validate_filter_members "$profiles" "profile"
  filter_matches "$packs" "$SELECTED_PACKS" || continue
  filter_matches "$profiles" "$SELECTED_PROFILES" || continue

  key="${token#\{\{}"; key="${key%\}\}}"
  match_has "$APPLICABLE_KEYS_MATCH" "$key" && die 4 "Duplicate applicable placeholder token: $token"
  APPLICABLE_KEYS_MATCH="${APPLICABLE_KEYS_MATCH}${key};"
  printf '%s\n' "$key" >> "$APPLICABLE_KEYS"

  value=""
  has_value=1
  case "$key" in
    PROJECT_NAME) value="$PROJECT_NAME" ;;
    OWNER) value="$OWNER" ;;
    CURRENT_DATE) value="$CURRENT_DATE" ;;
    *)
      if awk -F '\t' -v key="$key" '$1 == key { found=1 } END { exit(found ? 0 : 1) }' "$CUSTOM_VALUES"; then
        value="$(awk -F '\t' -v key="$key" '$1 == key { sub(/^[^\t]*\t/, ""); print; exit }' "$CUSTOM_VALUES")"
      elif [ -n "$default_value" ]; then value="$default_value"
      elif [ -n "$tbd_value" ]; then value="$tbd_value"
      elif [ "$required" = "true" ]; then die 2 "Required placeholder has no value, default, or TBD fallback: $token"
      else has_value=0
      fi
      ;;
  esac
  if [ "$has_value" -eq 1 ]; then
    case "$value" in *$'\t'*|*$'\r'*|*$'\n'*) die 2 "Replacement for $token contains a forbidden control character." ;; esac
    printf '%s\t%s\n' "$token" "$value" >> "$REPLACEMENTS"
  fi
done < <(awk -F '\t' 'NR > 1 { sub(/\r$/, "", $7); for (i=1;i<=7;i++) printf "%s%s", $i, (i<7 ? "\034" : "\n") }' "$PLACEHOLDERS_TSV")

while IFS=$'\t' read -r key value; do
  [ -n "$key" ] || continue
  match_has "$APPLICABLE_KEYS_MATCH" "$key" || die 2 "Unknown or inactive --set key for the selected profiles and packs: $key"
done < "$CUSTOM_VALUES"

safe_relative() {
  local value="$1"
  [ -n "$value" ] || return 1
  case "$value" in /*|*\\*|*:*|*/|*//*|.|..|./*|../*|*/./*|*/../*|*/.|*/..) return 1 ;; esac
  return 0
}

assert_no_lexical_target_links() {
  local input="${1//\\//}"
  local current remainder segment parent drive_root=""
  local -a segments

  # Build the target lexically. Do not use cd -P, pwd -P, realpath, or
  # readlink here: every existing component must be inspected before any
  # physical resolution can hide a symlink or Windows junction ancestor.
  if [[ "$input" =~ ^[A-Za-z]:/ ]]; then
    drive_root="${input:0:2}"
    current="$drive_root"
    remainder="${input:3}"
  else
    if [[ "$input" != /* ]]; then
      input="${PWD%/}/$input"
    fi
    current="/"
    remainder="${input#/}"
  fi

  IFS='/' read -r -a segments <<< "$remainder"
  for segment in "${segments[@]}"; do
    case "$segment" in
      ''|.)
        continue
        ;;
      ..)
        parent="$(dirname "$current")"
        if [ -n "$drive_root" ] && [ "$parent" = "." ]; then
          current="$drive_root"
        else
          current="$parent"
        fi
        continue
        ;;
    esac

    if [ "$current" = "/" ]; then
      current="/$segment"
    else
      current="$current/$segment"
    fi
    if [ -L "$current" ]; then
      die 2 "Target path contains a symlink or reparse point: $current"
    fi
  done
}

assert_no_lexical_target_links "$TARGET"
if [ -d "$TARGET" ]; then
  TARGET_ABS="$(cd -P "$TARGET" && pwd)" || die 2 "Could not resolve target directory."
  TARGET_EXISTS=1
elif [ -e "$TARGET" ]; then
  die 2 "Target exists and is not a directory: $TARGET"
else
  target_parent="$(dirname "$TARGET")"
  target_name="$(basename "$TARGET")"
  [ -d "$target_parent" ] || die 2 "The target parent directory does not exist: $target_parent"
  parent_abs="$(cd -P "$target_parent" && pwd)" || die 2 "Could not resolve target parent directory."
  TARGET_ABS="$parent_abs/$target_name"
  TARGET_EXISTS=0
fi
case "$TARGET_ABS" in /|/[A-Za-z]) die 2 "A filesystem root cannot be used as the target." ;; esac
[ ! -L "$TARGET" ] || die 2 "Target must not be a symlink."

compare_target="$TARGET_ABS"
compare_repo="$REPO_ROOT"
case "${OSTYPE:-}" in
  msys*|cygwin*) compare_target="$(lower_ascii "$compare_target")"; compare_repo="$(lower_ascii "$compare_repo")" ;;
esac
case "$compare_target/" in "$compare_repo/"|"$compare_repo/"*) die 2 "Target must not be the template repository or a child of it." ;; esac
case "$compare_repo/" in "$compare_target/"*) die 2 "Target must not be an ancestor of the template repository." ;; esac

TARGET_SAFETY_ERROR=""

same_physical_path() {
  local left="$1"
  local right="$2"
  case "${OSTYPE:-}" in
    msys*|cygwin*) left="$(lower_ascii "$left")"; right="$(lower_ascii "$right")" ;;
  esac
  [ "$left" = "$right" ]
}

physical_path_within_target() {
  local candidate="$1"
  local root="$TARGET_ABS"
  case "${OSTYPE:-}" in
    msys*|cygwin*) candidate="$(lower_ascii "$candidate")"; root="$(lower_ascii "$root")" ;;
  esac
  case "$candidate/" in "$root/"*) return 0 ;; *) return 1 ;; esac
}

check_safe_target_destination() {
  local relative="$1"
  local current="$TARGET_ABS"
  local resolved
  local segment
  local index
  local -a segments

  TARGET_SAFETY_ERROR=""
  IFS='/' read -r -a segments <<< "$relative"

  if [ -L "$current" ]; then
    TARGET_SAFETY_ERROR="Target root is a symlink or reparse point: $current"
    return 1
  fi
  if [ -d "$current" ]; then
    resolved="$(cd "$current" 2>/dev/null && pwd -P)" || {
      TARGET_SAFETY_ERROR="Could not resolve target root: $current"
      return 1
    }
    if ! same_physical_path "$resolved" "$TARGET_ABS"; then
      TARGET_SAFETY_ERROR="Resolved target root changed: $resolved"
      return 1
    fi
  fi

  for ((index=0; index<${#segments[@]}; index++)); do
    segment="${segments[$index]}"
    current="$current/$segment"

    if [ -L "$current" ]; then
      TARGET_SAFETY_ERROR="Target destination crosses a symlink or reparse point: $relative ($current)"
      return 1
    fi
    if [ -d "$current" ]; then
      resolved="$(cd "$current" 2>/dev/null && pwd -P)" || {
        TARGET_SAFETY_ERROR="Could not resolve target destination parent: $relative ($current)"
        return 1
      }
      if ! same_physical_path "$resolved" "$current" || ! physical_path_within_target "$resolved"; then
        TARGET_SAFETY_ERROR="Resolved target destination escapes the target root: $relative ($resolved)"
        return 1
      fi
    elif [ -e "$current" ]; then
      if [ "$index" -lt $((${#segments[@]} - 1)) ]; then
        break
      fi
    else
      break
    fi
  done

  return 0
}

check_safe_target_parent_for_creation() {
  local parent
  local resolved

  TARGET_SAFETY_ERROR=""
  parent="$(dirname "$TARGET_ABS")"
  if [ -L "$TARGET_ABS" ]; then
    TARGET_SAFETY_ERROR="Target root changed to a symlink or reparse point: $TARGET_ABS"
    return 1
  fi
  if [ -L "$parent" ] || [ ! -d "$parent" ]; then
    TARGET_SAFETY_ERROR="Target parent changed after preflight: $parent"
    return 1
  fi
  resolved="$(cd "$parent" 2>/dev/null && pwd -P)" || {
    TARGET_SAFETY_ERROR="Could not resolve target parent before creation: $parent"
    return 1
  }
  if ! same_physical_path "$resolved" "$parent"; then
    TARGET_SAFETY_ERROR="Resolved target parent changed after preflight: $resolved"
    return 1
  fi

  return 0
}

DESTINATIONS_MATCH=";"
while IFS="$US" read -r source destination packs mode conflict placeholder_policy index_group description; do
  source="${source%$'\r'}"; description="${description%$'\r'}"
  safe_relative "$source" || die 4 "Unsafe source path in files.tsv: $source"
  safe_relative "$destination" || die 4 "Unsafe destination path in files.tsv: $destination"
  case "$mode" in copy|render) ;; *) die 4 "Invalid mode '$mode' for $source" ;; esac
  case "$conflict" in fail|preserve) ;; *) die 4 "Invalid conflict policy '$conflict' for $source" ;; esac
  case "$placeholder_policy" in replace|preserve-template|none) ;; *) die 4 "Invalid placeholder policy '$placeholder_policy' for $source" ;; esac
  [ "$mode" != "copy" ] || [ "$placeholder_policy" != "replace" ] || die 4 "A copy row cannot use placeholder_policy=replace: $source"
  while IFS= read -r pack_name; do
    [ -n "$pack_name" ] || continue
    pack_exists "$pack_name" || die 4 "File '$source' references unknown pack '$pack_name'."
  done < <(split_manifest_values "$packs")
  filter_matches "$packs" "$SELECTED_PACKS" || continue
  [ "$(lower_ascii "$destination")" != ".docs-template/state.tsv" ] || die 4 "files.tsv must not own .docs-template/state.tsv."
  destination_key="$(lower_ascii "$destination")"
  match_has "$DESTINATIONS_MATCH" "$destination_key" && die 4 "Duplicate destination (case-insensitive): $destination"
  DESTINATIONS_MATCH="${DESTINATIONS_MATCH}${destination_key};"
  source_full="$REPO_ROOT/$source"
  [ -f "$source_full" ] || die 4 "Source file does not exist: $source"
  [ ! -L "$source_full" ] || die 4 "Source file is a symlink: $source"
  printf '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n' \
    "$destination" "$US" "$source" "$US" "$packs" "$US" "$mode" "$US" "$conflict" "$US" "$placeholder_policy" "$US" "$index_group" "$US" "$description" >> "$SELECTED_ROWS"
done < <(awk -F '\t' 'NR > 1 { sub(/\r$/, "", $8); for (i=1;i<=8;i++) printf "%s%s", $i, (i<8 ? "\034" : "\n") }' "$FILES_TSV")

[ -s "$SELECTED_ROWS" ] || die 4 "The selected profiles and packs produced no files."
LC_ALL=C sort "$SELECTED_ROWS" -o "$SELECTED_ROWS"

join_set() { awk 'BEGIN{first=1} { if(!first) printf ", "; printf "%s", $0; first=0 } END { print "" }' "$1"; }
CATALOG="$TMP_ROOT/catalog.md"
{
  printf '\n## 5. 已启用文档\n\n'
  printf -- '- Profile：`%s`\n' "$(join_set "$SELECTED_PROFILES")"
  printf -- '- Packs：`%s`\n\n' "$(join_set "$SELECTED_PACKS")"
  printf '| 分组 | 路径 | 类型 | 说明 |\n'
  printf '|------|------|------|------|\n'
  while IFS="$US" read -r destination source packs mode conflict placeholder_policy index_group description; do
    index_group="${index_group//|/\\|}"
    destination_display="${destination//|/\\|}"
    description="${description//|/\\|}"
    case "$placeholder_policy" in
      preserve-template) catalog_type="可复用模板" ;;
      none) catalog_type="工具或配置" ;;
      *) catalog_type="活跃文档" ;;
    esac
    printf '| `%s` | `%s` | %s | %s |\n' "$index_group" "$destination_display" "$catalog_type" "$description"
  done < "$SELECTED_ROWS"
} > "$CATALOG"

ROOT_CATALOG="$TMP_ROOT/root-catalog.md"
{
  printf '\n## 已启用项目入口\n\n'
  printf '以下入口由本次 profile 与 pack 选择生成，以实际文件为准。\n\n'
  root_catalog_rows=0
  while IFS="$US" read -r destination source packs mode conflict placeholder_policy index_group description; do
    [ "$destination" != "README.md" ] || continue
    case "$destination" in
      .github/*) ;;
      */*) continue ;;
    esac
    if [ "$root_catalog_rows" -eq 0 ]; then
      printf '| 入口 | 类型 | 说明 |\n'
      printf '|------|------|------|\n'
    fi
    description="${description//|/\\|}"
    case "$placeholder_policy" in
      preserve-template) catalog_type="可复用模板" ;;
      none) catalog_type="工具或配置" ;;
      *) catalog_type="活跃文档" ;;
    esac
    printf '| [%s](%s) | %s | %s |\n' "$destination" "$destination" "$catalog_type" "$description"
    root_catalog_rows=$((root_catalog_rows + 1))
  done < "$SELECTED_ROWS"
  if [ "$root_catalog_rows" -eq 0 ]; then
    printf '当前 profile 未启用额外的根目录或 GitHub 协作入口。\n'
  fi
} > "$ROOT_CATALOG"

render_file() {
  local source_path="$1"
  local output_path="$2"
  awk -F '\t' '
    NR==FNR { replacements[$1]=$2; next }
    {
      sub(/\r$/, "")
      remaining=$0; output=""
      while ((start=index(remaining, "{{")) > 0) {
        output=output substr(remaining, 1, start-1)
        tail=substr(remaining, start+2)
        finish=index(tail, "}}")
        if (finish == 0) { output=output substr(remaining, start); remaining=""; break }
        token="{{" substr(tail, 1, finish-1) "}}"
        if (token in replacements) output=output replacements[token]
        else output=output token
        remaining=substr(tail, finish+2)
      }
      print output remaining
    }
  ' "$REPLACEMENTS" "$source_path" > "$output_path"
}

scan_unresolved() {
  local relative="$1"
  local path="$2"
  awk -v relative="$relative" '
    {
      remaining=$0
      while ((start=index(remaining, "{{")) > 0) {
        tail=substr(remaining, start+2)
        finish=index(tail, "}}")
        if (finish == 0) break
        print relative "\t{{" substr(tail, 1, finish-1) "}}"
        remaining=substr(tail, finish+2)
      }
    }
  ' "$path" >> "$UNRESOLVED"
}

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print tolower($1)}'
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print tolower($1)}'
  else die 5 "Neither sha256sum nor shasum is available."
  fi
}

template_version="$(tr -d '\r\n' < "$SCAFFOLD_ROOT/VERSION")"
[[ "$template_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die 4 "scaffold/VERSION must contain a semantic version."
STATE_ENTRIES="$TMP_ROOT/state-entries.tsv"
: > "$STATE_ENTRIES"

while IFS="$US" read -r destination source packs mode conflict placeholder_policy index_group description; do
  staged="$STAGING_ROOT/$destination"
  mkdir -p "$(dirname "$staged")" || die 5 "Could not create staging directory for $destination"
  if [ "$mode" = "copy" ]; then
    cp "$REPO_ROOT/$source" "$staged" || die 5 "Could not stage $destination"
  else
    render_file "$REPO_ROOT/$source" "$staged" || die 5 "Could not render $destination"
    if [ "$destination" = "docs/README.md" ]; then
      cat "$CATALOG" >> "$staged" || die 5 "Could not append the generated document catalog."
    fi
    if [ "$destination" = "README.md" ]; then
      cat "$ROOT_CATALOG" >> "$staged" || die 5 "Could not append the generated project entry catalog."
    fi
  fi
  [ "$placeholder_policy" != "replace" ] || scan_unresolved "$destination" "$staged"
  staged_hash="$(sha256_file "$staged")"
  prospective_target="$TARGET_ABS/$destination"
  if [ "$conflict" = "preserve" ] && [ -f "$prospective_target" ] && [ "$(sha256_file "$prospective_target")" != "$staged_hash" ]; then
    :
  else
    printf '1\t%s\t%s\t%s\t%s\t%s\t%s\n' "$template_version" "$destination" "$source" "$packs" "$placeholder_policy" "$staged_hash" >> "$STATE_ENTRIES"
  fi
  printf '%s\t%s\t%s\n' "$destination" "$staged" "$conflict" >> "$OUTPUTS"
done < "$SELECTED_ROWS"

STATE_RELATIVE=".docs-template/state.tsv"
STATE_STAGED="$STAGING_ROOT/$STATE_RELATIVE"
mkdir -p "$(dirname "$STATE_STAGED")" || die 5 "Could not create state staging directory."
{
  printf 'schema_version\ttemplate_version\tdestination\tsource\tpacks\tplaceholder_policy\tsha256\n'
  cat "$STATE_ENTRIES"
} > "$STATE_STAGED"
printf '%s\t%s\tfail\n' "$STATE_RELATIVE" "$STATE_STAGED" >> "$OUTPUTS"
LC_ALL=C sort "$OUTPUTS" -o "$OUTPUTS"

while IFS=$'\t' read -r relative staged conflict_policy; do
  if ! check_safe_target_destination "$relative"; then
    die 2 "$TARGET_SAFETY_ERROR"
  fi
done < "$OUTPUTS"

if [ -s "$UNRESOLVED" ]; then
  unresolved_count="$(wc -l < "$UNRESOLVED" | tr -d ' ')"
  printf 'UNRESOLVED %s placeholder occurrence(s) remain in active documents:\n' "$unresolved_count"
  LC_ALL=C sort "$UNRESOLVED" | awk -F '\t' '
    {
      path=$1; token=$2; total[path]++
      key=path SUBSEP token
      if (!seen[key]++) {
        if (tokens[path] == "") tokens[path]=token
        else if (token_count[path] < 11) tokens[path]=tokens[path] ", " token
        token_count[path]++
      }
    }
    END {
      for (path in total) {
        suffix=(token_count[path] > 12 ? ", ..." : "")
        printf "  %s: %d (%s%s)\n", path, total[path], tokens[path], suffix
      }
    }
  ' | LC_ALL=C sort
  [ "$REQUIRE_COMPLETE" -eq 0 ] || die 6 "RequireComplete rejected unresolved placeholders."
fi

path_parent_has_file() {
  local target_path="$1"
  local parent
  parent="$(dirname "$target_path")"
  while [ "$parent" != "$TARGET_ABS" ] && [ "$parent" != "/" ]; do
    [ ! -f "$parent" ] || return 0
    parent="$(dirname "$parent")"
  done
  return 1
}

conflict_count=0
while IFS=$'\t' read -r relative staged conflict_policy; do
  target_path="$TARGET_ABS/$relative"
  action="CREATE"
  if [ -d "$target_path" ] || path_parent_has_file "$target_path"; then
    action="CONFLICT"; conflict_count=$((conflict_count + 1))
  elif [ -f "$target_path" ]; then
    if [ "$(sha256_file "$target_path")" = "$(sha256_file "$staged")" ]; then action="UNCHANGED"
    elif [ "$conflict_policy" = "preserve" ]; then action="PRESERVE"
    else action="CONFLICT"; conflict_count=$((conflict_count + 1))
    fi
  fi
  printf '%s\t%s\n' "$relative" "$action" >> "$ACTIONS"
  printf '[%-9s] %s\n' "$action" "$relative"
done < "$OUTPUTS"

[ "$conflict_count" -eq 0 ] || die 3 "Different existing files or path collisions were found. No target files were written."
if [ "$DRY_RUN" -eq 1 ]; then
  printf 'DRY-RUN OK: no target files were written.\n'
  exit 0
fi

assert_no_lexical_target_links "$TARGET"

rollback_created() {
  local index
  for ((index=${#CREATED_FILES[@]}-1; index>=0; index--)); do rm -f "${CREATED_FILES[$index]}" 2>/dev/null || true; done
  if [ "$CREATED_TARGET" -eq 1 ] && [ -d "$TARGET_ABS" ]; then rm -rf "$TARGET_ABS" 2>/dev/null || true; fi
}

if [ "$TARGET_EXISTS" -eq 0 ]; then
  if ! check_safe_target_parent_for_creation; then
    die 2 "$TARGET_SAFETY_ERROR"
  fi
  if [ -e "$TARGET_ABS" ] || [ -L "$TARGET_ABS" ]; then
    die 3 "Target changed after preflight: $TARGET_ABS"
  fi
  mkdir "$TARGET_ABS" || die 5 "Could not create target directory: $TARGET_ABS"
  CREATED_TARGET=1
  if ! check_safe_target_destination "$STATE_RELATIVE"; then
    rollback_created
    die 2 "$TARGET_SAFETY_ERROR"
  fi
fi

APPLY_OUTPUTS="$TMP_ROOT/apply-outputs.tsv"
grep -Fv $'.docs-template/state.tsv\t' "$OUTPUTS" > "$APPLY_OUTPUTS" || true
grep -F $'.docs-template/state.tsv\t' "$OUTPUTS" >> "$APPLY_OUTPUTS" || true
while IFS=$'\t' read -r relative staged conflict_policy; do
  action="$(awk -F '\t' -v key="$relative" '$1 == key { print $2; exit }' "$ACTIONS")"
  [ "$action" = "CREATE" ] || continue
  assert_no_lexical_target_links "$TARGET"
  target_path="$TARGET_ABS/$relative"
  if ! check_safe_target_destination "$relative"; then
    rollback_created
    die 2 "$TARGET_SAFETY_ERROR"
  fi
  if [ -e "$target_path" ]; then
    rollback_created
    die 3 "Target changed after preflight: $relative"
  fi
  mkdir -p "$(dirname "$target_path")" || { rollback_created; die 5 "Could not create target parent for $relative"; }
  if ! check_safe_target_destination "$relative"; then
    rollback_created
    die 2 "$TARGET_SAFETY_ERROR"
  fi
  if [ -e "$target_path" ]; then
    rollback_created
    die 3 "Target changed after parent creation: $relative"
  fi
  if ! check_safe_target_destination "$relative"; then
    rollback_created
    die 2 "$TARGET_SAFETY_ERROR"
  fi
  cp "$staged" "$target_path" || { rollback_created; die 5 "Could not create $relative"; }
  CREATED_FILES[${#CREATED_FILES[@]}]="$target_path"
done < "$APPLY_OUTPUTS"

file_count="$(wc -l < "$SELECTED_ROWS" | tr -d ' ')"
printf 'OK: initialized %s scaffold file(s) plus state metadata.\n' "$file_count"
exit 0
