# bash completion for ferment
# Install:
#   - Homebrew: handled by formula (bash_completion.install ...)
#   - Manual:   place at /usr/local/etc/bash_completion.d/ferment
#               or source from .bashrc

_ferment() {
  local cur prev words cword
  _init_completion 2>/dev/null || {
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  }

  local subcmds="help version init up start down stop reload restart \
    st status ls list watch mon monitor why long \
    flush pause resume reset pick edit path daemon"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$subcmds" -- "$cur") )
    return 0
  fi

  case "${COMP_WORDS[1]}" in
    flush|pause|resume|reset|why|long)
      if command -v mutagen >/dev/null 2>&1; then
        local sessions
        sessions=$(mutagen sync list --template '{{range .}}{{.Name}}
{{end}}' 2>/dev/null)
        COMPREPLY=( $(compgen -W "$sessions" -- "$cur") )
      fi
      ;;
  esac
}

complete -F _ferment ferment
