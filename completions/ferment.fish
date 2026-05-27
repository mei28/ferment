# fish completion for ferment
# Install:
#   ferment completion fish > ~/.config/fish/completions/ferment.fish

complete -c ferment -f

# Global flags (available before subcommand)
complete -c ferment -s v -l verbose -d "Print mutagen commands as they run"
complete -c ferment -s h -l help    -d "Show help"
complete -c ferment -s V -l version -d "Show version"

# Subcommand suggestions when none seen yet
complete -c ferment -n "__fish_use_subcommand" -a help       -d "show help"
complete -c ferment -n "__fish_use_subcommand" -a version    -d "show version"
complete -c ferment -n "__fish_use_subcommand" -a init       -d "create ferment.yml template"
complete -c ferment -n "__fish_use_subcommand" -a up         -d "start project"
complete -c ferment -n "__fish_use_subcommand" -a down       -d "terminate project"
complete -c ferment -n "__fish_use_subcommand" -a reload     -d "down then up"
complete -c ferment -n "__fish_use_subcommand" -a st         -d "1-line status summary"
complete -c ferment -n "__fish_use_subcommand" -a watch      -d "live st (2s refresh)"
complete -c ferment -n "__fish_use_subcommand" -a mon        -d "mutagen sync monitor"
complete -c ferment -n "__fish_use_subcommand" -a why        -d "per-session details"
complete -c ferment -n "__fish_use_subcommand" -a flush      -d "flush sessions"
complete -c ferment -n "__fish_use_subcommand" -a pause      -d "pause sessions"
complete -c ferment -n "__fish_use_subcommand" -a resume     -d "resume sessions"
complete -c ferment -n "__fish_use_subcommand" -a reset      -d "reset sessions"
complete -c ferment -n "__fish_use_subcommand" -a pick       -d "fzf-pick a session"
complete -c ferment -n "__fish_use_subcommand" -a edit       -d "open project file"
complete -c ferment -n "__fish_use_subcommand" -a path       -d "print project file path"
complete -c ferment -n "__fish_use_subcommand" -a daemon     -d "daemon status"
complete -c ferment -n "__fish_use_subcommand" -a completion -d "print completion script"

function __ferment_sessions
    if command -v mutagen >/dev/null
        mutagen sync list --template '{{range .}}{{.Name}}
{{end}}' 2>/dev/null
    end
end

complete -c ferment \
    -n "__fish_seen_subcommand_from flush f sync pause resume reset why long detail mon monitor" \
    -a "(__ferment_sessions)"

complete -c ferment -n "__fish_seen_subcommand_from completion" -a bash -d "Bash"
complete -c ferment -n "__fish_seen_subcommand_from completion" -a zsh  -d "Zsh"
complete -c ferment -n "__fish_seen_subcommand_from completion" -a fish -d "Fish"
