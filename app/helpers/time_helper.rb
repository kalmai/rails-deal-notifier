# frozen_string_literal: true

module TimeHelper
  OFFSETS = %w[-09:00 -10:00 -08:00 -07:00 -06:00 -05:00 -04:00 -03:00 -02:30].freeze

  class << self
    def offsets_for(utc_time:)
      OFFSETS.index_with { utc_time.getlocal(_1) }
    end

    def today?(timezone:, utc_time:, offsets: nil)
      (offsets || offsets_for(utc_time:))
      binding.pry
    end
  end
end
