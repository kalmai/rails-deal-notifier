# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DealNotifier
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # https://edgeguides.rubyonrails.org/active_record_encryption.html#unique-validations
    config.active_record.encryption.extend_queries = true

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # https://github.com/bensheldon/good_job?tab=readme-ov-file#configuration-options
    config.active_job.queue_adapter = :good_job
    config.good_job = {
      preserve_job_records: true, retry_on_unhandled_error: false, execution_mode: :async, queues: '*',
      max_threads: 5, poll_interval: 30, shutdown_timeout: 25, dashboard_default_locale: :en,
      on_thread_error: -> (exception) { Rails.error.report(exception) },
      enable_cron: false,
      cron: {
        example: {
          cron: '0 * * * *',
          class: 'ExampleJob'
        },
      }
    }
  end
end
