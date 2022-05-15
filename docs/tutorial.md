# チュートリアルノート

公式のチュートリアル <https://appsilon.github.io/rhino/articles/tutorial/create-your-first-rhino-app.html>
を進めながら適宜補足やメモを追加.

## 前提条件

このチュートリアルでは

- R 4.1 で導入されたネイティブパイプ演算子 `|>`
- Node.js と Yarn

を使用する.

💡 [`.devcontainer`](../.devcontainer) で R 4.2, Node.js, Yarn の入った Docker 環境を作成した.

## 新規プロジェクト作成

⚡️ `rhino::init()` を使うか, RStudio のプロジェクト作成ボタンから "Shiny Application using rhino" のプロジェクトタイプを選ぶ.

☘️ 次のようなファイル構成のプロジェクトが生成される

```
.
├── app
│   ├── js
│   │   └── index.js
│   ├── logic
│   │   └── __init__.R
│   ├── static
│   │   └── favicon.ico
│   ├── styles
│   │   └── main.scss
│   ├── view
│   │   └── __init__.R
│   └── main.R
├── tests
│   ├── cypress
│   │   └── integration
│   │       └── app.spec.js
│   ├── testthat
│   │   └── test-main.R
│   └── cypress.json
├── app.R
├── RhinoApplication.Rproj
├── dependencies.R
├── renv.lock
└── rhino.yml
```

とくに, `app/main.R` は初期状態でこのようになっている

📄 `app/main.R`

```r
# app/main.R

box::use(
  shiny[bootstrapPage, moduleServer, NS, renderText, tags, textOutput],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  bootstrapPage(
    tags$h3(
      textOutput(ns("message"))
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$message <- renderText("Hello!")
  })
}
```

## Shinyアプリの起動方法

⚡️ Rコンソールで

```r
shiny::shinyAppDir(".")
```

のコマンドを実行すると開発中の Shiny アプリが開く.

## モジュールの追加

### モジュールの作成

📄 `app/view/chart.R`

```r
# app/view/chart.R

box::use(
  shiny[moduleServer, NS, h3]
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  h3("Chart")
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    print("Chart module server part works!")
  })
}
```

### モジュールの呼び出し

定義したモジュール `app/view/chart` を `app/main.R` から呼び出して使う

📄 `app/main.R`

```diff
 # app/main.R
 
 box::use(
-  shiny[bootstrapPage, moduleServer, NS, renderText, tags, textOutput],
+  shiny[bootstrapPage, moduleServer, NS],
 )
 
+box::use(
+  app/view/chart
+)
+
 #' @export
 ui <- function(id) {
   ns <- NS(id)
   bootstrapPage(
-    tags$h3(
-      textOutput(ns("message"))
-    )
+    chart$ui(ns("chart"))
   )
 }
 
 #' @export
 server <- function(id) {
   moduleServer(id, function(input, output, session) {
-    output$message <- renderText("Hello!")
+    chart$server("chart")
   })
 }
```

⚡️ ここでまた `shiny::shinyAppDir(".")` でアプリを再起動して変化を確認.

☘️ chart の文字が表示される

### 📝 box について

- `app/view/chart.R` は box モジュール `app/view/chart` を定義している.
- box のモジュール定義については <https://klmr.me/box/articles/box.html#writing-modules-1> を参照のこと.
- `box::use()` はモジュールのインポートを行う関数. Python の `import` に相当.
- モジュール定義内で `box::use()` を使ったときは, そのモジュール内のみに影響する <https://klmr.me/box/reference/use.html#import-semantics>

### 📝 Shiny modules について

Shiny - Modularizing Shiny app code
<https://shiny.rstudio.com/articles/modules.html>

日本語の解説記事:
「ShinyModule」で中規模Shinyアプリをキレイにする - Dimension Planet Adventure 最終章 最終話『栄光なる未来』
<https://ksmzn.hatenablog.com/entry/shiny-module>

