# Small, deliberately unsorted dataset for testing.
scoring_fixture <- function() {
  data.frame(
    Name = c("Player C", "Player A", "Player B", "Player D"),
    Team = c("Barrie", "London", "Oshawa", "Erie"),
    G = c(30, 41, 36, 28),
    PTS = c(81, 96, 88, 75)
  )
}

test_that("leaders are ranked and limited correctly", {
  p <- plot_scoring_leaders(scoring_fixture(), n = 3)

  expect_equal(p$data$value, c(96, 88, 81))
  expect_equal(
    p$data$label,
    c("Player A (London)", "Player B (Oshawa)", "Player C (Barrie)")
  )

  # The highest scorer should appear at the top of the chart.
  built <- ggplot2::ggplot_build(p)
  expect_equal(as.numeric(built$data[[1]]$y), c(3, 2, 1))
})

test_that("users can select another statistic", {
  p <- plot_scoring_leaders(scoring_fixture(), stat = "G", n = 2)

  expect_equal(p$data$value, c(41, 36))
  expect_equal(p$labels$x, "Goals")
})

test_that("custom columns work without a team column", {
  players <- data.frame(
    player = c("Alex", "Sam"),
    points = c(20, 30)
  )

  p <- plot_scoring_leaders(
    players,
    stat = "points",
    player_col = "player",
    team_col = NULL
  )

  expect_equal(p$data$label, c("Sam", "Alex"))
  expect_equal(p$data$value, c(30, 20))
})

test_that("ties preserve input order at the cutoff", {
  players <- scoring_fixture()
  players$PTS <- c(90, 90, 80, 70)

  p <- plot_scoring_leaders(players, n = 1)

  expect_equal(p$data$label, "Player C (Barrie)")
})

test_that("identical display names remain separate bars", {
  players <- data.frame(
    Name = c("Alex Smith", "Alex Smith"),
    PTS = c(30, 20)
  )

  p <- plot_scoring_leaders(players, team_col = NULL)
  built <- ggplot2::ggplot_build(p)

  expect_equal(nrow(built$data[[1]]), 2L)
  expect_equal(length(unique(built$data[[1]]$y)), 2L)
})

test_that("missing statistics are omitted with a warning", {
  players <- scoring_fixture()
  players$PTS[1] <- NA_real_

  expect_warning(
    p <- plot_scoring_leaders(players),
    "omitted"
  )

  expect_equal(p$data$value, c(96, 88, 75))
})

test_that("unusable data produces clear errors", {
  players <- scoring_fixture()

  expect_error(
    plot_scoring_leaders(players, stat = "Missing"),
    "Missing required columns"
  )

  players$PTS <- as.character(players$PTS)

  expect_error(
    plot_scoring_leaders(players),
    "must be a numeric vector"
  )

  empty <- scoring_fixture()[0, ]

  expect_error(
    plot_scoring_leaders(empty),
    "No usable statistic values"
  )
})

test_that("invalid leaderboard sizes are rejected", {
  for (bad_n in list(0, -1, 1.5, NA_real_, Inf, "10")) {
    expect_error(
      plot_scoring_leaders(scoring_fixture(), n = bad_n),
      "positive whole number"
    )
  }
})

test_that("requesting more players than available works", {
  p <- plot_scoring_leaders(scoring_fixture(), n = 10)

  expect_equal(nrow(p$data), 4L)
})

test_that("plotting leaves the original data unchanged", {
  players <- scoring_fixture()
  original <- players

  plot_scoring_leaders(players, n = 2)

  expect_identical(players, original)
})
