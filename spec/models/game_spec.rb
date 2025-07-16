# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game do
  let(:game) { create(:game) }

  before do
    create(:event, team: game.home_team, game:)
    create(:event, team: game.away_team, game:)
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :utc_start_time }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:away_team).class_name('Team') }
    it { is_expected.to belong_to(:home_team).class_name('Team') }
    it { is_expected.to belong_to(:league) }
    it { is_expected.to have_many(:events).order('utc_occurred_at') }
  end

  describe '#home_goals' do
    subject(:total) { game.home_goals.count }

    it { is_expected.to eq 1 }
  end

  describe '#away_goals' do
    subject(:total) { game.away_goals.count }

    it { is_expected.to eq 1 }
  end

  describe '.most_recent_game' do
    subject(:recent_game) { described_class.most_recent_game(team_id: game.home_team.id) }

    let(:freeze_time) { Time.zone.now }

    before { Timecop.freeze(freeze_time) }
    after { Timecop.return }

    it { is_expected.to be_nil }

    context 'when there is a game in the future' do
      before { create(:game, slug: 'momvsdad-10-10-1000') }

      it { is_expected.to be_nil }
    end

    context 'when the game has read results' do
      let(:game) { create(:game, finalized: true) }

      it { is_expected.to eq game }

      context 'when there are multiple games that completed in history' do
        let(:game) { create(:game, finalized: true, utc_start_time: freeze_time) }

        before do
          3.times do |i|
            create(
              :game,
              home_team: game.home_team,
              slug: "momvsdad-10-1#{i + 1}-1000",
              utc_start_time: (Time.zone.now - (i + 1).days),
              finalized: true
            )
          end
        end

        it { is_expected.to eq game }
      end
    end
  end
end
