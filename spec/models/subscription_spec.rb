# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription do
  describe 'associations' do
    it { is_expected.to belong_to(:user).class_name('User') }
    it { is_expected.to belong_to(:promotion).class_name('Promotion') }
  end
end
