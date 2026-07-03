test_that("review creates a first review column", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference")

  expect_true("circumference_review_1" %in% names(reviewed))

  expect_equal(
    reviewed$circumference_review_1,
    reviewed$circumference_candidate
  )
})

test_that("review places review beside candidate", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference")

  expect_equal(
    names(reviewed),
    c(
      "claim_id",
      "age",
      "Tree",
      "circumference_candidate",
      "circumference_review_1"
    )
  )
})

test_that("review optionally creates status columns", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      obs_status = "P"
    )

  expect_true(
    "circumference_review_1_status" %in% names(reviewed)
  )

  expect_equal(
    reviewed$circumference_review_1_status,
    rep("P", nrow(reviewed))
  )
})

test_that("review creates multiple review columns", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference") |>
    review("circumference")

  expect_true("circumference_review_2" %in% names(reviewed))

  expect_equal(
    reviewed$circumference_review_2,
    reviewed$circumference_review_1
  )
})

test_that("review allocates provenance rounds", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference") |>
    review("circumference")

  expect_equal(
    attr(reviewed, "prov_id"),
    c("candidate", "review_1", "review_2")
  )

  expect_equal(
    names(attr(reviewed, "prov_activity")),
    c("candidate", "review_1", "review_2")
  )

  expect_true(
    all(is.na(attr(reviewed, "prov_activity")[-1]))
  )

  expect_true(
    all(is.na(attr(reviewed, "prov_agent")[-1]))
  )

  expect_true(
    all(is.na(attr(reviewed, "prov_used")[-1]))
  )
})

test_that("review creates review columns for multiple variables", {
  x <- data.frame(
    id = 1:3,
    s = letters[1:3],
    p1 = paste0("p1-", 1:3),
    p2 = paste0("p2-", 1:3)
  )

  reviewed <- claims_df(
    x,
    id_var = "id",
    scope_var = "s",
    subject_var = "p1"
  ) |>
    review("p2")

  expect_equal(
    names(reviewed),
    c(
      "id",
      "s",
      "p1",
      "p2_candidate",
      "p2_review_1"
    )
  )
})

test_that("review rejects non-claims_df input", {
  expect_error(
    review(Orange, "circumference"),
    ".data must be created with claims_df()"
  )
})

test_that("one review call allocates one provenance round", {
  x <- data.frame(
    id = 1:3,
    s = letters[1:3],
    p = paste0("p-", 1:3),
    v1 = 1:3,
    v2 = 4:6
  )

  reviewed <- claims_df(
    x,
    id_var = "id",
    scope_var = "s",
    subject_var = "p"
  ) |>
    review(c("v1", "v2"))

  expect_equal(
    attr(reviewed, "prov_id"),
    c("candidate", "review_1")
  )

  expect_true(
    all(c("v1_review_1", "v2_review_1") %in% names(reviewed))
  )
})

test_that("explain accepts a person agent", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference") |>
    explain(
      agent = person("Jane", "Doe", role = "rev")
    )

  expect_equal(
    unname(attr(reviewed, "prov_agent")["review_1"]),
    "Jane Doe [rev]"
  )
})


test_that("explain accepts a software agent", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference") |>
    explain(
      agent = "OpenRefine 3.10"
    )

  expect_equal(
    unname(attr(reviewed, "prov_agent")["review_1"]),
    "OpenRefine 3.10"
  )
})

test_that("explain accepts a DOI", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference") |>
    explain(
      used = "doi:10.5281/zenodo.1234567"
    )

  expect_equal(
    unname(attr(reviewed, "prov_used")["review_1"]),
    "doi:10.5281/zenodo.1234567"
  )
})

test_that("explain accepts an ORCID", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference") |>
    explain(
      used = "https://orcid.org/0000-0001-7513-6760"
    )

  expect_equal(
    unname(attr(reviewed, "prov_used")["review_1"]),
    "https://orcid.org/0000-0001-7513-6760"
  )
})
