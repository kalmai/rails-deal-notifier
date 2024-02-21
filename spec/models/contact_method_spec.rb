# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactMethod, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:contact_detail) }
    it { should validate_presence_of(:contact_type) }
    it { should validate_presence_of(:enabled) }
  end
end
