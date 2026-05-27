# bash completion for ferment
# Install:
#   ferment completion bash > ~/.local/share/bash-completion/completions/ferment
# or
#   source <(ferment completion bash)

_ferment() {
  local cur prev words cword
  if declare -F _init_completion >/dev/null 2>&1; then
    _init_completion || return
  else
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")
    cword=$COMP_CWORD
  fi

  local subcmds="help version init up down reload st watch mon why \
flush pause resume reset pick edit path daemon completion"
  local global_flags="-v --verbose -h --help -V --version"

  # Walk all words before the cursor and pick the first non-flag token as
  # the subcommand. This makes `-v` etc. positionally independent.
  local sub="" i
  for (( i=1; i<cword; i++ )); do
    case "${words[i]}" in
      -v|--verbose|-h|--help|-V|--version) continue ;;
      -*) continue ;;
      *) sub="${words[i]}"; break ;;
    esac
  done

  if [ -z "$sub" ]; then
    case "$cur" in
      -*) COMPREPLY=( $(compgen -W "$global_flags" -- "$cur") ) ;;
      *)  COMPREPLY=( $(compgen -W "$subcmds" -- "$cur") ) ;;
    esac
    return 0
  fi

  case "$sub" in
    flush|f|sync|pause|resume|reset|why|long|detail|mon|monitor)
      if command -v mutagen >/dev/null 2>&1; then
        local sessions
        sessions=$(mutagen sync list --template '{{range .}}{{.Name}}
{{end}}' 2>/dev/null)
        COMPREPLY=( $(compgen -W "$sessions" -- "$cur") )
      fi
      ;;
    completion)
      COMPREPLY=( $(compgen -W "bash zsh fish" -- "$cur") )
      ;;
  esac
}

complete -F _ferment ferment
