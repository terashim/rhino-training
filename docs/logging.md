# ロギングについて

[logger](https://daroczig.github.io/logger/) パッケージのラッパーとして
[`rhino::log`](https://appsilon.github.io/rhino/reference/log.html) が用意されている。

使い方

```r
box::use(rhino[log])

# Messages can be formatted using glue syntax.
name <- "Rhino"
log$warn("Hello {name}!")
log$info("{1:3} + {1:3} = {2 * (1:3)}")
```

`config.yml` の設定項目 `rhino_log_file` で出力先ファイルを指定する。`NA` なら標準エラー出力になる。

---

- [🏠 プロジェクトルートへ](https://github.com/terashim/rhino-training)
- [📗 ドキュメントフォルダへ `docs/`](./)
