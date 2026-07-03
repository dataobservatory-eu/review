test_that("claims_df creates a reviewable claims table", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_s3_class(claims, "claims_df")
  expect_s3_class(claims, "data.frame")
  expect_equal(nrow(claims), nrow(Orange))
})

test_that("claims_df creates a claim identifier", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_true("claim_id" %in% names(claims))
  expect_equal(claims$claim_id, seq_len(nrow(Orange)))
})

test_that("claims_df preserves scope and subject columns", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_equal(claims$Tree, Orange$Tree)
  expect_equal(claims$age, Orange$age)
})

test_that("claims_df creates candidate columns", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_true("circumference_candidate" %in% names(claims))
  expect_false("circumference" %in% names(claims))
  expect_equal(
    claims$circumference_candidate,
    Orange$circumference
  )
})

test_that("claims_df records review metadata", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_equal(attr(claims, "id"), "claim_id")
  expect_equal(attr(claims, "scope"), "age")
  expect_equal(attr(claims, "subject"), "Tree")
  expect_equal(attr(claims, "reviewable"), "circumference")

  expect_equal(
    attr(claims, "review_column"),
    c(circumference = "circumference_candidate")
  )
})

test_that("claims_df records candidate provenance", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree",
    prov_activity = "create",
    prov_agent = person("Jane", "Doe", role = "rev"),
    prov_used = "doi:10.1234/example"
  )

  expect_equal(attr(claims, "prov_id"), "candidate")

  expect_equal(
    attr(claims, "prov_activity"),
    c(candidate = "create")
  )

  expect_equal(
    attr(claims, "prov_agent"),
    c(candidate = "Jane Doe [rev]")
  )

  expect_equal(
    attr(claims, "prov_used"),
    c(candidate = "doi:10.1234/example")
  )
})

test_that("claims_df respects an existing identifier", {
  orange <- dplyr::mutate(
    Orange,
    id = seq_len(nrow(Orange))
  )

  claims <- claims_df(
    orange,
    id_var = "id",
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_false("claim_id" %in% names(claims))
  expect_true("id" %in% names(claims))
  expect_equal(claims$id, orange$id)
  expect_equal(attr(claims, "id"), "id")
})

test_that("claims_df places protected columns first", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_equal(
    names(claims)[1:3],
    c("claim_id", "age", "Tree")
  )

  expect_equal(
    names(claims)[-c(1:3)],
    "circumference_candidate"
  )
})
