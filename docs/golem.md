# golem との比較

[golem](https://thinkr-open.github.io/golem/) もまた Shiny アプリケーション開発フレームワークの１つ。

## 公式の説明

<https://appsilon.github.io/rhino/articles/explanation/what-is-rhino.html> から引用：

> Rhino apps are not R packages. Rhino puts more emphasis on development tools, clean configuration and minimal boilerplate and tries to provide default solutions for typical problems and questions in these areas.

Rhino は golem と違い Shiny アプリをパッケージ化しない。
Rhino は開発ツールやクリーンな構成設定、ミニマルなひな形を用意することにより重点を置いていて、こうした領域でよくある問題に対して標準的な解決策を提示しようとしている。

## プロジェクトの構造化

golem で採用されているプロジェクト構造

[Chapter 3 Structuring Your Project | Engineering Production-Grade Shiny Apps](https://engineering-shiny.org/structuring-project.html)

- Shiny アプリをパッケージとして開発することにより、バージョニング、依存性管理、ドキュメンテーション、テストなどのプラクティスを取り入れている。
- Shiny Modules を使ってアプリをモジュールに分割する。
- `app_*`, `fct_*`, `mod_*`, `utils_*`, `*_ui_*`, `*_server_*` などの命名規約によって R 関数を分類する。

Rhino

- Rhino アプリはパッケージではない。
- 依存性管理には renv を使用する。
- バージョニングについての規約は無い。
- box はパッケージと同様に roxygen2 の文法によるドキュメンテーションをサポートしている。
- testthat でユニットテストを実行する。
- Shiny Modules を使ってアプリをモジュールに分割する。
- 同時に box によりソースをモジュール化する。

## JavaScript と CSS

（調査中）

## デプロイ

golem は RStudio Connect、ShinyApps.io、Shiny Server へのデプロイ設定ファイル生成のほか、Heroku や ShinyProxy 用の Dockerfile 生成をサポートしている。

Rhino 自体は特にデプロイに関する機能を持たないが、[`rsconnect`](https://rstudio.github.io/rsconnect/) による ShinyApps.io や RStudio Connect へのデプロイに対応している。

---

- [🏠 プロジェクトルートへ](https://github.com/terashim/rhino-training)
- [📗 ドキュメントフォルダへ `docs/`](./)
