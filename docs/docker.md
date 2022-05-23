# Docker イメージのビルド

Rhino アプリケーションの [`Dockerfile`](../Dockerfile) と [`docker-compose.yml`](../docker-compose.yml) を作成した。
ローカルのターミナルから `docker compose build` でイメージをビルドし、`docker compose up` で起動したら、<http://localhost:3838> で Rhino アプリへの接続が可能になる。

これは開発環境用のイメージ（[.devcontainer/docker/Dockerfile](../.devcontainer/docker/Dockerfile) 参照）とは異なり、例えばRStudio Server を含んでいない。

### 開発環境の依存関係

Rhino アプリは `testthat`、`lintr`、`rstudioapi` など開発環境でしか使わないようなパッケージを含む。
本番環境にデプロイするときはこれらを除外できると嬉しい。

npm でいう [devDependencies](https://docs.npmjs.com/specifying-dependencies-and-devdependencies-in-a-package-json-file) にあたるものとして、renv ではそうした開発用パッケージを DESCRIPTION ファイルの Imports ではなく Suggests で指定するよう推奨している（<https://rstudio.github.io/renv/articles/faq.html#how-should-i-handle-development-dependencies>）。

golem では開発用パッケージを Suggests に変更する作業が進められている（<https://github.com/ThinkR-open/golem/issues/597>）。
いまのところ Rhino でそのような動きは見られない。

### マルチステージビルド

マルチステージビルドを利用することで、本番環境では不要な
`app/js/`、`app/styles/`、`.rhino/`
などのファイルを最終イメージから除外した。

### `RUN --mount=type=cache` による高速化

BuildKit の
[`RUN --mount=type=cache`](https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/syntax.md#run---mounttypecache)
を利用することによって、APT、renv、yarn のパッケージインストールでキャッシュが効くようになった。

例えば renv では次のように `/root/.cache` フォルダをマウントしている。

```dockerfile
RUN \
  --mount=type=cache,target=/root/.cache \
  Rscript -e "renv::restore(library = '/usr/local/lib/R/site-library')"
```

---

- [🏠 プロジェクトルートへ](https://github.com/terashim/rhino-training)
- [📗 ドキュメントフォルダへ `docs/`](./)

