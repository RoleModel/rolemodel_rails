# frozen_string_literal: true

require 'logger'
require 'action_controller/railtie'
require 'action_dispatch/testing/integration'

# Stand-ins for ActiveRecord models. `resource_for` only needs a constant that responds to `find`,
# so these avoid a database while still exercising the real routing & params stack.
class SpecResource
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def self.find(id) = new(id)
end

class Estimate < SpecResource; end
class Widget < SpecResource; end

module Reporting
  class Widget < SpecResource; end
end

# Note the absence of an `include` — Rolemodel::Engine adds `resource_for` to every controller.
class CommentsController < ActionController::Base
  def index
    commentable = resource_for(:commentable_type)

    render plain: "#{commentable.class.name}##{commentable.id}"
  end
end

class ReportsController < ActionController::Base
  def index
    reportable = resource_for(:reportable_type)

    render plain: "#{reportable.class.name}##{reportable.id}"
  end
end

class ResourceForApp < Rails::Application
  config.root = __dir__
  config.eager_load = false
  config.enable_reloading = false
  config.secret_key_base = 'resource_for_spec'
  config.logger = Logger.new(File::NULL)
  config.hosts.clear
  # Surface controller exceptions as raised errors rather than error pages
  config.action_dispatch.show_exceptions = :none

  routes.append do
    concern :commentable do
      resources :comments, only: %i[index], commentable_type: parent_resource.name.classify
    end

    shallow do
      resources :accounts do
        resources :estimates, concerns: :commentable do
          resources :widgets, concerns: :commentable do
            # An explicit, namespaced type — its id param is derived from the demodulized name
            resources :reports, only: %i[index], reportable_type: 'Reporting::Widget'
          end
        end
      end
    end
  end
end

ResourceForApp.initialize!

RSpec.describe Rolemodel::ResourceFor::ControllerExtension, type: :request do
  let(:session) { ActionDispatch::Integration::Session.new(ResourceForApp.instance) }

  def get_body(path, **params)
    session.get(path, **params)
    session.response.body
  end

  it 'loads the parent named by the route default' do
    expect(get_body('/estimates/1/comments')).to eq('Estimate#1')
  end

  it 'loads a different parent for the same controller' do
    expect(get_body('/widgets/9/comments')).to eq('Widget#9')
  end

  it 'prefers the route default over a request param of the same name' do
    expect(get_body('/estimates/1/comments', params: { commentable_type: 'Widget' })).to eq('Estimate#1')
  end

  it 'derives the id param from the demodulized class name' do
    expect(get_body('/widgets/9/reports')).to eq('Reporting::Widget#9')
  end

  it 'is available to every controller as a private method' do
    expect(ActionController::Base.private_method_defined?(:resource_for)).to be(true)
  end
end
