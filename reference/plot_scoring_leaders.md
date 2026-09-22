# Plot Scoring Leaders

Create a horizontal leaderboard from a data frame of player statistics.
Defaults match the column names returned by OHLpkg.

## Usage

``` r
plot_scoring_leaders(
  data,
  stat = "PTS",
  n = 10,
  player_col = "Name",
  team_col = "Team",
  title = "OHL Scoring Leaders",
  subtitle = NULL,
  caption = NULL,
  colour = "#2474B5"
)
```

## Arguments

- data:

  A data frame with one row per player for one season. Resolve duplicate
  player records or team splits before plotting.

- stat:

  Name of the numeric statistic column. Defaults to `"PTS"`.

- n:

  Maximum number of players to display. Defaults to 10.

- player_col:

  Name of the player-name column.

- team_col:

  Name of the team column, or `NULL` to omit team labels.

- title:

  Chart title.

- subtitle:

  Optional chart subtitle.

- caption:

  Optional chart caption.

- colour:

  Bar fill colour.

## Value

A ggplot object.

## Details

Players are ranked from highest to lowest. Ties are resolved by input
row order. Missing or non-finite statistic values are omitted with a
warning. Negative values are not supported.

## Examples

``` r
players <- data.frame(
  Name = c("Player A", "Player B", "Player C"),
  Team = c("Team A", "Team B", "Team C"),
  G = c(35, 28, 31),
  PTS = c(82, 76, 70)
)

plot_scoring_leaders(players)

plot_scoring_leaders(players, stat = "G", n = 2)
```
