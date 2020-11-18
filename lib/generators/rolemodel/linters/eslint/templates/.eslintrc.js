module.exports = {
  root: true,
  env: {
    es6: true
  },
  settings: {
    react: {
      version: 'detect'
    },
    'import/resolver': {
      webpack: {
        config: 'config/webpack/development.js'
      }
    }
  },
  extends: ['airbnb'],
  parser: 'babel-eslint',
  parserOptions: {
    ecmaFeatures: {
      jsx: true
    },
    ecmaVersion: 2021
  },
  rules: {
    'no-unused-vars': [
      'error',
      {
        argsIgnorePattern: '^_', // Allow unused arguments starting with an underscore
        varsIgnorePattern: '^_' // Allow unused variables starting with an underscore
      }
    ],

    // No semicolons
    semi: ['error', 'never'],
    'no-unexpected-multiline': 'error',

    // 1. We follow the convention of naming "private" properties with a leading underscore
    // 2. This conflicts with the no-unused-vars config
    'no-underscore-dangle': 'off',

    // Don't need trailing commas everywhere
    'comma-dangle': ['error', 'never'],

    // Multiple variable declarations (without assignment) on the same line
    // without multiple let/const
    'one-var': ['error', { initialized: 'never', uninitialized: 'always' }],
    'one-var-declaration-per-line': ['error', 'initializations'],

    // Don't require naming all non-arrow functions. Modern browsers can usually
    // detect the correct name if it's assigned to a variable or property.
    'func-names': 'off',

    // Don't require instance methods to use `this` (the rule name is confusing)
    'class-methods-use-this': 'off',

    // Allow console.log and similar
    'no-console': 'off',

    // Turning this on addresses some quirks with using `var`. It's unnecessary
    // for `let` and `const`.
    'no-loop-func': 'off',

    // Turning this on requires destructuring in too many cases
    'prefer-destructuring': 'off',

    // Turning this on prevents directly importing sub-dependencies
    'import/no-extraneous-dependencies': 'off',

    // One-liner methods can be readable without the extra spacing
    'lines-between-class-members': ['error', 'always', { exceptAfterSingleLine: true }],

    // Allow assigning to properties of arguments (might consider completely disabling this rule)
    'no-param-reassign': ['error', { props: false }],

    // This rule complains about use of things like PropTypes.object. We could
    // use more-specific types, but that could be a pain with smart objects.
    'react/forbid-prop-types': 'off',

    // This rule enforces either always or never destructuring state and props.
    // There is no "sometimes" option.
    'react/destructuring-assignment': 'off',

    // Sufficiently high that it won't be too annoying
    'max-len': ['warn', 120],

    // Disabled to allow interpolating text and components
    'react/jsx-one-expression-per-line': 'off',

    // Disabled because it complains if you mix `return` with `return <value>` in a function
    'consistent-return': 'off',

    // Don't require function components in an app that prefers class components
    'react/prefer-stateless-function': 'off',

    // Default requires the label to both wrap the input and have htmlFor set.
    // One or the other is usually sufficient.
    'jsx-a11y/label-has-associated-control': [
      'error',
      {
        assert: 'either',
        controlComponents: [], // Put custom input components here
        depth: 25,
        labelAttributes: [],
        labelComponents: []
      }
    ],

    // Whether a prop is required or optional isn't really related to if it has a default value
    'react/require-default-props': 'off',

    // Allow patterns like `while ((a = getNextValue()))`
    'no-cond-assign': ['error', 'except-parens'],

    // Default disallows mixing exponentiation with other arithmetic operators
    'no-mixed-operators': [
      'error',
      {
        allowSamePrecedence: false, // Could also make this true
        groups: [
          ['&', '|', '^', '~', '<<', '>>', '>>>'],
          ['==', '!=', '===', '!==', '>', '>=', '<', '<='],
          ['&&', '||'],
          ['in', 'instanceof']
        ]
      }
    ]
  }
}
