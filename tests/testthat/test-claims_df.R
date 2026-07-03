test_that("claims_df initialises candidate provenance", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_equal(attr(claims, "prov_id"), "candidate")

  expect_equal(
    attr(claims, "prov_activity"),
    stats::setNames("create", "candidate")
  )

  empty <- stats::setNames(NA_character_, "candidate")

  expect_equal(attr(claims, "prov_agent"), empty)
  expect_equal(attr(claims, "prov_used"), empty)

  # Only used by review():
  expect_equal(attr(claims, "review_label"), empty)

  # Only used by explain():
  expect_equal(attr(claims, "prov_comment"), empty)
})

test_that("claims_df records supplied candidate provenance", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree",
    prov_activity = "create",
    prov_agent = "Jane Doe [rev]",
    prov_used = "doi:10.1234/example"
  )

  expect_equal(attr(claims, "prov_id"), "candidate")

  expect_equal(
    attr(claims, "prov_activity"),
    stats::setNames("create", "candidate")
  )

  expect_equal(
    attr(claims, "prov_agent"),
    stats::setNames("Jane Doe [rev]", "candidate")
  )

  expect_equal(
    attr(claims, "prov_used"),
    stats::setNames("doi:10.1234/example", "candidate")
  )

  expect_equal(
    attr(claims, "review_label"),
    stats::setNames(NA_character_, "candidate")
  )
})
