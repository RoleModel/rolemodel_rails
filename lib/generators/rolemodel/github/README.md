# Github Generator

## Prerequisites

It doesn't need to be run first, but the parallel_tests generator must be run in order for the CI workflow to run successfully on GitHub.

## What you get

- CI workflow
  - A sensible default `ci.yml` to get you started with Github Actions. This will run linters, model tests, and system tests.
  - Along with the `ci.yml`, your `database.yml` will be modified to be able to be run in GHA.
- Pull Request Template
  - When you open a Pull Request in Github it will use the Markdown file as a [template](./templates/pull_request_template.md) for the content of the PR.
  - Helpful for reminding collaborators to add specific details to the PR.
- Copilot Instructions
  - Installed into `.github/instructions`, these are context-specific instructions for Copilot to help it give more accurate
  and relevant results. These are a good starting point but they should be tweaked for your project's frameworks and
  standards.
- Dependabot Configuration
  - defines a set of rules that dependabot will use to keep your applications dependencies up-to-date on a weekly basis.
