# React Generator
Sets up React 18 for Rails.

**Notes**:
* Expects `rolemodel:webpack` to have already run.
* Does not support server side rendering (yet).
* Does NOT use the `react-rails` gem since that gem depends on Shakapacker which we're not using.

## What you get

* A Stimulus controller to mount React components into Rails views
* A Rails view helper: `react_component`
