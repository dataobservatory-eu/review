test_that("claims_df creates a reviewable claims table", {

  claims <- claims_df(
    Orange,
    scope = age,
    subject = Tree
  )

  expect_s3_class(claims, "claims_df")
  expect_s3_class(claims, "data.frame")

  expect_equal(nrow(claims), nrow(Orange))
})

test_that("claims_df creates a claim identifier", {

  claims <- claims_df(
    Orange,
    scope = age,
    subject = Tree
  )

  expect_true("claim_id" %in% names(claims))
  expect_equal(claims$claim_id, seq_len(nrow(Orange)))
})

test_that("claims_df preserves scope and subject columns", {

  claims <- claims_df(
    Orange,
    scope = age,
    subject = Tree
  )

  expect_equal(claims$Tree, Orange$Tree)
  expect_equal(claims$age, Orange$age)
})

test_that("claims_df creates candidate columns", {

  claims <- claims_df(
    Orange,
    scope = age,
    subject = Tree
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
    scope = age,
    subject = Tree
  )

  expect_equal(attr(claims, "scope"), "age")
  expect_equal(attr(claims, "subject"), "Tree")
  expect_equal(attr(claims, "reviewable"), "circumference")
})

test_that("claims_df respects an existing identifier", {

  data("Orange", package = "datasets")

  orange <- dplyr::mutate(
    Orange,
    id = seq_len(nrow(Orange))
  )

  claims <- claims_df(
    orange,
    id = id,
    scope = age,
    subject = Tree
  )

  expect_false("claim_id" %in% names(claims))
  expect_true("id" %in% names(claims))
  expect_equal(claims$id, orange$id)
})
