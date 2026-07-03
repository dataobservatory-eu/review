#' Convert provenance objects to character
#'
#' Converts supported provenance representations to a character vector for
#' storage in `claims_df` provenance metadata.
#'
#' Supported inputs include `NULL`, character vectors,
#' [utils::person()] objects, and lists of values coercible to character.
#'
#' @param x A provenance object.
#'
#' @importFrom utils person
#' @return
#' A character vector. `NULL` is converted to `NA_character_`.
#'
#' @keywords internal

as_prov_character <- function(x) {
  if (is.null(x)) {
    return(NA_character_)
  }

  if (inherits(x, "person") && length(x) == 1) {
    return(as.character(x))
  }

  if (is.list(x) || length(x) > 1) {
    return(paste(vapply(x, as_prov_character, character(1)), collapse = "|"))
  }

  as.character(x)
}
