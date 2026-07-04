test_that("next_revisions starts a new review cycle", {

  next_review <- revisions(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured"
    ) |>
    accept() |>
    next_revisions()

  expect_s3_class(next_review, "claims_df")

  expect_false(
    inherits(next_review, "reviewed_df")
  )

  expect_equal(
    next_review$circumference_candidate,
    next_review$circumference_remeasured
  )
})