Shiny 1.5.0 以降, `callModule` ではなく `moduleServer` を使うのが推奨になった.
（文法が少しわかりやすくなったのと, `testServer` でテストできるようになった）.
<https://shiny.rstudio.com/reference/shiny/1.7.0/moduleServer.html>

## コンポーネントの追加

### パッケージの追加

⚡️ パッケージをインストールする:

```r
# Rのコンソールで実行
renv::install("echarts4r")
renv::install("reactable")
renv::install("tidyr")
renv::install("dplyr")
renv::install("htmlwidgets")
```

使用したいパッケージを `dependencies.R` ファイルに書き下す:

📄 `dependencies.R`

```r
# dependencies.R

# This file allows packrat (used by rsconnect during deployment) to pick up dependencies.
library(rhino)
library(echarts4r)
library(reactable)
library(tidyr)
library(dplyr)
library(htmlwidgets)
```

`rsconnect` でデプロイするとき、使用するパッケージを `packrat` に教えるためこのようにしている。`.renvignore` の設定により、`renv` もこのファイルを見て対象パッケージを判定するようになっている。

（感想：できれば DESCRIPTION ファイルと Explicit なスナップショット <https://rstudio.github.io/renv/articles/renv.html#explicit-snapshots> を使いたい）

⚡️ バージョン固定のため `renv.lock` ファイルを更新する:

```r
# Rコンソールで実行
renv::snapshot()
```

### モジュールへ依存関係を追加

追加したパッケージ `echarts4r` をモジュール `app/view/chart.R` からロードして使う.

📄 `app/view/chart.R`

```diff
 # app/view/chart.R
 
 box::use(
-  shiny[moduleServer, NS, h3]
+  shiny[moduleServer, NS, h3, tagList],
+  echarts4r,
 )
 
 #' @export
 ui <- function(id) {
   ns <- NS(id)
   
-  h3("Chart")
+  tagList(
+    h3("Chart"),
+    echarts4r$echarts4rOutput(ns("chart"))
+  )
 }
 
 #' @export
 server <- function(id) {
   moduleServer(id, function(input, output, session) {
-    print("Chart module server part works!")
+    output$chart <- echarts4r$renderEcharts4r(
+      rhino::rhinos |>
+        echarts4r$group_by(Species) |>
+        echarts4r$e_chart(x = Year) |>
+        echarts4r$e_line(Population) |>
+        echarts4r$e_x_axis(Year) |>
+        echarts4r$e_tooltip()
+    )
   })
 }
```

⚡️ アプリを再起動する: `shiny::shinyAppDir(".")`

☘️ グラフ表示が追加されている

### 📝 echarts4r について

<https://echarts4r.john-coene.com/>

R から JS のデータ可視化ライブラリ Apache Echarts <https://echarts.apache.org/en/index.html> を使ったウィジェットを生成できる.
パイプ演算子と相性の良い文法になっている.

<https://echarts4r.john-coene.com/articles/chart_types.html>
などのページから対応しているグラフの種類が確認できる.

### 📝  rsconnect について

