test_that("finalise_review promotes reviewed values", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  reviewed$circumference_review_1 <-
    reviewed$circumference_candidate + 1

  attr(reviewed, "review_column")["circumference"] <-
    "circumference_review_1"

  finalised <- finalise_review(reviewed)

  # Candidate updated
  expect_equal(
    finalised$circumference_candidate,
    reviewed$circumference_review_1
  )
})

test_that("finalise_review resets review pointers", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  reviewed$circumference_review_1 <-
    reviewed$circumference_candidate

  attr(reviewed, "review_column")["circumference"] <-
    "circumference_review_1"

  finalised <- finalise_review(reviewed)

  # Candidate becomes current
  expect_equal(
    attr(finalised, "review_column"),
    c(circumference = "circumference_candidate")
  )
})

test_that("finalise_review preserves review history", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference")

  finalised <- finalise_review(reviewed)

  # Review retained
  expect_true(
    "circumference_review_1" %in% names(finalised)
  )
})

test_that("finalise_review preserves provenance", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference") |>
    explain(
      activity = "manual review",
      agent = person("Jane", "Doe", role = "rev")
    )

  finalised <- finalise_review(reviewed)

  # Provenance unchanged
  expect_equal(
    attr(finalised, "prov_id"),
    attr(reviewed, "prov_id")
  )

  # Activity retained
  expect_equal(
    attr(finalised, "prov_activity"),
    attr(reviewed, "prov_activity")
  )

  # Agent retained
  expect_equal(
    attr(finalised, "prov_agent"),
    attr(reviewed, "prov_agent")
  )
})

test_that("finalise_review rejects non-claims_df input", {
  # Validate input
  expect_error(
    finalise_review(Orange),
    ".data must be created with claims_df()"
  )
})

test_that("finalise_review preserves review labels", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      label = "Remeasure the circumference."
    )

  finalised <- finalise_review(reviewed)

  # Review labels retained.
  expect_equal(
    attr(finalised, "review_label"),
    attr(reviewed, "review_label")
  )
})

test_that("review workflow preserves review history", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  reviewed <- claims |>
    review(
      "circumference",
      label = "Remeasure circumference."
    )

  reviewed$circumference_review_1 <-
    reviewed$circumference_review_1 + 1

  reviewed <- reviewed |>
    explain(
      activity = "manual_review",
      agent = person("Jane", "Doe", role = "rev"),
      comment = "Verified against field notebook."
    )

  finalised <- finalise_review(reviewed)

  # Candidate updated.
  expect_equal(
    finalised$circumference_candidate,
    reviewed$circumference_review_1
  )

  # Review history retained.
  expect_true(
    "circumference_review_1" %in% names(finalised)
  )

  # Review pointer reset.
  expect_equal(
    attr(finalised, "review_column"),
    c(circumference = "circumference_candidate")
  )

  # Provenance retained.
  expect_equal(
    attr(finalised, "prov_activity"),
    attr(reviewed, "prov_activity")
  )

  # Review labels retained.
  expect_equal(
    attr(finalised, "review_label"),
    attr(reviewed, "review_label")
  )
})
