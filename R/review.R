#' Initialise a review
#'
#' Creates a new review state for a reviewable variable or an existing
#' review state in a `claims_df`. The current values are copied into a new
#' review column placed immediately after its predecessor.
#'
#' @details
#' `review()` creates a new review state by allocating a new review column.
#' If `review_id` is supplied, it is used as the suffix of the new review
#' column. Otherwise, the review sequence number is used. It is also
#' possible to assign a human-readable `label` describing the intended
#' review task. The label serves both as an instruction for reviewers
#' during interactive review workflows and as a description of the review
#' activity once the review has been completed.
#'
#' In contrast, `document()` records provenance describing how a revision
#' was produced. It records information such as the review activity, the
#' responsible reviewer or software agent, supporting resources, and
#' optional reviewer comments explaining how the task was interpreted or
#' why particular review decisions were made.
#'
#' Together, `review()` and `document()` separate the definition of a
#' review task from the documentation of its execution, supporting
#' reproducible, explainable, and auditable review workflows.
#'
#' @param .data A `claims_df`.
#' @param review_var Character scalar identifying the current review state.
#'   A reviewable variable name is treated as shorthand for its
#'   corresponding `_candidate` column. Alternatively, an existing review
#'   column may be supplied to continue a multi-stage review workflow.
#' @param review_id Optional identifier for the new review state.
#'   It becomes the suffix of the new review column. If omitted,
#'   the review sequence number is used.
#' @param obs_status Optional observation status assigned to new review
#'   values.
#' @param label Optional human-readable label describing the review task.
#'   Before review, the label provides instructions to the reviewer.
#'   After review, it identifies the completed review activity.
#'
#' @return
#' A `claims_df` with one additional review round.
#'
#' @examples
#' claims <- claims_df(
#'   Orange,
#'   scope_var = "age",
#'   subject_var = "Tree"
#' )
#'
#' # Create an initial review.
#' reviewed <- claims |>
#'   review(
#'     "circumference", # equal to: circumference_candidate
#'     review_id = "remeasured",
#'     label = "Remeasure the circumference of each tree at the recorded age."
#'   )
#'
#' # Continue the review.
#' reviewed <- reviewed |>
#'   review(
#'     "circumference_remeasured",
#'     review_id = "reviewed",
#'     label = "Verify the remeasurement independently."
#'   )
#'
#' names(reviewed)
#'
#' attr(reviewed, "review_label")
#' @export
review <- function(
  .data,
  review_var,
  review_id = NULL,
  obs_status = NULL,
  label = NULL
) {
  if (!inherits(.data, "claims_df")) {
    stop(".data must be created with claims_df()", call. = FALSE)
  }

  ## Cache attributes ------------------------------------------------

  id <- attr(.data, "id")
  scope <- attr(.data, "scope")
  subject <- attr(.data, "subject")
  reviewable <- attr(.data, "reviewable")

  review_label <- attr(.data, "review_label")

  review_label <- attr(.data, "review_label")
  if (is.null(review_label)) {
    review_label <- character(0)
  }

  review_sequence <- attr(.data, "review_sequence")

  if (is.null(review_sequence) || length(review_sequence) == 0L) {
    stop(
      "Review sequence is missing. Did you create .data with claims_df()?",
      call. = FALSE
    )
  }

  prov_id <- attr(.data, "prov_id")
  prov_activity <- attr(.data, "prov_activity")
  prov_agent <- attr(.data, "prov_agent")
  prov_used <- attr(.data, "prov_used")
  prov_comment <- attr(.data, "prov_comment")

  if (review_var %in% reviewable) {
    # Case when the review refers to an "original" variable in one-stage
    review_var <- paste0(review_var, "_candidate")
  }

  if (!review_var %in% names(.data)) {
    # Normally we refer to the candiate by the exact column name:
    stop("Unknown review variable: ", review_var, call. = FALSE)
  }

  next_sequence <- utils::tail(review_sequence, 1) + 1L

  # If not review_id is provided, use the sequence number instead
  if (is.null(review_id) || is.na(review_id) || review_id == "") {
    review_id <- as.character(next_sequence)
  }

  # Current and next state of the variable (vector)
  candidate_column <- review_var

  review_column <- sub(
    "_[^_]+$",
    paste0("_", review_id),
    review_var
  )

  # Initialise the review with identical values
  .data[[review_column]] <- .data[[candidate_column]]

  # .. and relocate the review variable column after the candidate variable
  .data <- dplyr::relocate(
    .data,
    dplyr::all_of(review_column),
    .after = dplyr::all_of(candidate_column)
  )

  ## Carry forward observation status -------------------------------

  previous_status <- paste0(candidate_column, "_status")
  current_status <- paste0(review_column, "_status")

  if (previous_status %in% names(.data)) {
    # Carry forward an existing observation status.
    .data[[current_status]] <- .data[[previous_status]]
  } else if (!is.null(obs_status)) {
    # Initialise observation status. Subsequent review rounds inherit it.
    .data[[current_status]] <- rep(obs_status, nrow(.data))
  }

  if (current_status %in% names(.data)) {
    .data <- dplyr::relocate(
      .data,
      dplyr::all_of(current_status),
      .after = dplyr::all_of(review_column)
    )
  }

  ## Restore and update metadata -------------------------------------

  attr(.data, "id") <- id
  attr(.data, "scope") <- scope
  attr(.data, "subject") <- subject

  attr(.data, "reviewable") <- reviewable

  attr(.data, "prov_id") <- c(prov_id, review_column)
  empty <- stats::setNames(NA_character_, review_column)

  attr(.data, "prov_activity") <- c(prov_activity, empty)
  attr(.data, "prov_agent") <- c(prov_agent, empty)
  attr(.data, "prov_used") <- c(prov_used, empty)
  attr(.data, "prov_comment") <- c(prov_comment, empty)

  if (is.null(review_label)) {
    review_label <- stats::setNames(NA_character_, "candidate")
  }

  if (is.null(review_sequence)) {
    review_sequence <- stats::setNames(0L, "candidate")
  }

  attr(.data, "review_label") <- c(
    review_label,
    stats::setNames(
      if (is.null(label)) NA_character_ else label,
      review_id
    )
  )

  attr(.data, "review_sequence") <- c(
    review_sequence,
    stats::setNames(next_sequence, review_id)
  )

  .data
}
