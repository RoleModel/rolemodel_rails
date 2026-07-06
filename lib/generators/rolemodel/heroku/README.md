# Heroku Generator

## What you get

* Procfile configured for a server process and a release command to run migrations
* Basic app.json preconfigured with a script to initialize the database and common environment variables, addons, and buildpacks
* A `deploy-app` agent skill (`.claude/skills/deploy-app/`, referenced from `AGENTS.md`) that
  completes deployment setup: cleans up the generated Gemfile (merges duplicate groups, removes
  comments, alphabetizes), verifies the test suite and RuboCop pass, creates the Sentry project
  and wires up the DSN, creates and deploys the Heroku staging app (buildpacks, dynos, Postgres,
  Papertrail), and creates the GitHub `Staging` environment with the
  `HEROKU_APP_NAME`/`HEROKU_APP_URL` variables the deploy workflow consumes. The skill is LLM-agnostic (Agent Skills format): run `/deploy-app` in
  Claude Code, or point any other coding agent at the SKILL.md. Requires the Heroku CLI, the
  GitHub CLI, and the Sentry MCP server.

This is the basic config needed to deploy to Heroku.
