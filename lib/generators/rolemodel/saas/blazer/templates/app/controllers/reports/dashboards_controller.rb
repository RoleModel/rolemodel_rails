# frozen_string_literal: true

module Reports
  class DashboardsController < ApplicationController
    before_action :set_dashboard, only: [:show, :edit, :update]

    helper Blazer::BaseHelper

    def index
      # authorize Blazer::Dashboard.new
      # @dashboards = policy_scope(Blazer::Dashboard).distinct.order(:name)
      @dashboards = Blazer::Dashboard.distinct.order(:name)
    end

    def show # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      # authorize @dashboard
      # params['current_user_id'] = current_user.id # automatic variable for current_user specific queries

      # The rest is copied from Blazer::DashboardsController
      @queries = @dashboard.dashboard_queries.order(:position).preload(:query).map(&:query)
      @statements = []
      @queries.each do |query|
        statement = query.statement.dup
        process_vars(statement, query.data_source)
        @statements << statement
      end
      @bind_vars ||= []
      # added v
      @bind_vars = @bind_vars.without('current_user_id')

      @smart_vars = {}
      @sql_errors = []
      @data_sources = @queries.map { |q| Blazer.data_sources[q.data_source] }.uniq
      @bind_vars.each do |var|
        @data_sources.each do |data_source|
          smart_var, error = parse_smart_variables(var, data_source)
          (@smart_vars[var] ||= []).concat(smart_var).uniq! if smart_var
          @sql_errors << error if error
        end
      end

      add_cohort_analysis_vars if @queries.any?(&:cohort_analysis?)
    end

    def edit
      # authorize @dashboard
    end

    def update
      # authorize @dashboard

      if @dashboard.update(permitted_attributes(@dashboard))
        redirect_to reports_dashboards_url, notice: notice_msg('Dashboard successfully updated')
      else
        render :edit
      end
    end

    private

    # Copied from Blazer::DashboardsController
    def set_dashboard
      @dashboard = Blazer::Dashboard.find params[:id]
    end

    # Copied from Blazer::BaseController
    def process_vars(statement, data_source) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      (@bind_vars ||= []).concat(Blazer.extract_vars(statement)).uniq!
      @bind_vars.each do |var|
        params[var] ||= Blazer.data_sources[data_source].variable_defaults[var]
      end
      @success = @bind_vars.all? { |v| params[v] }

      if @success # rubocop:disable Style/GuardClause
        @bind_vars.each do |var|
          value = params[var].presence
          if value
            if ['start_time', 'end_time'].include?(var)
              value = value.to_s.gsub(' ', '+') # fix for Quip bug
            end

            if var.end_with?('_at')
              begin
                value = Blazer.time_zone.parse(value)
              rescue StandardError # rubocop:disable Metrics/BlockNesting
                # do nothing
              end
            end

            case value
            when /\A\d+\z/
              value = value.to_i
            when /\A\d+\.\d+\z/
              value = value.to_f
            end
          end
          value = Blazer.transform_variable.call(var, value) if Blazer.transform_variable
          statement.gsub!("{#{var}}", ActiveRecord::Base.connection.quote(value))
        end
      end
    end

    # Copied from Blazer::BaseController
    def parse_smart_variables(var, data_source) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      smart_var_data_source =
        ([data_source] + Array(data_source.settings['inherit_smart_settings']).map do |ds|
                           Blazer.data_sources[ds]
                         end).find { |ds| ds.smart_variables[var] }

      if smart_var_data_source
        query = smart_var_data_source.smart_variables[var]

        if query.is_a? Hash
          smart_var = query.map { |k, v| [v, k] }
        elsif query.is_a? Array
          smart_var = query.map { |v| [v, v] }
        elsif query
          result = smart_var_data_source.run_statement(query)
          smart_var = result.rows.map(&:reverse)
          error = result.error if result.error
        end
      end

      [smart_var, error]
    end

    # Copied from Blazer::BaseController
    def add_cohort_analysis_vars
      @bind_vars << 'cohort_period' unless @bind_vars.include?('cohort_period')
      @smart_vars['cohort_period'] = ['day', 'week', 'month']
      params[:cohort_period] ||= 'week'
    end
  end
end
