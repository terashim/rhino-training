# コードの linting と自動フォーマットについて

> lintとは、コンピュータプログラムなどのソースコードを読み込んで内容を分析し、問題点を指摘してくれる静的解析ツール。また、そのようなツールで解析を行うこと。ツールを指す場合は “linter” （リンター）と呼ぶこともある。

出典: [lintとは - 意味をわかりやすく - IT用語辞典 e-Words](https://e-words.jp/w/lint.html)


## R

[`rhino::lint_r()`](https://appsilon.github.io/rhino/reference/lint_r.html)
は [`lintr`](https://cran.r-project.org/package=lintr) のラッパー関数。

[`rhino::format_r()`](https://appsilon.github.io/rhino/reference/format_r.html)
は [`styler`](https://styler.r-lib.org) のラッパー関数。

## Sass

[`rhino::lint_sass()`](https://appsilon.github.io/rhino/reference/lint_sass.html)
は
[Stylelint](https://stylelint.io/)
を呼び出し、`app/styles` フォルダのコードに対して lint を行う。

`rhino::lint_sass(fix = TRUE)` とすれば自動で修正も行う。

## JavaScript

[`rhino::lint_js`](https://appsilon.github.io/rhino/reference/lint_js.html)
は
[ESLint](https://eslint.org/) を呼び出し、`app/js` フォルダのコードに対して lint を行う。

`rhino::lint_js(fix = TRUE)` とすれば自動で修正も行う。

