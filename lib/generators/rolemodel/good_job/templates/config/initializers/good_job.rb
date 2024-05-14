# frozen_string_literal: true

# NOTE: queues - Configuring queues is an important part of prioritization. GoodJob uses
# multiple ways to override. 12factor override used here with fallback to a common queue
# override example/pattern for Heroku apps using pdf generation limiting to serial
# processing to constrain resource [memory] limitations

# NOTE: execution_mode - development defaults to async but has known to hang in certain
# [unidentified] situations so use external which gives devs more control on running too

Rails.application.configure do
  config.good_job = {
    smaller_number_is_higher_priority: true, # new default in V4 and for all of ActiveJob
    queues: ENV.fetch('GOOD_JOB_QUEUES', 'pdf:1;-pdf'), # see note above
    execution_mode: Rails.env.test? ? :inline : :external # see note above
    # enable_cron: true,
    # cron: {
    #   <cron_label>: {
    #     cron: 'every friday at 12pm EST',
    #     class: '<class_name>'
    #   }
    # }
  }
end
