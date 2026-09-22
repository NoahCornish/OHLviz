# OHLviz 0.1.0

Initial release.

## Visualizations

* Added `plot_scoring_leaders()` for player scoring leaderboards,
  with configurable statistics, player limits, and column names.
* Added `plot_team_scoring()` for stacked goals-and-assists charts
  within a selected team.
* Added `plot_goalie_leaders()` for save percentage,
  goals-against average, and wins, with metric-specific ranking
  and formatting.
* Added `theme_ohl()` for consistent chart styling.

## Customization

* Plotting functions accept data frames and return ggplot objects.
* Default column names support OHLpkg output.
* Charts support custom titles, subtitles, captions, and colours.
* Goalie save percentages support explicitly specified proportion
  or percentage inputs.

## Documentation and testing

* Added function documentation and runnable offline examples.
* Added a README with a chart gallery and OHLpkg workflow examples.
* Added automated tests for ranking, filtering, formatting,
  input validation, and preservation of supplied data.
