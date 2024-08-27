# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationMailer do
  subject(:mail) { described_class.with(user:).welcome_email.deliver_now }

  let!(:promotion) { create(:promotion, :with_league_team_and_users, league_abbr: 'nhl', api_methods: ['won?']) }
  let(:user) { promotion.users.first }
  let(:email_address) { user.contact_methods.detail_for(type: :email) }
  let(:client) { Nhl::Client.new(args: { timezone: user.timezone, short_name: promotion.team.short_name }) }
  let(:freeze_time) { Time.at(0) }
  let(:results_cache) { {} }

  before do
    Timecop.freeze(freeze_time)
    allow(Nhl::Client).to receive(:new).and_return(client)
    allow(client).to receive_messages(results_cache:, schedule_cache: {})
  end

  after do
    Timecop.return
  end

  it 'renders the body and headers' do
    expect(mail.subject).to eq('Welcome to Sports DealNotifier')
    expect(mail.to).to eq([email_address])
    expect(mail.from).to eq(['tester.sport.deal.notifier@gmail.com'])
    expect(CGI.unescape_html(mail.body.encoded)).to include(
      "You have successfully signed up with: #{email_address}", *user.promotions.map(&:name)
    )
  end

  context 'when there are actionable results' do
    let(:results_cache) do
      {
        promotion.team.short_name => BaseClient::GameResult.new(
          won?: true, goals: [BaseClient::Goal.new(period: 1, time: '00:15')],
          away?: false, opponent: 'NME', utc_start_time: freeze_time - 23.hours
        )
      }
    end

    it 'renders the promotions additionally' do
      expect(CGI.unescape_html(mail.body.encoded)).to include(
        "You have successfully signed up with: #{email_address}", *user.promotions.map(&:name)
      )
      expect(CGI.unescape_html(mail.body.encoded)).to include('Actionable Promotions', promotion.promo_code)
    end
  end
end
