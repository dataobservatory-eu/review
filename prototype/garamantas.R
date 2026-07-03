photo_collection <- data.frame(
  resources = c("https://garamantas.lv/en/file/475833",
                "https://garamantas.lv/en/file/475823",
                "https://garamantas.lv/en/file/475856",
                "https://garamantas.lv/en/file/471378",
                "https://garamantas.lv/en/file/475825"),
  instance_of = rep("photograph", 5),
  depicts  = rep("human", 5),
  personality_rights_profile = rep("one recognisable person", 5)
)

garamantas_claims <- claims_df(photo_collection,
                               scope = instance_of,
                               subject=resources)

garamantas_review <- garamantas_claims %>%
  review(.cols = c(depicts, personality_rights_profile),
         obs_status = NULL)

depicts_codelist <- c(
  "human",
  "group of humans",
  "building",
  "thing"
)


personality_rights_profile_codelist <- c(
  "one recognisable person",
  "group of recognisable persons",
  "one unrecognisable person",
  "group of unrecognisable persons",
  "mixed recognition of persons",
  "no recognisable person",
  "deferred"
)


library(openxlsx2)

excel_col <- function(x) {
  stopifnot(all(x >= 1))

  vapply(x, function(i) {
    out <- character()

    while (i > 0) {
      r <- (i - 1) %% 26
      out <- c(LETTERS[r + 1], out)
      i <- (i - 1) %/% 26
    }

    paste0(out, collapse = "")
  }, character(1))
}

wb <- wb_workbook()

hide_codelist <- FALSE

garamantas_excel <- garamantas_review

resources <- garamantas_excel$resources

names(resources) <- paste("Open image", seq_along(resources))
class(resources) <- "hyperlink"

garamantas_excel$resources <- resources

wb$add_worksheet("Review")

wb$add_data(
  sheet = "Review",
  x = garamantas_excel
)

wb$set_col_widths(
  sheet = "Review",
  cols = 1:ncol(garamantas_excel),
  widths = "auto"
)

wb$freeze_pane(
  sheet = "Review",
  first_active_row = 2
)

review_cols <-
  grep(
    "_review_[0-9]+$",
    names(garamantas_review)
  )

for (i in review_cols) {

  col <- excel_col(i)

  wb <- wb_add_fill(
    wb,
    sheet = "Review",
    dims = sprintf("%s2:%s%d",
                   col,
                   col,
                   nrow(garamantas_review) + 1),
    color = wb_color(hex = "FAE000")
  )
}

## ---- Code lists ----------------------------------------------------------

wb$add_worksheet("depicts_codelist")

wb$add_data(
  sheet = "depicts_codelist",
  x = data.frame(depicts = depicts_codelist)
)

wb$add_worksheet("personality_rights_codelist")

wb$add_data(
  sheet = "personality_rights_codelist",
  x = data.frame(
    personality_rights_profile =
      personality_rights_profile_codelist
  )
)

wb$add_worksheet("obs_status_codelist")

wb$add_data(
  sheet = "obs_status_codelist",
  x = data.frame(
    status = c(
      "A","P","E","I","D","U","O"
    )
  )
)

## ---- Hide lookup sheets --------------------------------------------------

if(hide_codelist) {
  wb$set_sheet_visibility(
    sheet = c(
      "depicts_codelist",
      "personality_rights_codelist",
      "obs_status_codelist"
    ),
    rep("hidden", 3)
  )
}

## ---- Data validation -----------------------------------------------------

review_rows <- 2:(nrow(garamantas_review) + 1)

## depicts_review_1
wb$add_data_validation(
  sheet = "Review",
  dims = wb_dims(
    rows = review_rows,
    cols = which(names(garamantas_review) == "depicts_review_1")
  ),
  type = "list",
  value = "'depicts_codelist'!$A$2:$A$5"
)

## depicts_review_1_status

if ( "depicts_review_1_status" %in% names(garamantas_review)) {
  wb$add_data_validation(
    sheet = "Review",
    dims = wb_dims(
      rows = review_rows,
      cols = which(names(garamantas_review) == "depicts_review_1_status")
    ),
    type = "list",
    value = "'obs_status_codelist'!$A$2:$A$8"
  )
}


## personality_rights_profile_review_1
wb$add_data_validation(
  sheet = "Review",
  dims = wb_dims(
    rows = review_rows,
    cols = which(
      names(garamantas_review) ==
        "personality_rights_profile_review_1"
    )
  ),
  type = "list",
  value = "'personality_rights_codelist'!$A$2:$A$8"
)

if ( "personality_rights_profile_review_1_status" %in% names(garamantas_review)) {
wb$add_data_validation(
  sheet = "Review",
  dims = wb_dims(
    rows = review_rows,
    cols = which(
      names(garamantas_review) ==
        "personality_rights_profile_review_1_status"
    )
  ),
  type = "list",
  value = "'obs_status_codelist'!$A$2:$A$8"
)
}

wb$set_col_widths(
  "depicts_codelist",
  cols = 1,
  widths = 30
)

wb$set_col_widths(
  "personality_rights_codelist",
  cols = 1,
  widths = 40
)

wb$set_col_widths(
  "obs_status_codelist",
  cols = 1,
  widths = 12
)

wb$save("garamantas_review.xlsx", overwrite = TRUE)

