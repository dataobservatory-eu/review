#' Approve a review
#'
#' Creates an approved state from the current revision.
#'
#' @details
#' `approve()` closes a completed review by copying the most recent
#' revision of each reviewable variable into a corresponding
#' `_approved` column. The original candidate values, intermediate
#' revisions, review labels, and review provenance are preserved.
#'
#' Approval records a separate provenance activity describing the
#' editorial or curatorial decision to approve the reviewed values.
#' The approving agent is typically different from the reviewer who
#' created and explained the revision.
#'
#' An approved review becomes a `reviewed_df`, which may subsequently
#' be converted into a publication-ready object, for example with
#' `dataset_df()`.
#'
#' @param .data A `claims_df`.
#' @param activity Optional approval activity.
#' @param agent Optional approving person or software agent.
#' @param comment Optional approval comment.
#'
#' @return
#' A `reviewed_df`.
#'
#' @export
approve <- function(
    .data,
    activity = "approval",
    agent = NULL,
    comment = NULL
) {

  if (!inherits(.data, "claims_df")) {
    stop(".data must be created with claims_df()", call. = FALSE)
  }

  reviewable <- attr(.data, "reviewable")
  review_sequence <- attr(.data, "review_sequence")

  review_sequence <- review_sequence[names(review_sequence) != "candidate"]
  latest <- names(review_sequence)[which.max(review_sequence)]

  ## Create approved states -------------------------------------------

  for (var in reviewable) {

    revision <- paste0(var, "_", latest)
    approved <- paste0(var, "_approved")

    if (revision %in% names(.data)) {
      .data[[approved]] <- .data[[revision]]
    }

    revision_status <- paste0(revision, "_status")
    approved_status <- paste0(approved, "_status")

    if (revision_status %in% names(.data)) {
      .data[[approved_status]] <- .data[[revision_status]]
    }
  }

  ## Record approval provenance ---------------------------------------

  attr(.data, "approval_activity") <- activity
  attr(.data, "approval_agent") <- as_prov_character(agent)
  attr(.data, "approval_comment") <- comment

  class(.data) <- unique(c("reviewed_df", class(.data)))

  .data
}
