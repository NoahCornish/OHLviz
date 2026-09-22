# Apply the OHLviz Chart Theme

A complete ggplot2 theme with a white background, navy text, subtle
gridlines, and left-aligned titles and captions.

## Usage

``` r
theme_ohl(base_size = 12, base_family = "sans")
```

## Arguments

- base_size:

  Base font size in points. Must be a positive number.

- base_family:

  Font family used throughout the chart. Defaults to `"sans"` for
  portability.

## Value

A ggplot2 theme object.

## Examples

``` r
library(ggplot2)

ggplot(mtcars, aes(wt, mpg)) +
  geom_point(colour = "#2474B5", size = 3) +
  labs(
    title = "An OHLviz Theme Example",
    subtitle = "Consistent styling for clear visual comparisons",
    x = "Weight (1,000 lbs)",
    y = "Fuel economy (mpg)",
    caption = "Source: mtcars"
  ) +
  theme_ohl()
```
