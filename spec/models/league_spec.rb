# frozen_string_literal: true

require 'rails_helper'

RSpec.describe League do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:short_name) }
    it { is_expected.to validate_presence_of(:start_month) }
    it { is_expected.to validate_presence_of(:end_month) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:teams).dependent(:destroy) }
  end

  describe '#in_season?' do
    subject(:range) { build(:league, start_month:, end_month:, short_name: 'mls').in_season? }

    let(:freeze_time) { Time.parse('2024-10-02T10:00:00.0000000Z') }
    let(:start_month) { 1 }
    let(:end_month) { '11' }

    before { travel_to(freeze_time) }
    after { travel_back }

    it { is_expected.to be true }

    context 'when the end month falls outside of the season' do
      let(:end_month) { '9' }

      it { is_expected.to be false }
    end

    context 'when the end month is next year annotated by a `+` in the string' do
      let(:start_month) { 9 }
      let(:end_month) { '2+' }

      it { is_expected.to be true }

      context 'when the current date is not within the months of the season' do
        let(:freeze_time) { Time.parse('2024-07-02T10:00:00.0000000Z') }

        it { is_expected.to be false }
      end
    end
  end
end
