#' Apply the OHLviz Chart Theme
#'
#' A complete ggplot2 theme with a white background, navy text,
#' subtle gridlines, and left-aligned titles and captions.
#'
#' @param base_size Base font size in points. Must be a positive number.
#' @param base_family Font family used throughout the chart.
#'   Defaults to `"sans"` for portability.
#'
#' @return A ggplot2 theme object.
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point(colour = "#2474B5", size = 3) +
#'   labs(
#'     title = "An OHLviz Theme Example",
#'     subtitle = "Consistent styling for clear visual comparisons",
#'     x = "Weight (1,000 lbs)",
#'     y = "Fuel economy (mpg)",
#'     caption = "Source: mtcars"
#'   ) +
#'   theme_ohl()
theme_ohl <- function(base_size = 12, base_family = "sans") {
  if (
    !is.numeric(base_size) ||
    length(base_size) != 1L ||
    !is.finite(base_size) ||
    base_size <= 0
  ) {
    stop("`base_size` must be a single positive number.", call. = FALSE)
  }

  if (
    !is.character(base_family) ||
    length(base_family) != 1L ||
    is.na(base_family)
  ) {
    stop("`base_family` must be a single character string.", call. = FALSE)
  }

  navy <- "#142D4E"
  grey <- "#596779"
  grid <- "#E5EAF0"

  ggplot2::theme_minimal(
    base_size = base_size,
    base_family = base_family
  ) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = navy),

      plot.background = ggplot2::element_rect(
        fill = "white",
        colour = NA
      ),
      panel.background = ggplot2::element_rect(
        fill = "white",
        colour = NA
      ),

      plot.title = ggplot2::element_text(
        size = ggplot2::rel(1.5),
        face = "bold",
        hjust = 0,
        margin = ggplot2::margin(b = 6)
      ),
      plot.subtitle = ggplot2::element_text(
        size = ggplot2::rel(1),
        colour = grey,
        hjust = 0,
        margin = ggplot2::margin(b = 14)
      ),
      plot.caption = ggplot2::element_text(
        size = ggplot2::rel(0.8),
        colour = grey,
        hjust = 0,
        margin = ggplot2::margin(t = 12)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.margin = ggplot2::margin(16, 18, 16, 18),

      axis.title = ggplot2::element_text(
        size = ggplot2::rel(0.95),
        face = "bold"
      ),
      axis.title.x = ggplot2::element_text(
        margin = ggplot2::margin(t = 10)
      ),
      axis.title.y = ggplot2::element_text(
        margin = ggplot2::margin(r = 10)
      ),
      axis.text = ggplot2::element_text(
        size = ggplot2::rel(0.9),
        colour = grey
      ),
      axis.ticks = ggplot2::element_blank(),

      panel.grid.major = ggplot2::element_line(
        colour = grid,
        linewidth = 0.35
      ),
      panel.grid.minor = ggplot2::element_blank(),

      legend.position = "bottom",
      legend.title = ggplot2::element_text(
        size = ggplot2::rel(0.9),
        face = "bold"
      ),
      legend.text = ggplot2::element_text(
        size = ggplot2::rel(0.85)
      ),
      legend.background = ggplot2::element_blank(),
      legend.key = ggplot2::element_blank(),

      strip.background = ggplot2::element_rect(
        fill = "#F0F4F8",
        colour = NA
      ),
      strip.text = ggplot2::element_text(
        face = "bold",
        colour = navy,
        margin = ggplot2::margin(8, 8, 8, 8)
      )
    )
}
