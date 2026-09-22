#' Plot Goalie Leaders
#'
#' Create a ranked dot chart of goalie statistics.
#' Defaults match the column names returned by OHLpkg.
#'
#' @param data A data frame with one row per goalie for one season.
#'   Apply qualification filters and resolve duplicate records beforehand.
#' @param stat Statistic to display: `"SAV%"`, `"GAA"`, or `"W"`.
#' @param n Maximum number of goalies to display.
#' @param player_col Name of the goalie-name column.
#' @param team_col Name of the team column, or `NULL` to omit team labels.
#' @param stat_col Name of the statistic column. If `NULL`, uses `stat`.
#' @param save_pct_scale Input units for save percentage:
#'   `"proportion"` for values such as 0.915, or `"percent"` for 91.5.
#'   Used only when `stat = "SAV%"`.
#' @param title Chart title. If `NULL`, uses the selected statistic.
#' @param subtitle Optional subtitle. If `NULL`, describes ranking direction.
#' @param caption Optional chart caption.
#' @param colour Point colour.
#'
#' @details
#' Save percentage and wins are ranked highest first. Goals-against
#' average is ranked lowest first. Ties preserve input row order.
#' Missing or non-finite statistic values are omitted with a warning.
#'
#' Save percentage is displayed as a proportion with three decimal places.
#' GAA is displayed with two decimal places. Wins must be non-negative
#' whole numbers. The horizontal axis is fitted to the selected values
#' and does not necessarily start at zero.
#'
#' @return A ggplot object.
#'
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' goalies <- data.frame(
#'   Name = c("Goalie A", "Goalie B", "Goalie C"),
#'   Team = c("Team A", "Team B", "Team C"),
#'   GAA = c(2.45, 2.70, 2.30),
#'   W = c(25, 30, 22)
#' )
#' goalies[["SAV%"]] <- c(0.915, 0.908, 0.921)
#'
#' plot_goalie_leaders(goalies)
#' plot_goalie_leaders(goalies, stat = "GAA")
plot_goalie_leaders <- function(
    data,
    stat = "SAV%",
    n = 10,
    player_col = "Name",
    team_col = "Team",
    stat_col = NULL,
    save_pct_scale = "proportion",
    title = NULL,
    subtitle = NULL,
    caption = NULL,
    colour = "#2474B5"
) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  if (anyDuplicated(names(data))) {
    stop("`data` must have unique column names.", call. = FALSE)
  }

  is_string <- function(x) {
    is.character(x) &&
      length(x) == 1L &&
      !is.na(x) &&
      nzchar(trimws(x))
  }

  if (!is_string(stat) || !stat %in% c("SAV%", "GAA", "W")) {
    stop('`stat` must be "SAV%", "GAA", or "W".', call. = FALSE)
  }

  if (is.null(stat_col)) {
    stat_col <- stat
  }

  if (!is_string(player_col) || !is_string(stat_col)) {
    stop(
      "`player_col` and `stat_col` must be single column-name strings.",
      call. = FALSE
    )
  }

  if (!is.null(team_col) && !is_string(team_col)) {
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

  required <- c(player_col, team_col, stat_col)
  missing <- setdiff(required, names(data))

  if (length(missing) > 0L) {
    stop(
      paste("Missing required columns:", paste(missing, collapse = ", ")),
      call. = FALSE
    )
  }

  values <- data[[stat_col]]

  if (!is.numeric(values) || !is.null(dim(values))) {
    stop(
      paste0("Column `", stat_col, "` must be a numeric vector."),
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

  values <- values[keep]

  if (any(values < 0)) {
    stop("Goalie statistics must be non-negative.", call. = FALSE)
  }

  if (stat == "SAV%") {
    if (
      !is_string(save_pct_scale) ||
      !save_pct_scale %in% c("proportion", "percent")
    ) {
      stop(
        '`save_pct_scale` must be "proportion" or "percent".',
        call. = FALSE
      )
    }

    upper <- if (save_pct_scale == "proportion") 1 else 100

    if (any(values > upper)) {
      stop(
        paste0(
          "Save percentage exceeds ", upper,
          ". Check `save_pct_scale` and the supplied values."
        ),
        call. = FALSE
      )
    }

    if (save_pct_scale == "percent") {
      values <- values / 100
    }
  }

  if (stat == "W" && any(values != floor(values))) {
    stop("Wins must be non-negative whole numbers.", call. = FALSE)
  }

  players <- trimws(as.character(data[[player_col]][keep]))

  if (any(is.na(players) | !nzchar(players))) {
    stop("Goalie names must not be missing or blank.", call. = FALSE)
  }

  labels <- players

  if (!is.null(team_col)) {
    teams <- trimws(as.character(data[[team_col]][keep]))
    has_team <- !is.na(teams) & nzchar(teams)

    labels[has_team] <- paste0(
      players[has_team], " (", teams[has_team], ")"
    )
  }

  plot_data <- data.frame(
    label = labels,
    value = values,
    stringsAsFactors = FALSE
  )

  lower_is_better <- stat == "GAA"
  rank_values <- if (lower_is_better) values else -values
  ordering <- order(rank_values, seq_along(values))

  plot_data <- plot_data[ordering, , drop = FALSE]
  plot_data <- utils::head(plot_data, n)

  ids <- as.character(seq_len(nrow(plot_data)))
  plot_data$row_id <- factor(ids, levels = rev(ids))
  axis_labels <- stats::setNames(plot_data$label, ids)

  metric_label <- switch(
    stat,
    "SAV%" = "Save Percentage",
    "GAA" = "Goals-Against Average",
    "W" = "Wins"
  )

  format_value <- switch(
    stat,
    "SAV%" = function(x) sprintf("%.3f", x),
    "GAA" = function(x) sprintf("%.2f", x),
    "W" = scales::label_number(accuracy = 1, big.mark = ",")
  )

  plot_data$value_label <- format_value(plot_data$value)

  if (is.null(title)) {
    title <- paste("OHL Goalie Leaders:", metric_label)
  }

  if (is.null(subtitle)) {
    subtitle <- if (lower_is_better) {
      "Lower is better | Ranked among supplied goalies"
    } else {
      "Higher is better | Ranked among supplied goalies"
    }
  }

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = .data$value, y = .data$row_id)
  ) +
    ggplot2::geom_point(
      colour = colour,
      size = 3.5
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$value_label),
      hjust = -0.35,
      fontface = "bold",
      colour = "#142D4E",
      size = 3.8
    ) +
    ggplot2::scale_y_discrete(labels = axis_labels) +
    ggplot2::scale_x_continuous(
      labels = format_value,
      expand = ggplot2::expansion(mult = c(0.12, 0.35))
    ) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = metric_label,
      y = NULL,
      caption = caption
    ) +
    theme_ohl() +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank()
    )
}
