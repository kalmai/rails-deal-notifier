# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CleanUpOldGames do
  subject(:job) { described_class.new }

  let(:promotion) do
    create(:promotion, :with_users, api_methods: ['scored_in?'], api_parameters: { period: 1 })
  end
  let(:freeze_time) { Time.current }
  let(:utc_start_time) { Time.at(0) }
  let(:finalized) { true }

  before do
    create(:game, home_team: promotion.team, finalized:, utc_start_time:)
    Timecop.freeze(freeze_time)
  end

  after { Timecop.return }

  describe '#perform' do
    it 'deletes a game that is no longer redeemable' do
      expect { described_class.new.perform_now }
        .to change(Game, :count).from(1).to(0)
    end

    context 'when the game is today' do
      let(:utc_start_time) { Time.current }

      it 'does NOT delete the game' do
        expect { described_class.new.perform_now }
          .not_to change(Game, :count)
      end
    end

    context 'when the game is in the future' do
      let(:utc_start_time) { 2.weeks.from_now }

      it 'does NOT delete the game' do
        expect { described_class.new.perform_now }
          .not_to change(Game, :count)
      end
    end

    context 'when the game is not finalized' do
      let(:finalized) { false }

      it 'does NOT delete the game' do
        expect { described_class.new.perform_now }
          .not_to change(Game, :count)
      end
    end
  end
end
