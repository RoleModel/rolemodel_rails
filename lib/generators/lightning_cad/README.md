# LightningCAD Generator

Run all the generators:

```
rails g lightning_cad:all
```

Or run them individually
```
rails g lightning_cad:install
rails g lightning_cad:webpack
rails g lightning_cad:test
```

## Depends On

- `rolemodel:linters:eslint`
- `rolemodel:optics:base`
- `rolemodel:webpack`
- `rolemodel:react`

## What you get

Pulls in [LightningCAD](https://github.com/RoleModel/lightning-cad) and sets up a demo editor

This will add a route for `/editor` with a blank canvas.

The main entrypoint into the JavaScript code is `/app/javascript/components/App.jsx`. In this file a project is created. You can manually add components like lines or shapes to that project.

After running the generators additional setup is required see [how to setup a LightningCAD app](https://github.com/RoleModel/lightning-cad?tab=readme-ov-file#app-setup) for more details.
