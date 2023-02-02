# frozen_string_literal: true

module Reports
  class DashboardsController < ApplicationController
    helper Blazer::BaseHelper

    def index
      # authorize Blazer::Dashboard.new
      # @dashboards = policy_scope(Blazer::Dashboard).distinct.order(:name)
      @dashboards = Blazer::Dashboard.distinct.order(:name)
    end

    def show
      @dashboard = Blazer::Dashboard.find(params[:id])
      # authorize @dashboard

      # The rest is copied from Blazer::DashboardsController
      @queries = @dashboard.dashboard_queries.order(:position).preload(:query).map(&:query)
      @queries.each do |query|
        @success = process_vars(query.statement_object)
      end
      @bind_vars ||= []

      @smart_vars = {}
      @sql_errors = []
      @data_sources = @queries.map { |q| Blazer.data_sources[q.data_source] }.uniq
      @bind_vars.each do |var|
        @data_sources.each do |data_source|
          smart_var, error = parse_smart_variables(var, data_source)
          ((@smart_vars[var] ||= []).concat(smart_var)).uniq! if smart_var
          @sql_errors << error if error
        end
      end

      add_cohort_analysis_vars if @queries.any?(&:cohort_analysis?)
    end

    private

    # Copied from Blazer::BaseController
    def process_vars(statement, var_params = nil)
      var_params ||= request.query_parameters
      (@bind_vars ||= []).concat(statement.variables).uniq!
      # update in-place so populated in view and consistent across queries on dashboard
      @bind_vars.each do |var|
        if !var_params[var]
          default = statement.data_source.variable_defaults[var]
          # only add if default exists
          var_params[var] = default if default
        end
      end
      runnable = @bind_vars.all? { |v| var_params[v] }
      statement.add_values(var_params) if runnable
      runnable
    end

    # Copied from Blazer::BaseController
    def add_cohort_analysis_vars
      @bind_vars << "cohort_period" unless @bind_vars.include?("cohort_period")
      @smart_vars["cohort_period"] = ["day", "week", "month"] if @smart_vars
      # TODO create var_params method
      request.query_parameters["cohort_period"] ||= "week"
    end

    # Copied from Blazer::BaseController
    def parse_smart_variables(var, data_source)
      smart_var_data_source =
        ([data_source] + Array(data_source.settings["inherit_smart_settings"]).map { |ds| Blazer.data_sources[ds] }).find { |ds| ds.smart_variables[var] }

      if smart_var_data_source
        query = smart_var_data_source.smart_variables[var]

        if query.is_a? Hash
          smart_var = query.map { |k,v| [v, k] }
        elsif query.is_a? Array
          smart_var = query.map { |v| [v, v] }
        elsif query
          result = smart_var_data_source.run_statement(query)
          smart_var = result.rows.map { |v| v.reverse }
          error = result.error if result.error
        end
      end

      [smart_var, error]
    end

    # Copied from Blazer::BaseController
    def variable_params(resource, var_params = nil)
      permitted_keys = resource.variables
      var_params ||= request.query_parameters
      var_params.slice(*permitted_keys)
    end
    helper_method :variable_params

    # Copied from Blazer::BaseController
    def nested_variable_params(resource)
      variable_params(resource, request.query_parameters["variables"] || {})
    end
    helper_method :nested_variable_params
  end
end
