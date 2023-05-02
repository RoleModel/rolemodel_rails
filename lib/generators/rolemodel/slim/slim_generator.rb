module Rolemodel
  class SlimGenerator < Rails::Generators::Base
    def add_slim
      run 'bundle add slim'
    end
  end
end
