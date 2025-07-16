# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  describe 'validations' do
    it { is_expected.to validate_presence_of :slug }
    it { is_expected.to validate_presence_of :event_type }
    it { is_expected.to validate_presence_of :period }
    it { is_expected.to validate_presence_of :utc_occurred_at }
  end

  describe 'associations' do
    it { is_expected.to belong_to :team }
    it { is_expected.to belong_to :game }
  end
end
