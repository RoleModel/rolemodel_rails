# Blazer Generator

Depends on the blazer generator
Depends on [RSpec Generator](../testing/rspec)
Depends on slim
Works best with Optics
* If not using with Optics, update blazer.css to use your own tokens.

## What you get

Installs [blazer](https://github.com/ankane/blazer) with customization for enabling non-admin users to run Dashboard-type reports (SQL queries with variables) at /reports/dashboards. Prevents SQL-injection vulnerability present in base gem which assumes super-admin access only.

### Controllers
* Adds Reports::DashboardController
* Add Reports::QueriesController

### Views
* Reports list and show

### Tests
* Report system test
