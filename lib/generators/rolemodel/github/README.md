# Github Generator

## Prerequisites

It doesn't need to be run first, but the parallel_tests generator must be run in order for the CI workflow to run successfully on GitHub.

## What you get

- CI workflow
  - A sensible default `ci.yml` to get you started with Github Actions. This will run linters, model tests, and system tests.
  - Along with the `ci.yml`, your `database.yml` will be modified to be able to be run in GHA.
- Deploy workflows
  - `deploy-staging.yml` deploys to Heroku on every push to `main` (or manually); `deploy-production.yml` deploys manually via `workflow_dispatch`.
  - Both target a GitHub deployment environment (`Staging`/`Production`) that provides `HEROKU_APP_NAME` and `HEROKU_APP_URL` variables, and authenticate with the org-level `HEROKU_IT_SUPPORT_API_KEY` secret and `HEROKU_IT_SUPPORT_EMAIL` variable.
  - Note: the staging workflow will fail on pushes to `main` until the environment exists — run the `deploy-app` agent skill (installed by the heroku generator) to create the Heroku app and the GitHub environment.
- Pull Request Template
  - When you open a Pull Request in Github it will use the Markdown file as a [template](./templates/pull_request_template.md) for the content of the PR.
  - Helpful for reminding collaborators to add specific details to the PR.
- Copilot Instructions
  - Installed into `.github/instructions`, these are context-specific instructions for Copilot to help it give more accurate
  and relevant results. These are a good starting point but they should be tweaked for your project's frameworks and
  standards.
- Dependabot Configuration
  - defines a set of rules that dependabot will use to keep your applications dependencies up-to-date on a weekly basis.
