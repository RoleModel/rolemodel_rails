# Base CSS Generator

Depends on [Webpacker Generator](../../webpacker)

## What you get

* Puts CSS in app/javascript so [CSS is managed with Webpacker](https://github.com/rails/webpacker/blob/master/docs/css.md)
* Sets up standard RoleModel CSS folder/variable structure
  * Includes Normalize
* Sets up basic Styleguide route to display styles, `/styleguide`

## Inspiration

[Every Layout](https://every-layout.dev/) specifically these Rudiments:

* [Boxes](https://every-layout.dev/rudiments/boxes/)
* [Composition](https://every-layout.dev/rudiments/composition/)
* [Units](https://every-layout.dev/rudiments/units/)
* [Modular Scale](https://every-layout.dev/rudiments/modular-scale/)

[Codyhouse Globals](https://codyhouse.co/ds/globals) specifically:

* [Colors](https://codyhouse.co/ds/globals/colors)
* [Typography Type Scale](https://codyhouse.co/ds/globals/typography)
* [Spacing](https://codyhouse.co/ds/globals/spacing)

## Color Theory

* [Swatches](https://yeun.github.io/open-color/)

## Component Reference Resources

* [csslayout.io](https://csslayout.io/patterns/)
* [codyhouse.co](https://codyhouse.co/ds/components)
* [uiguideline.com](https://www.uiguideline.com)

## Updating Styles

* Generate in a sample app

```
rails g rolemodel:webpacker
rails g rolemodel:css:all
```

* View the styleguide modify as desired
* Copy changes to generator with

```
cp -r example_rails6/app/javascript/stylesheets/ lib/generators/rolemodel/css/base/templates/app/javascript/stylesheets/
cp example_rails6/app/views/styleguide/index.html.slim lib/generators/rolemodel/css/base/templates/app/views/styleguide/index.html.slim
```
