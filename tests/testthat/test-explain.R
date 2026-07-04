test_that("review workflow records provenance", {

  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured",
      label = "Remeasure the circumference."
    ) |>
    explain(
      result = "remeasured",
      activity = "expert review",
      agent = person("Jane", "Doe", role = "rev"),
      used = "lab notebook",
      comment = "Measurements agreed with the original observations."
    )

  expect_equal(
    attr(reviewed, "prov_activity"),
    c(
      candidate = "create",
      remeasured = "expert review"
    )
  )

  expect_equal(
    attr(reviewed, "prov_agent"),
    c(
      candidate = NA_character_,
      remeasured = "Jane Doe [rev]"
    )
  )

  expect_equal(
    attr(reviewed, "prov_used"),
    c(
      candidate = NA_character_,
      remeasured = "lab notebook"
    )
  )

  expect_equal(
    attr(reviewed, "prov_comment"),
    c(
      remeasured =
        "Measurements agreed with the original observations."
    )
  )
})


test_that("explain records multiple provenance resources", {

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
      used = c(
        "doi:10.5281/zenodo.1234567",
        "https://orcid.org/0000-0001-7513-6760"
      )
    )

  expect_equal(
    unname(attr(reviewed, "prov_used")["remeasured"]),
    paste(
      "doi:10.5281/zenodo.1234567",
      "https://orcid.org/0000-0001-7513-6760",
      sep = "|"
    )
  )
})


test_that("review instructions and reviewer feedback are stored separately", {

  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      review_id = "remeasured",
      label = "Remeasure the circumference."
    ) |>
    explain(
      result = "remeasured",
      comment = "Tree 3 required a second measurement."
    )

  expect_equal(
    unname(attr(reviewed, "review_label")["remeasured"]),
    "Remeasure the circumference."
  )

  expect_equal(
    unname(attr(reviewed, "prov_comment")["remeasured"]),
    "Tree 3 required a second measurement."
  )
})


test_that("explain updates the requested review state", {

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
    ) |>
    explain(
      result = "remeasured",
      activity = "measurement"
    )

  expect_equal(
    unname(attr(reviewed, "prov_activity")["remeasured"]),
    "measurement"
  )

  expect_true(
    is.na(attr(reviewed, "prov_activity")["reviewed"])
  )
})
