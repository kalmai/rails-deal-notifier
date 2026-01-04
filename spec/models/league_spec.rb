# frozen_string_literal: true

require 'rails_helper'

RSpec.describe League do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:short_name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:teams).dependent(:destroy) }
  end
end
