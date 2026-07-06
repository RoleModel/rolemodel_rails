# Heroku Generator

## What you get

* Procfile configured for a server process and a release command to run migrations
* Basic app.json preconfigured with a script to initialize the database and common environment variables, addons, and buildpacks
* A pointer in `AGENTS.md` to the `deploy-app` agent skill, which ships inside the
  `rolemodel-rails` gem (`lib/rolemodel/skills/deploy-app/SKILL.md`) rather than being copied
  into your repo — it's one-time deployment setup, so nothing skill-related is committed to the
  app. The skill cleans up the generated Gemfile (merges duplicate groups, removes comments,
  alphabetizes), verifies the test suite and RuboCop pass, creates the Sentry project and wires
  up the DSN, creates and deploys the Heroku staging app (buildpacks, dynos, Postgres,
  Papertrail), and creates the GitHub `Staging` environment with the
  `HEROKU_APP_NAME`/`HEROKU_APP_URL` variables the deploy workflow consumes. The skill is
  LLM-agnostic (Agent Skills format): locate it with `bundle show rolemodel-rails` and point any
  coding agent at the SKILL.md. Requires the Heroku CLI, the GitHub CLI, and the Sentry MCP server.

This is the basic config needed to deploy to Heroku.
