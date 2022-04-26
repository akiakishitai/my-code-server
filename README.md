# My Code-Server

A 'code-server' docker container configured for personal use.

## Usage

### Prepare

1. Build rust tools

    ```bash
    podman build \
      --tag util-tools \
      --file docker/Dockerfile.build.rust docker/
    ```

1. Copy built tools to volume

    ```bash
    CODESERVER_APP=coder-app
    podman run --rm \
      -v $CODESERVER_APP:/cli \
      localhost/util-tools
    ```

### Run

```bash
podman play kube code-server-pod.yml --configmap secrets.conf.yml
```

The `secrets.conf.yml` file example:

```yaml
# secrets.conf.yml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: code-server-config
data:
  password: mypassword
```

## Tools

### Environment variables

- `$VOLTA_HOME`
  - /app/local/volta
- `$CARGO_HOME`
  - /app/local/cargo
- `$RUSTUP_HOME`
  - /app/local/rustup
- `$FLUTTER_HOME`
  - /app/local/flutter
- `$PATH`
  - /app/local/bin:/app/local/flutter/bin:/app/local/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

### コンテナ起動時にインストール開始

[linuxserver/code-server](https://github.com/linuxserver/docker-code-server) イメージのバージョンアップへ簡単に追従させたいので、上記をカスタマイズした _Docker_ イメージは作成しない。
代わりに `s6-overlay` の初期化処理を利用して、コンテナ起動時に `/app/local/bin` 以下へ下記ツール群をインストールするようにしている。

`/app/local` を _volume_ マウントしておけば 2 回目からはインストール処理が行われず、コンテナが起動するまでの時間が短縮できる。

- [`fish shell`](https://fishshell.com) : _fish is a smart and user-friendly command line shell for Linux, macOS, and the rest of the family._

- [`peco`](https://github.com/peco/peco) : _Simplistic interactive filtering tool_

- [`gdu`](https://github.com/dundee/gdu) : _Pretty fast disk usage analyzer written in Go ([ncdu](https://dev.yorhel.nl/ncdu)-like)._

- [`Nerd Fonts`](https://www.nerdfonts.com) : _Install the powerline font 'Sauce Code Pro Nerd Font'._

- [`ytt`](https://github.com/vmware-tanzu/carvel-ytt) : _YAML templating tool that works on YAML structure instead of text_

  - Use to generate YAML files of _GitHub Actions Workflow_ .

- [`powerline-go`](https://github.com/justjanne/powerline-go) : _A beautiful and useful low-latency prompt for your shell, written in go_

- [`ghq`](https://github.com/x-motemen/ghq) : _Remote repository management made easy_

- [`pet`](https://github.com/knqyf263/pet) : _Simple command-line snippet manager, written in Go._

- [`hyperfine`](https://github.com/sharkdp/hyperfine) : _A command-line benchmarking tool_

- [`fd`](https://github.com/sharkdp/fd) : _A simple, fast and user-friendly alternative to 'find'_

- [`tldr`](https://github.com/tldr-pages/tldr) : _📚 Collaborative cheatsheets for console commands_
  - [`tealdeer`](https://dbrgn.github.io/tealdeer/) : _A very fast implementation of tldr in Rust._

#### Flutter

サイズが大きすぎるので自動インストールは行わない。
必要ツール（`unzip`, `xz-utils`, `zip`, `libglu1-mesa`）についてはインストールする。

### Pre-Compile rust tools

- [`exa`](https://github.com/ogham/exa) : _A modern replacement for ‘ls’._
- [`git-interactive-rebase-tool`](https://github.com/MitMaro/git-interactive-rebase-tool) : _Native cross-platform full feature terminal-based sequence editor for git interactive rebase._
  - binary name is `interactive-rebase-tool` .
- [`volta`](https://github.com/volta-cli/volta) : _The Hassle-Free JavaScript Tool Manager._

---

1. Build image for building rust tools

    ```bash
    podman build \
      --tag build-musl-rust \
      --file docker/Dockerfile.build.rust \
      docker/
    ```

1. Build rust tools

    ```bash
    ./build-rust.sh
    ```
