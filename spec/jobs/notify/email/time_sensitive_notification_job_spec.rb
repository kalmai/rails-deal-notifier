# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notify::Email::TimeSensitiveNotificationJob do
  let!(:promotion) { create(:promotion, :with_league_team_and_users, team_abbr:, league_abbr: 'nhl', timing_methods:) }
  let(:timing_methods) { ['playing_today_at'] }
  let(:user) { promotion.users.first }
  let(:client) { Nhl::Client.new(args: { timezone:, short_name: team_abbr }) }
  let(:team_abbr) { 'cbj' }
  let(:timezone) { 'America/New_York' }
  let(:freeze_time) { Time.at(0) }
  let(:utc_start_time) { freeze_time.in(1.hour) }
  let(:schedule_cache) do
    [
      BaseClient::TodayGame.new(away?: false, team_abbrev: 'cbj', utc_start_time:),
      BaseClient::TodayGame.new(away?: true, team_abbrev: 'arz', utc_start_time:)
    ]
  end

  before do
    Timecop.freeze(freeze_time)
    allow(Nhl::Client).to receive(:new).and_return(client)
    allow(client).to receive(:schedule_cache).and_return(schedule_cache)
  end

  after do
    Timecop.return
  end

  describe '#perform' do
    it 'enqueues the email' do
      expect { described_class.new.perform }.to have_enqueued_mail(TimeSensitiveMailer, :notify)
        .with(params: { user:, promotion: }, args: [])
        .on_queue(:default).at(1.hour.from_now).exactly(:once)
    end

    context 'when there are location requirements for the promotion' do
      let(:timing_methods) { %w[playing_today_at future_home_game?] }

      it 'enqueues the email' do
        expect { described_class.new.perform }.to have_enqueued_mail(TimeSensitiveMailer, :notify)
          .with(params: { user:, promotion: }, args: [])
          .on_queue(:default).at(1.hour.from_now).exactly(:once)
      end

      context 'when the it is an away game expectation' do
        let(:timing_methods) { %w[playing_today_at future_away_game?] }
        let(:team_abbr) { 'arz' }

        it 'enqueues the email' do
          expect { described_class.new.perform }.to have_enqueued_mail(TimeSensitiveMailer, :notify)
            .with(params: { user:, promotion: }, args: [])
            .on_queue(:default).at(1.hour.from_now).exactly(:once)
        end
      end
    end
  end
end
