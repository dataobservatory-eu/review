#' Explain a review round
#'
#' Records provenance information for the most recently created review
#' round.
#'
#' @param .data A `claims_df`.
#' @param activity Review activity.
#' @param agent Person or software carrying out the review.
#' @param used Optional evidence, source or other provenance entity.
#'
#' @return
#' A `claims_df`.
#'
#' @export
explain <- function(
  .data,
  activity = NULL,
  agent = NULL,
  used = NULL
) {
  if (!inherits(.data, "claims_df")) {
    stop(
      ".data must be created with claims_df()",
      call. = FALSE
    )
  }

  review_id <- tail(attr(.data, "prov_id"), 1)

  prov_activity <- attr(.data, "prov_activity")
  prov_agent <- attr(.data, "prov_agent")
  prov_used <- attr(.data, "prov_used")

  if (!is.null(activity)) {
    prov_activity[review_id] <- activity
  }

  if (!is.null(agent)) {
    prov_agent[review_id] <- as_prov_character(agent)
  }

  if (!is.null(used)) {
    prov_used[review_id] <- as_prov_character(used)
  }

  attr(.data, "prov_activity") <- prov_activity
  attr(.data, "prov_agent") <- prov_agent
  attr(.data, "prov_used") <- prov_used

  .data
}
