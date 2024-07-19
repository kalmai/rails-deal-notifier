# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations' do
  let(:new_york_ip) { '63.116.61.253' }
  let(:postal_code) { '10001' }
  let(:new_york_info) do
    {
      'coordinates' => [40.7143528, -74.0059731],
      'address' => 'New York, NY, USA',
      'state' => 'New York',
      'state_code' => 'NY',
      'country' => 'United States',
      'country_code' => 'US'
    }
  end

  before do
    Geocoder.configure(lookup: :test, ip_lookup: :test)
    Geocoder::Lookup::Test.add_stub(new_york_ip, [new_york_info])
    Geocoder::Lookup::Test.add_stub(
      postal_code, [
        { 'properties' => new_york_info.merge({ 'timezone' => { 'name' => 'America/New_York' } }) }
      ]
    )
  end

  describe '#index' do
    it 'renders page and implies the postal code of the user' do
      get '/', headers: { 'REMOTE_ADDR' => new_york_ip }

      expect(response.body).to include 'Email'
      expect(session[:geocode_data]).to eq new_york_info
    end
  end

  describe '#create' do
    let!(:promotion) { create(:promotion, :with_users, team:) }
    let(:team) { create(:team, region: 'ny') }
    let(:params) do
      {
        user: {
          postal: postal_code,
          contact_methods_attributes: {
            '0' => {
              contact_detail: 'email@domain.com'
            }
          }
        }
      }
    end

    it 'saves a new user' do
      assert_enqueued_with(job: Registration::NotifyJob) { post '/registration', params: }
      expect(response).to redirect_to '/'
      expect(flash[:notice][:message]).to eq 'You will be receiving a welcome email shortly.'
      expect(User.last.postal).to eq postal_code
      expect(User.last.promotions.first).to eq promotion
    end

    context 'when the contact detail already exists' do
      let!(:existing_contact_method) { create(:contact_method) }

      it 'says it succeeded when the record is actually not created' do
        assert_no_enqueued_jobs do
          post '/registration', params: { postal: postal_code, contact_detail: existing_contact_method.contact_detail }
        end
        expect(response).to redirect_to '/'
        expect(flash[:notice][:message]).to eq 'Something went wrong, please try again.'
        expect(ContactMethod.where(contact_detail: existing_contact_method.contact_detail).count).to eq 1
      end
    end
  end
end
