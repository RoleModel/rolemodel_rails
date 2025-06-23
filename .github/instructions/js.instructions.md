---
applyTo: "**/*.js,**/*.mjs,**/*.cjs"
---

- Prefer ESM syntax for JavaScript files, and avoid using CommonJS syntax unless the file is already CommonJS.
- Important: Never use semicolons at the end of statements.
- Use single quotes for strings, except when the string contains a single quote, in which case use double quotes.
- Use `const` for variables that are not reassigned, and `let` for variables that are reassigned.

## Frameworks and Libraries
// Note to maintainers: Tailor this section to the specific frameworks and libraries used in your project
// and remove this comment.

- Use [Stimulus](https://stimulus.hotwired.dev/) for JavaScript behavior.
- Use [Turbo](https://turbo.hotwired.dev/) for page navigation and updates.
