test_that("review workflow records provenance for a revision", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review(
      "circumference",
      review_id = "remeasured",
      label = "Remeasure the circumference."
    ) |>
    document(
      revision = "circumference_remeasured",
      activity = "expert review",
      agent = person("Jane", "Doe", role = "rev"),
      used = "lab notebook",
      comment = "Measurements agreed with the original observations."
    )

  # Records the review activity.
  expect_equal(
    unname(attr(reviewed, "prov_activity")["circumference_remeasured"]),
    "expert review"
  )

  # Records the reviewer.
  expect_equal(
    unname(attr(reviewed, "prov_agent")["circumference_remeasured"]),
    "Jane Doe [rev]"
  )

  # Records the source used.
  expect_equal(
    unname(attr(reviewed, "prov_used")["circumference_remeasured"]),
    "lab notebook"
  )

  # Records the reviewer comment.
  expect_equal(
    unname(attr(reviewed, "prov_comment")["circumference_remeasured"]),
    "Measurements agreed with the original observations."
  )
})


test_that("explain records multiple provenance resources", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference", review_id = "remeasured") |>
    document(
      revision = "circumference_remeasured",
      used = c(
        "doi:10.5281/zenodo.1234567",
        "https://orcid.org/0000-0001-7513-6760"
      )
    )

  # Records multiple sources as one provenance string.
  expect_equal(
    unname(attr(reviewed, "prov_used")["circumference_remeasured"]),
    paste(
      "doi:10.5281/zenodo.1234567",
      "https://orcid.org/0000-0001-7513-6760",
      sep = "|"
    )
  )
})


test_that("review label and reviewer comment are stored separately", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review(
      "circumference",
      review_id = "remeasured",
      label = "Remeasure the circumference."
    ) |>
    document(
      revision = "circumference_remeasured",
      comment = "Tree 3 required a second measurement."
    )

  # Records reviewer feedback separately.
  expect_equal(
    unname(attr(reviewed, "prov_comment")["circumference_remeasured"]),
    "Tree 3 required a second measurement."
  )
})


test_that("explain updates the requested revision only", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference", review_id = "remeasured") |>
    review("circumference_remeasured", review_id = "reviewed") |>
    document(
      revision = "circumference_remeasured",
      activity = "measurement"
    )

  # Updates the requested revision.
  expect_equal(
    unname(attr(reviewed, "prov_activity")["circumference_remeasured"]),
    "measurement"
  )

  # Leaves the later revision unexplained.
  expect_true(
    is.na(attr(reviewed, "prov_activity")["circumference_reviewed"])
  )
})


test_that("explain accepts a software agent", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference", review_id = "checked") |>
    document(
      revision = "circumference_checked",
      agent = "OpenRefine 3.10"
    )

  # Records the software agent.
  expect_equal(
    unname(attr(reviewed, "prov_agent")["circumference_checked"]),
    "OpenRefine 3.10"
  )
})


test_that("explain rejects non-claims_df input", {
  # Rejects ordinary data frames.
  expect_error(
    document(Orange, revision = "circumference_checked"),
    ".data must be created with claims_df()"
  )
})
