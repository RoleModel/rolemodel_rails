---
applyTo: '**/*.rb'
---
## Coding Standards
- Use Ruby 3.0 or later.
- Follow the rubocop rules defined in the [.rubocop.yml](../../.rubocop.yml) file.
- Use snake_case for method and variable names.
- Use CamelCase for class names.
- Use `# frozen_string_literal: true` at the top of each file to enable frozen string literals.
- Don't add any unnecessary comments; the code should be self-explanatory.

## Testing
- Use FactoryBot for creating test data.
- Prefer FactoryBot over mocking objects.
- Use Faker for generating fake data in factories.
- Write tests in the `spec` directory.
- Write tests for all new features and bug fixes.
