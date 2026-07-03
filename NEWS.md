# review 0.0.2

## Development improvements

- Added support for review labels, reviewer comments, and richer provenance
  metadata.
- Expanded documentation, examples, vignettes, and test coverage.

# review 0.0.1

## Initial exploratory release

This first public release introduces **review**, an R package that provides a
tidy relational algebra for iterative semantic review of tabular data.

The initial implementation consists of four core verbs:

- `claims_df()` creates a collection of reviewable claims from an ordinary
  data frame by separating structural variables from reviewable values.
- `review()` allocates one or more review rounds without prescribing how the
  review itself is carried out.
- `explain()` records provenance for each review round, including review
  activities, agents, and supporting resources.
- `finalise_review()` promotes the current reviewed values into the next
  candidate version while preserving the review history.

The package currently includes two vignettes:

- **The Review Algebra**, introducing the review workflow and its underlying
  concepts.
- **Review Provenance**, describing how review activities, agents, and
  resources are recorded using a lightweight provenance model inspired by
  W3C PROV.

This exploratory release establishes the core review algebra and provides a
foundation for future development of reproducible semantic review workflows,
metadata integration, and interoperability with the companion `dataset`
package.
