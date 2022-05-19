# Docker イメージのビルド

Rhino アプリケーションの [`Dockerfile`](../Dockerfile) と [`docker-compose.yml`](../docker-compose.yml) を作成した。
ローカルのターミナルから `docker compose build` でイメージ（`rhino-training:dev`）をビルドし、`docker compose up` で起動したら、<http://localhost:3838> で Rhino アプリへの接続が可能になる。

これは開発環境用のイメージ（[.devcontainer/docker/Dockerfile](../.devcontainer/docker/Dockerfile) 参照）とは異なり、例えばRStudio Server を含んでいない。

Rhino アプリは `testthat`、`lintr`、`rstudioapi` など開発環境でしか使わないようなパッケージを含む。
本番環境にデプロイするときはこれらを除外できると嬉しい。

npm でいう [devDependencies](https://docs.npmjs.com/specifying-dependencies-and-devdependencies-in-a-package-json-file) にあたるものとして、renv ではそうした開発用パッケージを DESCRIPTION ファイルの Imports ではなく Suggests で指定するよう推奨している（https://rstudio.github.io/renv/articles/faq.html#how-should-i-handle-development-dependencies）。

golem では開発用パッケージを Suggests に変更する作業が進められている（https://github.com/ThinkR-open/golem/issues/597）。

TODO： マルチステージビルドまたは `--mount=type=cache` の利用

---

- [🏠 プロジェクトルートへ](https://github.com/terashim/rhino-training)
- [📗 ドキュメントフォルダへ `docs/`](./)

