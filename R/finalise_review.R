#' Finalise a review
#'
#' Promotes the most recently reviewed values to the current candidate
#' claims.
#'
#' @details
#' `finalise_review()` accepts the most recent review round by replacing
#' each `_candidate` value with the corresponding reviewed value. Earlier
#' review columns remain unchanged, preserving the complete review
#' history.
#'
#' Finalising a review resets the current review target to the updated
#' candidate values. Existing provenance metadata, review labels, review
#' comments and earlier review rounds are retained, allowing the complete
#' review process to be reconstructed.
#'
#' @param .data A `claims_df`.
#'
#' @return
#' A `claims_df` with updated candidate values.
#'
#' @examples
#' reviewed <- claims_df(
#'   Orange,
#'   scope_var = "age",
#'   subject_var = "Tree"
#' ) |>
#'   review("circumference")
#'
#' reviewed$circumference_review_1 <- reviewed$circumference_review_1 + 1
#'
#' accepted <- finalise_review(reviewed)
#'
#' accepted$circumference_candidate
#'
#' @export
finalise_review <- function(.data) {
  if (!inherits(.data, "claims_df")) {
    stop(".data must be created with claims_df()", call. = FALSE)
  }

  ## Cache review metadata --------------------------------------------

  reviewable <- attr(.data, "reviewable")
  review_columns <- attr(.data, "review_column")

  candidate_columns <- stats::setNames(
    paste0(reviewable, "_candidate"),
    reviewable
  )

  ## Promote reviewed values ------------------------------------------

  for (var in reviewable) {
    .data[[candidate_columns[[var]]]] <-
      .data[[review_columns[[var]]]]
  }

  ## Reset review pointers --------------------------------------------

  attr(.data, "review_column") <- candidate_columns

  .data
}
