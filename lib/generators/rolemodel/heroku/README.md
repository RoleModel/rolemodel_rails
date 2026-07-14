# Heroku Generator

## What you get

* Procfile configured for a server process and a release command to run migrations
* Basic app.json preconfigured with a script to initialize the database and common environment variables, addons, and buildpacks
This is the basic config needed to deploy to Heroku.

## Deploying the app

Deployment setup itself is handled by the `deploy-app` agent skill, which ships inside the
`rolemodel-rails` gem rather than being copied into your repo — it's one-time setup, so nothing
skill-related is committed to the app. When the generator finishes, it prints the path to the
skill's `SKILL.md`; point any coding agent at that file to deploy the app. You can also locate
it yourself:

```sh
$(bundle show rolemodel-rails)/lib/generators/rolemodel/heroku/templates/deploy-app/SKILL.md
```

The skill cleans up the generated Gemfile (merges duplicate groups, removes comments,
alphabetizes), verifies the test suite and RuboCop pass, creates the Sentry project and wires
up the DSN, creates and deploys the Heroku staging app (buildpacks, dynos, Postgres,
Papertrail), and creates the GitHub `Staging` environment with the
`HEROKU_APP_NAME`/`HEROKU_APP_URL` variables the deploy workflow consumes. The skill is
LLM-agnostic (Agent Skills format). Requires the Heroku CLI, the GitHub CLI, and the Sentry
MCP server.
