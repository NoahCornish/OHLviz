test_that("the theme works on a standalone ggplot", {
  p <- ggplot2::ggplot(
    data.frame(x = 1:3, y = c(2, 4, 3)),
    ggplot2::aes(x = x, y = y)
  ) +
    ggplot2::geom_point() +
    theme_ohl()

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("font settings are applied", {
  theme <- theme_ohl(
    base_size = 16,
    base_family = "serif"
  )

  expect_equal(theme$text$size, 16)
  expect_equal(theme$text$family, "serif")
})

test_that("invalid font sizes are rejected", {
  for (bad_size in list(0, -1, NA_real_, Inf, "12", numeric(0), c(12, 14))) {
    expect_error(
      theme_ohl(base_size = bad_size),
      "single positive number"
    )
  }
})

test_that("invalid font families are rejected", {
  for (bad_family in list(12, NA_character_, NULL, c("sans", "serif"))) {
    expect_error(
      theme_ohl(base_family = bad_family),
      "single character string"
    )
  }
})

test_that("creating the theme leaves the global theme unchanged", {
  original <- ggplot2::theme_get()

  theme_ohl(base_size = 18)

  expect_identical(ggplot2::theme_get(), original)
})
