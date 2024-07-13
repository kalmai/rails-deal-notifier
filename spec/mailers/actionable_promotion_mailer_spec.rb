# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionablePromotionMailer do
  subject(:mail) { described_class.with(user:, promotions:).notify.deliver_now }

  let(:promotions) { [create(:promotion, :with_league_team_and_users)] }
  let(:user) { promotions.first.users.first }
  let(:email_address) { user.contact_methods.detail_for(type: :email) }

  it 'renders the headers' do
    expect(mail.subject).to eq('Sports DealNotifier: Actionable Promotions')
    expect(mail.to).to eq([email_address])
    expect(mail.from).to eq(['tester.sport.deal.notifier@gmail.com'])
  end

  it 'renders the body' do
    expect(CGI.unescape_html(mail.body.encoded)).to include(
      'The following promotions are active!', *user.promotions.map(&:name)
    )
  end
end
