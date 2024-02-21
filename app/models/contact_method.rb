# frozen_string_literal: true

class ContactMethod < ApplicationRecord
  enum :contact_type, { email: 0, phone_number: 1 }
  encrypts :contact_detail, deterministic: true, downcase: true
  validates :contact_detail, :enabled, :contact_type, presence: true
  validate :valid_contact_detail?
  validates_uniqueness_of :contact_detail

  belongs_to :user

  def valid_contact_detail?
    case contact_type
    when 'email'
      unless contact_detail.match?(URI::MailTo::EMAIL_REGEXP) && contact_detail.length.between?(6, 256)
        errors.add(:contact_detail, 'invalid email')
      end
    when 'phone_number' then false # POST-MVP
    end
  end
end