[rsconnect](https://rstudio.github.io/rsconnect/index.html) は開発した Shiny アプリを
[shinyapps.io](https://www.shinyapps.io/) や [RStudio Connect](https://www.rstudio.com/products/connect/)
にデプロイするためのパッケージ.

`rsconnect` はデプロイ時に `packrat` でソースコードを解析して必要な依存関係を判断する.
代わりに `renv.lock` を使うようにできないかという Issue は立てられているが, 優先度は低い様子.

[Are there plans for rsconnect::deployApp to support using renv.lock instead of detecting dependencies from source? · Issue #404 · rstudio/rsconnect](https://github.com/rstudio/rsconnect/issues/404)

## 第２のモジュールを追加

テーブル表示のための新しいモジュールを定義する.

📄 `app/view/table.R`

```r
# app/view/table.R

box::use(
  shiny[moduleServer, NS, h3, tagList],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  tagList(
    h3("Table")
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {

  })
}
```

そのモジュールを `app/main.R` から呼び出す

📄 `app/main.R`

```diff
 # app/main.R
 
 box::use(
   shiny[bootstrapPage, moduleServer, NS],
 )
 
 box::use(
-  app/view/chart
+  app/view/chart,
+  app/view/table
 )
 
 #' @export
 ui <- function(id) {
   ns <- NS(id)
 
   bootstrapPage(
+    table$ui(ns("table")),
     chart$ui(ns("chart"))
   )
 }
 
 #' @export
 server <- function(id) {
   moduleServer(id, function(input, output, session) {
+    table$server("table")
     chart$server("chart")
   })
 }
```

⚡️ またアプリを再起動する

☘️ この時点で空の Table セクションが追加されていることを確認.

### ２つのモジュールから共通のデータセットを使う

データを共通化するため、`table` と `chart` の両モジュールの外から引数で渡すようにする

📄 `app/main.R`

```diff
 # app/main.R
 
 box::use(
   shiny[bootstrapPage, moduleServer, NS],
 )
 
 box::use(
   app/view/chart,
   app/view/table
 )
 
 #' @export
 ui <- function(id) {
   ns <- NS(id)
 
   bootstrapPage(
     table$ui(ns("table")),
     chart$ui(ns("chart"))
   )
 }
 
 #' @export
 server <- function(id) {
   moduleServer(id, function(input, output, session) {
+    # Datasets are the only case when you need to use :: in `box`.
+    # This issue should be solved in the next `box` release.
+    data <- rhino::rhinos
+
-    table$server("table")
-    chart$server("chart")
+    table$server("table", data = data)
+    chart$server("chart", data = data)
   })
 }
```

モジュール `app/view/chart.R` はデータを引数で受け取るように修正

📄 `app/view/chart.R`

```diff
 # app/view/chart.R
 
 box::use(
   shiny[moduleServer, NS, h3, tagList],
   echarts4r
 )
 
 #' @export
 ui <- function(id) {
   ns <- NS(id)
 
   tagList(
     h3("Chart"),
     echarts4r$echarts4rOutput(ns("chart"))
   )
 }
 
 #' @export
-server <- function(id) {
+server <- function(id, data) {
   moduleServer(id, function(input, output, session) {
     output$chart <- echarts4r$renderEcharts4r(
-      rhino::rhinos |>
+      data |>
         echarts4r$group_by(Species) |>
         echarts4r$e_chart(x = Year) |>
         echarts4r$e_line(Population) |>
         echarts4r$e_x_axis(Year) |>
         echarts4r$e_tooltip()
     )
   })
 }
```

（メモ： 動的に変化するデータをモジュール間で共有したい場合は reactive にする必要があるかも）

### テーブルを作る

テーブルのほうは `reactable` パッケージを使って実装する

📄 `app/view/table.R`

```r
# app/view/table.R

box::use(
  shiny[moduleServer, NS, h3, tagList],
  reactable,
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  tagList(
    h3("Table"),
    reactable$reactableOutput(ns("table"))
  )
}

#' @export
server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$table <- reactable$renderReactable(
      reactable$reactable(data)
    )
  })
}
```

⚡️ アプリを再起動する: `shiny::shinyAppDir(".")`

☘️ テーブルが表示されている

## ロジックの追加

テーブル表示の前にデータ変換を行いたい.

新しいモジュールを作成

📄 `app/logic/data_transformation.R`

```r
# app/logic/data_transformation.R

box::use(
  tidyr[pivot_wider]
)

#' @export
transform_data <- function(data) {
  pivot_wider(
    data = data,
    names_from = Species,
    values_from = Population
  )
}
```

このモジュールを `app/view/table.R` からロードして使う

📄 `app/view/table.R`

```diff
 # app/view/table.R
 
 box::use(
   shiny[moduleServer, NS, h3, tagList],
   reactable,
 )
 
+box::use(
+  app/logic/data_transformation[transform_data]
+)
+
 #' @export
 ui <- function(id) {
   ns <- NS(id)
   
   tagList(
     h3("Table"),
     reactable$reactableOutput(ns("table"))
   )
 }
 
 #' @export
 server <- function(id, data) {
   moduleServer(id, function(input, output, session) {
     output$table <- reactable$renderReactable(
-      reactable$reactable(data)
+      data |>
+        transform_data() |>
+        reactable$reactable()
     )
   })
 }
```

⚡️ アプリを再起動する: `shiny::shinyAppDir(".")`

☘️ テーブルが横持ちに変わっている

データ変換ロジックのモジュール `app/logic/data_transformation.R` を修正する

📄 `app/logic/data_transformation.R`

```diff
 # app/logic/data_transformation.R
 
 box::use(
   tidyr[pivot_wider],
+  dplyr[arrange]
 )
 
 #' @export
 transform_data <- function(data) {
   pivot_wider(
     data = data,
     names_from = Species,
     values_from = Population
-  )
+  ) |>
+    arrange(Year)
 }
```

⚡️ アプリを再起動する: `shiny::shinyAppDir(".")`

☘️ データの並び替えがテーブルに反映されている

グラフのX軸ラベルを修正したい（年にカンマが入っているのはおかしい）
-> 新しいモジュール `app/logic/chart_utils.R` を作成

📄 `app/logic/chart_utils.R`

```r
# app/logic/chart_utils.R

box::use(
  htmlwidgets[JS]
)

#' @export
label_formatter <- JS(
  "function(value, index){
    return value;
  }"
)
```

フォーマッタ関数 `label_formatter` を定義した.

それを `app/view/chart.R` モジュールからロードして使用

📄 `app/view/chart.R`

```diff
 # app/view/chart.R
 
 box::use(
   shiny[moduleServer, NS, h3, tagList],
   echarts4r
 )
 
+box::use(
+  app/logic/chart_utils[label_formatter]
+)
+
 #' @export
 ui <- function(id) {
   ns <- NS(id)
 
   tagList(
     h3("Chart"),
     echarts4r$echarts4rOutput(ns("chart"))
   )
 }
 
 #' @export
 server <- function(id, data) {
   moduleServer(id, function(input, output, session) {
     output$chart <- echarts4r$renderEcharts4r(
       data |>
         echarts4r$group_by(Species) |>
         echarts4r$e_chart(x = Year) |>
         echarts4r$e_line(Population) |>
-        echarts4r$e_x_axis(Year) |>
+        echarts4r$e_x_axis(
+          Year,
+          axisLabel = list(
+            formatter = label_formatter
+          )
+        ) |>
         echarts4r$e_tooltip()
     )
   })
 }
```

⚡️ アプリを再起動する: `shiny::shinyAppDir(".")`

☘️ グラフの横軸が変化

box / Shiny modules によるモジュール開発はいったんここまで. 次は CSS と JavaScript.

---

## スタイルのカスタマイズ

カスタムCSSを追加するには `app/styles/` へCSSファイルを置けば良い.
その前にまず準備としてdivタグとクラスを追加する.

📄 `app/main.R`

```diff
 # app/main.R
 
 box::use(
-  shiny[bootstrapPage, moduleServer, NS],
+  shiny[bootstrapPage, moduleServer, NS, div],
 )
 
 box::use(
   app/view/table,
   app/view/chart,
 )
 
 #' @export
 ui <- function(id) {
   ns <- NS(id)
 
   bootstrapPage(
-    table$ui(ns("table")),
-    chart$ui(ns("chart"))
+    div(
+      class = "components-container",
+      table$ui(ns("table")),
+      chart$ui(ns("chart"))
+    )
   )
 }
 
 #' @export
 server <- function(id) {
   moduleServer(id, function(input, output, session) {
     # Datasets are the only case when you need to use :: in `box`.
     # This issue should be solved in the next `box` release.
     data <- rhino::rhinos
 
     table$server("table", data = data)
     chart$server("chart", data = data)
   })
 }
```

📄 `app/view/chart.R`

```diff
 # app/view/chart.R
 
 box::use(
-  shiny[moduleServer, NS, h3, tagList],
+  shiny[moduleServer, NS, div],
   echarts4r
 )
 
 box::use(
   app/logic/chart_utils[label_formatter]
 )
 
 #' @export
 ui <- function(id) {
   ns <- NS(id)
 
-  tagList(
-    h3("Chart"),
-    echarts4r$echarts4rOutput(ns("chart"))
-  )
+  div(
+    class = "component-box",
+    echarts4r$echarts4rOutput(ns("chart"))
+  )
 }
 
 #' @export
 server <- function(id, data) {
   moduleServer(id, function(input, output, session) {
     output$chart <- echarts4r$renderEcharts4r(
       data |>
         echarts4r$group_by(Species) |>
         echarts4r$e_chart(x = Year) |>
         echarts4r$e_line(Population) |>
         echarts4r$e_x_axis(
           Year,
           axisLabel = list(
             formatter = label_formatter
           )
         ) |>
         echarts4r$e_tooltip()
     )
   })
 }
```

📄 `app/view/table.R`

```diff
 # app/view/table.R
 
 box::use(
-  shiny[moduleServer, NS, h3, tagList],
+  shiny[moduleServer, NS, div],
   reactable,
 )
 
 box::use(
   app/logic/data_transformation[transform_data]
 )
 
 #' @export
 ui <- function(id) {
   ns <- NS(id)
 
-  tagList(
-    h3("Table"),
-    reactable$reactableOutput(ns("table"))
-  )
+  div(
+    class = "component-box",
+    reactable$reactableOutput(ns("table"))
+  )
 }
 
 #' @export
 server <- function(id, data) {
   moduleServer(id, function(input, output, session) {
     output$table <- reactable$renderReactable(
       data |>
         transform_data() |>
         reactable$reactable()
     )
   })
 }
```

次に, カスタムのスタイルを `app/styles/main.scss` で定義する

📄 `app/styles/main.scss`

```scss
// app/styles/main.scss

.components-container {
  display: inline-grid;
  grid-template-columns: 1fr 1fr;
  width: 100%;

  .component-box {
    padding: 10px;
    margin: 10px;
    box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
  }
}
```

⚡️ Sass をビルドする:

```r
# Rコンソールで実行
rhino::build_sass()
```

☘️ `app/static/app.min.css` が作成される

📝 このとき, 同時に `.rhino/node/` ディレクトリに `package.json` や `webpack.config.babel.js` その他のファイルが生成された

⚡️ アプリを再起動する: `shiny::shinyAppDir(".")`

☘️ スタイルが変化していることを確認.

さらにタイトルをつけてみる

📄 `app/main.R`

```diff
 # app/main.R
 
 box::use(
-  shiny[bootstrapPage, moduleServer, NS, div],
+  shiny[bootstrapPage, moduleServer, NS, div, h1],
 )
 
 box::use(
   app/view/table,
   app/view/chart,
 )
 
 #' @export
 ui <- function(id) {
   ns <- NS(id)
 
   bootstrapPage(
+    h1("RhinoApplication"),
     div(
       class = "components-container",
       table$ui(ns("table")),
       chart$ui(ns("chart"))
     )
   )
 }
 
 #' @export
 server <- function(id) {
   moduleServer(id, function(input, output, session) {
     # Datasets are the only case when you need to use :: in `box`.
     # This issue should be solved in the next `box` release.
     data <- rhino::rhinos
 
     table$server("table", data = data)
     chart$server("chart", data = data)
   })
 }
```

📄 `app/styles/main.scss`

```diff
 // app/styles/main.scss
 
 .components-container {
   display: inline-grid;
   grid-template-columns: 1fr 1fr;
   width: 100%;
 
   .component-box {
     padding: 10px;
     margin: 10px;
     box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
   }
 }
+
+h1 {
+  text-align: center;
+  font-weight: 900;
+}
```

⚡️ `app/styles/main.scss` を修正したので, また `rhino::build_sass()` を実行する. 

⚡️ アプリを再起動する: `shiny::shinyAppDir(".")`

☘️ タイトルが追加されている

## JavaScript のコードを追加する

JavaScriptでボタンをクリックしたらポップアップ表示が出るようにしたい.

まずはボタンを追加してスタイルを整える.

📄 `app/main.R` 

```diff
 # app/main.R
 
 box::use(
-  shiny[bootstrapPage, moduleServer, NS, div, h1],
+  shiny[bootstrapPage, moduleServer, NS, div, h1, tags, icon],
 )
 
 box::use(
   app/view/table,
   app/view/chart,
 )
 
 #' @export
 ui <- function(id) {
   ns <- NS(id)
 
   bootstrapPage(
     h1("RhinoApplication"),
     div(
       class = "components-container",
       table$ui(ns("table")),
       chart$ui(ns("chart"))
-    )
+    ),
+     tags$button(
+       id = "help-button",
+       icon("question")
+     )
   )
 }
 
 #' @export
 server <- function(id) {
   moduleServer(id, function(input, output, session) {
     # Datasets are the only case when you need to use :: in `box`.
     # This issue should be solved in the next `box` release.
     data <- rhino::rhinos
 
     table$server("table", data = data)
     chart$server("chart", data = data)
   })
 }
```

📄 `app/styles/main.scss`

```diff
 // app/styles/main.scss
 
 .components-container {
   display: inline-grid;
   grid-template-columns: 1fr 1fr;
   width: 100%;
 
   .component-box {
     padding: 10px;
     margin: 10px;
     box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
   }
 }
 
 h1 {
   text-align: center;
   font-weight: 900;
 }
+
+#help-button {
+  position: fixed;
+  top: 0;
+  right: 0;
+  margin: 10px;
+}
```

⚡️ また `rhino::build_sass()` で Sass のビルドを実行し, `shiny::shinyAppDir(".")` でアプリを再起動する.

☘️ この時点で画面右上にボタンが追加される. まだクリックしても何も起こらない.

JSファイルは `app/js/` 以下に配置する.
ここでは `app/js/index.js` を作成する.

📄 `app/js/index.js`

```js
// app/js/index.js

export function showHelp() {
  alert("Check rhino here: https://appsilon.github.io/rhino/");
}
```

ここではブラウザ標準のアラートボックスを表示するJS関数 `showHelp()` を定義している.

CSSと同様、JSもビルドする必要がある.

⚡️ JSのビルド用コマンド `rhino::build_js()` を実行する

```r
# Rコンソールで実行
rhino::build_js()
```

☘️ `app/static/js/app.min.js` が生成される.

最後に, 定義したJS関数がボタンクリックで呼び出されるようにする.

📄 `app/main.R` 

```diff
 # app/main.R
 
 box::use(
   shiny[bootstrapPage, moduleServer, NS, div, h1, tags, icon],
 )
 
 box::use(
   app/view/table,
   app/view/chart,
 )
 
 #' @export
 ui <- function(id) {
   ns <- NS(id)
 
   bootstrapPage(
     h1("RhinoApplication"),
     div(
       class = "components-container",
       table$ui(ns("table")),
       chart$ui(ns("chart"))
     ),
      tags$button(
        id = "help-button",
-       icon("question"),
+       icon("question"),
+       onclick = "App.showHelp()"
      )
   )
 }
 
 #' @export
 server <- function(id) {
   moduleServer(id, function(input, output, session) {
     # Datasets are the only case when you need to use :: in `box`.
     # This issue should be solved in the next `box` release.
     data <- rhino::rhinos
 
     table$server("table", data = data)
     chart$server("chart", data = data)
   })
 }
```

ここで `export` された関数 `showHelp()` が `App.showHelp()` の形で呼び出されていることに注目.

⚡️ `shiny::shinyAppDir(".")` でアプリを再起動する.

☘️ ボタンをクリックするとアラートが表示される.

☕ チュートリアルおわり.

---

- [🏠 プロジェクトルートへ](https://github.com/terashim/rhino-training)
- [📗 ドキュメントフォルダへ `docs/`](./)
