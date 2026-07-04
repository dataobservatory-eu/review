#' Initialise the next review cycle
#'
#' Creates a new review workspace from an accepted review.
#'
#' @param .data A `reviewed_df`.
#'
#' @return
#' A `claims_df`.
#'
#' @export
next_revisions <- function(.data) {

  if (!inherits(.data, "reviewed_df")) {
    stop(".data must be created with accept_review().",
         call. = FALSE)
  }

  class(.data) <- setdiff(class(.data), "reviewed_df")

  .data
}
