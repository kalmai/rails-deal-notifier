# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:postal) }
    it { is_expected.to validate_presence_of(:region) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_presence_of(:timezone) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:contact_methods) }
  end
end
