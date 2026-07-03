test_that("explain records review provenance", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      label = "Remeasure the circumference."
    ) |>
    explain(
      activity = "expert review",
      agent = person("Jane", "Doe", role = "rev"),
      used = "lab notebook",
      comment = "Measurements agreed with the original observations."
    )

  # Records the review activity.
  expect_equal(
    unname(attr(reviewed, "prov_activity")["review_1"]),
    "expert review"
  )

  # Records the reviewer.
  expect_equal(
    unname(attr(reviewed, "prov_agent")["review_1"]),
    "Jane Doe [rev]"
  )

  # Records the evidence used.
  expect_equal(
    unname(attr(reviewed, "prov_used")["review_1"]),
    "lab notebook"
  )

  # Records reviewer feedback.
  expect_equal(
    unname(attr(reviewed, "prov_comment")["review_1"]),
    "Measurements agreed with the original observations."
  )
})


test_that("explain accepts multiple provenance sources", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference") |>
    explain(
      used = c(
        "doi:10.5281/zenodo.1234567",
        "https://orcid.org/0000-0001-7513-6760"
      )
    )

  # Records multiple provenance entities.
  expect_equal(
    unname(attr(reviewed, "prov_used")["review_1"]),
    "doi:10.5281/zenodo.1234567|https://orcid.org/0000-0001-7513-6760"
  )
})

test_that("review task and reviewer feedback are stored separately", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review(
      "circumference",
      label = "Remeasure the circumference."
    ) |>
    explain(
      comment = "Tree 3 required a second measurement."
    )

  # Preserves the review task.
  expect_equal(
    unname(attr(reviewed, "review_label")["review_1"]),
    "Remeasure the circumference."
  )

  # Records reviewer feedback separately.
  expect_equal(
    unname(attr(reviewed, "prov_comment")["review_1"]),
    "Tree 3 required a second measurement."
  )
})
