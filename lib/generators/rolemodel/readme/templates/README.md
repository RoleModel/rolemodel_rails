# Overview
## Name and aliases
The project is named "<name>". Some will refer to it as "<alias1>" or "<alias2>".

## Purpose
The system is designed to solve the problem of ... Users had the problem, but this system resolves it by ...

## Technologies
### Chosen
* Ruby on Rails
* Postgres
* nginx
* unicorn

### Tried and rejected
* Node.js - Not enough internal experience.
* Mongo - Needed to use a relational database for reporting.
* Websphere - Cost
* webrick - Application servers are using newer technology now.

## Technology relationships
<insert image here>

## Supported browsers
The customer states that only Chrome will be used.

# How to set up the project
## External tool installation
\```
brew update --system
brew upgrade ruby-build
git clone http://github.com/RoleModel/<project>
cd <project>
rbenv install
gem install bundler
bundle install
\```

## How to run locally
`rails s`

## How to run tests
`rake`

## Editor plugins
* Rubocop linter

## Troubleshooting information
* [App Status Page](http://app.<applicationname>.com/_ping) will give you information about what is running.
* Alternatively, you can ssh in and check that the application server and web server are both running.

# Testing Strategy
## Testing approach
### System tests
Due to the nature of this application, End User tests are...

### Unit tests
Due to the nature of this application, unit tests are prominent and handle most of the confidence building and documentation needs of the system below the user interface.

### Other tests
At this point, no other tests are being employed.
However, one might consider performance tests or other categories and describe the reasons here

## Testing tools
Which tools are we using?

## Continuous integration
No CI has been set up yet (though we recommend Sempahore in most cases).  When you set it up, tell what you need to know here

# Branching strategy
To begin a new feature run, `git checkout -b <branchname>`.
When finished with the feature and the code has been reviewed, the commits should be squashed before merging. See [RoleModel Best Practices](https://github.com/RoleModel/BestPractices) for more information.

# List of background processes
* Nightly database backup and export
* Monthly invoicing on last business day of the month

# Links to:
## [Git repo](http://github.com/RoleModel/)
## [Task management system](http://trello.com)
## [Staging](http://staging.<applicationname>.com)
## [Production](http://app.<applicationname>.com)
## External services
* [HoneyBadger](http://honeybadger.io)
* [Skylight](http://skylight.io)
* [SendGrid](http://sendgrid.com/RoleModel)
* [Heroku](http://herokuapp.com)

## [CI](http://semaphoreci.com/RoleModel)
## [Core project presentation](http://docs.google.com)
## [List of contributors](http://github.com/RoleModel)
## [Change log](file://./docs/change_log.md)

# Deployment
## Strategy/process/commands
`master` is always deployed to production. The `staging` branch is deployed to staging.
\```
git checkout master
git tag 2016-05-16 # <date> YYYY-MM-DD
git push --tags
\```
Deployment is done with [Ansible](http://ansible.com).
`ansible <command goes here>`

## Description of host(s), DNS, certificate authority
The application is deployed to Heroku. They are also hosting the DNS. We certificate was received from [Let's Encrypt](https://letsencrypt.org/).

## ssh information
`ssh user@hostname.com`

# Customer contacts
* Joe Johnson - 919-555-1212
* Larry Anderson - 919-555-1213

# Copyright & licensing
Copyright (c) 2019 Closed Source @CompanyName
