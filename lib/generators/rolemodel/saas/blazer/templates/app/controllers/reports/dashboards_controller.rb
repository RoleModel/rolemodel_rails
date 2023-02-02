# frozen_string_literal: true

module Reports
  class DashboardsController < Blazer::DashboardsController
    layout 'application'

    def index
      # authorize Blazer::Dashboard.new
      # @dashboards = policy_scope(Blazer::Dashboard).distinct.order(:name)
      @dashboards = Blazer::Dashboard.distinct.order(:name)
    end

    def show
      # authorize @dashboard
      super
    end
  end
end
