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
