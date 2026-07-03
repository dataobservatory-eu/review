## Code to prepare `review_activity_crosswalk` dataset

review_activity_crosswalk <- data.frame(
  activity = c(
    "corroborate",
    "estimate",
    "forecast",
    "impute",
    "translate",
    "transcribe",
    "reconcile",
    "classify",
    "defer"
  ),
  default_obs_status = c(
    "A",
    "E",
    "F",
    "I",
    "D",
    "D",
    "D",
    "D",
    "P"
  ),
  stringsAsFactors = FALSE
)

usethis::use_data(
  review_activity_crosswalk,
  overwrite = TRUE
)

usethis::use_data(review_activity_crosswalk, overwrite = TRUE)
