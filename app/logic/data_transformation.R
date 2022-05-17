# app/logic/data_transformation.R

box::use(
  tidyr[pivot_wider],
  dplyr[arrange]
)

#' @export
transform_data <- function(data) {
  pivot_wider(
    data = data,
    names_from = Species,
    values_from = Population
  ) |>
    arrange(Year)
}
