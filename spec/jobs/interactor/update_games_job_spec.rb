# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interactor::UpdateGamesJob do
  subject(:job) { described_class.new }

  let(:end_month) { '11' }
  let(:freeze_time) { Time.parse('2024-10-02T10:00:00.0000000Z') }

  before { Timecop.freeze(freeze_time) }

  after { Timecop.return }

  describe '#perform' do
    let!(:game) { create(:game) }

    before do
      stub_request(:get, %r{#{Interactor::Mls::BASE_URL}/matches/*})
        .to_return(status: 200, body: file_fixture('mls/raw_update_data.json').read)
      stub_request(:get, %r{#{Interactor::Mls::GOAL_DATA_URL}/*})
        .to_return(status: 200, body: file_fixture('mls/goal_update_data.json').read)
    end

    it 'performs the job successfully' do
      expect do
        job.perform_now
        game.reload
      end
        .to change(game, :has_consumed_results).from(false).to(true)
        .and change { game.goals.count }.from(0).to(3)
        .and change { game.home_goals.count }.from(0).to(1)
        .and change { game.away_goals.count }.from(0).to(2)
    end

    context 'when the league is out of season' do
      let(:end_month) { '9' }
      let(:interactor) { Interactor::Mls }

      before do
        allow(Interactor::Mls).to receive(:new).and_return(interactor)
        allow(interactor).to receive(:update_games)
      end

      it 'does not trigger the interactor' do
        expect(interactor).not_to have_received(:update_games)
      end
    end
  end
end
