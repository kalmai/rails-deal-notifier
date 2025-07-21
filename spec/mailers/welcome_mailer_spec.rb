# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WelcomeMailer do
  subject(:mail) { described_class.with(user:).send_email.deliver_now }

  let!(:promotion) { create(:promotion, :with_users, team:, api_methods: ['won?']) }
  let!(:team) { create(:team, region: 'ny') }
  let!(:game) { create(:game, home_team: promotion.team, finalized: true, utc_start_time: freeze_time - 1.hour) }
  let(:user) { promotion.users.first }
  let(:email_address) { user.contact_methods.detail_for(type: :email) }
  let(:freeze_time) { Time.parse('2024-10-02T10:00:00.0000000Z') }

  before do
    travel_to(freeze_time)
    create(:event, game:, team: game.home_team, utc_occurred_at: Time.current)
  end

  after { travel_back }

  it 'renders the body and headers' do
    expect(mail.subject).to eq('Welcome to Sports DealNotifier')
    expect(mail.to).to eq([email_address])
    expect(mail.from).to eq(['tester.sport.deal.notifier@gmail.com'])
    expect(CGI.unescape_html(mail.body.encoded)).to include(
      "You have successfully signed up with: #{email_address}", *user.promotions.map(&:name)
    )
  end

  context 'when there are actionable results' do
    before { create(:event, game:, team: game.home_team) }

    it 'renders the promotions additionally' do
      expect(CGI.unescape_html(mail.body.encoded)).to include(
        "You have successfully signed up with: #{email_address}", *user.promotions.map(&:name)
      )
      expect(CGI.unescape_html(mail.body.encoded)).to include('Actionable Promotions', promotion.promo_code)
    end
  end
end
