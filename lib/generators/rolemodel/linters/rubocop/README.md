# Linters Generator

## Why do we use linters?

* Catches silly errors - static analysis can catch bug where code may not function in an edge case or just won't compile
* Teaching tool - a good linter setup is oriented around community best practices and can teach you new techniques
* Fast feedback loop - having feedback in your editor while working on a feature, can simplify a code review
  * Note we **strongly** recommend that if you are using linters on a project, every project team member has it setup in their editor. No need for surprises when CI fails.

## What we care about with linters

* It is not a master to bow to
  * You should not be reorganizing your code _just_ to get the linter to pass. For this reason we recommend turning off or lowering to warnings any line length or complexity metrics. They are hard to believe in and there will always be exceptions.
  * If a rule doesn't match expectations of the project team, change it and document why in the config. Also consider a PR to this repo with some reasoning.
* Minimal set of rules
  * We try to limit our linter config to minimum set of rules we as broader team can agree on (or commit to using).
  * For CI we also ensure only the most severe errors cause a failing build.

## Ruby / Rubocop

Base [rubocop](https://github.com/bbatsov/rubocop#inheriting-configuration-from-a-remote-url) configuration used on all RoleModel Ruby projects.

### Editor Setup

* Atom - [linter-rubocop](https://atom.io/packages/linter-rubocop)
  * Supporting: [rubocop-auto-correct](https://atom.io/packages/rubocop-auto-correct)
* VSCode - [ruby-rubocop](https://marketplace.visualstudio.com/items?itemName=misogi.ruby-rubocop)

## JavaScript / ESLint

TODO - incorporate from separate PR

## CSS/SCSS / Stylelint

Base linter to enforce basic CSS/SCSS best practices.

## Contributing

Submit a PR for changes documenting the why behind the change to the config.

## License

MIT
