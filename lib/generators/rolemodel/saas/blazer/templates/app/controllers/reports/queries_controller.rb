# frozen_string_literal: true

module Reports
  # Since this doesn't rely on our layout, we can get away with inheriting straight from blazer,
  # and mixing in our authorization
  class QueriesController < Blazer::QueriesController
    # TODO: must be reenabled because Blazer disables all inherited before/around/after callbacks
    # after_action :verify_authorized

    def run
      @query = Blazer::Query.find_by(id: params[:query_id])
      # authorize @query
      params[:statement] = @query.statement.dup
      super
    end

    # def cancel
    #   authorize Blazer::Query.new
    #   super
    # end
  end
end
