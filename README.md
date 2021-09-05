# My Code-Server

A 'code-server' docker container configured for personal use.

## Build

```bash
docker compose build
docker compose up -d
```

### Podman

_Podman_ でビルドする場合、`TARGETARCH` などの自動設定される変数は、明示的にグローバル宣言する必要がある（が `Docker` ではグローバル宣言するとうまくいかない）。
そのため `sed` コマンドにて _Dockerfile_ に挿入してビルドする。

```bash
sed -e '1i ARG TARGETARCH' ./docker/Dockerfile | \
  podman build \
    --layers \
    --tag localhost/code-server:3.10.2 \
    --platform="linux/arm64" \
    --format docker \
    --file - \
    docker
```

```bash
# raw podman cli
env CODE_SERVER_VERSION=3.10.2 PASSWORD=abcd1234 ./podman-cmd.sh

# or, use Kubernetes YAML
podman play kube code-server-pod.yml --configmap secrets-configmap.yml
```

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

- [`git-interactive-rebase-tool`](https://github.com/MitMaro/git-interactive-rebase-tool) : _Native cross-platform full feature terminal-based sequence editor for git interactive rebase._

  - binary name is `interactive-rebase-tool` .

- [`pet`](https://github.com/knqyf263/pet) : _Simple command-line snippet manager, written in Go._

- [`hyperfine`](https://github.com/sharkdp/hyperfine) : _A command-line benchmarking tool_

- [`Nerd Fonts`](https://www.nerdfonts.com) (RobotoMono)

- CLI
  - [`exa`](https://github.com/ogham/exa) : _A modern replacement for ‘ls’._
  - [`fd`](https://github.com/sharkdp/fd) : _A simple, fast and user-friendly alternative to 'find'_
  - [`ncdu`](https://dev.yorhel.nl/ncdu) : _Ncdu is a disk usage analyzer with an ncurses interface_
  - [`tldr`](https://github.com/tldr-pages/tldr) : _📚 Collaborative cheatsheets for console commands_
    - [`tealdeer`](https://dbrgn.github.io/tealdeer/) : _A very fast implementation of tldr in Rust._
