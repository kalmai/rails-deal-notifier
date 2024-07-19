# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationMailer do
  subject(:mail) { described_class.with(user:).welcome_email.deliver_now }

  let!(:promotion) { create(:promotion, :with_users, team:, api_methods: ['won?']) }
  let!(:team) { create(:team, region: 'ny') }
  let!(:game) { create(:game, home_team: promotion.team, has_consumed_results: true) }
  let(:user) { promotion.users.first }
  let(:email_address) { user.contact_methods.detail_for(type: :email) }

  it 'renders the body and headers' do
    expect(mail.subject).to eq('Welcome to Sports DealNotifier')
    expect(mail.to).to eq([email_address])
    expect(mail.from).to eq(['tester.sport.deal.notifier@gmail.com'])
    expect(CGI.unescape_html(mail.body.encoded)).to include(
      "You have successfully signed up with: #{email_address}", *user.promotions.map(&:name)
    )
  end

  context 'when there are actionable results' do
    before { create(:goal, game:, team: game.home_team) }

    it 'renders the promotions additionally' do
      expect(CGI.unescape_html(mail.body.encoded)).to include(
        "You have successfully signed up with: #{email_address}", *user.promotions.map(&:name)
      )
      expect(CGI.unescape_html(mail.body.encoded)).to include('Actionable Promotions', promotion.promo_code)
    end
  end
end
