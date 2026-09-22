# Plot Goalie Leaders

Create a ranked dot chart of goalie statistics. Defaults match the
column names returned by OHLpkg.

## Usage

``` r
plot_goalie_leaders(
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
)
```

## Arguments

- data:

  A data frame with one row per goalie for one season. Apply
  qualification filters and resolve duplicate records beforehand.

- stat:

  Statistic to display: `"SAV%"`, `"GAA"`, or `"W"`.

- n:

  Maximum number of goalies to display.

- player_col:

  Name of the goalie-name column.

- team_col:

  Name of the team column, or `NULL` to omit team labels.

- stat_col:

  Name of the statistic column. If `NULL`, uses `stat`.

- save_pct_scale:

  Input units for save percentage: `"proportion"` for values such as
  0.915, or `"percent"` for 91.5. Used only when `stat = "SAV%"`.

- title:

  Chart title. If `NULL`, uses the selected statistic.

- subtitle:

  Optional subtitle. If `NULL`, describes ranking direction.

- caption:

  Optional chart caption.

- colour:

  Point colour.

## Value

A ggplot object.

## Details

Save percentage and wins are ranked highest first. Goals-against average
is ranked lowest first. Ties preserve input row order. Missing or
non-finite statistic values are omitted with a warning.

Save percentage is displayed as a proportion with three decimal places.
GAA is displayed with two decimal places. Wins must be non-negative
whole numbers. The horizontal axis is fitted to the selected values and
does not necessarily start at zero.

## Examples

``` r
goalies <- data.frame(
  Name = c("Goalie A", "Goalie B", "Goalie C"),
  Team = c("Team A", "Team B", "Team C"),
  GAA = c(2.45, 2.70, 2.30),
  W = c(25, 30, 22)
)
goalies[["SAV%"]] <- c(0.915, 0.908, 0.921)

plot_goalie_leaders(goalies)

plot_goalie_leaders(goalies, stat = "GAA")
```
