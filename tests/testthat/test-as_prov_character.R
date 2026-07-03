test_that("NULL becomes NA_character_", {
  # Missing provenance
  expect_identical(as_prov_character(NULL), NA_character_)
})

test_that("character vectors are collapsed", {
  x <- c("Doe, Jane [rev]", "Eurostat [dtc]")

  # Preserve character values
  expect_identical(
    as_prov_character(x),
    "Doe, Jane [rev]|Eurostat [dtc]"
  )
})

test_that("person objects are flattened", {
  x <- person("Jane", "Doe", role = "rev")

  # Format person
  expect_identical(as_prov_character(x), "Jane Doe [rev]")
})

test_that("lists are collapsed", {
  x <- list(
    person("Jane", "Doe", role = "rev"),
    "Eurostat [dtc]"
  )

  # Collapse list
  expect_identical(
    as_prov_character(x),
    "Jane Doe [rev]|Eurostat [dtc]"
  )
})

test_that("person comments are preserved", {
  x <- person(
    "Jane", "Doe",
    role = "rev",
    comment = c(orcid = "0000-0002-1825-0097")
  )

  # Preserve comments
  expect_identical(
    as_prov_character(x),
    "Jane Doe [rev] (orcid: 0000-0002-1825-0097)"
  )
})

test_that("lists preserve comments", {
  x <- list(
    person(
      "Jane", "Doe",
      role = "rev",
      comment = c(orcid = "0000-0002-1825-0097")
    ),
    "Eurostat [dtc] (doi: 10.2908/NAMA_10_GDP)"
  )

  # Collapse commented values
  expect_identical(
    as_prov_character(x),
    paste(
      "Jane Doe [rev] (orcid: 0000-0002-1825-0097)",
      "Eurostat [dtc] (doi: 10.2908/NAMA_10_GDP)",
      sep = "|"
    )
  )
})

test_that("vectors of person objects are collapsed", {
  x <- c(
    person(
      "Jane", "Doe",
      role = "rev",
      comment = c(orcid = "0000-0002-1825-0097")
    ),
    person(
      "review",
      role = "ctb",
      comment = c(version = "0.1.0")
    )
  )

  # Collapse persons
  expect_identical(
    as_prov_character(x),
    paste(
      "Jane Doe [rev] (orcid: 0000-0002-1825-0097)",
      "review [ctb] (version: 0.1.0)",
      sep = "|"
    )
  )
})
