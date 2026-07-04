#' Explain a review state
#'
#' Records provenance information describing how a review state was
#' produced.
#'
#' @details
#' `explain()` documents how a review activity was carried out after the
#' review has been completed. It complements `review()`, which creates a
#' new review state and optionally assigns a human-readable label
#' describing the intended review task.
#'
#' The recorded provenance may describe the review activity, the person
#' or software agent performing the review, evidence or other resources
#' consulted during the review, and optional reviewer comments explaining
#' how the review task was interpreted or why particular review decisions
#' were made.
#'
#' @param .data A `claims_df`.
#' @param result Identifier of the review state being explained.
#' @param activity Optional type of review activity.
#' @param agent Optional person or software agent carrying out the review.
#' @param used Optional evidence, source or other provenance entity used
#'   during the review.
#' @param comment Optional reviewer comment describing how the review
#'   task was interpreted or why particular review decisions were made.
#'
#' @return
#' A `claims_df` with updated provenance metadata for the specified
#' review state.
#'
#' @examples
#' reviewed <- claims_df(
#'   Orange,
#'   scope_var = "age",
#'   subject_var = "Tree"
#' ) |>
#'   review(
#'     "circumference",
#'     review_id = "remeasured",
#'     label = "Remeasure the circumference of each tree."
#'   ) |>
#'   explain(
#'     result = "remeasured",
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
    result,
    activity = NULL,
    agent = NULL,
    used = NULL,
    comment = NULL
) {
  if (!inherits(.data, "claims_df")) {
    stop(".data must be created with claims_df()", call. = FALSE)
  }

  ## Validate review state --------------------------------------------

  prov_id <- attr(.data, "prov_id")

  if (!result %in% prov_id) {
    stop("Unknown review state: ", result, call. = FALSE)
  }

  ## Cache provenance metadata ----------------------------------------

  prov_activity <- attr(.data, "prov_activity")
  prov_agent <- attr(.data, "prov_agent")
  prov_used <- attr(.data, "prov_used")
  prov_comment <- attr(.data, "prov_comment")

  if (is.null(prov_comment)) {
    prov_comment <- stats::setNames(
      rep(NA_character_, length(prov_id)),
      prov_id
    )
  }

  ## Record review provenance -----------------------------------------

  if (!is.null(activity)) {
    prov_activity[result] <- activity
  }

  if (!is.null(agent)) {
    prov_agent[result] <- as_prov_character(agent)
  }

  if (!is.null(used)) {
    prov_used[result] <- as_prov_character(used)
  }

  if (!is.null(comment)) {
    prov_comment[result] <- comment
  }

  ## Restore provenance metadata --------------------------------------

  attr(.data, "prov_activity") <- prov_activity
  attr(.data, "prov_agent") <- prov_agent
  attr(.data, "prov_used") <- prov_used
  attr(.data, "prov_comment") <- prov_comment

  .data
}
