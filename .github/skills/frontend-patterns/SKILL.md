---
name: frontend-patterns
description: Frontend patterns for Rails applications using Slim templates, Stimulus JavaScript framework, CSS with Optics utilities. Use when building views, adding interactivity, styling components, or when the user mentions Slim, Stimulus, JavaScript, CSS, or frontend development.
---

# Frontend Patterns

## Tech Stack
- **Slim** - HTML templating
- **Stimulus** - JavaScript interactions
- **CSS** - Styling
- **Optics** - CSS styling framework

## Slim Templates

### Conventions
- Use Ruby 3+ syntax (e.g., keyword arguments with `:`)
- Keep logic minimal in views
- Extract complex rendering to helpers or partials
- Use locals for partial data passing
- **Always prioritize DRY principles - extract repeated markup into partials**
- **Extract partials when logic or markup is repeated more than once**
- **Never use inline styles**

### When to Use Helpers vs Partials

**Use Helper Methods when:**
- Simple conditional logic that returns HTML with different text/classes
- Formatting data (dates, currency, durations)
- Generating single HTML elements with varying attributes
- Logic is stateless and doesn't need multiple elements
- Example: `status_badge(status)`, `format_duration(seconds)`

**Use Partials when:**
- Complex markup structure (multiple nested elements)
- Reusable UI components with layout
- Need to render collections
- Significant HTML that would clutter a helper
- Example: `_time_entry_row.html.slim`, `_timer_form.html.slim`

**Rule of thumb:** If it's primarily conditional text/classes in a single element, use a helper. If it's a structure/layout, use a partial.

### Partial Extraction Guidelines
- Extract forms on the `new` and `edit` pages into `_form` partials
- Extract repeated structures into component partials
- Use descriptive partial names: `_time_entry_row`, `_project_selector`, `_status_badge`
- Place partials in same directory as parent view or in `shared/` for cross-feature use
- Always use keyword arguments for partial locals: `render 'row', time_entry:, show_actions: true`

### Partial Organization
```
app/views/
  time_entries/
    edit.html.slim            # Edit view
    index.html.slim           # Main view
    new.html.slim             # New view
    show.html.slim            # Show view
    _time_entries.html.slim   # Table collection of rows
    _time_entry.html.slim     # Individual row
    _form.html.slim           # Time Entries form
  shared/
    _status_badge.html.slim   # Reusable badge
    _empty_state.html.slim    # Empty state pattern
```

### Conditional class names
Use the rails class_names helper to manage conditional class names in Slim templates.
```slim
button.btn class=class_names('btn--active': active) Click Me
```

### Example
```slim
-# locals: (user:, active: false)
.user-card class=('active' if active)
  h3 = user.name
  p = user.email
```

## Stimulus Controllers

### Structure
- One controller per behavior
- Use data attributes for configuration
- Keep controllers focused and composable
- Follow naming conventions (kebab-case in HTML)

### Example
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  static values = { url: String }

  connect() {
    // Initialization
  }

  perform() {
    // Action logic
  }
}
```

## CSS & Optics

### Guidelines
- Use Optics utility classes where applicable
- Keep custom CSS minimal and scoped
- Follow BEM or similar naming for custom components
- Avoid inline styles

## Future Topics
- Turbo Frames and Streams patterns
- Form styling conventions
- Icon helper usage
- Responsive design patterns
- Animation and transition guidelines
