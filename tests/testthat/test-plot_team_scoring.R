team_scoring_fixture <- function() {
  data.frame(
    Name = c("Player C", "Player A", "Player B", "Player D"),
    Team = c("London", "London", "London", "Oshawa"),
    G = c(18, 25, 32, 50),
    A = c(30, 40, 25, 60)
  )
}

test_that("team filtering and ranking produce the correct leaders", {
  p <- plot_team_scoring(
    team_scoring_fixture(),
    team = "London",
    n = 2
  )

  # The text layer contains one total per selected player.
  totals <- p$layers[[2]]$data

  expect_equal(totals$player, c("Player A", "Player B"))
  expect_equal(totals$points, c(65, 57))

  built <- ggplot2::ggplot_build(p)

  expect_equal(as.numeric(built$data[[2]]$y), c(2, 1))
  expect_equal(built$data[[2]]$x, c(65, 57))
})

test_that("goals and assists stack to the displayed total", {
  p <- plot_team_scoring(
    team_scoring_fixture(),
    team = "London"
  )

  built <- ggplot2::ggplot_build(p)
  bars <- built$data[[1]]
  labels <- built$data[[2]]

  for (i in seq_len(nrow(labels))) {
    segments <- bars[bars$y == labels$y[i], ]

    expect_equal(nrow(segments), 2L)
    expect_equal(min(segments$xmin), 0)
    expect_equal(max(segments$xmax), labels$x[i])
    expect_equal(
      sum(segments$xmax - segments$xmin),
      labels$x[i]
    )
  }
})

test_that("a single team is selected automatically", {
  players <- team_scoring_fixture()
  players <- players[players$Team == "London", ]

  p <- plot_team_scoring(players)

  expect_equal(p$labels$title, "London Scoring")
  expect_equal(nrow(p$layers[[2]]$data), 3L)
})

test_that("multiple teams require an explicit selection", {
  expect_error(
    plot_team_scoring(team_scoring_fixture()),
    "exactly one named team"
  )
})

test_that("an unknown team produces a clear error", {
  expect_error(
    plot_team_scoring(team_scoring_fixture(), team = "Unknown"),
    "No rows found"
  )
})

test_that("custom column names work", {
  players <- data.frame(
    player = c("Alex", "Sam"),
    club = c("Example", "Example"),
    goals = c(10, 20),
    assists = c(25, 10)
  )

  p <- plot_team_scoring(
    players,
    player_col = "player",
    team_col = "club",
    goals_col = "goals",
    assists_col = "assists"
  )

  totals <- p$layers[[2]]$data

  expect_equal(totals$player, c("Alex", "Sam"))
  expect_equal(totals$points, c(35, 30))
})

test_that("ties preserve input order at the cutoff", {
  players <- data.frame(
    Name = c("First", "Second"),
    Team = c("Example", "Example"),
    G = c(10, 15),
    A = c(20, 15)
  )

  p <- plot_team_scoring(players, n = 1)

  expect_equal(p$layers[[2]]$data$player, "First")
})

test_that("missing scoring values are omitted with a warning", {
  players <- team_scoring_fixture()
  players$G[1] <- NA_real_

  expect_warning(
    p <- plot_team_scoring(players, team = "London"),
    "omitted"
  )

  expect_equal(
    p$layers[[2]]$data$player,
    c("Player A", "Player B")
  )
})

test_that("invalid scoring columns are rejected", {
  players <- team_scoring_fixture()
  players$G <- as.character(players$G)

  expect_error(
    plot_team_scoring(players, team = "London"),
    "must be a numeric vector"
  )

  for (bad_value in c(-1, 1.5)) {
    players <- team_scoring_fixture()
    players$G[1] <- bad_value

    expect_error(
      plot_team_scoring(players, team = "London"),
      "non-negative whole numbers"
    )
  }
})

test_that("duplicate player names are rejected", {
  players <- team_scoring_fixture()
  players$Name[2] <- players$Name[1]

  expect_error(
    plot_team_scoring(players, team = "London"),
    "Duplicate player names"
  )
})

test_that("invalid player limits are rejected", {
  for (bad_n in list(0, -1, 1.5, NA_real_, Inf, "10")) {
    expect_error(
      plot_team_scoring(
        team_scoring_fixture(),
        team = "London",
        n = bad_n
      ),
      "positive whole number"
    )
  }
})

test_that("requesting more players than available works", {
  p <- plot_team_scoring(
    team_scoring_fixture(),
    team = "London",
    n = 20
  )

  expect_equal(nrow(p$layers[[2]]$data), 3L)
})

test_that("plotting leaves the original data unchanged", {
  players <- team_scoring_fixture()
  original <- players

  plot_team_scoring(players, team = "London", n = 2)

  expect_identical(players, original)
})
