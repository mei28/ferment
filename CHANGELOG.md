# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/) and
the project tries to follow [SemVer](https://semver.org/).

## [Unreleased]

_Nothing yet._

## [0.1.0] - 2026-05-26

Initial release.

### Added
- `ferment` CLI with subcommands: `init`, `up`, `down`, `reload`, `st`,
  `watch`, `mon`, `why`, `flush`, `pause`, `resume`, `reset`, `pick`,
  `edit`, `path`, `daemon`.
- Color-coded one-line status summary (`st`) using `mutagen sync list --template`,
  with a transparent fallback for mutagen < 0.16.
- Live status refresh (`watch`).
- Project file template generator (`init`); accepts both `ferment.yml`
  (preferred) and `mutagen.yml`.
- Shell completions for zsh / bash / fish.
- `install.sh` curl installer, Nix flake (`flake.nix`), and Homebrew
  formula (`Formula/ferment.rb`, single-repo tap layout).
- `justfile` task runner (`lint` / `test` / `smoke` / `release-prep`).
- bats integration suite (`test/*.bats`, 28 cases) covering help/version,
  `init` idempotency, alias dispatch, project-file discovery, and the
  `cmd_st` template fallback path.
- CI lint workflow running `bash -n`, shellcheck, bats, and smoke.

[Unreleased]: https://github.com/mei28/ferment/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/mei28/ferment/releases/tag/v0.1.0
