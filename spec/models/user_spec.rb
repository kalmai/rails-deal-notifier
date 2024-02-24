# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:zipcode) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:contact_methods) }
  end
end
