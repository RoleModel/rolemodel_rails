# frozen_string_literal: true

gem 'rolemodel-rails'

after_bundle do
  rails_command 'generate rolemodel:core_setup'
end
