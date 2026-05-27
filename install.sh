#!/usr/bin/env sh
# ferment installer — curl | sh
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/mei28/ferment/main/install.sh | sh
#
# Environment variables:
#   FERMENT_PREFIX   install directory (default: ~/.local/bin or ~/bin if on PATH)
#   FERMENT_REF      git ref/branch/tag to install (default: main)
#   FERMENT_REPO     override repository (default: mei28/ferment)
#
# What this installer does:
#   1. Detects a writable bin directory on PATH
#   2. Downloads bin/ferment at the requested ref
#   3. Installs it to PREFIX/ferment and chmods +x
#   4. Best-effort: installs shell completions into known locations

set -eu

REPO="${FERMENT_REPO:-mei28/ferment}"
REF="${FERMENT_REF:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${REF}"

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

# ---------- prerequisites ----------
command -v curl >/dev/null 2>&1 || die "curl not found on PATH"

# ---------- prefix detection ----------
pick_prefix() {
  if [ -n "${FERMENT_PREFIX:-}" ]; then
    printf "%s" "$FERMENT_PREFIX"
    return
  fi
  case ":$PATH:" in
    *:"$HOME/.local/bin":*) printf "%s" "$HOME/.local/bin"; return ;;
    *:"$HOME/bin":*)        printf "%s" "$HOME/bin";        return ;;
  esac
  # nothing on PATH; default to ~/.local/bin (most common)
  printf "%s" "$HOME/.local/bin"
}

PREFIX="$(pick_prefix)"
mkdir -p "$PREFIX"

# ---------- download ----------
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

info "Downloading ferment from ${REPO}@${REF}"
curl -fsSL "$RAW_BASE/bin/ferment" -o "$TMP/ferment"
chmod +x "$TMP/ferment"

# Sanity check: should start with a bash shebang
if ! head -n 1 "$TMP/ferment" | grep -q "bash"; then
  die "downloaded file doesn't look like a bash script; aborting"
fi

# ---------- install ----------
install -m 0755 "$TMP/ferment" "$PREFIX/ferment"
ok "Installed ferment to ${PREFIX}/ferment"

# ---------- completions (best-effort) ----------
install_completion() {
  src_url="$1"; dest="$2"
  if [ -d "$(dirname "$dest")" ]; then
    if curl -fsSL "$src_url" -o "$dest" 2>/dev/null; then
      ok "Installed completion: $dest"
    fi
  fi
}
install_completion "$RAW_BASE/completions/_ferment"       "${HOME}/.zsh/completions/_ferment"
install_completion "$RAW_BASE/completions/ferment.bash"   "${HOME}/.local/share/bash-completion/completions/ferment"
install_completion "$RAW_BASE/completions/ferment.fish"   "${HOME}/.config/fish/completions/ferment.fish"

# ---------- PATH guard ----------
case ":$PATH:" in
  *:"$PREFIX":*) ;;
  *)
    warn "$PREFIX is not on PATH. Add this to your shell rc:"
    printf '  export PATH="%s:$PATH"\n' "$PREFIX"
    ;;
esac

# ---------- verify ----------
if command -v ferment >/dev/null 2>&1; then
  ok "Verify: $(ferment version 2>/dev/null || echo "(installed but not yet on PATH)")"
else
  warn "ferment is not on PATH yet. Open a new shell or run the export above."
fi

cat <<EOF

${B}Next steps:${R}
  ${B}1.${R} Install mutagen if you haven't:
       brew install mutagen-io/mutagen/mutagen
  ${B}2.${R} (Re)install shell completions any time with:
       ferment completion bash > ~/.local/share/bash-completion/completions/ferment
       ferment completion zsh  > ~/.zsh/completions/_ferment
       ferment completion fish > ~/.config/fish/completions/ferment.fish
  ${B}3.${R} In a project directory:
       ferment init
       ferment edit     # tweak alpha/beta
       ferment up
       ferment st

EOF
