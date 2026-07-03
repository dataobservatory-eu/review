test_that("explain records review provenance", {
  reviewed <- claims_df(
    Orange,
    scope_var = "age",
    subject_var = "Tree"
  ) |>
    review("circumference") |>
    explain(
      activity = "manual_review",
      agent = person("Jane", "Doe", role = "rev"),
      used = "lab notebook"
    )

  expect_equal(
    unname(attr(reviewed, "prov_activity")["review_1"]),
    "manual_review"
  )

  expect_equal(
    unname(attr(reviewed, "prov_agent")["review_1"]),
    "Jane Doe [rev]"
  )

  expect_equal(
    unname(attr(reviewed, "prov_used")["review_1"]),
    "lab notebook"
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

  expect_equal(
    unname(attr(reviewed, "prov_used")["review_1"]),
    "doi:10.5281/zenodo.1234567|https://orcid.org/0000-0001-7513-6760"
  )
})
