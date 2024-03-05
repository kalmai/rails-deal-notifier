# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:region) }
    it { is_expected.to validate_presence_of(:country) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:league).class_name('League') }
  end
end
