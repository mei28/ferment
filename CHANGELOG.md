# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/) and
the project tries to follow [SemVer](https://semver.org/).

## [Unreleased]

### Added
- bats integration test suite (`test/*.bats`) covering help/version, `init`
  behaviour, alias dispatch, and `cmd_st` template parsing (incl. the
  pre-0.16 fallback path).

### Changed
- CI `smoke` job now runs `just smoke` instead of the non-existent
  `make smoke` (SPEC §8.2 already specified `just`).

### Fixed
- shellcheck warnings in `bin/ferment`: dropped unused `C_MAGENTA`
  (SC2034) and the redundant `*Watching*` branch shadowed by `*atching*`
  (SC2221 / SC2222).
- Homebrew formula no longer references `docs/SPEC*.md`, which are
  intentionally `.gitignore`d and therefore absent from release tarballs.
- README links to internal-only `docs/SPEC*` removed for the same reason.

## [0.1.0] - TBD

Initial release.

### Added
- `ferment` CLI with subcommands: `init`, `up`, `down`, `reload`, `st`,
  `watch`, `mon`, `why`, `flush`, `pause`, `resume`, `reset`, `pick`,
  `edit`, `path`, `daemon`.
- Color-coded one-line status summary (`st`) using `mutagen sync list --template`.
- Live status refresh (`watch`).
- Project file template generator (`init`).
- Acceptance of both `ferment.yml` (preferred) and `mutagen.yml`.
- Shell completions for zsh / bash / fish.
- `install.sh` curl installer.
- Nix flake (`flake.nix`).
- Homebrew formula (`Formula/ferment.rb`, single-repo tap layout).
- `justfile` task runner.

[Unreleased]: https://github.com/mei28/ferment/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/mei28/ferment/releases/tag/v0.1.0
