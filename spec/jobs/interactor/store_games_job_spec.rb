# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Interactor::StoreGamesJob do
  subject(:job) { described_class.new }

  let(:end_month) { '11' }
  let(:freeze_time) { Time.parse('2024-10-02T10:00:00.0000000Z') }

  before do
    league = create(:league, end_month:, short_name: 'mls')
    allow(League).to receive(:all).and_return([league])
    Timecop.freeze(freeze_time)
  end

  after { Timecop.return }

  describe '#perform' do
    before do
      stub_request(:get, %r{#{Interactor::Mls::BASE_URL}/matches/*})
        .to_return(status: 200, body: file_fixture('mls/raw_data.json').read)
      create(:team, short_name: 'clb')
      create(:team, short_name: 'ne')
      create(:team, short_name: 'van')
      create(:team, short_name: 'lafc')
    end

    it 'performs the job successfully' do
      expect { job.perform_now }.to change(Game, :count).by(2)
    end

    context 'when the league is out of season' do
      let(:end_month) { '9' }
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
