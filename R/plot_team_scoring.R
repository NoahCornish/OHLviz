#' Plot Team Scoring
#'
#' Compare players on one team using stacked goals and assists.
#' Defaults match the column names returned by OHLpkg.
#'
#' @param data A data frame with one row per player for one season.
#'   Goals and assists must cover the same reporting scope.
#' @param team Team name to select. If `NULL`, the data must contain
#'   exactly one team.
#' @param n Maximum number of players to display. Defaults to 10.
#' @param player_col Name of the player-name column.
#' @param team_col Name of the team column.
#' @param goals_col Name of the numeric goals column.
#' @param assists_col Name of the numeric assists column.
#' @param title Chart title. If `NULL`, uses the selected team name.
#' @param subtitle Optional chart subtitle.
#' @param caption Optional chart caption.
#' @param goals_colour Fill colour for goals.
#' @param assists_colour Fill colour for assists.
#'
#' @details
#' Players are ranked by goals plus assists, from highest to lowest.
#' Ties preserve input row order. Rows with missing or non-finite goals
#' or assists are omitted with a warning.
#'
#' Goals and assists must be non-negative whole numbers.
#' Duplicate player names within the selected team are rejected:
#' resolve duplicate records or supply unique player labels first.
#'
#' Selecting a team filters rows; it does not convert season totals
#' into statistics earned only with that team. Supply team-specific
#' statistics when that distinction matters.
#'
#' @return A ggplot object.
#'
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' players <- data.frame(
#'   Name = c("Player A", "Player B", "Player C"),
#'   Team = rep("Example Team", 3),
#'   G = c(25, 32, 18),
#'   A = c(40, 25, 30)
#' )
#'
#' plot_team_scoring(players)
#' plot_team_scoring(players, team = "Example Team", n = 2)
plot_team_scoring <- function(
    data,
    team = NULL,
    n = 10,
    player_col = "Name",
    team_col = "Team",
    goals_col = "G",
    assists_col = "A",
    title = NULL,
    subtitle = NULL,
    caption = NULL,
    goals_colour = "#142D4E",
    assists_colour = "#2474B5"
) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  if (anyDuplicated(names(data))) {
    stop("`data` must have unique column names.", call. = FALSE)
  }

  is_column_name <- function(x) {
    is.character(x) &&
      length(x) == 1L &&
      !is.na(x) &&
      nzchar(trimws(x))
  }

  column_args <- list(player_col, team_col, goals_col, assists_col)

  if (!all(vapply(column_args, is_column_name, logical(1)))) {
    stop(
      "Column arguments must be single, non-empty column-name strings.",
      call. = FALSE
    )
  }

  if (identical(goals_col, assists_col)) {
    stop(
      "`goals_col` and `assists_col` must identify different columns.",
      call. = FALSE
    )
  }

  required <- c(player_col, team_col, goals_col, assists_col)
  missing <- setdiff(required, names(data))

  if (length(missing) > 0L) {
    stop(
      paste("Missing required columns:", paste(missing, collapse = ", ")),
      call. = FALSE
    )
  }

  if (
    !is.numeric(n) ||
    length(n) != 1L ||
    !is.finite(n) ||
    n < 1 ||
    n != floor(n)
  ) {
    stop("`n` must be a single positive whole number.", call. = FALSE)
  }

  if (!is.null(team) && !is_column_name(team)) {
    stop(
      "`team` must be a single non-empty team name or NULL.",
      call. = FALSE
    )
  }

  # Determine which team's rows to display.
  teams <- trimws(as.character(data[[team_col]]))
  valid_team <- !is.na(teams) & nzchar(teams)
  available <- unique(teams[valid_team])

  if (is.null(team)) {
    if (length(available) != 1L || any(!valid_team)) {
      stop(
        "Supply `team`, or provide data containing exactly one named team.",
        call. = FALSE
      )
    }

    team <- available[[1]]
  } else {
    team <- trimws(team)
  }

  selected <- which(valid_team & teams == team)

  if (length(selected) == 0L) {
    stop(
      paste0("No rows found for team \"", team, "\"."),
      call. = FALSE
    )
  }

  team_data <- data[selected, , drop = FALSE]

  # Validate the scoring columns.
  for (column in c(goals_col, assists_col)) {
    values <- team_data[[column]]

    if (!is.numeric(values) || !is.null(dim(values))) {
      stop(
        paste0("Column `", column, "` must be a numeric vector."),
        call. = FALSE
      )
    }
  }

  goals <- team_data[[goals_col]]
  assists <- team_data[[assists_col]]
  keep <- is.finite(goals) & is.finite(assists)

  if (any(!keep)) {
    warning(
      "Rows with missing or non-finite goals or assists were omitted.",
      call. = FALSE
    )
  }

  if (!any(keep)) {
    stop("No usable scoring values remain to plot.", call. = FALSE)
  }

  goals <- goals[keep]
  assists <- assists[keep]
  players <- trimws(as.character(team_data[[player_col]][keep]))

  if (
    any(goals < 0 | assists < 0) ||
    any(goals != floor(goals) | assists != floor(assists))
  ) {
    stop(
      "Goals and assists must be non-negative whole numbers.",
      call. = FALSE
    )
  }

  if (any(is.na(players) | !nzchar(players))) {
    stop("Player names must not be missing or blank.", call. = FALSE)
  }

  if (anyDuplicated(players)) {
    stop(
      paste(
        "Duplicate player names found in the selected team.",
        "Resolve duplicate records or supply unique player labels."
      ),
      call. = FALSE
    )
  }

  # Calculate the displayed stack total and rank players.
  totals <- data.frame(
    player = players,
    goals = goals,
    assists = assists,
    points = goals + assists,
    stringsAsFactors = FALSE
  )

  if (any(!is.finite(totals$points))) {
    stop("Scoring totals must be finite.", call. = FALSE)
  }

  ordering <- order(-totals$points, seq_len(nrow(totals)))
  totals <- totals[ordering, , drop = FALSE]
  totals <- utils::head(totals, n)

  ids <- as.character(seq_len(nrow(totals)))
  totals$row_id <- factor(ids, levels = rev(ids))
  axis_labels <- stats::setNames(totals$player, ids)

  # Reshape only the fields needed for the stacked bars.
  plot_data <- data.frame(
    row_id = factor(rep(ids, 2), levels = rev(ids)),
    component = factor(
      rep(c("Goals", "Assists"), each = nrow(totals)),
      levels = c("Goals", "Assists")
    ),
    value = c(totals$goals, totals$assists)
  )

  totals$value_label <- scales::label_number(
    accuracy = 1,
    big.mark = ","
  )(totals$points)

  if (is.null(title)) {
    title <- paste(team, "Scoring")
  }

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(
      x = .data$value,
      y = .data$row_id,
      fill = .data$component
    )
  ) +
    ggplot2::geom_col(
      width = 0.65,
      position = ggplot2::position_stack(reverse = TRUE)
    ) +
    ggplot2::geom_text(
      data = totals,
      mapping = ggplot2::aes(
        x = .data$points,
        y = .data$row_id,
        label = .data$value_label
      ),
      inherit.aes = FALSE,
      hjust = -0.2,
      fontface = "bold",
      colour = "#142D4E",
      size = 3.8
    ) +
    ggplot2::scale_fill_manual(
      values = c(
        Goals = goals_colour,
        Assists = assists_colour
      ),
      breaks = c("Goals", "Assists"),
      name = NULL
    ) +
    ggplot2::scale_y_discrete(labels = axis_labels) +
    ggplot2::scale_x_continuous(
      limits = c(0, NA),
      expand = ggplot2::expansion(mult = c(0, 0.18)),
      labels = scales::label_number(accuracy = 1)
    ) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = "Points",
      y = NULL,
      caption = caption
    ) +
    theme_ohl() +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank()
    )
}
