#' Create a reviewable claims table
#'
#' Converts a data frame into a reviewable collection of claims.
#' Identifier, scope, and subject variables are placed first. Remaining
#' variables become reviewable claim values stored as `_candidate`
#' columns.
#'
#' @param .data A data frame or tibble.
#' @param scope_var Character vector of scope variable names.
#' @param subject_var Character vector of subject variable names.
#' @param id_var Optional identifier variable. If `NULL`, a sequential
#'   `claim_id` is created.
#' @param prov_activity Provenance activity creating the candidate values.
#' @param prov_agent Provenance agent.
#' @param prov_used Provenance source or entity.
#'
#' @return A `claims_df`.
#' @export
claims_df <- function(
  .data,
  scope_var,
  subject_var,
  id_var = NULL,
  prov_activity = "create",
  prov_agent = NULL,
  prov_used = NULL
) {
  if (!is.data.frame(.data)) {
    stop(".data must be a data frame.", call. = FALSE)
  }

  if (is.null(id_var)) {
    .data$claim_id <- seq_len(nrow(.data))
    id_var <- "claim_id"
  }

  required <- unique(c(id_var, scope_var, subject_var))
  missing <- setdiff(required, names(.data))

  if (length(missing)) {
    stop(
      "Unknown variable(s): ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }

  reviewable <- setdiff(names(.data), required)

  claims <- dplyr::select(.data, dplyr::all_of(required))

  for (var in reviewable) {
    claims[[paste0(var, "_candidate")]] <- .data[[var]]
  }

  class(claims) <- unique(c("claims_df", class(claims)))

  attr(claims, "id") <- id_var
  attr(claims, "scope") <- scope_var
  attr(claims, "subject") <- subject_var
  attr(claims, "reviewable") <- reviewable

  attr(claims, "review_column") <- stats::setNames(
    paste0(reviewable, "_candidate"),
    reviewable
  )

  attr(claims, "prov_id") <- "candidate"
  attr(claims, "prov_activity") <- c(candidate = prov_activity)
  attr(claims, "prov_agent") <-
    c(candidate = as_prov_character(prov_agent))
  attr(claims, "prov_used") <-
    c(candidate = as_prov_character(prov_used))

  claims
}
