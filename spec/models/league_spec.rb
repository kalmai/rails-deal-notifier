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

  describe '#season_range' do
    subject(:range) { build(:league, end_month:).season_range }

    let(:end_month) { '11' }

    it 'yields a valid range' do
      expect(range.min).to eq(Time.new(Time.now.year, 1))
      expect(range.max).to eq(Time.new(Time.now.year, 11).end_of_month)
    end

    context 'when the end month is next year annotated by a `+` in the string' do
      let(:end_month) { '11+' }

      it 'properly sets the max range to next year' do
        expect(range.min).to eq(Time.new(Time.now.year, 1))
        expect(range.max).to eq(Time.new(Time.now.next_year.year, 11).end_of_month)
      end
    end
  end
end
