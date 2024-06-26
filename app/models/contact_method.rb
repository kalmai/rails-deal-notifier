# frozen_string_literal: true

class ContactMethod < ApplicationRecord
  enum :contact_type, { email: 0, phone_number: 1 }
  encrypts :contact_detail, deterministic: true, downcase: true
  validates :contact_detail, :enabled, :contact_type, presence: true
  validate :valid_contact_detail?
  validates :contact_detail, uniqueness: { case_sensitive: false }

  belongs_to :user

  def valid_contact_detail?
    case contact_type
    when 'email'
      unless contact_detail.match?(URI::MailTo::EMAIL_REGEXP) && contact_detail.length.between?(6, 256)
        errors.add(:contact_detail, 'invalid email')
      end
    else errors.add(:contact_detail, 'unsupported contact type') # POST-MVP add phone_number
    end
  end
end
