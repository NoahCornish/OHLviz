#' Plot Scoring Leaders
#'
#' Create a horizontal leaderboard from a data frame of player statistics.
#' Defaults match the column names returned by OHLpkg.
#'
#' @param data A data frame with one row per player for one season.
#'   Resolve duplicate player records or team splits before plotting.
#' @param stat Name of the numeric statistic column. Defaults to `"PTS"`.
#' @param n Maximum number of players to display. Defaults to 10.
#' @param player_col Name of the player-name column.
#' @param team_col Name of the team column, or `NULL` to omit team labels.
#' @param title Chart title.
#' @param subtitle Optional chart subtitle.
#' @param caption Optional chart caption.
#' @param colour Bar fill colour.
#'
#' @details
#' Players are ranked from highest to lowest. Ties are resolved by input
#' row order. Missing or non-finite statistic values are omitted with a
#' warning. Negative values are not supported.
#'
#' @return A ggplot object.
#'
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' players <- data.frame(
#'   Name = c("Player A", "Player B", "Player C"),
#'   Team = c("Team A", "Team B", "Team C"),
#'   G = c(35, 28, 31),
#'   PTS = c(82, 76, 70)
#' )
#'
#' plot_scoring_leaders(players)
#' plot_scoring_leaders(players, stat = "G", n = 2)
plot_scoring_leaders <- function(
    data,
    stat = "PTS",
    n = 10,
    player_col = "Name",
    team_col = "Team",
    title = "OHL Scoring Leaders",
    subtitle = NULL,
    caption = NULL,
    colour = "#2474B5"
) {
  # Validate the input data.
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
      nzchar(x)
  }

  if (!is_column_name(stat) || !is_column_name(player_col)) {
    stop(
      "`stat` and `player_col` must be single column-name strings.",
      call. = FALSE
    )
  }

  if (!is.null(team_col) && !is_column_name(team_col)) {
    stop(
      "`team_col` must be a single column-name string or NULL.",
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

  required <- c(player_col, team_col, stat)
  missing <- setdiff(required, names(data))

  if (length(missing) > 0L) {
    stop(
      paste("Missing required columns:", paste(missing, collapse = ", ")),
      call. = FALSE
    )
  }

  # Validate the selected statistic.
  values <- data[[stat]]

  if (!is.numeric(values) || !is.null(dim(values))) {
    stop(
      paste0("Column `", stat, "` must be a numeric vector."),
      call. = FALSE
    )
  }

  keep <- is.finite(values)

  if (any(!keep)) {
    warning(
      "Rows with missing or non-finite statistic values were omitted.",
      call. = FALSE
    )
  }

  if (!any(keep)) {
    stop("No usable statistic values remain to plot.", call. = FALSE)
  }

  if (any(values[keep] < 0)) {
    stop(
      "Choose a scoring statistic with non-negative values.",
      call. = FALSE
    )
  }

  # Prepare player and team labels.
  players <- trimws(as.character(data[[player_col]]))

  if (any(is.na(players[keep]) | !nzchar(players[keep]))) {
    stop("Player names must not be missing or blank.", call. = FALSE)
  }

  labels <- players

  if (!is.null(team_col)) {
    teams <- trimws(as.character(data[[team_col]]))
    has_team <- !is.na(teams) & nzchar(teams)

    labels[has_team] <- paste0(
      players[has_team], " (", teams[has_team], ")"
    )
  }

  plot_data <- data.frame(
    label = labels[keep],
    value = values[keep],
    stringsAsFactors = FALSE
  )

  # Rank players, preserving input order when values are tied.
  ordering <- order(-plot_data$value, seq_len(nrow(plot_data)))
  plot_data <- plot_data[ordering, , drop = FALSE]
  plot_data <- utils::head(plot_data, n)

  # Separate row IDs prevent identical names from merging into one bar.
  ids <- as.character(seq_len(nrow(plot_data)))
  plot_data$row_id <- factor(ids, levels = rev(ids))
  axis_labels <- stats::setNames(plot_data$label, ids)

  stat_labels <- c(
    G = "Goals",
    A = "Assists",
    PTS = "Points",
    "Pts/G" = "Points per game"
  )

  axis_title <- if (stat %in% names(stat_labels)) {
    unname(stat_labels[[stat]])
  } else {
    stat
  }

  plot_data$value_label <- scales::label_number(
    accuracy = if (all(plot_data$value %% 1 == 0)) 1 else NULL,
    big.mark = ","
  )(plot_data$value)

  # Build and return the chart.
  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = .data$value, y = .data$row_id)
  ) +
    ggplot2::geom_col(
      fill = colour,
      width = 0.65
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$value_label),
      hjust = -0.2,
      fontface = "bold",
      colour = "#142D4E",
      size = 3.8
    ) +
    ggplot2::scale_y_discrete(
      labels = axis_labels
    ) +
    ggplot2::scale_x_continuous(
      limits = c(0, NA),
      expand = ggplot2::expansion(mult = c(0, 0.18)),
      labels = scales::label_number()
    ) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = axis_title,
      y = NULL,
      caption = caption
    ) +
    theme_ohl() +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank()
    )
}
