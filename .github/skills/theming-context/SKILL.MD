---
name: theming-context
description: Using Optics for implementing design system guidelines, theming, and color scales.
metadata:
  triggers:
    - theme
    - design-system
    - optics
---
# Theming
To customize the application, a custom theme files that serve as overrides to the existing tokens can be provided. An example implementation of the main project CSS file would look like:
```css
@import '@rolemodel/optics';

@import 'stylesheets/theme/my_app_theme';
```
Note how the custom theme is imported after the main Optics styles, ensuring that any token overrides take precedence.

A custom theme can change any tokens, including colors, radius, fonts, and even redefine the luminosity and semantic scales.

```css
@import url('https://fonts.googleapis.com/css2?family=Coming+Soon&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Grandstander:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap');

:root {
  /* Colors */
  --op-color-primary-h: my-new-value;
  --op-color-primary-s: my-new-value;
  --op-color-primary-l: my-new-value;

  /* Color Scale */
  --op-color-primary-plus-two: light-dark(
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 64%),
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 32%)
  );

  /* Fonts */
  --op-font-family: 'Coming Soon', sans-serif;
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme-mode='light']) {
    --op-font-family: 'Grandstander', sans-serif;
  }
}

:root[data-theme-mode='dark'] {
  --op-font-family: 'Grandstander', sans-serif;
}
```

### Color Scale Overriding
If  you need to override the provided color scales, you should redefine all the variants of that color to ensure consistency across the application. For example, if you are overriding the primary color, you should redefine all its variants like so:

```css
:root {
  --op-color-primary-h: 164;
  --op-color-primary-s: 100%;
  --op-color-primary-l: 50%;

  /* Main Scale */
  --op-color-primary-plus-two: light-dark(
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 64%),
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 32%)
  );
  --op-color-primary-plus-one: light-dark(
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 45%),
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 35%)
  );

  /* On Scale */
  --op-color-primary-on-plus-two: light-dark(
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 16%),
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 80%)
  );
  --op-color-primary-on-plus-two-alt: light-dark(
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 6%),
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 92%)
  );
  --op-color-primary-on-plus-one: light-dark(
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 100%),
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 80%)
  );
  --op-color-primary-on-plus-one-alt: light-dark(
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 95%),
    hsl(var(--op-color-primary-h) var(--op-color-primary-s) 98%)
  );
}
```

## For More Information
For more details on theming and token overrides, refer to the Optics documentation using the links below
- [Optics Repo](https://github.com/RoleModel/optics/)

### Documentation Resources
For detailed component usage, refer to:
- **Component API**: https://docs.optics.rolemodel.design/?path=/docs/components-button--docs
- **Token Reference**: https://docs.optics.rolemodel.design/?path=/docs/overview-tokens--docs
- **Color System**: https://docs.optics.rolemodel.design/?path=/docs/tokens-color-color-scale--docs

### When You Need More Information
If the user asks about specific components or advanced features not covered in this skill:
1. Use `web_fetch` or another method to retrieve the relevant documentation page
2. Extract the specific information needed
3. Apply it to the user's request

Example: For button variants, check https://docs.optics.rolemodel.design/?path=/docs/components-button--docs
