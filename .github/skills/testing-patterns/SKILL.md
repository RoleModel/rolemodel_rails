---
name: testing-patterns
description: Write automated tests using RSpec, Capybara, and FactoryBot for Rails applications. Use when implementing features, fixing bugs, or when the user mentions testing, specs, RSpec, Capybara, or test data. Avoid using rails console or server for testing.
---

# Testing Patterns

## Overview
Write automated tests using RSpec and Capybara. Avoid using the Rails console or starting a Rails server for testing.

## Test Command
```bash
bundle exec rspec
```

## Tech Stack
- **RSpec** - Testing framework
- **Capybara** - System/integration testing
- **FactoryBot** - Test data generation

## Best Practices

### General Guidelines
- Write tests first or alongside implementation
- Avoid manual testing via console
- Use factories for test data creation
- Keep tests focused and readable

### RSpec Conventions
- Use descriptive context and describe blocks
- Follow the arrange-act-assert pattern
- Use let for test data setup
- Prefer `let` over instance variables

### Validation Testing Pattern
Test validations explicitly using `build` with invalid data, then verify the model is invalid and check error messages:

```ruby
describe 'validations' do
  it 'must have a start date' do
    membership = build(:membership, start_date: nil)

    expect(membership).not_to be_valid
    expect(membership.errors.full_messages).to contain_exactly "Start date can't be blank"
  end

  it 'enforces end date must follow start date' do
    membership = build(:membership, start_date: 1.year.ago, end_date: 2.years.ago)

    expect(membership).not_to be_valid
    expect(membership.errors.full_messages).to contain_exactly 'End date must follow start date'
  end

  it 'permits empty end date' do
    membership = build(:membership, start_date: 1.year.ago, end_date: nil)

    expect(membership).to be_valid
  end
end
```

Key points:
- Use `build` instead of `create` to avoid database writes
- Test both invalid and valid scenarios
- Verify exact error messages with `full_messages`
- Use descriptive test names that explain the business rule
- Don't test associations or enums

### Capybara System Tests
- Test user-facing functionality
- Use `data-testid` attributes with `dom_id` for reliable element selection
- Test happy paths and edge cases
- Ensure tests are deterministic
- Avoid sleep statements; use Capybara's waiting mechanisms such as native expectations of elements to appear
- Use `:js` (e.g. `it 'does something', :js do`) for specs that run javascript such as stimulus controllers

### Element Selection with data-testid
Use `data-testid` attributes with `dom_id` for stable, reliable element selection that's resistant to UI changes:

**View:**
```slim
tbody
  - @entries.each do |entry|
    tr data-testid=dom_id(entry)
      td= entry.name
```

**Spec:**
```ruby
within(data_test(entry1)) do
  click_button 'Submit'
end
```

**Benefits:**
- Resilient to text changes (descriptions, labels, etc.)
- Works with dynamic content
- Self-documenting test intent
- Easier to refactor views

**Avoid:**
- Text-based lookups: `within('tr', text: 'Entry 1')`
- CSS class selectors that may change during styling
- Overly specific DOM traversal

### FactoryBot
- Define factories for all models
- Use traits for variations
- Keep factories minimal
- Override attributes in tests as needed
- Always use `build` or `create` instead of direct model instantiation
- Use `build` for validation tests to avoid database writes
- Use `create` when you need persisted records

## Future Topics
- Mocking and stubbing patterns
- Test organization strategies
- Performance testing
- CI/CD integration
