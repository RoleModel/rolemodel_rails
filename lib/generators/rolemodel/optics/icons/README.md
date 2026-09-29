# Icons Generator

[Base Optics Generator](../base)

## What you get

Adds icon helper for handling icon generation using the provider of your choice.

## Icon Builder Customization

Run the generator with the `-i` option to install the IconBuilders themselves in your
application's `lib/rolemodel/optics` directory.

## SVG icons (Hugeicons)

`bin/rails g rolemodel:optics:icons --hugeicons` renders icons as inline SVG instead of a font.
The app keeps only the icons it uses, in `app/icons/hugeicons/<style>/<name>.svg`, and reads
each file once per process. Rendering needs no token, no API call and no CDN.

```slim
= icon('home-01')                           / stroke-rounded (free)
= icon('home-01', duotone: true)            / duotone-rounded (Pro)
= icon('home-01', filled: true)             / solid-rounded (Pro)
= icon('home-01', style: 'twotone-rounded') / any Hugeicons style
= icon('home-01', hover_text: 'Home')       / labelled for screen readers; otherwise decorative
```

The generator also adds:

- `lib/tasks/optics_icons.rake`: fetches SVGs from the Hugeicons API. This is the only step that
  needs `HUGEICONS_API_KEY`.
  - `bin/rails optics:icons:vendor` fetches every icon the views use that is not vendored yet.
  - `bin/rails optics:icons:vendor ICONS=home-01,duotone-rounded/user` fetches named icons.
- `spec/icons_spec.rb`: fails when a view uses an icon that is not vendored, and prints the
  command to run. It reads literal names only (`icon('name')`), so vendor names built at runtime
  by hand.

Commit the SVGs with the code that uses them. Colors are rewritten to `currentColor`, so icons
follow the text color and Optics' `color:` option.

**License:** Hugeicons Pro needs a seat for each developer who commits Pro icons, and Pro icons
must not be served as downloadable files. That is why the files live in `app/icons`, outside the
asset pipeline. Never put Pro SVGs or the token in a public repo or package.

To keep the files somewhere else (for example, an app that already vendors them):

```ruby
# config/initializers/icons.rb
Rolemodel::Optics::HugeiconsIconBuilder.root = Rails.root.join('vendor/huge_icons')
```

Requires the Optics `.icon--svg` styles (Optics 2.5+).
