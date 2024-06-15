# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeSensitiveMailer do
  subject(:mail) { described_class.with(user:, promotion:).notify.deliver_now }

  let(:promotion) { create(:promotion, :with_league_team_and_users) }
  let(:user) { promotion.users.first }
  let(:email_address) { user.contact_methods.detail_for(type: :email) }

  it 'renders the headers' do
    expect(mail.subject).to eq('Sports DealNotifier: Action Suggested!')
    expect(mail.to).to eq([email_address])
    expect(mail.from).to eq(['tester.sport.deal.notifier@gmail.com'])
  end

  it 'renders the body' do
    expect(CGI.unescape_html(mail.body.encoded)).to include(
      'The following time sensitive promotion requires action in order to redeem it', promotion.name
    )
  end
end
