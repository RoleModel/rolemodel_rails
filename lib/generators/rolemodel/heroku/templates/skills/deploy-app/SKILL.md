---
name: deploy-app
description: >
  Set up deployment for a RoleModel Rails app after running the rolemodel_rails
  core_setup generator. Cleans up the generated Gemfile, verifies the test suite and
  RuboCop pass, creates the Sentry project and wires up the DSN, creates and deploys
  the Heroku app (buildpacks, dynos, Postgres, Papertrail), and creates the GitHub
  deployment environment + deploy workflow. Use when the user says "deploy app",
  "set up staging", "set up heroku", "set up sentry for deploy", or "set up production
  deploy". Defaults to staging; pass "production" for the production flow.
---

# Deploy App

Completes deployment setup for a RoleModel Rails app in five phases: Gemfile cleanup,
green build (tests + RuboCop), Sentry, Heroku, GitHub. Default mode is **staging**. If
invoked with `production`, follow the [Production mode](#production-mode) differences.

Every step must be **idempotent**: check whether the resource already exists before
creating it, and skip or repair rather than failing. Report each phase's outcome as you
go. Ask the user questions **one at a time**.

## Phase 0: Preflight

Run these checks before touching anything. Stop and tell the user how to fix any that
fail:

1. `git remote get-url origin` — must be a GitHub repo. Derive `REPO_NAME` from
   `gh repo view --json name -q .name` (fallback: basename of the origin URL).
2. `gh auth status` — GitHub CLI authenticated.
3. `heroku auth:whoami` — Heroku CLI installed and logged in.
4. Sentry MCP tools available (try listing organizations). If no Sentry MCP server is
   connected, ask the user to add/authorize the Sentry MCP server
   (https://mcp.sentry.dev) in their coding agent's MCP configuration and stop — do not
   fall back to another mechanism.
5. Read `Procfile` — note whether a `worker` process exists.
6. Read `config/initializers/sentry.rb` — determine how the DSN is consumed:
   - reads `ENV['SENTRY_DSN']` → **env-var mode** (RoleModel standard)
   - reads `Rails.application.credentials...` → **credentials mode**

Set `APP_NAME` = `<REPO_NAME>-staging` (staging) or `<REPO_NAME>` (production), but
confirm it with the user before creating anything on Heroku.

## Phase 1: Gemfile cleanup

The rolemodel_rails generators append gems as they run, leaving multiple blocks for the
same group and top-level gems scattered between them. Normalize the Gemfile first (skip
this phase if it's already clean):

1. Merge duplicate `group` blocks so each unique group combination
   (e.g. `:development, :test`, `:development`, `:test`) appears exactly once.
2. Remove all comments, including commented-out gems (e.g. `# gem "redis" ...`).
3. Alphabetize the gems — the top-level list and the list within each group.
4. Preserve every gem's version constraint and options (`require:`, `platforms:`,
   `path:`, etc.) exactly as written. File order: `source`, then `ruby` (if present),
   then top-level gems, then the group blocks.
5. Run `bundle install` and confirm it succeeds. `git diff Gemfile.lock` must show no
   changes — this is an ordering-only cleanup; if the lockfile changed, you altered a
   dependency and must fix it.

## Phase 2: Green build

Do not deploy a broken app. Both checks must pass before continuing to any later phase:

1. RuboCop: `bin/rubocop` (fallback: `bundle exec rubocop`). If there are offenses,
   apply safe autocorrections (`rubocop -a`), then fix the remainder by hand.
2. Test suite: `bin/rspec` (fallback: `bundle exec rspec`). Fix any failures at the
   root cause — never skip, pend, or delete tests to get to green.
3. Re-run both until clean, then commit the Gemfile cleanup and any fixes (the deploy
   later pushes this branch, so everything must be committed).

## Phase 3: Sentry project + DSN

1. List the Sentry organizations/teams via the Sentry MCP. Ask the user which team the
   project belongs under (skip the question if there is only one option).
2. Check whether a project named `REPO_NAME` already exists in that org. If it does,
   reuse it and fetch its DSN instead of creating a duplicate.
3. Otherwise create the project: slug/name = `REPO_NAME`, platform `ruby-rails`,
   assigned to the confirmed team.
4. Fetch the project's client key (DSN).
5. Deliver the DSN according to the mode detected in preflight:
   - **env-var mode**: no code change needed. The DSN is set as a Heroku config var in
     Phase 4 (`SENTRY_DSN`, plus `SENTRY_ENVIRONMENT=staging`). Mention that local
     error reporting (if ever wanted) uses the same `SENTRY_DSN` env var.
   - **credentials mode**: do NOT edit credentials yourself. Print the DSN and exact
     instructions — e.g. `bin/rails credentials:edit --environment production`, add
     `sentry_dsn: <DSN>` — then wait for the user to confirm they've saved it. Verify
     afterwards with
     `bin/rails runner "abort 'missing' unless Rails.application.credentials.sentry_dsn"`
     (adjust env/key path to match the initializer) before moving on.

## Phase 4: Heroku app

1. `heroku teams` — ask the user which team to create the app in. **Do not create the
   app until they confirm the team and the app name** (default `<REPO_NAME>-staging`).
2. Ensure the current branch is pushed: check `git status` and
   `git rev-parse @ @{u}`. If there's no upstream or local is ahead, ask the user to
   push (or push for them if they say so) before continuing.
3. Create the app if it doesn't exist (`heroku apps:info -a $APP_NAME` to check):
   `heroku apps:create $APP_NAME --team <team>`
4. Buildpacks, in this exact order (check `heroku buildpacks -a $APP_NAME` first):
   1. `heroku buildpacks:add heroku/nodejs -a $APP_NAME`
   2. `heroku buildpacks:add heroku/ruby -a $APP_NAME`
5. Add-ons (skip any that already exist per `heroku addons -a $APP_NAME`):
   - `heroku addons:create heroku-postgresql:essential-0 -a $APP_NAME`
   - Papertrail: run `heroku addons:plans papertrail` and pick the plan whose
     name/description matches "Development" (case-insensitive); if no plan matches,
     show the plan list and ask the user which to use. Then
     `heroku addons:create papertrail:<plan> -a $APP_NAME`.
6. Config vars:
   - `RAILS_MASTER_KEY`: **never read `config/master.key` (or
     `config/credentials/production.key`) — the key must not enter the model's context.**
     Pause and tell the user to run this in their own terminal:
     `heroku config:set RAILS_MASTER_KEY=$(cat config/master.key) -a $APP_NAME`
     (substitute `config/credentials/production.key` if per-environment credentials are
     in use). Once they confirm, verify presence without exposing the value:
     `heroku config --json -a $APP_NAME | jq 'has("RAILS_MASTER_KEY")'` — must be `true`.
   - env-var mode only, set these yourself:
     `heroku config:set SENTRY_DSN=<dsn> SENTRY_ENVIRONMENT=staging -a $APP_NAME`
7. Enable runtime dyno metadata (idempotent) so Sentry can detect releases:
   `heroku labs:enable runtime-dyno-metadata -a $APP_NAME`. This adds `HEROKU_*`
   env vars (e.g. `HEROKU_SLUG_COMMIT`) on the next release; without it the release
   command logs a warning about dyno metadata.
8. Initial deploy from the local machine:
   - `heroku git:remote -a $APP_NAME -r heroku-staging`
   - `git push heroku-staging <current-branch>:main`
   - If the build or release phase fails, read the build output / `heroku logs` and fix
     the root cause before proceeding — do not create the GitHub environment until the
     app deploys and boots.
9. Dyno formation (after the first successful deploy):
   - `heroku ps:type web=basic -a $APP_NAME`
   - If the Procfile has a `worker` process: `heroku ps:scale worker=1:basic -a $APP_NAME`
10. Verify: get the app URL from `heroku apps:info -a $APP_NAME --json` (`web_url`), then
    curl `<web_url>/up` and confirm a 200. Save the URL as `APP_URL` (no trailing slash).

## Phase 5: GitHub environment + deploy workflow

1. Create the environment (idempotent PUT):
   `gh api -X PUT repos/{owner}/{repo}/environments/Staging`
2. Set the environment variables:
   - `gh variable set HEROKU_APP_NAME --env Staging --body "$APP_NAME"`
   - `gh variable set HEROKU_APP_URL --env Staging --body "$APP_URL"`
3. If `.github/workflows/deploy-staging.yml` doesn't exist, copy it from this skill's
   `templates/deploy-staging.yml`, commit it, and push. The workflow relies on the
   RoleModel **org-level** `HEROKU_IT_SUPPORT_API_KEY` secret and
   `HEROKU_IT_SUPPORT_EMAIL` variable — do not create per-repo copies.
4. Verify end-to-end: `gh workflow run deploy-staging.yml` then `gh run watch` the run.
   A green run (including its `/up` healthcheck) is the definition of done.

## Production mode

Same phases with these differences — ask, don't assume, on every sizing choice:

- App name defaults to `<REPO_NAME>` (confirm with the user).
- Sentry: reuse the existing project; set `SENTRY_ENVIRONMENT=production`.
- Heroku tiers: ask the user for dyno type (basic/standard-1x/standard-2x/performance),
  Postgres plan, and Papertrail plan instead of assuming the staging defaults.
- GitHub environment is `Production`; workflow template is
  `templates/deploy-production.yml` (manual `workflow_dispatch` only — production never
  auto-deploys on push).

## Notes

- Never run destructive Heroku commands (`apps:destroy`, `addons:destroy`,
  `pg:reset`) as part of this skill.
- Never read secret material into the model's context: `config/master.key`,
  `config/credentials/*.key`, or the output of `heroku config` without `--json | jq`
  filtering. When a secret must be set, have the user run the command themselves and
  verify only the key's presence afterwards.
- If any phase was already completed on a previous run, say so and continue with the
  next phase rather than starting over.
