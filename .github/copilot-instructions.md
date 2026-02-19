## Project Context

This project is a Ruby on Rails application that requires specific coding standards and practices to ensure
maintainability and readability.

## Testing

Please avoid using the rails console or starting up a rails server. Instead write automated tests using RSpec and Capybara.

When you run your tests, use the terminal `bundle exec rspec` command.

## Tech Stack

- Ruby on Rails
- PostgreSQL for the database
- Slim for HTML templating
- Stimulus for JavaScript interactions
- CSS for styling
- Optics for CSS styling
- RSpec for testing
- Capybara for system testing
- FactoryBot for test data generation
- Rubocop for code linting

## Response

- Provide evidence-based responses to feedback, focusing on technical accuracy and clarity.
- Maintain a professional and constructive tone in all communications.
- Avoid unnecessary embellishments or emotional language; focus on the task at hand.
- Avoid unnecessary comments; the code should be self-explanatory.
- Do not output a summary of your work at the end
- Always tell me what skill you are using to generate the code.

## Formatting

Find the proper instructions file for the type of code you are generating and follow those instructions.

## Skills

When working with this codebase, use the following skills which contain domain-specific best practices and patterns. Each skill should be referenced when the task matches its domain:

### controller-patterns
Review and update existing Rails controllers and generate new controllers following professional patterns and best practices. Covers RESTful conventions, authorization patterns, proper error handling, and maintainable code organization.
- File: `.github/skills/controller-patterns/SKILL.md`

### dynamic-nested-attributes
Implement Rails nested attributes with dynamic add/remove functionality using Turbo Streams and Simple Form. Use when building forms where users need to manage multiple child records (has_many associations), add/remove nested items without page refresh, or create bulk records inline.
- File: `.github/skills/dynamic-nested-attributes/SKILL.md`

### form-auto-save
Automatic form submission after user input changes using a debounce mechanism to prevent excessive server requests. Creates a seamless auto-save experience for forms with rich text editors or multiple fields.
- File: `.github/skills/form-auto-save/SKILL.md`

### frontend-patterns
Frontend patterns for Rails applications using Slim templates, Stimulus JavaScript framework, CSS with Optics utilities. Use when building views, adding interactivity, styling components, or when the user mentions Slim, Stimulus, JavaScript, CSS, or frontend development.
- File: `.github/skills/frontend-patterns/SKILL.md`

### json-typed-attributes
Define typed attributes backed by JSON fields in Rails models. Use when models need flexible data storage with type casting, validations, and form integration. Supports integer, decimal, string, text, boolean, date, and array types.
- File: `.github/skills/json-typed-attributes/SKILL.md`

### routing-patterns
Review, generate, and update Rails routes following professional patterns and best practices. Covers RESTful resource routing, route concerns for code reusability, shallow nesting strategies, and advanced route configurations.
- File: `.github/skills/routing-patterns/SKILL.md`

### stimulus-controllers
Create and register Stimulus controllers for interactive JavaScript features. Use when adding client-side interactivity, dynamic UI updates, or when the user mentions Stimulus controllers or JavaScript behavior.
- File: `.github/skills/stimulus-controllers/SKILL.md`

### testing-patterns
Write automated tests using RSpec, Capybara, and FactoryBot for Rails applications. Use when implementing features, fixing bugs, or when the user mentions testing, specs, RSpec, Capybara, or test data. Avoid using rails console or server for testing.
- File: `.github/skills/testing-patterns/SKILL.md`

### turbo-fetch
Implement dynamic form updates using Turbo Streams and Stimulus. Use when forms need to update fields based on user selections without full page reloads, such as cascading dropdowns, conditional fields, or dynamic option lists.
- File: `.github/skills/turbo-fetch/SKILL.md`

### optics-context
Use the Optics design framework for styling applications. Apply Optics classes for layout, spacing, typography, colors, and components. Use when working on CSS, styling views, or implementing design system guidelines.
- File: `.github/skills/optics-context/SKILL.md`
