# frozen_string_literal: true

class UserPromotion < ApplicationRecord
  belongs_to :user
  belongs_to :promotion
end
