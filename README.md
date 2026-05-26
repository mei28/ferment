# ferment

> A thin Mutagen wrapper that ferments your file changes.

[日本語版 README はこちら](README.ja.md)

[Mutagen](https://mutagen.io) is powerful, but the day-to-day commands
(`mutagen sync ...`, `mutagen project ...`) are long, and the raw status
output is hard to scan. `ferment` wraps that with three things:

1. **Project-file first.** Builds on top of `mutagen project` so each
   project's sync setup lives in a `ferment.yml` (or `mutagen.yml`).
   Switching projects becomes `cd && ferment up`.
2. **Short subcommands.** `ferment up` / `down` / `st` / `flush` instead
   of the long mutagen incantations.
3. **A readable, colored one-line status.** Connection state, sync state,
   conflicts and problems per session, with `ferment watch` for live updates.

## Why the name?

mutagen = "an agent that causes mutation". ferment = "an agent that causes
(slow, biological) change". A wrapper that quietly ferments your file
changes into propagation across hosts.

## Install

Three channels, in order of priority.

### curl (fastest, zero dependencies beyond curl)

```sh
curl -fsSL https://raw.githubusercontent.com/mei28/ferment/main/install.sh | sh
```

Installs to `~/.local/bin/ferment` by default. Override with
`FERMENT_PREFIX=/usr/local/bin`, or pin a version with `FERMENT_REF=v0.1.0`.

### nix

```sh
nix profile install github:mei28/ferment

# In a flake:
# inputs.ferment.url = "github:mei28/ferment";
# home.packages = [ inputs.ferment.packages.${system}.default ];
```

### Homebrew

The formula lives in this repository (single-repo layout). On first install,
tap with an explicit URL once, then install normally:

```sh
brew tap mei28/ferment https://github.com/mei28/ferment.git
brew install ferment
```

After that, `brew update && brew upgrade` keeps it fresh.

**Dependency:** [mutagen](https://mutagen.io) ≥ 0.16 (required for the
`--template` flag used by `ferment st`).

## 30-second tour

```sh
cd ~/projects/myproj
ferment init             # generate ./ferment.yml
ferment edit             # edit alpha/beta for your environment
ferment up               # start all syncs declared in the project file
ferment st               # one-line color summary
ferment watch            # live status, refreshes every 2 seconds (Ctrl-C to exit)
ferment flush            # force-flush all sessions now
ferment down             # stop everything
```

## Reading `ferment st`

```
NAME                    A   B   STATUS                CFL  PRB  ALPHA <-> BETA
myproj-code             ✓   ✓   Watching for changes  0    0    .  <->  dev@host:/srv/myproj
myproj-assets           ✓   ✗   Disconnected          0    1    ./assets <-> dev@host:/srv/myproj/assets
```

- **A / B**: connection state of alpha / beta (✓ connected, ✗ disconnected)
- **STATUS**: green = idle/watching, yellow = transferring, red = paused/halted/disconnected
- **CFL**: number of conflicts
- **PRB**: alpha + beta problem count
- **trailing columns**: alpha URL `<->` beta URL — at a glance, what is syncing where

## Subcommand reference

| Command | What it does |
|---|---|
| `ferment init [name]` | generate a `ferment.yml` template |
| `ferment up` / `start` | `mutagen project start` |
| `ferment down` / `stop` | `mutagen project terminate` |
| `ferment reload` | `down` then `up` |
| `ferment st` / `status` / `ls` | colored one-line summary |
| `ferment watch` | re-render `st` every 2 seconds |
| `ferment mon` | raw `mutagen sync monitor` stream |
| `ferment why [session]` | per-session detail (`mutagen sync list --long`) |
| `ferment flush [session]` | flush (defaults to `--all`) |
| `ferment pause` / `resume` / `reset` | same shape as `flush` |
| `ferment pick` | fzf-pick a session name and print it to stdout |
| `ferment edit` | open project file in `$EDITOR` |
| `ferment path` | print absolute path of the project file |
| `ferment daemon` | `mutagen daemon status` |

## direnv integration

Auto-start the project when entering its directory:

```sh
# .envrc
if [ -f ferment.yml ] || [ -f mutagen.yml ]; then
  ferment up 2>/dev/null || true
fi
```

After `direnv allow`, `cd`'ing into the project starts it automatically.
**Don't auto-`down`** — it tends to kill long-running syncs you wanted to
keep alive. Stop deliberately with `ferment down`.

## Development

```sh
just                # list recipes
just lint           # bash -n + shellcheck
just smoke          # stub mutagen, run a handful of subcommands
just release-prep   # print the release checklist for the current version
```

## License

MIT
