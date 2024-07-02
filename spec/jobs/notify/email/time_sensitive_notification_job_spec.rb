# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notify::Email::TimeSensitiveNotificationJob do
  let!(:promotion) { create(:promotion, :cbj_moo_moo_carwash) }
  let(:user) { create(:user, :with_contact_methods, region: 'ohio', timezone:) }
  let(:client) { Nhl::Client.new(args: { timezone:, short_name: promotion.team.short_name }) }
  let(:timezone) { 'America/New_York' }
  let(:freeze_time) { Time.at(0) }
  let(:utc_start_time) { freeze_time.in(1.hour) }
  let(:schedule_cache) do
    [
      BaseClient::TodayGame.new(away?: true, team_abbrev: 'cbj', utc_start_time:),
      BaseClient::TodayGame.new(away?: false, team_abbrev: 'arz', utc_start_time:)
    ]
  end

  before do
    allow(Nhl::Client).to receive(:new).and_return(client)
    allow(client).to receive(:schedule_cache).and_return(schedule_cache)
  end

  describe '#perform' do
    it 'enqueues the email' do
      Timecop.freeze(freeze_time) do
        expect { described_class.new.perform }.to have_enqueued_mail(TimeSensitiveMailer, :notify)
          .with(params: { user:, promotion: }, args: [])
          .on_queue(:default).at(1.hour.from_now).exactly(:once)
      end
    end
  end
end
