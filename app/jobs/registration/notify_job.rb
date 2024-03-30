# frozen_string_literal: true

module Registration
  class NotifyJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      # Do something later
      puts 'himom'
    end
  end
end
