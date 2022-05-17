# app/logic/chart_utils.R

box::use(
  htmlwidgets[JS]
)

#' @export
label_formatter <- JS(
  "function(value, index) {
    return value;
  }"
)
