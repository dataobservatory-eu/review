#' Document a revision
#'
#' Records provenance information describing how a revision was produced.
#'
#' @details
#' `document()` records provenance describing how a revision was created
#' after the review has been carried out. It complements `review()`,
#' which allocates a new revision and optionally assigns a human-readable
#' label describing the intended review task.
#'
#' The recorded provenance may describe the review activity, the person
#' or software agent performing the review, evidence or other resources
#' consulted during the review, and optional reviewer comments explaining
#' how the review was carried out or why particular review decisions were
#' made.
#'
#' By making review activities explicit, `document()` improves the
#' explainability, reproducibility, and auditability of review workflows.
#' The recorded provenance also provides a foundation for future
#' implementations of the `dplyr::explain()` generic for `review`
#' objects.
#'
#' @param .data A `claims_df`.
#' @param revision Character scalar identifying the revision to document,
#'   for example `"height_remeasured"` or
#'   `"circumference_reviewed"`.
#' @param activity Optional type of review activity.
#' @param agent Optional person or software agent carrying out the review.
#' @param used Optional evidence, source or other provenance entity used
#'   during the review.
#' @param comment Optional reviewer comment.
#'
#' @return
#' A `claims_df` with updated provenance metadata for the specified
#' revision.
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
#'   document(
#'     revision = "circumference_remeasured",
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
#' @export
document <- function(
  .data,
  revision,
  activity = NULL,
  agent = NULL,
  used = NULL,
  comment = NULL
) {
  if (!inherits(.data, "claims_df")) {
    stop(".data must be created with claims_df()", call. = FALSE)
  }

  revision <- as.character(revision)

  ## Cache provenance metadata ----------------------------------------

  prov_activity <- attr(.data, "prov_activity")
  prov_agent <- attr(.data, "prov_agent")
  prov_used <- attr(.data, "prov_used")
  prov_comment <- attr(.data, "prov_comment")

  ## Record provenance ------------------------------------------------

  if (!is.null(activity)) {
    prov_activity[revision] <- activity
  }

  if (!is.null(agent)) {
    prov_agent[revision] <- as_prov_character(agent)
  }

  if (!is.null(used)) {
    prov_used[revision] <- as_prov_character(used)
  }

  if (!is.null(comment)) {
    prov_comment[revision] <- comment
  }

  ## Restore provenance metadata --------------------------------------

  attr(.data, "prov_activity") <- prov_activity
  attr(.data, "prov_agent") <- prov_agent
  attr(.data, "prov_used") <- prov_used
  attr(.data, "prov_comment") <- prov_comment

  .data
}
