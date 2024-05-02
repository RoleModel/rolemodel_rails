# frozen_string_literal: true

Rails.application.configure do
  config.good_job = {
    smaller_number_is_higher_priority: true, # new default in V4 and for all of ActiveJob
    queues: ENV.fetch('GOOD_JOB_QUEUES', 'pdf:1;-pdf'),
    execution_mode: Rails.env.test? ? :inline : :external
    # enable_cron: true,
    # cron: {
    #   <cron_label>: {
    #     cron: 'every friday at 12pm EST',
    #     class: '<class_name>'
    #   }
    # }
  }
end
