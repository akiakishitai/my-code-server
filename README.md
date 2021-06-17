# My Code-Server

A 'code-server' docker container configured for personal use.

## コンテナ起動時にインストール開始

_Docker_ イメージサイズが巨大になるのを避けるため、下記ツールはイメージに含まない。
代わりに `s6-overlay` の初期化処理を利用して、コンテナ起動時に `/app` 以下へインストールするようにしている。

`/app` を _volume_ マウントしておけば 2 回目からはインストール処理が行われず、コンテナが起動するまでの時間が短縮できる。

- `volta`
  _Node_ のバージョン管理ツール。
  `$VOLTA_HOME` -> `/app/volta`

- `rustup`
  _Rust_ バージョン管理。
  `$RUSTUP_HOME` -> `/app/rustup`
  `$CARGO_HOME` -> `/app/cargo`

上記ツールへの `PATH` は設定済み。

### Flutter

サイズが大きすぎるので自動インストールは行わない。
ただし、必要ツールや環境変数 `PATH` への登録は設定済み。

マウントポイントとして `/app/flutter` ディレクトリを用意しているので、必要に応じてマウントする。

## Development Tools

- [`ytt`](https://github.com/vmware-tanzu/carvel-ytt) : _YAML templating tool that works on YAML structure instead of text_

  - Use to generate YAML files of _GitHub Actions Workflow_ .

- [`fish shell`](https://fishshell.com) : _fish is a smart and user-friendly command line shell for Linux, macOS, and the rest of the family._

- [`powerline-go`](https://github.com/justjanne/powerline-go) : _A beautiful and useful low-latency prompt for your shell, written in go_

- [`peco`](https://github.com/peco/peco) : _Simplistic interactive filtering tool_

- [`ghq`](https://github.com/x-motemen/ghq) : _Remote repository management made easy_

- CLI
  - [`ncdu`](https://dev.yorhel.nl/ncdu) : _Ncdu is a disk usage analyzer with an ncurses interface_
  - [`tldr`](https://github.com/tldr-pages/tldr) : _📚 Collaborative cheatsheets for console commands_
