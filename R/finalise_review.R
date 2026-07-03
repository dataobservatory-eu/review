#' Finalise a review
#'
#' Promotes the most recent reviewed values to the current claims.
#' The review history and provenance metadata are preserved.
#'
#' @param .data A `claims_df`.
#'
#' @return
#' A `claims_df`.
#'
#' @export
finalise_review <- function(.data) {

  if (!inherits(.data, "claims_df")) {
    stop(
      ".data must be created with claims_df()",
      call. = FALSE
    )
  }

  reviewable <- attr(.data, "reviewable")
  review_column <- attr(.data, "review_column")

  for (var in reviewable) {
    .data[[paste0(var, "_candidate")]] <-
      .data[[review_column[[var]]]]
  }

  attr(.data, "review_column") <-
    stats::setNames(
      paste0(reviewable, "_candidate"),
      reviewable
    )

  .data
}
