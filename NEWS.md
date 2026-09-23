# OHLviz 0.1.0

## Initial release

OHLviz 0.1.0 is the first public release of the package.

OHLviz provides consistent, customizable, publication-quality visualizations for Ontario Hockey League data using `ggplot2`. It is designed to complement `OHLpkg`, while remaining compatible with other data frames through configurable column mappings.

### Visualizations

* Added `plot_scoring_leaders()` for creating ranked player scoring leaderboards.

  * Supports configurable statistics.
  * Supports configurable leaderboard sizes with `n`.
  * Supports custom player, team, and statistic column names.
  * Supports optional team labels.
  * Handles non-finite values with validation and warnings.
  * Returns a standard `ggplot` object.

* Added `plot_team_scoring()` for visualizing player scoring within a selected team.

  * Displays goals and assists as stacked bars.
  * Displays combined scoring totals.
  * Supports configurable player limits.
  * Supports custom column names.
  * Supports custom goals and assists colours.
  * Allows the team argument to be omitted when the supplied data contains exactly one team.

* Added `plot_goalie_leaders()` for ranked goaltender comparisons.

  * Supports save percentage (`SAV%`).
  * Supports goals-against average (`GAA`).
  * Supports wins (`W`).
  * Applies statistic-specific ranking direction.
  * Applies statistic-specific value formatting.
  * Supports both proportion and percentage save-percentage inputs.
  * Supports custom column names.
  * Returns a standard `ggplot` object.

### Themes

* Added `theme_ohl()` as the shared visual theme for OHLviz.
* The theme can be used independently with custom `ggplot2` visualizations.
* Added support for configurable base text size and font family.

### OHLpkg integration

* Default column names are designed to work directly with common `OHLpkg` outputs.
* Added documentation demonstrating workflows using:

  * `OHLpkg::get_Stats()`
  * `OHLpkg::get_GoalieStats()`
* OHLviz intentionally keeps data retrieval separate from visualization.
* Plotting functions accept ordinary data frames and do not require OHLpkg.

### Customization

* Added custom chart titles.
* Added custom subtitles.
* Added custom captions.
* Added configurable chart colours.
* Added configurable column mappings.
* All plotting functions return `ggplot` objects so users can add additional `ggplot2` layers and theme modifications.

### Validation

* Added validation for required columns.
* Added validation for numeric statistic columns.
* Added validation for supported goalie statistics.
* Added handling of missing and non-finite statistic values.
* Added validation of supplied teams and plotting parameters.

### Documentation

* Added package README.
* Added installation instructions.
* Added quick-start examples.
* Added scoring leaderboard examples.
* Added team scoring examples.
* Added goaltender leaderboard examples.
* Added OHLpkg workflow examples.
* Added custom-column examples.
* Added chart customization examples.
* Added chart export examples.
* Added a getting-started vignette.
* Added pkgdown configuration and package website support.

### Testing

* Added automated tests using `testthat`.
* Added tests covering:

  * ranking behaviour
  * team filtering
  * goalie ranking direction
  * statistic formatting
  * input validation
  * missing values
  * preservation of supplied data

### Package infrastructure

* Established the initial OHLviz package structure.
* Added package metadata and MIT licensing.
* Added GitHub repository and issue-tracking links.
* Added roxygen2-generated documentation.
* Added pkgdown website configuration.
* Added development infrastructure for future OHL visualization functionality.
