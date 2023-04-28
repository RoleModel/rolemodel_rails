module Rolemodel
  class CIGenerator < Rails::Generators::Base
    def select_ci_platform
      ci_platform = ask('Which CI platform are you using? (semaphore/github)', limited_to: %w[semaphore github])

      case ci_platform
      when 'semaphore'
        generate 'rolemodel:ci:semaphore'
      when 'github'
        generate 'rolemodel:ci:github'
      end
    end
  end
end
