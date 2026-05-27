# ferment — task runner (just)
# https://github.com/casey/just
#
# Usage: `just`, `just lint`, `just smoke`, ...

# Extract VERSION from the bin/ferment script
version := `grep -E '^VERSION=' bin/ferment | head -1 | cut -d'"' -f2`

# Default recipe: list available recipes
default:
    @just --list

# Syntax-check bash and run shellcheck (warnings or above)
lint:
    bash -n bin/ferment install.sh uninstall.sh
    @if command -v shellcheck >/dev/null; then \
        shellcheck -S warning bin/ferment install.sh uninstall.sh; \
    else \
        echo "shellcheck not installed (brew install shellcheck)"; \
    fi

# Run bats integration tests (if present)
test:
    @if [ -d test ]; then \
        bats test; \
    else \
        echo "no test/ directory yet"; \
    fi

# Smoke test: stub mutagen and run a handful of subcommands
smoke:
    @mkdir -p .stub
    @printf '#!/usr/bin/env bash\necho "mutagen-stub: $@"\n' > .stub/mutagen
    @chmod +x .stub/mutagen
    @PATH="$(pwd)/.stub:$PATH" ./bin/ferment version
    @PATH="$(pwd)/.stub:$PATH" ./bin/ferment help > /dev/null && echo "✓ help"
    @PATH="$(pwd)/.stub:$PATH" ./bin/ferment unknown 2>&1 | grep -q "unknown subcommand" && echo "✓ unknown subcommand handled"
    @PATH="$(pwd)/.stub:$PATH" ./bin/ferment flush > /dev/null && echo "✓ flush --all"
    @PATH="$(pwd)/.stub:$PATH" ./bin/ferment -v flush 2>&1 | grep -q 'mutagen sync flush --all' && echo "✓ -v traces commands"
    @./bin/ferment completion bash | grep -q '^complete -F _ferment ferment' && echo "✓ completion bash"
    @./bin/ferment completion zsh  | grep -q '^#compdef ferment'             && echo "✓ completion zsh"
    @./bin/ferment completion fish | grep -q '^complete -c ferment'          && echo "✓ completion fish"
    @rm -rf .stub

# Regenerate static completion files from the source of truth (bin/ferment).
# Run after editing the embedded completion heredocs.
regen-completions:
    ./bin/ferment completion bash > completions/ferment.bash
    ./bin/ferment completion zsh  > completions/_ferment
    ./bin/ferment completion fish > completions/ferment.fish
    @echo "✓ regenerated completions/"

# Print the release-prep checklist for the current VERSION
release-prep:
    @echo "Version detected: {{version}}"
    @echo ""
    @echo "Release steps:"
    @echo "  1. Update CHANGELOG.md"
    @echo "  2. git commit -am 'release: v{{version}}'"
    @echo "  3. git tag -a v{{version}} -m 'v{{version}}'"
    @echo "  4. git push --tags  (release.yml will auto-create the GitHub Release"
    @echo "                       and commit a Formula bump on main)"
    @echo ""
    @echo "Manual sha256 (if needed):"
    @echo "  curl -L https://github.com/mei28/ferment/archive/refs/tags/v{{version}}.tar.gz \\"
    @echo "    | shasum -a 256"

# Locally install a Homebrew formula bump (after a release).
# Use this to dry-run the formula before pushing.
formula-test:
    brew install --build-from-source ./Formula/ferment.rb
    brew test ferment
    brew audit --strict --new ferment

# Build the nix flake locally
nix-build:
    nix build .#

# Remove ephemeral build/test artifacts
clean:
    rm -rf .stub result result-*
