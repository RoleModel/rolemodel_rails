# frozen_string_literal: true

require 'action_controller'
require 'action_dispatch/testing/integration'

# The engine hands `resource_for` to controllers through this initializer during app boot.
# Running it here gives us the same wiring without booting an app inside the generator specs' process.
Rolemodel::Engine.initializers.detect { it.name == 'rolemodel.action_controller' }.run

# Stand-ins for ActiveRecord models. `resource_for` only needs a constant that responds to `find`,
# so these keep the spec database-free while still exercising the real router & params stack.
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

# Note the absence of an `include` — the engine adds `resource_for` to every controller.
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

RSpec.describe Rolemodel::ResourceFor::ControllerExtension, type: :request do
  let(:routes) do
    ActionDispatch::Routing::RouteSet.new.tap do |route_set|
      route_set.draw do
        concern :commentable do
          resources :comments, only: %i[index], commentable_type: parent_resource.name.classify
        end

        shallow do
          resources :accounts do
            resources :estimates, concerns: :commentable do
              resources :widgets, concerns: :commentable do
                # An explicit, namespaced type — its id param comes from the demodulized name
                resources :reports, only: %i[index], reportable_type: 'Reporting::Widget'
              end
            end
          end
        end
      end
    end
  end

  let(:session) { ActionDispatch::Integration::Session.new(routes) }

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
