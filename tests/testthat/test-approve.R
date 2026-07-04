test_that("approve creates approved variables", {

  approved <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference", review_id = "remeasured") |>
    approve()

  # Creates approved variables.
  expect_true(
    "circumference_approved" %in% names(approved)
  )
})


test_that("approve copies the latest revision", {

  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference", review_id = "remeasured") |>
    review("circumference_remeasured", review_id = "reviewed")

  reviewed$circumference_reviewed <-
    reviewed$circumference_candidate + 2

  approved <- approve(reviewed)

  # Copies the latest revision.
  expect_equal(
    approved$circumference_approved,
    reviewed$circumference_reviewed
  )
})


test_that("approve preserves review history", {

  approved <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference", review_id = "remeasured") |>
    approve()

  # Preserves review revisions.
  expect_true(
    "circumference_remeasured" %in% names(approved)
  )
})


test_that("approve returns a reviewed_df", {

  approved <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference", review_id = "remeasured") |>
    approve()

  # Returns the reviewed classes.
  expect_s3_class(approved, "reviewed_df")
  expect_s3_class(approved, "claims_df")
})


test_that("approve preserves review provenance", {

  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference", review_id = "remeasured") |>
    explain(
      revision = "circumference_remeasured",
      activity = "manual review",
      agent = person("Jane", "Doe", role = "dtc"),
      comment = "Verified against field notebook."
    )

  approved <- approve(reviewed)

  # Preserves review provenance.
  expect_equal(attr(approved, "prov_id"), attr(reviewed, "prov_id"))
  expect_equal(attr(approved, "prov_activity"), attr(reviewed, "prov_activity"))
  expect_equal(attr(approved, "prov_agent"), attr(reviewed, "prov_agent"))
  expect_equal(attr(approved, "prov_used"), attr(reviewed, "prov_used"))
  expect_equal(attr(approved, "prov_comment"), attr(reviewed, "prov_comment"))
  expect_equal(attr(approved, "review_label"), attr(reviewed, "review_label"))
})


test_that("approve records approval provenance", {

  approved <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference", review_id = "remeasured") |>
    approve(
      activity = "editorial approval",
      agent = person("John", "Smith", role = "rev"),
      comment = "Approved for publication."
    )

  # Records approval provenance.
  expect_equal(attr(approved, "approval_activity"), "editorial approval")
  expect_equal(attr(approved, "approval_agent"), "John Smith [rev]")
  expect_equal(attr(approved, "approval_comment"), "Approved for publication.")
})


test_that("approve rejects non-claims_df input", {

  # Rejects ordinary data frames.
  expect_error(
    approve(Orange),
    ".data must be created with claims_df()"
  )
})
