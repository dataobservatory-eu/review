
<!-- README.md is generated from README.Rmd. Please edit that file -->

# review

<!-- badges: start -->

[![lifecycle](https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Project Status:
WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![devel-version](https://img.shields.io/badge/devel%20version-0.0.1-blue.svg)](https://github.com/dataobservatory-eu/fscontext/tree/devel)
[![dataobservatory](https://img.shields.io/badge/ecosystem-dataobservatory.eu-3EA135.svg)](https://dataobservatory.eu/)

<!-- badges: end -->

**review** provides a tidy relational algebra for iterative semantic
review of tabular data.

Rather than overwriting reviewed values, the package creates successive
review rounds that preserve candidate values, review history, reviewer
provenance, and observation status. It is designed for reproducible
review workflows in official statistics, digital humanities, archives,
and other data-intensive disciplines.

## Installation

Install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("dataobservatory-eu/review")
```

## Review workflow

The review algebra consists of four operations.

``` text
claims_df()
      ↓
review()
      ↓
explain()
      ↓
finalise_review()
```

- `claims_df()` creates reviewable claims from an ordinary data frame.
- `review()` allocates one or more review rounds.
- `explain()` records provenance for each review round.
- `finalise_review()` promotes the current review into the next
  candidate version.

## Example

``` r
library(review)

claims <- claims_df(
  Orange,
  scope_var = "age",
  subject_var = "Tree"
)

reviewed <- claims |>
  review("circumference")

reviewed$circumference_review_1[1] <- 31

reviewed <- reviewed |>
  explain(
    activity = "manual review",
    agent = person("Jane", "Doe", role = "rev"),
    used = "doi:10.5281/zenodo.1234567"
  ) |>
  finalise_review()

reviewed
#>    claim_id  age Tree circumference_candidate circumference_review_1
#> 1         1  118    1                      31                     31
#> 2         2  484    1                      58                     58
#> 3         3  664    1                      87                     87
#> 4         4 1004    1                     115                    115
#> 5         5 1231    1                     120                    120
#> 6         6 1372    1                     142                    142
#> 7         7 1582    1                     145                    145
#> 8         8  118    2                      33                     33
#> 9         9  484    2                      69                     69
#> 10       10  664    2                     111                    111
#> 11       11 1004    2                     156                    156
#> 12       12 1231    2                     172                    172
#> 13       13 1372    2                     203                    203
#> 14       14 1582    2                     203                    203
#> 15       15  118    3                      30                     30
#> 16       16  484    3                      51                     51
#> 17       17  664    3                      75                     75
#> 18       18 1004    3                     108                    108
#> 19       19 1231    3                     115                    115
#> 20       20 1372    3                     139                    139
#> 21       21 1582    3                     140                    140
#> 22       22  118    4                      32                     32
#> 23       23  484    4                      62                     62
#> 24       24  664    4                     112                    112
#> 25       25 1004    4                     167                    167
#> 26       26 1231    4                     179                    179
#> 27       27 1372    4                     209                    209
#> 28       28 1582    4                     214                    214
#> 29       29  118    5                      30                     30
#> 30       30  484    5                      49                     49
#> 31       31  664    5                      81                     81
#> 32       32 1004    5                     125                    125
#> 33       33 1231    5                     142                    142
#> 34       34 1372    5                     174                    174
#> 35       35 1582    5                     177                    177
```

For a complete introduction, see the **Review Algebra** vignette.

- Website: <https://review.dataobservatory.eu/>
- Issues: <https://github.com/dataobservatory-eu/review/issues>
