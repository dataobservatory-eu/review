#' Initialise a review round
#'
#'  Creates a new review round for a reviewable variable in a
#' `claims_df`. The current review values are copied into new review
#' columns placed immediately after their predecessors.
#'
#' @details
#' `review()` creates a new review round by allocating review columns and
#' assigning a human-readable `label` describing the intended review task.
#' The label serves both as an instruction for reviewers in interactive
#' review workflows and as the label of the review activity once the review
#' has been completed.
#'
#' In contrast, `explain()` documents how the review activity was carried
#' out. It records provenance information such as the activity type, the
#' responsible reviewer or software agent, resources used during the review,
#' and optional reviewer comments explaining how the task was interpreted or
#' why particular review decisions were made.
#'
#' Together, `review()` and `explain()` separate the design of a review
#' activity from its execution while supporting reproducible review
#' workflows.
#'
#' @param .data A `claims_df`.
#' @param review_var A reviewable variable in `.data`.
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
#' reviewed <- claims |>
#'   review(
#'     "circumference",
#'     label = "Remeasure the circumference of each tree at the recorded age."
#'   )
#'
#' attr(reviewed, "review_label")
#' @export
review <- function(
  .data,
  review_var,
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

  review_columns <- attr(.data, "review_column")
  review_label <- attr(.data, "review_label")

  prov_id <- attr(.data, "prov_id")
  prov_activity <- attr(.data, "prov_activity")
  prov_agent <- attr(.data, "prov_agent")
  prov_used <- attr(.data, "prov_used")
  prov_comment <- attr(.data, "prov_comment")

  if (!review_var %in% reviewable) {
    stop("Unknown review variable: ", review_var, call. = FALSE)
  }

  review_id <- paste0("review_", length(prov_id))

  candidate_column <- review_columns[[review_var]]
  review_column <- paste0(review_var, "_", review_id)

  .data[[review_column]] <- .data[[candidate_column]]

  .data <- dplyr::relocate(
    .data,
    dplyr::all_of(review_column),
    .after = dplyr::all_of(candidate_column)
  )

  review_columns[[review_var]] <- review_column

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
  attr(.data, "review_column") <- review_columns

  attr(.data, "prov_id") <- c(prov_id, review_id)
  empty <- stats::setNames(NA_character_, review_id)

  attr(.data, "prov_activity") <- c(prov_activity, empty)
  attr(.data, "prov_agent") <- c(prov_agent, empty)
  attr(.data, "prov_used") <- c(prov_used, empty)
  attr(.data, "prov_comment") <- c(prov_comment, empty)

  attr(.data, "review_label") <- c(
    review_label,
    stats::setNames(
      if (is.null(label)) NA_character_ else label,
      review_id
    )
  )

  .data
}
