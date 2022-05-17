# 環境と設定ファイル、秘密情報について

## 元資料

How to: Manage secrets and environments  
<https://appsilon.github.io/rhino/articles/how-to/manage-secrets-and-environments.html>

## 秘密情報

秘密情報はバージョン管理システムで扱うべきではない。環境変数に格納するのが自然である。
R はセッションの開始時に `.Renviron` から環境変数を読み込む。

📄 `.Renviron`

```sh
# A comment in .Renviron file
DATABASE_PASSWORD="foobar123!"
API_KEY="75170fc230cd88f32e475ff4087f81d9"
```

設定した環境変数は次のようにして使える。

```r
db_password <- Sys.getenv("DATABASE_PASSWORD")
if (db_password == "") {
  # Handle unset or empty DATABASE_PASSWORD variable
}
pool <- pool::dbPool(
  drv = RMySQL::MySQL(),
  dbname = "...",
  host = "...",
  username = "admin",
  password = db_password
)
```

推奨事項

- 秘密情報や環境変数は `.Renviron` に保存すること。
- `.Renviron` ファイルは環境ごとに分離すること。
- 変数名は大文字で `CONSTANT_CASE` のようにすること。
- `.Renviron` ファイルはバージョン管理システムでトラッキングしない。安全な場所（例：パスワードマネージャ）に保管すること。
- `.Renviron` は RStudio Connect や shinyapps.io に送らない。RStudio Connect にも Shiny Apps にも環境変数の管理機能が用意されている。

## 環境

秘密情報以外の設定情報についてはバージョン管理システムが使える。
Rhino では [`config`](https://github.com/rstudio/config) パッケージでの管理を推奨している。

📄 `config.yaml`

```yaml
default:
  rhino_log_level: !expr Sys.getenv("RHINO_LOG_LEVEL", "INFO")
  rhino_log_file: !expr Sys.getenv("RHINO_LOG_FILE", NA)
  database_user: "service_account"
  database_schema: "dev"

dev:
  rhino_log_level: !expr Sys.getenv("RHINO_LOG_LEVEL", "DEBUG")

staging:
  database_schema: "stg"

production:
  database_user: "service_account_prod"
  database_schema: "prod"
```

📄 `.Renviron`

```sh
R_CONFIG_ACTIVE="dev"
```

設定値にアクセスするには次のようにする。

```r
box::use(config)

config$get("rhino_log_level") # == "DEBUG"
config$get("database_user") # == "service_account"

config$get("rhino_log_level", config = "production") # == "INFO"
config$get("database_user", config = "production") # == "service_account_prod"

withr::with_envvar(list(RHINO_LOG_LEVEL = "ERROR"), {
  config$get("rhino_log_level") # == "ERROR"
  config$get("rhino_log_level", config = "production") # == "ERROR"
})
```

推奨事項

- 環境ごとの設定を `config.yml` で定義する。
- `.Renviron` ファイル中の `R_CONFIG_ACTIVE` 変数で環境を選択する。
- default 変数を使う。
- 環境変数でオーバーライド可能な設定には `!expr Sys.getenv()` を使う。
- box で config をロードし、通常通りに呼び出す。つまり `box::use(config)` としてから `config$get()` を使う。
- フィールド名にはスネークケース `snake_case` を使う。

---

- [🏠 プロジェクトルートへ](https://github.com/terashim/rhino-training)
- [📗 ドキュメントフォルダへ `docs/`](./)
