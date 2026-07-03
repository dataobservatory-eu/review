#' Create a reviewable claims table
#'
#' Converts a tidy data frame into a reviewable claims table. The user specifies
#' the observational scope and subject columns, while all remaining variables are
#' treated as reviewable claim values. For each reviewable variable, a
#' corresponding `_candidate` column is created containing the initial values.
#'
#' The returned object remains a tibble with additional class
#' `claims_df`. Metadata identifying the scope, subject, and reviewable
#' variables are stored as attributes for use by downstream review operations.
#'
#' @param data A data frame or tibble.
#' @param scope <[`tidy-select`][dplyr::dplyr_tidy_select]> One or more columns
#'   defining the observational scope of each claim.
#' @param subject <[`tidy-select`][dplyr::dplyr_tidy_select]> One or more columns
#'   identifying the subject of each claim.
#' @param id Optional <[`tidy-select`][dplyr::dplyr_tidy_select]> identifying an
#'   existing unique identifier column. If omitted, a sequential `claim_id`
#'   column is created.
#'
#' @return
#' A tibble of class `claims_df` containing:
#' \describe{
#'   \item{Identifier columns}{The supplied identifier (or generated
#'     `claim_id`), scope, and subject columns.}
#'   \item{Candidate columns}{One `_candidate` column for each reviewable
#'     variable.}
#' }
#'
#' The returned object also stores the review metadata as attributes:
#' \itemize{
#'   \item `scope`
#'   \item `subject`
#'   \item `reviewable`
#' }
#'
#' @importFrom dplyr mutate row_number select all_of
#' @importFrom rlang enquo quo_is_null
#' @importFrom tidyselect eval_select
#' @importFrom utils data
#'
#' @examples
#' data("Orange", package = "datasets")
#'
#' orange_claims <- claims_df(
#'   Orange,
#'   scope = age,
#'   subject = Tree
#' )
#'
#' names(orange_claims)
#' attr(orange_claims, "reviewable")
#'
#' @export
claims_df <- function(data,
                      scope,
                      subject,
                      id = NULL) {

  scope <- tidyselect::eval_select(
    rlang::enquo(scope),
    data
  )

  subject <- tidyselect::eval_select(
    rlang::enquo(subject),
    data
  )

  if (rlang::quo_is_null(rlang::enquo(id))) {

    data <- dplyr::mutate(
      data,
      claim_id = dplyr::row_number()
    )

    id_name <- "claim_id"

  } else {

    id_name <- names(
      tidyselect::eval_select(
        rlang::enquo(id),
        data
      )
    )
  }

  protected <- unique(c(
    id_name,
    names(scope),
    names(subject)
  ))

  reviewable <- setdiff(names(data), protected)

  out <- data %>%
    dplyr::select(dplyr::all_of(protected))

  for (nm in reviewable) {
    out[[paste0(nm, "_candidate")]] <- data[[nm]]
  }

  class(out) <- unique(c("claims_df", class(out)))

  attr(out, "scope") <- names(scope)
  attr(out, "subject") <- names(subject)
  attr(out, "reviewable") <- reviewable

  out
}

