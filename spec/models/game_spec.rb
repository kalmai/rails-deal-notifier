# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game do
  describe 'validations' do
    it { is_expected.to validate_presence_of :utc_start_time }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:away_team).class_name('Team') }
    it { is_expected.to belong_to(:home_team).class_name('Team') }
    it { is_expected.to belong_to(:league) }
    it { is_expected.to have_many(:goals).order('utc_scored_at') }
  end

  describe '#played?' do
    subject(:game) { build(:game).played?(timezone:) }

    let(:timezone) { 'America/New_York' }

    it { is_expected.to be true }
  end
end
