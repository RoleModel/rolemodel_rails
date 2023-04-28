rubocop.lint(
  # Comment on individual files on the PR
  inline_comment: true,

  # New option to use the severity reported by Rubocop, e.g. errors
  # will fail the build.
  # https://github.com/ashfurrow/danger-rubocop/pull/61
  report_severity: true,

  # Allowed Danger-Rubocop to fail the build, but it reported all offenses
  # as failures if true, or all as warnings if fails / not provided. The
  # option above allows for better specificity.
  # file_on_inline_comment: true,

  # Empty string will report on all files, even those not directly touched
  # in the current PR. This is useful in case a change impacts other files,
  # such as modifying the Rubocop config.
  files: '',
)
