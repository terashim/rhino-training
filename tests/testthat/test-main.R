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
