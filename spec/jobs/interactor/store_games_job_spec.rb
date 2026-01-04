# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interactor::StoreGamesJob do
  subject(:job) { described_class.new }

  let(:freeze_time) { Time.parse('2024-10-02T10:00:00.0000000Z') }

  before { travel_to(freeze_time) }
  after { travel_back }

  describe '#perform' do
    before do
      league = create(:league, short_name: 'mls')
      stub_request(:get, %r{#{Interactor::Mls::BASE_URL}/*})
        .to_return(status: 200, body: file_fixture('mls/raw_data.json').read)
      create(:team, short_name: 'atl', league:)
      create(:team, short_name: 'la', league:)
      create(:team, short_name: 'nsh', league:)
      create(:team, short_name: 'por', league:)
    end

    it 'performs the job successfully' do
      expect { job.perform_now }.to change(Game, :count).by(2)
    end

    context 'when the league is out of season' do
      let(:interactor) { Interactor::Mls }

      before do
        allow(Interactor::Mls).to receive(:new).and_return(interactor)
        allow(interactor).to receive(:store_games)
      end

      it 'does not trigger the interactor' do
        expect(interactor).not_to have_received(:store_games)
      end
    end
  end
end
