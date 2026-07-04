#' Initialise a review workspace
#'
#' Creates a collection of semantic revisions from a tabular data source.
#'
#' @inheritParams claims_df
#'
#' @return
#' A `claims_df`.
#'
#' @export
revisions <- function(
    .data,
    scope_var,
    subject_var,
    id_var = NULL,
    prov_activity = "create",
    prov_agent = NULL,
    prov_used = NULL
) {

  claims_df(
    .data = .data,
    scope_var = scope_var,
    subject_var = subject_var,
    id_var = id_var,
    prov_activity = prov_activity,
    prov_agent = prov_agent,
    prov_used = prov_used
  )
}
