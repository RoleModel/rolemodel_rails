# Tom Select Generator

`rails g rolemodel:tom_select`

## What you get

* The [Tom Select](https://tom-select.js.org/) package and its stylesheet
* A `tom-select` Stimulus controller that survives Turbo morphs
* `tom_select` and `grouped_tom_select` SimpleForm inputs, if the app uses SimpleForm

```slim
= f.input :project_manager, as: :tom_select, collection: User.all
= f.input :material, as: :grouped_tom_select, collection: Category.all, group_method: :materials
```
