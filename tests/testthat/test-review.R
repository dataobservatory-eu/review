test_that("review creates a first review column", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference")

  # Creates a review column.
  expect_true("circumference_review_1" %in% names(reviewed))

  # Copies the candidate values.
  expect_equal(reviewed$circumference_review_1, reviewed$circumference_candidate)
})

test_that("review places review beside candidate", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference")

  # Places review immediately after the candidate column.
  expect_equal(
    names(reviewed),
    c(
      "claim_id", "age", "Tree",
      "circumference_candidate", "circumference_review_1"
    )
  )
})

test_that("review optionally creates status columns", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference", obs_status = "P")

  # Creates a status column.
  expect_true("circumference_review_1_status" %in% names(reviewed))

  # Initialises status values.
  expect_equal(reviewed$circumference_review_1_status, rep("P", nrow(reviewed)))
})

test_that("review creates multiple review columns", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference") |>
    review("circumference")

  # Creates a second review column.
  expect_true("circumference_review_2" %in% names(reviewed))

  # Copies values from the previous review.
  expect_equal(reviewed$circumference_review_2, reviewed$circumference_review_1)
})

test_that("review allocates provenance rounds", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference") |>
    review("circumference")

  # Allocates provenance identifiers.
  expect_equal(attr(reviewed, "prov_id"), c("candidate", "review_1", "review_2"))

  # Keeps provenance vectors aligned.
  expect_equal(names(attr(reviewed, "prov_activity")), c("candidate", "review_1", "review_2"))

  # Initialises empty review activities.
  expect_true(all(is.na(attr(reviewed, "prov_activity")[-1])))

  # Initialises empty review agents.
  expect_true(all(is.na(attr(reviewed, "prov_agent")[-1])))

  # Initialises empty review resources.
  expect_true(all(is.na(attr(reviewed, "prov_used")[-1])))
})

test_that("review rejects non-claims_df input", {
  # Rejects ordinary data frames.
  expect_error(
    review(Orange, "circumference"),
    ".data must be created with claims_df()"
  )
})

test_that("explain accepts a person agent", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference") |>
    explain(agent = person("Jane", "Doe", role = "rev"))

  # Records a formatted reviewer.
  expect_equal(unname(attr(reviewed, "prov_agent")["review_1"]), "Jane Doe [rev]")
})

test_that("explain accepts a software agent", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference") |>
    explain(agent = "OpenRefine 3.10")

  # Records a software agent.
  expect_equal(unname(attr(reviewed, "prov_agent")["review_1"]), "OpenRefine 3.10")
})

test_that("explain accepts a DOI", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference") |>
    explain(used = "doi:10.5281/zenodo.1234567")

  # Records a DOI.
  expect_equal(
    unname(attr(reviewed, "prov_used")["review_1"]),
    "doi:10.5281/zenodo.1234567"
  )
})

test_that("explain accepts an ORCID", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review("circumference") |>
    explain(used = "https://orcid.org/0000-0001-7513-6760")

  # Records an ORCID.
  expect_equal(
    unname(attr(reviewed, "prov_used")["review_1"]),
    "https://orcid.org/0000-0001-7513-6760"
  )
})

test_that("review stores review labels", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review(
      "circumference",
      label = "Remeasure the circumference of each tree at the recorded age."
    )

  # Records the review task.
  expect_equal(
    unname(attr(reviewed, "review_label")["review_1"]),
    "Remeasure the circumference of each tree at the recorded age."
  )
})

test_that("review stores labels for successive review rounds", {
  reviewed <- claims_df(Orange, scope_var = "age", subject_var = "Tree") |>
    review(
      "circumference",
      label = "Remeasure the circumference of each tree."
    ) |>
    review(
      "circumference",
      label = "Verify the remeasurement independently."
    )

  # Records one label per review round.
  expect_equal(
    attr(reviewed, "review_label"),
    c(
      candidate = NA_character_,
      review_1 = "Remeasure the circumference of each tree.",
      review_2 = "Verify the remeasurement independently."
    )
  )
})


test_that("review initialises a missing label", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference")

  expect_true(
    is.na(attr(reviewed, "review_label")["review_1"])
  )
})


test_that("review updates the review column mapping", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference")

  expect_equal(
    attr(reviewed, "review_column"),
    c(circumference = "circumference_review_1")
  )
})


test_that("review rejects an unknown review variable", {
  claims <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  )

  expect_error(review(claims, "height"), "Unknown review variable")
})


test_that("review inherits observation status", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference", obs_status = "P") |>
    review("circumference")

  expect_equal(
    reviewed$circumference_review_2_status,
    rep("P", nrow(reviewed))
  )
})


test_that("review retains existing provenance metadata", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree",
    prov_activity = "create",
    prov_agent = person("Jane", "Doe", role = "crt"),
    prov_used = "doi:10.1234/example"
  ) |>
    review("circumference")

  # Preserves candidate activity.
  expect_equal(
    attr(reviewed, "prov_activity"),
    c(candidate = "create", review_1 = NA_character_)
  )

  # Preserves candidate agent.
  expect_equal(
    attr(reviewed, "prov_agent"),
    c(candidate = "Jane Doe [crt]", review_1 = NA_character_)
  )

  # Preserves candidate provenance.
  expect_equal(
    attr(reviewed, "prov_used"),
    c(candidate = "doi:10.1234/example", review_1 = NA_character_)
  )

  # Preserves candidate comment.
  expect_equal(
    attr(reviewed, "prov_comment"),
    c(candidate = NA_character_, review_1 = NA_character_)
  )

  # Allocates an empty review label.
  expect_equal(
    attr(reviewed, "review_label"),
    c(candidate = NA_character_, review_1 = NA_character_)
  )
})
