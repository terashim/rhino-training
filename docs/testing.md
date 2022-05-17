# テストについて

## R の単体テスト

[`rhino::test_r()`](https://appsilon.github.io/rhino/reference/test_r.html) で `tests/testthat/` ディレクトリ内のユニットテストをすべて実行する。

**補足**
[`testthat`](https://testthat.r-lib.org/) はパッケージ開発を前提としているが、パッケージ開発でなくても [`testthat::test_dir`](https://testthat.r-lib.org/reference/test_dir.html) でテストを実行することは可能。`rhino::test_r` はその単純なラッパーになっている。

## box モジュールとテストについて

（調査中）

参考: [Testing modules • box](https://klmr.me/box/articles/testing.html)

## testServer について

`testServer()` は Shiny 1.5.0 で `moduleServer()` とともに追加されたテスト用の関数。

ドキュメント: <https://shiny.rstudio.com/reference/shiny/1.7.0/testServer.html>

構文

```r
testServer(app = NULL, expr, args = list(), session = MockShinySession$new())
```

`app` にサーバー関数やモジュール関数を、`expr` にテストコードを書く。

server 関数のテスト例

```r
server <- function(input, output, session) {
  x <- reactive(input$a * input$b)
}

testServer(server, {
  session$setInputs(a = 2, b = 3)
  stopifnot(x() == 6)
})
```

`server` 関数内のスコープで定義されているはずの `input` や `x` が `testServer` の中で使えている。不思議。

モジュールのテスト例

```r
myModuleServer <- function(id, multiplier = 2, prefix = "I am ") {
  moduleServer(id, function(input, output, session) {
    myreactive <- reactive({
      input$x * multiplier
    })
    output$txt <- renderText({
      paste0(prefix, myreactive())
    })
  })
}

testServer(myModuleServer, args = list(multiplier = 2), {
  session$setInputs(x = 1)
  # You're also free to use third-party
  # testing packages like testthat:
  #   expect_equal(myreactive(), 2)
  stopifnot(myreactive() == 2)
  stopifnot(output$txt == "I am 2")

  session$setInputs(x = 2)
  stopifnot(myreactive() == 4)
  stopifnot(output$txt == "I am 4")
  # Any additional arguments, below, are passed along to the module.
})
```

ここでも `moduleServer` 中の `session`、`output` や `myreactive` をテストコード中で使っている。


引数 `expr` の説明：

> Test code containing expectations. The objects from inside the server function environment will be made available in the environment of the test expression (this is done using a data mask with rlang::eval_tidy()). This includes the parameters of the server function (e.g. input, output, and session), along with any other values created inside of the server function.

期待する挙動が書かれたテストコード。サーバー関数の環境中にあるオブジェクトはこのテスト式の環境で使えるようになる（これは `rlang::eval_tidy()` によるデータマスクを使って実現されている）。これにはサーバー関数の引数（input、output、session など）や、サーバー関数内で作成されたその他の値が含まれる。

## 実験

[チュートリアル](./tutorial.md) で作成したメインモジュール

📄 `app/main.R`

```r
box::use(
  shiny[bootstrapPage, moduleServer, NS, div, h1, tags, icon],
)

box::use(
  app/view/table,
  app/view/chart,
)

# ...(中略)...

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

に対して、次のテストコードを作成：

📄 `tests/testthat/test-main.R`

```r
box::use(
  shiny[testServer],
  testthat[...],
)
box::use(
  app/main[...],
)

test_that("`data` is available in the main server function", {
  testServer(server, {
    expect_equal(dim(data), c(58, 3))
  })
})
```

⚡️テストを実行

```r
rhino::test_r()
```

このとき、`server` の定義中で変数 `data` にデータフレーム `rhino::rhinos` が格納されていることを反映し、テストが成功する。

## E2Eテスト

[`rhino::test_e2e()`](https://appsilon.github.io/rhino/reference/test_e2e.html) で
Cypress による E2E テストを実行する。

---

- [🏠 プロジェクトルートへ](https://github.com/terashim/rhino-training)
- [📗 ドキュメントフォルダへ `docs/`](./)
