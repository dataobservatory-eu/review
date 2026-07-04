#' Review activity crosswalk
#'
#' Recommended mapping between review activities and SDMX observation
#' status codes. The table provides default observation statuses for use
#' by [approve()]. Activities describe the provenance of a review
#' step, while observation statuses describe the semantic status of the
#' resulting observation.
#'
#' Users may extend or replace this table for domain-specific workflows.
#'
#' @format A data frame with 9 rows and 2 variables:
#' \describe{
#'   \item{activity}{Review activity.}
#'   \item{default_obs_status}{Recommended SDMX CL_OBS_STATUS code.}
#' }
#'
#' @source
#' SDMX Cross-Domain Code List CL_OBS_STATUS (version 2.3), extended with
#' review activities for statistical and semantic production workflows.
#'
#' @examples
#' review_activity_crosswalk
#'
"review_activity_crosswalk"
