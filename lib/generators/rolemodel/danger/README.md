# Danger Generator

## What you get

* danger.yml file to run danger itself
* .danger/rubocop.rb file to get rubocop PR comments
* .danger/eslint.rb file to get eslint PR comments
* .danger/brakeman.rb file to get brakeman PR comments

This is the basic config needed to use semaphore.

## Note
This config assumes
 - `main` is the base branch
 - `yarn test` is the command to run JS tests
