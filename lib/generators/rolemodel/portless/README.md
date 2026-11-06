# Portless Generator

## What you get

### Portless

Sets up [portless](https://github.com/vercel-labs/portless), which gives each app a stable
`https://<app-name>.localhost` URL instead of a port number. Several apps can run at once
without fighting over port 3000.

* `bin/portless` installs portless, starts its proxy (HTTPS, `.localhost`) if needed, then runs `Procfile.pdev`
* `Procfile.pdev` is a copy of `Procfile.dev` with the web process run through portless

Run `bin/portless` in place of `bin/dev`. The proxy needs `sudo` the first time it starts.
Keep `Procfile.pdev` in step with `Procfile.dev` when you add processes.
