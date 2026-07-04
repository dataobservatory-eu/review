test_that("accept promotes a specified review state", {

  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured"
    ) |>
    review(
      "circumference_remeasured",
      review_id = "reviewed"
    )

  reviewed$circumference_remeasured <-
    reviewed$circumference_candidate + 1

  reviewed$circumference_reviewed <-
    reviewed$circumference_candidate + 2

  accepted <- accept(
    reviewed,
    result = "remeasured"
  )

  expect_equal(
    accepted$circumference_candidate,
    reviewed$circumference_remeasured
  )
})

test_that("accept promotes a specified review state", {

  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured"
    ) |>
    review(
      "circumference_remeasured",
      review_id = "reviewed"
    )

  reviewed$circumference_remeasured <-
    reviewed$circumference_candidate + 1

  reviewed$circumference_reviewed <-
    reviewed$circumference_candidate + 2

  accepted <- accept(
    reviewed,
    result = "remeasured"
  )

  expect_equal(
    accepted$circumference_candidate,
    reviewed$circumference_remeasured
  )
})


test_that("accept preserves review history", {

  accepted <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured"
    ) |>
    accept()

  expect_true(
    "circumference_remeasured" %in% names(accepted)
  )
})


test_that("accept returns a reviewed_df", {

  accepted <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured"
    ) |>
    accept()

  expect_s3_class(accepted, "reviewed_df")
  expect_s3_class(accepted, "claims_df")
})

test_that("accept preserves provenance metadata", {

  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured"
    ) |>
    explain(
      result = "remeasured",
      activity = "manual review",
      agent = person("Jane", "Doe", role = "rev"),
      comment = "Verified against field notebook."
    )

  accepted <- accept(reviewed)

  expect_equal(
    attr(accepted, "prov_id"),
    attr(reviewed, "prov_id")
  )

  expect_equal(
    attr(accepted, "prov_activity"),
    attr(reviewed, "prov_activity")
  )

  expect_equal(
    attr(accepted, "prov_agent"),
    attr(reviewed, "prov_agent")
  )

  expect_equal(
    attr(accepted, "prov_used"),
    attr(reviewed, "prov_used")
  )

  expect_equal(
    attr(accepted, "prov_comment"),
    attr(reviewed, "prov_comment")
  )

  expect_equal(
    attr(accepted, "review_label"),
    attr(reviewed, "review_label")
  )
})

test_that("accept rejects non-claims_df input", {

  expect_error(
    accept(Orange),
    ".data must be created with claims_df()"
  )
})
