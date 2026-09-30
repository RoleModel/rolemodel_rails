# Icons Generator

[Base Optics Generator](../base)

## What you get

Adds icon helper for handling icon generation using the provider of your choice.

## Icon Builder Customization

Run the generator with the `-i` option to install the IconBuilders themselves in your
application's `lib/rolemodel/optics` directory.

## SVG icons (for example, Hugeicons)

Use `--custom`. Put each SVG in `app/assets/images/icons/`, and `icon('name')` inlines it with
Optics' `.icon--svg` modifier (Optics 2.5+), so size, weight and emphasis modifiers apply. A subfolder
works as part of the name: `icon('duotone-rounded/home-01')`. Draw the SVGs with `currentColor`
so they follow the text color.
