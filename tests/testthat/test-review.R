test_that("review creates a review state from a reviewable variable", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference")

  expect_true("circumference_1" %in% names(reviewed))

  expect_equal(
    reviewed$circumference_1,
    reviewed$circumference_candidate
  )
})

test_that("review creates a named review state", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured"
    )

  expect_true("circumference_remeasured" %in% names(reviewed))

  expect_equal(
    reviewed$circumference_remeasured,
    reviewed$circumference_candidate
  )
})

test_that("review continues an existing review state", {
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

  expect_true("circumference_reviewed" %in% names(reviewed))

  expect_equal(
    reviewed$circumference_reviewed,
    reviewed$circumference_remeasured
  )
})

test_that("review places review beside its predecessor", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured"
    )

  expect_equal(
    names(reviewed),
    c(
      "claim_id",
      "age",
      "Tree",
      "circumference_candidate",
      "circumference_remeasured"
    )
  )
})


test_that("review allocates provenance metadata", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured"
    )

  expect_equal(
    attr(reviewed, "prov_id"),
    c("candidate", "circumference_remeasured")
  )

  expect_equal(
    names(attr(reviewed, "prov_activity")),
    attr(reviewed, "prov_id")
  )

  expect_equal(
    names(attr(reviewed, "prov_agent")),
    attr(reviewed, "prov_id")
  )

  expect_equal(
    names(attr(reviewed, "prov_used")),
    attr(reviewed, "prov_id")
  )
})


test_that("reviewable variables resolve to candidate columns", {
  a <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference")

  b <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference_candidate")

  expect_equal(a, b)
})


test_that("review allocates sequence identifiers", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference") |>
    review("circumference_1")

  expect_true("circumference_2" %in% names(reviewed))
})


test_that("review rejects an unknown review state", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_error(
    review(claims, "circumference_xyz"),
    "Unknown review variable"
  )
})


test_that("review rejects an unknown reviewable variable", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_error(
    review(claims, "height"),
    "Unknown review variable"
  )
})


test_that("review initialises observation status", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured",
      obs_status = "P"
    )

  expect_true(
    "circumference_remeasured_status" %in% names(reviewed)
  )

  expect_equal(
    reviewed$circumference_remeasured_status,
    rep("P", nrow(reviewed))
  )
})


test_that("review carries forward observation status", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured",
      obs_status = "P"
    ) |>
    review(
      "circumference_remeasured",
      review_id = "reviewed"
    )

  expect_equal(
    reviewed$circumference_reviewed_status,
    reviewed$circumference_remeasured_status
  )
})


test_that("review allocates review sequence numbers", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured"
    )

  expect_equal(
    attr(reviewed, "review_sequence"),
    c(candidate = 0L, remeasured = 1L)
  )
})

test_that("review increments review sequence numbers", {
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

  expect_equal(
    attr(reviewed, "review_sequence"),
    c(
      candidate = 0L,
      remeasured = 1L,
      reviewed = 2L
    )
  )
})


test_that("review stores a review label", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured",
      label = "Remeasure the circumference of each tree."
    )

  expect_equal(
    attr(reviewed, "review_label"),
    c(
      remeasured = "Remeasure the circumference of each tree."
    )
  )
})

test_that("review initialises a missing review label", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured"
    )

  expect_equal(
    attr(reviewed, "review_label"),
    c(
      remeasured = NA_character_
    )
  )
})
