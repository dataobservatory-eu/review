#' Initialise a review round
#'
#' Creates a new review round for one or more reviewable variables in a
#' `claims_df`. The current review values are copied into new review
#' columns placed immediately after their predecessors.
#'
#' @param .data A `claims_df`.
#' @param review_vars Character vector of variables to review.
#' @param obs_status Optional observation status assigned to new review
#'   values.
#'
#' @return
#' A `claims_df` with one additional review round.
#'
#' @export
review <- function(
  .data,
  review_vars,
  obs_status = NULL
) {
  if (!inherits(.data, "claims_df")) {
    stop(".data must be created with claims_df()", call. = FALSE)
  }

  ## Cache attributes ------------------------------------------------

  id <- attr(.data, "id")
  scope <- attr(.data, "scope")
  subject <- attr(.data, "subject")
  reviewable <- attr(.data, "reviewable")

  review_column <- attr(.data, "review_column")
  prov_id <- attr(.data, "prov_id")
  prov_activity <- attr(.data, "prov_activity")
  prov_agent <- attr(.data, "prov_agent")
  prov_used <- attr(.data, "prov_used")

  unknown <- setdiff(review_vars, attr(.data, "reviewable"))

  if (length(unknown)) {
    stop(
      "Unknown review variable(s): ",
      paste(unknown, collapse = ", "),
      call. = FALSE
    )
  }

  review_column <- attr(.data, "review_column")
  prov_id <- attr(.data, "prov_id")
  review_id <- paste0("review_", length(prov_id))

  for (var in review_vars) {
    previous <- review_column[[var]]
    current <- paste0(var, "_", review_id)

    .data[[current]] <- .data[[previous]]

    .data <- dplyr::relocate(
      .data,
      dplyr::all_of(current),
      .after = dplyr::all_of(previous)
    )

    review_column[[var]] <- current

    if (!is.null(obs_status)) {
      previous_status <- paste0(previous, "_status")
      current_status <- paste0(current, "_status")

      .data[[current_status]] <-
        if (previous_status %in% names(.data)) {
          .data[[previous_status]]
        } else {
          obs_status
        }

      .data <- dplyr::relocate(
        .data,
        dplyr::all_of(current_status),
        .after = dplyr::all_of(current)
      )
    }
  }

  ## Restore and update metadata attributes ------------------------------

  attr(.data, "id") <- id
  attr(.data, "scope") <- scope
  attr(.data, "subject") <- subject
  attr(.data, "reviewable") <- reviewable

  attr(.data, "review_column") <- review_column
  attr(.data, "prov_id") <- c(prov_id, review_id)

  attr(.data, "prov_activity") <-
    c(prov_activity, stats::setNames(NA_character_, review_id))

  attr(.data, "prov_agent") <-
    c(prov_agent, stats::setNames(NA_character_, review_id))

  attr(.data, "prov_used") <-
    c(prov_used, stats::setNames(NA_character_, review_id))

  .data
}
