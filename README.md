
<!-- README.md is generated from README.Rmd. Please edit that file -->

# review

<!-- badges: start -->

[![lifecycle](https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Project Status:
WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![devel-version](https://img.shields.io/badge/devel%20version-0.0.2-blue.svg)](https://github.com/dataobservatory-eu/review/tree/devel)
[![dataobservatory](https://img.shields.io/badge/ecosystem-dataobservatory.eu-3EA135.svg)](https://dataobservatory.eu/)
[![R-CMD-check](https://github.com/dataobservatory-eu/review/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dataobservatory-eu/review/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/dataobservatory-eu/review/graph/badge.svg)](https://app.codecov.io/gh/dataobservatory-eu/review)
<!-- badges: end -->

**review** a tidy relational algebra and a dual extension of the
*tidyverse* data model for iterative semantic review of tabular data.

The package provides a vectorised review workspace for creating,
reviewing, documenting, and finalising semantic claims while remaining
compatible with ordinary data frames. Rather than prescribing how
reviews are carried out, it supports reproducible review workflows that
integrate naturally with external tools such as spreadsheets, databases,
and interactive review interfaces.

Although it is not an ontology toolkit, its design is informed by
provenance, policy, and statistical quality-control models, allowing
review histories to be audited, serialised, compared with expected
review activities, and exchanged in a reproducible form.

## Installation

Install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("dataobservatory-eu/review")
```

## Review workflow

The review package provides four verbs for reproducible semantic review.

``` text
  data
   ↓
revisions()
   ↓
review()
   ↓
document()
   ↓
approve()
```

- `claims_df()` creates reviewable claims from an ordinary data frame.

<!-- -->

- `review()` allocates a review round and labels the intended review
  task.

<!-- -->

- `document()` records how the review was carried out, including
  provenance and optional reviewer comments.

<!-- -->

- `finalise_review()` approves the reviewed values as the current
  candidate claims while preserving the complete review history.

## Example

``` r
library(review)

claims <- revisions(
  Orange,
  scope_var = "age",
  subject_var = "Tree"
)

reviewed <- claims |>
  review(
    "circumference",
    label = "Remeasure the circumference of each tree."
  )

reviewed$circumference_review_1[1] <- 31

reviewed <- reviewed |>
  document(
    revision = "circumference_review_1",
    agent = person("Jane", "Doe", role = "rev"),
    used = "doi:10.5281/zenodo.1234567",
    comment = "Verified against the laboratory notebook."
  ) |>
  approve()

reviewed
#>    claim_id  age Tree circumference_candidate circumference_1
#> 1         1  118    1                      30              30
#> 2         2  484    1                      58              58
#> 3         3  664    1                      87              87
#> 4         4 1004    1                     115             115
#> 5         5 1231    1                     120             120
#> 6         6 1372    1                     142             142
#> 7         7 1582    1                     145             145
#> 8         8  118    2                      33              33
#> 9         9  484    2                      69              69
#> 10       10  664    2                     111             111
#> 11       11 1004    2                     156             156
#> 12       12 1231    2                     172             172
#> 13       13 1372    2                     203             203
#> 14       14 1582    2                     203             203
#> 15       15  118    3                      30              30
#> 16       16  484    3                      51              51
#> 17       17  664    3                      75              75
#> 18       18 1004    3                     108             108
#> 19       19 1231    3                     115             115
#> 20       20 1372    3                     139             139
#> 21       21 1582    3                     140             140
#> 22       22  118    4                      32              32
#> 23       23  484    4                      62              62
#> 24       24  664    4                     112             112
#> 25       25 1004    4                     167             167
#> 26       26 1231    4                     179             179
#> 27       27 1372    4                     209             209
#> 28       28 1582    4                     214             214
#> 29       29  118    5                      30              30
#> 30       30  484    5                      49              49
#> 31       31  664    5                      81              81
#> 32       32 1004    5                     125             125
#> 33       33 1231    5                     142             142
#> 34       34 1372    5                     174             174
#> 35       35 1582    5                     177             177
#>    circumference_review_1 circumference_approved
#> 1                      31                     30
#> 2                      31                     58
#> 3                      31                     87
#> 4                      31                    115
#> 5                      31                    120
#> 6                      31                    142
#> 7                      31                    145
#> 8                      31                     33
#> 9                      31                     69
#> 10                     31                    111
#> 11                     31                    156
#> 12                     31                    172
#> 13                     31                    203
#> 14                     31                    203
#> 15                     31                     30
#> 16                     31                     51
#> 17                     31                     75
#> 18                     31                    108
#> 19                     31                    115
#> 20                     31                    139
#> 21                     31                    140
#> 22                     31                     32
#> 23                     31                     62
#> 24                     31                    112
#> 25                     31                    167
#> 26                     31                    179
#> 27                     31                    209
#> 28                     31                    214
#> 29                     31                     30
#> 30                     31                     49
#> 31                     31                     81
#> 32                     31                    125
#> 33                     31                    142
#> 34                     31                    174
#> 35                     31                    177
```

## Learn more

The package includes three introductory vignettes:

- [The Review
  Algebra](https://review.dataobservatory.eu/articles/intro.html)
  introduces the four review verbs and demonstrates a complete review
  workflow.

- [From Review Algebra to Provenance
  Modelling](https://review.dataobservatory.eu/articles/prov.html)
  explains the underlying provenance model and its relationship to the
  W3C PROV data model.

- [Review Workflows in the
  Tidyverse](https://review.dataobservatory.eu/articles/tidyverse.html)
  how the review algebra integrates naturally into ordinary tidyverse
  workflows. The package extends tidy workflows with review states and
  provenance while preserving compatibility with familiar data-frame
  operations.

You can read them by clicking to the links to the package website, or,
after installing the package, open them with:

``` r
vignette("review")
vignette("prov")
```

## Contributing

Contributions are welcome.

Please read the following documents before submitting pull requests:

- **Contributor Covenant Code of Conduct**

- **Contributing Guidelines** (`CONTRIBUTING.md`)

- **Coding Guidelines** (`CODING-GUIDELINES.md`)

## Project links

- Website: <https://review.dataobservatory.eu/>

- Issues: <https://github.com/dataobservatory-eu/review/issues>
