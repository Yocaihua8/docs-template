# SHA-256 of Markdown bytes with LF endings. Older state files may record CRLF.
template_text_hash() {
  local path="$1" content='' digest
  local -a hash_command
  [ -r "$path" ] || return 1
  # Read through EOF so a missing final newline stays significant. Markdown is text.
  if IFS= read -r -d '' content < "$path"; then return 1; fi
  content="${content//$'\r\n'/$'\n'}"
  if [ "${2:-lf}" = "crlf" ]; then content="${content//$'\n'/$'\r\n'}"; fi

  if command -v sha256sum >/dev/null 2>&1; then hash_command=(sha256sum)
  elif command -v shasum >/dev/null 2>&1; then hash_command=(shasum -a 256)
  elif command -v openssl >/dev/null 2>&1; then hash_command=(openssl dgst -sha256 -r)
  else return 1
  fi
  digest="$(printf '%s' "$content" | "${hash_command[@]}")" || return 1
  printf '%s\n' "${digest%% *}"
}
