test_that("revisions creates a claims_df", {
  reviewed <- revisions(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_s3_class(reviewed, "claims_df")

  expect_true(
    "circumference_candidate" %in% names(reviewed)
  )
})
