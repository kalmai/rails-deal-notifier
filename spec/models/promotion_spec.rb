# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Promotion do
  it { is_expected.to belong_to(:team).class_name('Team') }
  it { is_expected.to validate_presence_of(:company) }

  it { is_expected.to have_many(:users).through(:subscriptions) }
end
