#!/usr/bin/env sh
# ferment uninstaller — counterpart to install.sh.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/mei28/ferment/main/uninstall.sh | sh
#   # or, from a checkout:
#   ./uninstall.sh
#
# Environment variables:
#   FERMENT_PREFIX   if set, only this directory is checked for bin/ferment.
#                    when unset, well-known prefixes ($HOME/.local/bin, $HOME/bin,
#                    /usr/local/bin) are scanned, plus whatever `command -v ferment`
#                    resolves to.
#   FERMENT_FORCE    when "1", skip the confirmation prompt.
#
# What this script removes:
#   - bin/ferment from the detected prefix(es)
#   - completions installed by install.sh in their known locations
#
# What this script deliberately does NOT touch:
#   - `mutagen` itself (it is a dependency, not part of ferment)
#   - any `ferment.yml` / `mutagen.yml` files in your projects (your data)
#   - Homebrew / nix installs (see the post-script hints)

set -eu

# ---------- ui ----------
if [ -t 1 ]; then
  R=$(printf '\033[0m')
  B=$(printf '\033[1m')
  G=$(printf '\033[32m')
  Y=$(printf '\033[33m')
  E=$(printf '\033[31m')
else
  R=""; B=""; G=""; Y=""; E=""
fi
info() { printf "%s->%s %s\n" "$B" "$R" "$*"; }
ok()   { printf "%s✓%s %s\n"  "$G" "$R" "$*"; }
warn() { printf "%s!%s %s\n"  "$Y" "$R" "$*"; }
die()  { printf "%serror:%s %s\n" "$E" "$R" "$*" >&2; exit 1; }

# ---------- collect candidate paths ----------
# We append matches to $TARGETS (newline-separated); dedupe before acting.
TARGETS=""

add_target() {
  case "$1" in
    "") return ;;
  esac
  if [ -e "$1" ] || [ -L "$1" ]; then
    TARGETS="${TARGETS}${1}
"
  fi
}

# Binary candidates
if [ -n "${FERMENT_PREFIX:-}" ]; then
  add_target "${FERMENT_PREFIX}/ferment"
else
  add_target "${HOME}/.local/bin/ferment"
  add_target "${HOME}/bin/ferment"
  add_target "/usr/local/bin/ferment"
  if command -v ferment >/dev/null 2>&1; then
    add_target "$(command -v ferment)"
  fi
fi

# Completion candidates (mirrors install.sh)
add_target "${HOME}/.zsh/completions/_ferment"
add_target "${HOME}/.local/share/bash-completion/completions/ferment"
add_target "${HOME}/.config/fish/completions/ferment.fish"

# Dedupe (POSIX: awk-based)
TARGETS=$(printf '%s' "$TARGETS" | awk 'NF && !seen[$0]++')

if [ -z "$TARGETS" ]; then
  warn "Nothing to remove. ferment was not found in any known location."
  warn "If you installed via Homebrew, run: brew uninstall ferment"
  warn "If you installed via nix, run:      nix profile remove ferment"
  exit 0
fi

# ---------- detect brew / nix ----------
# Don't try to remove from these; just point the user at the right tool.
detect_managed() {
  managed=""
  if command -v brew >/dev/null 2>&1; then
    if brew list --formula 2>/dev/null | grep -qx ferment; then
      managed="brew"
    fi
  fi
  if [ -z "$managed" ] && command -v nix >/dev/null 2>&1; then
    if nix profile list 2>/dev/null | grep -q 'ferment'; then
      managed="nix"
    fi
  fi
  printf '%s' "$managed"
}
MANAGED="$(detect_managed)"

# ---------- confirm ----------
info "The following will be removed:"
printf '%s\n' "$TARGETS" | sed 's/^/    /'

if [ "${FERMENT_FORCE:-0}" != "1" ]; then
  # Read from controlling terminal so `curl | sh` still gets a prompt.
  if [ -r /dev/tty ]; then
    printf "Proceed? [y/N] "
    read -r reply < /dev/tty
  else
    reply=""
  fi
  case "$reply" in
    y|Y|yes|YES) ;;
    *) warn "Aborted. (Set FERMENT_FORCE=1 to skip this prompt.)"; exit 1 ;;
  esac
fi

# ---------- remove ----------
removed=0
printf '%s\n' "$TARGETS" | while IFS= read -r path; do
  [ -z "$path" ] && continue
  if rm -f -- "$path"; then
    ok "removed $path"
    removed=$((removed + 1))
  else
    warn "could not remove $path"
  fi
done

# ---------- post-script hints ----------
echo
if [ -n "$MANAGED" ]; then
  case "$MANAGED" in
    brew)
      warn "Homebrew install detected. To fully remove the formula:"
      printf '    brew uninstall ferment\n'
      printf '    brew untap mei28/ferment   # optional\n'
      ;;
    nix)
      warn "nix profile install detected. To fully remove:"
      printf '    nix profile remove ferment\n'
      ;;
  esac
fi

cat <<EOF

${B}Notes:${R}
  - mutagen was not touched (uninstall separately if you no longer need it).
  - Your project files (ferment.yml / mutagen.yml) are untouched.
EOF
