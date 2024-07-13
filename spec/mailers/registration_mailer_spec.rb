# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationMailer do
  subject(:mail) { described_class.with(user:).welcome_email.deliver_now }

  let(:user) { create(:user, :with_contact_methods) }
  let(:email_address) { user.contact_methods.detail_for(type: :email) }

  before do
    create(:promotion, :with_league_team_and_users, user_count: 0)
    create(:promotion, :with_league_team_and_users, user_count: 0)
  end

  it 'renders the headers' do
    expect(mail.subject).to eq('Welcome to Sports DealNotifier')
    expect(mail.to).to eq([email_address])
    expect(mail.from).to eq(['tester.sport.deal.notifier@gmail.com'])
  end

  it 'renders the body' do
    expect(CGI.unescape_html(mail.body.encoded)).to include(
      "You have successfully signed up with: #{email_address}", *user.promotions.map(&:name)
    )
  end
end
