goalie_fixture <- function() {
  goalies <- data.frame(
    Name = c("Goalie A", "Goalie B", "Goalie C", "Goalie D"),
    Team = c("London", "Oshawa", "Barrie", "Erie"),
    GAA = c(2.45, 2.70, 2.30, 3.05),
    W = c(25, 30, 22, 18)
  )

  goalies[["SAV%"]] <- c(0.915, 0.908, 0.921, 0.899)
  goalies
}

test_that("save percentage ranks highest first", {
  p <- plot_goalie_leaders(goalie_fixture(), n = 3)

  expect_equal(p$data$value, c(0.921, 0.915, 0.908))
  expect_equal(
    p$data$label,
    c("Goalie C (Barrie)", "Goalie A (London)", "Goalie B (Oshawa)")
  )

  built <- ggplot2::ggplot_build(p)

  expect_equal(as.numeric(built$data[[1]]$y), c(3, 2, 1))
  expect_equal(built$data[[1]]$x, c(0.921, 0.915, 0.908))
})

test_that("GAA ranks lowest first", {
  p <- plot_goalie_leaders(goalie_fixture(), stat = "GAA", n = 2)

  expect_equal(p$data$value, c(2.30, 2.45))
  expect_equal(
    p$data$label,
    c("Goalie C (Barrie)", "Goalie A (London)")
  )

  built <- ggplot2::ggplot_build(p)

  expect_equal(as.numeric(built$data[[1]]$y), c(2, 1))
  expect_equal(built$data[[1]]$x, c(2.30, 2.45))
})

test_that("wins rank highest first", {
  p <- plot_goalie_leaders(goalie_fixture(), stat = "W", n = 2)

  expect_equal(p$data$value, c(30, 25))
  expect_equal(
    p$data$label,
    c("Goalie B (Oshawa)", "Goalie A (London)")
  )
})

test_that("statistic labels use the correct precision", {
  save_plot <- plot_goalie_leaders(goalie_fixture(), n = 2)
  gaa_plot <- plot_goalie_leaders(
    goalie_fixture(), stat = "GAA", n = 2
  )
  wins_plot <- plot_goalie_leaders(
    goalie_fixture(), stat = "W", n = 2
  )

  expect_equal(save_plot$data$value_label, c("0.921", "0.915"))
  expect_equal(gaa_plot$data$value_label, c("2.30", "2.45"))
  expect_equal(wins_plot$data$value_label, c("30", "25"))
})

test_that("percent inputs match proportion inputs after conversion", {
  proportions <- goalie_fixture()
  percentages <- proportions
  percentages[["SAV%"]] <- percentages[["SAV%"]] * 100

  p1 <- plot_goalie_leaders(proportions)
  p2 <- plot_goalie_leaders(
    percentages,
    save_pct_scale = "percent"
  )

  expect_equal(p2$data$value, p1$data$value)
  expect_equal(p2$data$value_label, p1$data$value_label)
  expect_equal(p2$data$label, p1$data$label)
})

test_that("save percentage units must be explicit and valid", {
  goalies <- goalie_fixture()
  goalies[["SAV%"]] <- goalies[["SAV%"]] * 100

  expect_error(
    plot_goalie_leaders(goalies),
    "Check `save_pct_scale`"
  )

  goalies[["SAV%"]][1] <- 101

  expect_error(
    plot_goalie_leaders(goalies, save_pct_scale = "percent"),
    "Check `save_pct_scale`"
  )

  expect_error(
    plot_goalie_leaders(goalie_fixture(), save_pct_scale = "guess"),
    "must be"
  )
})

test_that("custom columns work without team labels", {
  goalies <- data.frame(
    goalie = c("Alex", "Sam"),
    average = c(2.80, 2.20)
  )

  p <- plot_goalie_leaders(
    goalies,
    stat = "GAA",
    stat_col = "average",
    player_col = "goalie",
    team_col = NULL
  )

  expect_equal(p$data$label, c("Sam", "Alex"))
  expect_equal(p$data$value, c(2.20, 2.80))
})

test_that("ties preserve input order at the cutoff", {
  goalies <- goalie_fixture()
  goalies$W <- c(30, 30, 20, 10)

  p <- plot_goalie_leaders(goalies, stat = "W", n = 1)

  expect_equal(p$data$label, "Goalie A (London)")
})

test_that("missing and infinite values are omitted with a warning", {
  goalies <- goalie_fixture()
  goalies$GAA[1] <- NA_real_
  goalies$GAA[2] <- Inf

  expect_warning(
    p <- plot_goalie_leaders(goalies, stat = "GAA"),
    "omitted"
  )

  expect_equal(p$data$value, c(2.30, 3.05))
})

test_that("empty data produces a clear error", {
  goalies <- goalie_fixture()[0, ]

  expect_error(
    plot_goalie_leaders(goalies),
    "No usable statistic values"
  )
})

test_that("invalid statistics and missing columns are rejected", {
  expect_error(
    plot_goalie_leaders(goalie_fixture(), stat = "Unknown"),
    "must be"
  )

  expect_error(
    plot_goalie_leaders(goalie_fixture(), stat_col = "Missing"),
    "Missing required columns"
  )

  goalies <- goalie_fixture()
  goalies$GAA <- as.character(goalies$GAA)

  expect_error(
    plot_goalie_leaders(goalies, stat = "GAA"),
    "must be a numeric vector"
  )
})

test_that("negative statistics and fractional wins are rejected", {
  for (metric in c("SAV%", "GAA", "W")) {
    goalies <- goalie_fixture()
    goalies[[metric]][1] <- -1

    expect_error(
      plot_goalie_leaders(goalies, stat = metric),
      "non-negative"
    )
  }

  goalies <- goalie_fixture()
  goalies$W[1] <- 2.5

  expect_error(
    plot_goalie_leaders(goalies, stat = "W"),
    "whole numbers"
  )
})

test_that("invalid goalie limits are rejected", {
  for (bad_n in list(0, -1, 1.5, NA_real_, Inf, "10")) {
    expect_error(
      plot_goalie_leaders(goalie_fixture(), n = bad_n),
      "positive whole number"
    )
  }
})

test_that("requesting more goalies than available works", {
  p <- plot_goalie_leaders(goalie_fixture(), n = 20)

  expect_equal(nrow(p$data), 4L)
})

test_that("identical names remain separate points", {
  goalies <- goalie_fixture()
  goalies$Name <- rep("Alex Smith", 4)

  p <- plot_goalie_leaders(goalies, team_col = NULL)
  built <- ggplot2::ggplot_build(p)

  expect_equal(nrow(built$data[[1]]), 4L)
  expect_equal(length(unique(built$data[[1]]$y)), 4L)
})

test_that("plotting leaves the original data unchanged", {
  goalies <- goalie_fixture()
  original <- goalies

  plot_goalie_leaders(goalies, stat = "GAA", n = 2)

  expect_identical(goalies, original)
})
