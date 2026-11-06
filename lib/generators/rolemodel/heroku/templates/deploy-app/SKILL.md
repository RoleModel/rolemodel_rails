---
name: deploy-app
description: >
  Set up deployment for a RoleModel Rails app after running the rolemodel_rails
  core_setup generator. Cleans up the generated Gemfile, verifies RuboCop, the test
  suite, and a local production smoke test pass, creates the Sentry project and wires
  up the DSN, creates and deploys the Heroku app (buildpacks, dynos, Postgres,
  Papertrail), and creates the GitHub deployment environment + deploy workflow. Use
  when the user says "deploy app",
  "set up staging", "set up heroku", "set up sentry for deploy", or "set up production
  deploy". Defaults to staging; pass "production" for the production flow.
---

# Deploy App

Completes deployment setup for a RoleModel Rails app in five phases: Gemfile cleanup,
green build (RuboCop + tests + production smoke test), Sentry, Heroku, GitHub. Default
mode is **staging**. If invoked with `production`, follow the
[Production mode](#production-mode) differences.

Every step must be **idempotent**: check whether the resource already exists before
creating it, and skip or repair rather than failing. Report each phase's outcome as you
go. Ask the user questions **one at a time**.

## Phase 0: Preflight

Run these checks before touching anything (creating a missing GitHub repo is the one
exception). Stop and tell the user how to fix any that fail:

1. `gh auth status` — GitHub CLI authenticated.
2. `git remote get-url origin` — must be a GitHub repo. A brand-new app has no `origin` yet:
   offer to create one, confirming the name (default: the app directory's name) and that it
   should be private in the RoleModel org, then
   `gh repo create RoleModel/<name> --private --source . --remote origin --push`.
   Derive `REPO_NAME` from `gh repo view --json name -q .name` (fallback: basename of the
   origin URL).
3. `heroku auth:whoami` — Heroku CLI installed and logged in.
4. Sentry MCP tools available (try listing organizations). If no Sentry MCP server is
   connected, ask the user to add/authorize the Sentry MCP server
   (https://mcp.sentry.dev) in their coding agent's MCP configuration and stop — do not
   fall back to another mechanism.
5. Read `Procfile` — note whether a `worker` process exists.
6. Read `config/initializers/sentry.rb` — determine how the DSN is consumed:
   - reads `ENV['SENTRY_DSN']` → **env-var mode** (RoleModel standard)
   - reads `Rails.application.credentials...` → **credentials mode**
7. Deploy-readiness (recent `rolemodel-rails` bakes these in; older apps need the manual
   fixes noted in each phase). Confirm the generated app already has:
   - custom cops under `.rubocop/cops/`, not `lib/cops/` (the latter crashes prod boot)
   - `config/initializers/lograge.rb` uses `controller.try(:current_user)`
   - a `ruby` directive in the `Gemfile` (so the version reaches `Gemfile.lock`)
   - `stackprof` in the `Gemfile` (Sentry profiling)
   If any are missing, apply the fix inline and note the app predates the generator update.

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

## Phase 2: Green build + production smoke test

Do not deploy a broken app. This is a **verification gate**: on a current generated app
these should pass with no changes. A failure here usually means a generator regression —
fix the root cause (and flag it for the generator), never paper over it.

1. RuboCop: `bin/rubocop` (fallback: `bundle exec rubocop`). If there are offenses,
   apply safe autocorrections (`rubocop -a`), then fix the remainder by hand.
2. Test suite: `bundle exec rspec` (fallback: `bin/rspec`). Fix any failures at the
   root cause — never skip, pend, or delete tests to get to green.
3. **Local production smoke test** — this is what catches the boot/asset/DB failures that
   only surface under `RAILS_ENV=production` (eager loading, `force_ssl`, DATABASE_URL).
   Run against a throwaway local Postgres DB (do not touch development/test data):
   ```
   export PROD="RAILS_ENV=production SECRET_KEY_BASE=smoketest \
     DATABASE_URL=postgres://$(whoami)@localhost/<repo>_prodsmoke"
   env $PROD bundle exec rails db:create
   env $PROD bundle exec rails assets:precompile      # webpack + asset pipeline
   env $PROD RAILS_SERVE_STATIC_FILES=true PORT=3999 bundle exec puma -C config/puma.rb &
   sleep 6
   curl -s -o /dev/null -w '%{http_code}\n' -H 'X-Forwarded-Proto: https' \
     http://localhost:3999/up      # expect 200 (plain http returns 301 due to force_ssl)
   kill %1; env $PROD bundle exec rails db:drop
   ```
   `assets:precompile` succeeding and `/up` → 200 is the gate. If `/up` 500s, read the
   server log for the root cause before proceeding.
4. Re-run until clean, then commit the Gemfile cleanup and any fixes (the deploy later
   pushes this branch, so everything must be committed).

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
3. Run [`heroku_setup`](./heroku_setup) (next to this file) from the app's root. It does
   the rest of this phase and steps 1–2 of Phase 5, and skips anything that already exists,
   so it is safe to re-run after a failure:
   - creates the app in the team, adds the `heroku/nodejs` then `heroku/ruby` buildpacks
   - adds `heroku-postgresql:essential-0` and the Papertrail plan named "Development"
   - sets `RAILS_MASTER_KEY` (from `config/credentials/<stage>.key` when it exists, else
     `config/master.key`), `SENTRY_ENVIRONMENT`, and `SENTRY_DSN` when given; enables
     `runtime-dyno-metadata` so Sentry can detect releases
   - pushes the current branch to Heroku's `main`, sets the dyno type, scales a `worker`
     to 1 if the Procfile has one, and waits for `<web_url>/up` to return 200
   - creates the GitHub environment and sets `HEROKU_APP_NAME` and `HEROKU_APP_URL`

   The script reads the master key, which must not enter the model's context, so **the user
   runs it in their own terminal**. Give them the exact command (omit `SENTRY_DSN` in
   credentials mode):
   ```
   SENTRY_DSN=<dsn> bash <path to this folder>/heroku_setup $APP_NAME <team> staging
   ```
   If it fails, read the error it stops on (or `heroku logs -a $APP_NAME`), fix the root
   cause, and have the user run it again. Do not set up the deploy workflow until the app
   deploys and boots.

## Phase 5: GitHub environment + deploy workflow

1. Confirm the script set the environment variables:
   `gh variable list --env Staging` must show `HEROKU_APP_NAME` and `HEROKU_APP_URL`.
   Never let the deploy workflow run before they exist: with an empty `HEROKU_APP_NAME`
   the deploy action creates a randomly named Heroku app instead of failing.
2. Confirm `.github/workflows/deploy-staging.yml` exists (the rolemodel-rails github
   generator installs it). If it's missing, the app skipped the github generator — tell
   the user to run it (`rails generate rolemodel:github`) rather than hand-writing the
   workflow. The workflow relies on the RoleModel **org-level**
   `HEROKU_IT_SUPPORT_API_KEY` secret and `HEROKU_IT_SUPPORT_EMAIL` variable — do not
   create per-repo copies.
3. Verify end-to-end: `gh workflow run deploy-staging.yml` then `gh run watch` the run.
   A green run (including its `/up` healthcheck) is the definition of done.

## Production mode

Same phases with these differences — ask, don't assume, on every sizing choice:

- App name defaults to `<REPO_NAME>` (confirm with the user).
- Sentry: reuse the existing project; set `SENTRY_ENVIRONMENT=production`.
- Heroku tiers: ask the user for dyno type (basic/standard-1x/standard-2x/performance),
  Postgres plan, and Papertrail plan instead of assuming the staging defaults. Pass them to
  the script as `DYNO_TYPE`, `POSTGRES_PLAN` and `PAPERTRAIL_PLAN`, with `production` as
  its third argument.
- GitHub environment is `Production`; the workflow is
  `.github/workflows/deploy-production.yml` (also installed by the github generator; manual
  `workflow_dispatch` only — production never auto-deploys on push).

## Notes

- Never run destructive Heroku commands (`apps:destroy`, `addons:destroy`,
  `pg:reset`) as part of this skill.
- Never read secret material into the model's context: `config/master.key`,
  `config/credentials/*.key`, or the output of `heroku config` without `--json | jq`
  filtering. When a secret must be set, have the user run the command themselves and
  verify only the key's presence afterwards.
- If any phase was already completed on a previous run, say so and continue with the
  next phase rather than starting over.
