# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game do
  let(:freeze_time) { Time.use_zone(timezone) { Time.current.change(hour: 18) }.utc }
  let(:timezone) { 'America/New_York' }

  before do
    Timecop.freeze(freeze_time)
  end

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
    subject(:game) { build(:game, utc_start_time:).played?(timezone:) }

    let(:utc_start_time) { freeze_time.yesterday }

    it { is_expected.to be true }

    context 'when the utc_start_time is in the future' do
      let(:utc_start_time) { freeze_time + 1.hour }

      it { is_expected.to be false }
    end

    context 'when the utc_start_time is multiple days ago' do
      let(:utc_start_time) { freeze_time - 72.hours }

      it { is_expected.to be false }
    end
  end
end
