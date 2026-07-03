#' Explain a review round
#'
#' Records provenance information for the most recently created review
#' round in a `claims_df`.
#'
#' @details
#' `explain()` documents how a review task was carried out after the
#' review has been completed. It complements `review()`, which creates
#' the review round and assigns a human-readable label describing the
#' intended review task.
#'
#' The recorded provenance may describe the review activity, the person
#' or software agent performing the review, evidence or other resources
#' consulted during the review, and optional reviewer comments explaining
#' how the review task was interpreted or why particular review decisions
#' were made.
#'
#' @param .data A `claims_df`.
#' @param activity Optional type of review activity.
#' @param agent Optional person or software agent carrying out the review.
#' @param used Optional evidence, source or other provenance entity used
#'   during the review.
#' @param comment Optional reviewer comment describing how the review
#'   task was interpreted or why particular review decisions were made.
#'
#' @return
#' A `claims_df` with updated provenance metadata for the most recent
#' review round.
#'
#' @examples
#' reviewed <- claims_df(
#'   Orange,
#'   scope_var = "age",
#'   subject_var = "Tree"
#' ) |>
#'   review(
#'     "circumference",
#'     label = "Remeasure the circumference of each tree."
#'   ) |>
#'   explain(
#'     activity = "manual_review",
#'     agent = person("Jane", "Doe", role = "rev"),
#'     used = "doi:10.5281/zenodo.1234567",
#'     comment = "Measurements verified against the laboratory notebook."
#'   )
#'
#' attr(reviewed, "prov_activity")
#' attr(reviewed, "prov_agent")
#' attr(reviewed, "prov_used")
#' attr(reviewed, "prov_comment")
#'
#' @importFrom utils tail
#' @export
explain <- function(
  .data,
  activity = NULL,
  agent = NULL,
  used = NULL,
  comment = NULL
) {
  if (!inherits(.data, "claims_df")) {
    stop(".data must be created with claims_df()", call. = FALSE)
  }

  ## Cache provenance metadata ----------------------------------------

  review_id <- utils::tail(attr(.data, "prov_id"), 1)

  prov_activity <- attr(.data, "prov_activity")
  prov_agent <- attr(.data, "prov_agent")
  prov_used <- attr(.data, "prov_used")
  prov_comment <- attr(.data, "prov_comment")

  ## Record review provenance -----------------------------------------

  if (!is.null(activity)) {
    prov_activity[review_id] <- activity
  }

  if (!is.null(agent)) {
    prov_agent[review_id] <- as_prov_character(agent)
  }

  if (!is.null(used)) {
    prov_used[review_id] <- as_prov_character(used)
  }

  if (!is.null(comment)) {
    prov_comment[review_id] <- comment
  }

  ## Restore provenance metadata --------------------------------------

  attr(.data, "prov_activity") <- prov_activity
  attr(.data, "prov_agent") <- prov_agent
  attr(.data, "prov_used") <- prov_used
  attr(.data, "prov_comment") <- prov_comment

  .data
}
