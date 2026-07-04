#' Accept a review
#'
#' Promotes a reviewed state to the current candidate values.
#'
#' @details
#' `accept()` accepts a completed review by replacing each
#' `_candidate` value with the corresponding reviewed value. Earlier review
#' states remain unchanged, preserving the complete review history.
#'
#' By default, the most recent review state is accepted. Alternatively,
#' `result` may be used to accept an earlier review state explicitly.
#'
#' Accepting a review updates only the candidate values. Existing review
#' states, provenance metadata, review labels, and reviewer comments are
#' preserved, allowing the complete review process to be reconstructed.
#'
#' @param .data A `claims_df`.
#' @param result Optional identifier of the review state to accept. If
#'   omitted, the most recent review state is accepted.
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
#'   review(
#'     "circumference",
#'     review_id = "remeasured"
#'   )
#'
#' reviewed$circumference_remeasured <-
#'   reviewed$circumference_remeasured + 1
#'
#' accepted <- accept(reviewed)
#'
#' accepted$circumference_candidate
#'
#' @export
accept <- function(
    .data,
    result = NULL
) {

  if (!inherits(.data, "claims_df")) {
    stop(".data must be created with claims_df()", call. = FALSE)
  }

  reviewable <- attr(.data, "reviewable")
  review_sequence <- attr(.data, "review_sequence")

  if (is.null(review_sequence) || length(review_sequence) == 0L) {
    stop(
      "Review sequence is missing.",
      call. = FALSE
    )
  }

  ## Accept the most recent review by default -------------------------

  if (is.null(result)) {
    review_sequence <- review_sequence[names(review_sequence) != "candidate"]
    result <- names(review_sequence)[which.max(review_sequence)]
  }

  ## Promote reviewed values -----------------------------------------

  for (var in reviewable) {

    review_column <- paste0(var, "_", result)
    candidate_column <- paste0(var, "_candidate")

    if (review_column %in% names(.data)) {
      .data[[candidate_column]] <- .data[[review_column]]
    }

    review_status <- paste0(review_column, "_status")
    candidate_status <- paste0(candidate_column, "_status")

    if (review_status %in% names(.data)) {
      .data[[candidate_status]] <- .data[[review_status]]
    }
  }

  class(.data) <- unique(c("reviewed_df", class(.data)))

  .data
}
