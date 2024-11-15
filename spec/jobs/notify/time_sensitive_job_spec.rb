# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notify::TimeSensitiveJob do
  let!(:promotion) { create(:promotion, :with_users, team:, timing_methods:, timing_parameters:) }
  let!(:team) { create(:team, region: 'ny') }
  let(:timing_methods) { [] }
  let(:timing_parameters) { { minutes_before: 60 } }
  let(:user) { promotion.users.first }
  let(:timezone) { 'America/New_York' }
  let(:freeze_time) { Time.parse('2024-10-02T10:00:00.0000000Z') }
  let(:utc_start_time) { Time.parse('2024-10-02T23:30:00.0000000Z') }

  before do
    Timecop.freeze(freeze_time)
    create(:game, home_team: team, has_consumed_results: false, utc_start_time:)
  end

  after { Timecop.return }

  describe '#perform' do
    it 'enqueues the email' do
      expect { described_class.new.perform }.to have_enqueued_mail(TimeSensitiveMailer, :notify)
        .with(params: { user:, promotion: }, args: [])
        .on_queue(:default).at(utc_start_time - 1.hour).exactly(:once)
    end

    context 'when there are location requirements for the promotion' do
      let(:timing_methods) { ['home?'] }

      it 'enqueues the email' do
        expect { described_class.new.perform }.to have_enqueued_mail(TimeSensitiveMailer, :notify)
          .with(params: { user:, promotion: }, args: [])
          .on_queue(:default).at(utc_start_time - 1.hour).exactly(:once)
      end

      context 'when the it is an away game expectation' do
        let(:team_abbr) { 'arz' }

        it 'enqueues the email' do
          expect { described_class.new.perform }.to have_enqueued_mail(TimeSensitiveMailer, :notify)
            .with(params: { user:, promotion: }, args: [])
            .on_queue(:default).at(utc_start_time - 1.hour).exactly(:once)
        end
      end
    end
  end
end
