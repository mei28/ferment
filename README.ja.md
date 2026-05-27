# ferment (日本語)

> A thin Mutagen wrapper that ferments your file changes.

[English README](README.md)

[Mutagen](https://mutagen.io) は強力ですが、毎日触るには `mutagen sync ...` /
`mutagen project ...` が長く、状態確認も読みにくいです。`ferment` は次の 3 つを
1 つにまとめます。

1. **公式の Project 機能** (`ferment.yml` / `mutagen.yml`) を前提にして、
   プロジェクトごとの設定をファイルに固定 — `cd && ferment up` だけになる
2. **短いサブコマンド** — `ferment up` / `down` / `st` / `flush`
3. **色付き 1 行ステータスサマリ** — 接続・同期状態・コンフリクト数を
   セッションごとに 1 行で表示。`ferment watch` でライブ更新

## なぜこの名前か

mutagen = 「mutation generator (変化を起こす因子)」。
ferment = 「ゆっくりとした変化 (発酵/醸成)」を起こすもの。
ファイルの変更を静かに発酵させ、複数のホストへ伝播させるラッパー、という命名です。

## インストール

優先順位は **curl → nix → brew** です。

### curl (最速)

```sh
curl -fsSL https://raw.githubusercontent.com/mei28/ferment/main/install.sh | sh
```

デフォルトでは `~/.local/bin/ferment` に入ります。設置先は `FERMENT_PREFIX`、
バージョン固定は `FERMENT_REF=v0.1.0` で上書きできます。

アンインストール:

```sh
curl -fsSL https://raw.githubusercontent.com/mei28/ferment/main/uninstall.sh | sh
```

確認プロンプトが出ます (`FERMENT_FORCE=1` でスキップ可)。バイナリと
install.sh が置いた補完だけを掃除し、Homebrew / nix 経由の場合は
`brew uninstall` / `nix profile remove` の案内を出すだけで触りません。

### nix

```sh
nix profile install github:mei28/ferment

# flake から:
# inputs.ferment.url = "github:mei28/ferment";
# home.packages = [ inputs.ferment.packages.${system}.default ];
```

### Homebrew

Formula はこのリポジトリ内 (`Formula/ferment.rb`) にあります。リポジトリ名が
`homebrew-...` ではないので、初回だけ tap URL を明示します。

```sh
brew tap mei28/ferment https://github.com/mei28/ferment.git
brew install ferment
```

以降は `brew update && brew upgrade` で更新されます。

**依存**: [mutagen](https://mutagen.io) 0.16+ (`ferment st` が使う
`--template` フラグのため)

## 5 秒チュートリアル

```sh
cd ~/projects/myproj
ferment init             # ./ferment.yml のひな形を生成
ferment edit             # alpha/beta を実環境に書き換える
ferment up               # 全 sync を起動
ferment st               # 1 行サマリ
ferment watch            # 2 秒おきに自動更新 (Ctrl-C で抜ける)
ferment flush            # 即時 flush (--all)
ferment down             # 停止
```

## `ferment st` の読み方

```
NAME                    A   B   STATUS                CFL  PRB  ALPHA <-> BETA
myproj-code             ✓   ✓   Watching for changes  0    0    .  <->  dev@host:/srv/myproj
myproj-assets           ✓   ✗   Disconnected          0    1    ./assets <-> dev@host:/srv/myproj/assets
```

- **A / B**: alpha / beta の接続状態 (✓ / ✗)
- **STATUS**: 緑=待機, 黄=反映途中, 赤=異常/一時停止
- **CFL**: コンフリクト数
- **PRB**: alpha + beta の problem 合計
- 末尾: alpha と beta の URL (どこからどこへ同期しているか即わかる)

「いま sync してるのか・止まってるのか・動きっぱなしか・反映途中か・どこからどこへ」
が 1 行で全部読めます。

## サブコマンド一覧

| コマンド | 中身 |
|---|---|
| `ferment init [name]` | `ferment.yml` のひな形を生成 |
| `ferment up` / `start` | `mutagen project start` |
| `ferment down` / `stop` | `mutagen project terminate` |
| `ferment reload` | down → up |
| `ferment st` / `status` / `ls` | 色付き 1 行サマリ |
| `ferment watch` | 2 秒ごとに更新 |
| `ferment mon` | `mutagen sync monitor` (生ストリーム) |
| `ferment why [session]` | `mutagen sync list --long` |
| `ferment flush [session]` | flush (省略時 `--all`) |
| `ferment pause / resume / reset` | 同上 |
| `ferment pick` | fzf でセッション 1 件選択 |
| `ferment edit` | `$EDITOR` で project ファイル |
| `ferment path` | project ファイルの絶対パス |
| `ferment daemon` | `mutagen daemon status` |
| `ferment completion <shell>` | `bash` / `zsh` / `fish` の補完スクリプトを出力 |

### グローバルフラグ

- `-v`, `--verbose` — 実行する `mutagen` のコマンドラインを 1 行だけ
  先に表示します。サブコマンドの前後どちらでも置けます。

  ```sh
  ferment -v flush
  ferment flush --verbose
  ```

  出力例:

  ```
  $ mutagen sync flush --all
  ✓ flush all sessions
  ```

## シェル補完

`ferment` は bash / zsh / fish の補完スクリプトを内蔵しています。
インストーラが自動で配置しますが、後から差し替えるときは:

```sh
# bash
ferment completion bash > ~/.local/share/bash-completion/completions/ferment

# zsh — $fpath 配下に置いて compinit を再実行
ferment completion zsh > "${fpath[1]}/_ferment"

# fish
ferment completion fish > ~/.config/fish/completions/ferment.fish
```

補完されるもの: サブコマンド、`-v` / `--help` / `--version` などの
グローバルフラグ、`ferment completion` の引数 (`bash` / `zsh` / `fish`)、
`flush` / `pause` / `resume` / `reset` / `mon` / `why` でのセッション名
(mutagen が稼働中であれば動的に取得)。

## direnv 連携

```sh
# プロジェクトの .envrc
if [ -f ferment.yml ] || [ -f mutagen.yml ]; then
  ferment up 2>/dev/null || true
fi
```

`direnv allow` してから `cd` で自動 up。**自動 down はオススメしません**
(cd で抜けるたびに sync が止まると事故るため)。停止は明示的に `ferment down`。

## 開発

```sh
just                     # レシピ一覧
just lint                # bash -n + shellcheck
just test                # bats による統合テスト
just smoke               # スタブ環境で動作確認
just regen-completions   # bin/ferment 内の補完を completions/ に書き出す
just release-prep        # リリース手順の表示
```

`completions/` 配下のファイルは生成物です。補完ロジックを直すときは
`bin/ferment` の `cmd_completion` 内の heredoc を編集し、
`just regen-completions` で再生成してください。

## ライセンス

MIT
