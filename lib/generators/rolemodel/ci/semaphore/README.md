# Semaphore Generator

## What you get

* semaphore.yml file to run the relevant CI commands
* heroku-deployment-commands.sh file with commands to deploy to heroku
* staging-deploy.yml file with commands to deploy to staging
* production-deploy.yml file with commands to deploy to production

This is the basic config needed to use semaphore.

## Note
This config assumes
 - `main` is the base branch
 - `yarn test` is the command to run JS tests
